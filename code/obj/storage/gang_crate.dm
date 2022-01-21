var/booze_items = list(
	/obj/item/reagent_containers/food/drinks/bottle/beer,
	/obj/item/reagent_containers/food/drinks/bottle/wine,
	/obj/item/reagent_containers/food/drinks/bottle/mead,
	/obj/item/reagent_containers/food/drinks/bottle/cider,
	/obj/item/reagent_containers/food/drinks/bottle/rum,
	/obj/item/reagent_containers/food/drinks/bottle/vodka,
	/obj/item/reagent_containers/food/drinks/bottle/tequila,
	/obj/item/reagent_containers/food/drinks/bottle/bojackson,
	/obj/item/reagent_containers/food/drinks/curacao
)
var/drug_items = list(
	/obj/item/storage/pill_bottle/methamphetamine,
	/obj/item/storage/pill_bottle/crank,
	/obj/item/storage/pill_bottle/bathsalts,
	/obj/item/storage/pill_bottle/catdrugs,
	/obj/item/storage/pill_bottle/cyberpunk
)

var/ammo_9mm = list(
/obj/item/ammo/bullets/nine_mm_NATO/mag_ten,
/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen)

//GANG CRATES!
//Generates a layout of fancy loot with predetermined value
/obj/storage/gang_crate
	name = "Gang Crate"
	desc = "A small, cuboid object with a hinged top and empty interior."
	is_short = 0
	icon_state = "attachecase"
	icon_closed = "attachecase"
	icon_opened = "attachecase_open"
	soundproofing = 3
	throwforce = 50 //ouch
	can_flip_bust = 1
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT  | NO_MOUSEDROP_QOL
	var/list/lootSpawns
	var/max_loot_x = 4 //how many loot items can fit, horizontal
	var/loot_x_pixels = 8 //pixels per loot_x
	var/loot_x_offset = -16 //offset for spawns_x
	var/max_loot_y = 3 //samesies, vertical
	var/loot_y_pixels = 8 //pixels per loot_y
	var/loot_y_offset = -16 //offset for spawns_y


	only_gimmicks
		New()
			generate_gang_crate(list(1,1,1,1,1,1,1,1,1,1,1,1))
			..()
	some_weak
		New()
			generate_gang_crate(list(2,2,2))
			..()
	only_weak
		New()
			generate_gang_crate(list(2,2,2,2,2,2,2,2,2,2,2,2,2))
			..()
	some_middle
		New()
			generate_gang_crate(list(3,3,2,2,2))
			..()
	only_middle
		New()
			generate_gang_crate(list(2,2,2,2,2,2,2,2,2,2,2,2))
			..()
	some_strong
		New()
			generate_gang_crate(list(3,3,3,2,2,2))
			..()
	only_strong
		New()
			generate_gang_crate(list(3,3,3,3,3,3,3,3,3,3,3,3))
			..()



	Cross(atom/movable/mover)
		if(istype(mover, /obj/projectile))
			return 1
		return ..()

	CheckExit(atom/movable/O as mob|obj, target as turf)
		if(istype(O, /obj/projectile))
			return 1
		return ..()

	proc/generate_gang_crate(var/list/totalValue)
		var/lootSpawns = generate_loot_layout() //RNG all item sizes, distribute value randomly among items, spawn
		generate_loot(lootSpawns, totalValue) //RNG all item sizes, distribute value randomly among items, spawn


	proc/generate_loot_layout()
		var/lootGrid[max_loot_y][max_loot_x] //boolean representation of available grid
		var/cursor_x = 1
		var/cursor_y = 1
		var/lootSize_x = rand(1,2)
		var/lootSize_y = 1
		var/largest_x  = 0
		var/largest_y  = 0
		var/done = false
		lootSpawns = list()

		while (!done)
			largest_x = 0
			largest_y = 0
			//scan to find how wide we can make this next item
			while (cursor_x+largest_x <= max_loot_x && !lootGrid[cursor_y][cursor_x+largest_x])
				largest_x++
			largest_y = min(2,max_loot_y-cursor_y)

			lootSize_x = 1
			while (lootSize_x < largest_x && prob(60-(10*lootSize_x))) //weird probability calc - but we prefer smaller drops
				lootSize_x++

			lootSize_y = 1
			while (lootSize_y < largest_y && prob(40))
				lootSize_y++

			for (var/x=1 to lootSize_x) //mark lootGrid as used
				for (var/y=1 to lootSize_y)
					lootGrid[cursor_y-1+y][cursor_x+x-1] = 1

			var/obj/gangloot_spawner/loot = select_loot(src,lootSize_x,lootSize_y)
			loot.size_x = lootSize_x
			loot.size_y = lootSize_y
			loot.set_layer = 3+(max_loot_y-cursor_y)
			loot.offset_x = loot_x_offset + loot_x_pixels*(cursor_x-1) + loot_x_pixels*(lootSize_x/2)
			loot.offset_y = loot_y_offset + loot_y_pixels*(cursor_y-1) + loot_y_pixels*(lootSize_y/2)
			lootSpawns += loot


			while (!done && lootGrid[cursor_y][cursor_x] == 1)
				cursor_x++
				boutput(world,"checking [cursor_x],[cursor_y]")
				if (cursor_x > max_loot_x)
					cursor_x = 1
					cursor_y++
					if (cursor_y > max_loot_y)
						done = true
		return lootSpawns

	proc/generate_loot(var/list/lootSpawns, var/list/totalValue)
		var/lootItems = lootSpawns.len
		var/lootPot = lootSpawns.Copy(1,0) // we want to generate loot randomly but still initialise them from the top down
		var/lootValue
		var/obj/gangloot_spawner/lootObject
		for (var/x=1 to lootItems)
			if (totalValue.len > 0)
				lootValue = pick(totalValue)
				totalValue -= lootValue
			else
				lootValue = 1

			lootObject = pick(lootPot)
			lootObject.value = lootValue
			lootPot -= lootObject
			var/refund = lootObject.create_loot(src)
			if (refund)
				totalValue += refund


			boutput(world,"LootValue of [lootValue] applied to [lootObject]")



	proc/select_loot(C,size_x,size_y)
		if (size_y == 1)
			switch(size_x)
				if(1)
					return new /obj/gangloot_spawner/small(C)
				if(2)
					return new /obj/gangloot_spawner/medium(C)
				if(3)
					return new /obj/gangloot_spawner/long(C)
				if(4)
					return new /obj/gangloot_spawner/xlong(C)
		else if (size_y == 2)
			switch(size_x)
				if(1)
					return new /obj/gangloot_spawner/short_tall(C)
				if(2)
					return new /obj/gangloot_spawner/medium_tall(C)
				if(3)
					return new /obj/gangloot_spawner/long_tall(C)
				if(4)
					return new /obj/gangloot_spawner/xlong_tall(C)

	//also add a chance for something funny as well, like a buttbot or something

/obj/gangloot_spawner
	var/list/items[][]
	var/size_x
	var/size_y
	var/value
	var/offset_x
	var/offset_y
	var/set_layer
	var/test_item


	proc/spawn_item(loc,path,off_x=0,off_y=0, rot=0, scale_x=1,scale_y=1)
		boutput(world,"creating new [path]")
		var/obj/lootObject = new path(loc)
		boutput(world,"see? [lootObject]")
		lootObject.transform = lootObject.transform.Scale(scale_x,scale_y)
		lootObject.transform = lootObject.transform.Turn(rot)
		lootObject.pixel_x = offset_x + off_x
		lootObject.pixel_y = offset_y + off_y
		lootObject.layer = set_layer + 3 // 3 seems to be default
		lootObject.AddComponent(/datum/component/transform_on_pickup)
		return lootObject
	proc/create_loot(var/C)
//		boutput(world,"Gangloot of size [src.size_x],[src.size_y] of [value] added to [C]")
//		var/obj/gangloot_spawner/loot = select_loot(C,value)

		boutput(world,"Gangloot is go with [value]")
		var/obj/gangloot_spawner/loot = src.choose_loot(C)
		loot.offset_x = offset_x
		loot.offset_y = offset_y
		loot.set_layer = set_layer
		var/refund_token = loot.create_loot(C) //so bad weapons can refund some value
		del(loot)
		del(src)
		return refund_token


		//Chooses what loot to spawn
	proc/choose_loot()


//
//ASSAULT: Combat oriented syndie gear, Assault weapons!!!
//DANGEROUS: Combat-oriented traitor gear TC - OR - weaker gear that's from nukies. be very careful!
//WEAPONS: Weak combat items like D-swords and 9mm guns. To be used alongside Medium Gears
//GEAR: Protective equipment, gimmicky syndicate items, grenades, valuable/sought out station items
//GIMMICKS: Stuff you can find during most rounds, or uncommon items that are goofy.

// Crates:
// 1st crate @ 15m : ~3 Mediums
// 2nd crate @ 25m: 1 High value, 4 medium
// 3rd crate @ 35m: 2 High value, 5 medium
// 4th crate @ 45m: 3 High value, 6 medium
// 4th crate @ 55m: 1 Assault, 4 High value, rest medium
//
//VALUATION
//Larger items should be a little generous as they reduce the amount of filler, but keep in mind...
//not many tiny items are incredible drops either
//
// Tier 4 loot:	150 points 	/ 1800 per crate
// Tier 3 loot: 90 points	/ 1080 per crate
// Tier 2 loot: 40 points	/ 480 gang points per crate
// Tier 1 loot: 12.5 points / 150 gang points per crate

//Starting crates will have 1-2 medium tier items,  later crates may contain up to 2 larger items
		//test
			//items = list(list(_,0,0))

	small //1x1
		choose_loot(C)

			switch(value)
				if(3) //Weapon value
					var/chance = rand(1,100)
					if (chance <= 50)
						return new /obj/gangloot_spawner/small/derringer(C) // adjust
					else
						return new /obj/gangloot_spawner/small/derringer(C) // adjust
				if(2) //Gear value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/small/flashbang(C)
					else if (chance <= 40)
						return new /obj/gangloot_spawner/small/robusttecs(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/small/recharge_cell(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/small/ammo_nine(C)
					else
						return new /obj/gangloot_spawner/small/flash(C)
				if(1) //Low value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/small/juicerillo(C)
					else if (chance <= 40)
						return new /obj/gangloot_spawner/small/rillo(C)
					else if (chance <= 50)
						return new /obj/gangloot_spawner/small/jaffacakes(C)
					else if (chance <= 65)
						return new /obj/gangloot_spawner/small/weed(C)
					else if (chance <= 70)
						return new /obj/gangloot_spawner/small/omegaweed(C)
					else if (chance <= 75)
						return new /obj/gangloot_spawner/small/whiteweed(C)
					else if (chance <= 80)
						return new /obj/gangloot_spawner/small/meds(C)
					else if (chance <= 85)
						return new /obj/gangloot_spawner/small/goldzippo(C)
					else
						return new /obj/gangloot_spawner/small/drugs(C)

		// HIGH VALUE:
		derringer
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/derringer,0,0)
				return 2 //give an extra gear item, since these are kinda niche
		ammo_nine
			create_loot(var/C)
				spawn_item(C,pick(ammo_9mm),-2,0)
				spawn_item(C,pick(ammo_9mm),2,0)
		ammo_shot
			create_loot(var/C)
				spawn_item(C,/obj/item/ammo/bullets/nails,0,0)
		// MID VALUE:
		robusttecs
			create_loot(var/C)
				spawn_item(C,/obj/item/implantcase/robust,off_x=0,off_y= 2,rot=0,scale_x=0.8,scale_y=0.8)
				spawn_item(C,/obj/item/implantcase/robust,off_x=0,off_y=-2,rot=0,scale_x=0.8,scale_y=0.8)
		poison_loose
			create_loot(var/C)
				spawn_item(C,/obj/item/reagent_containers/glass/bottle/poison,0,0)
		flash
			create_loot(var/C)
				spawn_item(C,/obj/item/device/flash,0,0)
		flashbang
			create_loot(var/C)
				spawn_item(C,/obj/item/chem_grenade/flashbang,0,0)
		ammo_loose_pistol
			create_loot(var/C)


		//LOW VALUE: Gimmicks
		//loose drugs
		//No money, it too wide
		//meds
		recharge_cell //maybe good to bribe Sec...
			create_loot(var/C)
				spawn_item(C,/obj/item/ammo/power_cell/self_charging/medium,0,2)
		meds
			create_loot(var/C)
				spawn_item(C,/obj/item/storage/pill_bottle/epinephrine,0,0)
		jaffacakes
			create_loot(var/C)
				spawn_item(C,/obj/item/reagent_containers/food/snacks/cookie/jaffa,0,2)
				spawn_item(C,/obj/item/reagent_containers/food/snacks/cookie/jaffa,0,0)
				spawn_item(C,/obj/item/reagent_containers/food/snacks/cookie/jaffa,0,-2)
				spawn_item(C,/obj/item/reagent_containers/food/snacks/cookie/jaffa,0,-4)

		weed
			create_loot(var/C)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,0,2)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,0,0)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,0,-2)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,0,-4)
		whiteweed
			create_loot(var/C)
				spawn_item(C,/obj/item/plant/herb/cannabis/white/spawnable,0,2)
				spawn_item(C,/obj/item/plant/herb/cannabis/white/spawnable,0,0)
				spawn_item(C,/obj/item/plant/herb/cannabis/white/spawnable,0,-2)
				spawn_item(C,/obj/item/plant/herb/cannabis/white/spawnable,0,-4)
		omegaweed
			create_loot(var/C)
				spawn_item(C,/obj/item/plant/herb/cannabis/omega/spawnable,0,2)
				spawn_item(C,/obj/item/plant/herb/cannabis/omega/spawnable,0,0)
				spawn_item(C,/obj/item/plant/herb/cannabis/omega/spawnable,0,-2)
				spawn_item(C,/obj/item/plant/herb/cannabis/omega/spawnable,0,-4)

		goldzippo
			create_loot(var/C)
				spawn_item(C,/obj/item/device/light/zippo/gold,0,0)
		rillo

			create_loot(var/C)
				spawn_item(C,/obj/item/cigpacket/cigarillo,-2,0)
				spawn_item(C,/obj/item/cigpacket/cigarillo,2,0)
		juicerillo
			create_loot(var/C)
				spawn_item(C,/obj/item/cigpacket/cigarillo/juicer,-2,0)
				spawn_item(C,/obj/item/cigpacket/cigarillo/juicer,2,0)
		drugs
			create_loot(var/C)
				spawn_item(C,pick(drug_items),0,0)

	medium //2x1

		choose_loot(C)
			switch(value)
				if(4) //Assault value - Guaranteed to be some kinda heavy weapon
					var/chance = rand(1,100)
					if (chance <= 50)
						return new /obj/gangloot_spawner/medium/syndie_pistol(C)
					else
						return new /obj/gangloot_spawner/medium/smart_gun(C)
				if(3) //Weapon value
					var/chance = rand(1,100)
					if(chance <= 10)
						return new /obj/gangloot_spawner/medium/clock(C)
					else if (chance <= 25)
						return new /obj/gangloot_spawner/medium/hipoint(C)
					else if (chance <= 40)
						return new /obj/gangloot_spawner/medium/beretta(C)
					else if (chance <= 70)
						return new /obj/gangloot_spawner/medium/saa(C)
					else
						return new /obj/gangloot_spawner/medium/deagle(C)
				if(2)//Medium value
					var/chance = rand(1,100)
					if (chance <= 35)
						return new /obj/gangloot_spawner/medium/donks(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/medium/money_huge(C)
					else if (chance <= 80)
						return new /obj/gangloot_spawner/medium/robust_donuts(C)
					else
						return new /obj/gangloot_spawner/medium/money_big(C)

				if(1) //Low  value
					var/chance = rand(1,9)
					if (chance <= 20)
						return new /obj/gangloot_spawner/medium/money(C)
					else if (chance <= 45)
						return new /obj/gangloot_spawner/medium/cigar(C)
					else if (chance <= 65)
						return new /obj/gangloot_spawner/medium/drug_injectors(C)
					else if (chance < 90)
						return new /obj/gangloot_spawner/medium/utility_belt(C)
					else
						return new /obj/gangloot_spawner/medium/goldcigar(C)
		// ASSAULT VALUE: Syndie gear
		syndie_pistol
			create_loot(var/C)
				//spawn_item(C,//spawn_item(C,/obj/item/ammo/bullets/bullet_9mm,2,0)
				spawn_item(C,/obj/item/gun/kinetic/pistol,0,0)
		smart_gun
			create_loot(var/C)
				//spawn_item(C,//spawn_item(C,/obj/item/ammo/bullets/bullet_22/smartgun,2,0)
				spawn_item(C,/obj/item/gun/kinetic/pistol/smart/mkII,0,0)
		// HIGH VALUE:
		money_huge
			create_loot(var/C)
				spawn_item(C,/obj/item/spacecash/tenthousand,0,2)
				spawn_item(C,/obj/item/spacecash/tenthousand,0,0)
				spawn_item(C,/obj/item/spacecash/tenthousand,0,-2)
		clock
			create_loot(var/C)
				spawn_item(C,/obj/item/ammo/bullets/nine_mm_NATO,0,0)
				spawn_item(C,/obj/item/gun/kinetic/clock_188/boomerang,0,0)

		deagle
			create_loot(var/C)
				spawn_item(C,/obj/item/ammo/bullets/deagle50cal,0,0)
				spawn_item(C,/obj/item/gun/kinetic/deagle,0,0)
		donks
			create_loot(var/C)
				spawn_item(C,/obj/item/reagent_containers/emergency_injector/methamphetamine,0,3)
				spawn_item(C,/obj/item/reagent_containers/emergency_injector/high_capacity/donk_injector,0,0)
				spawn_item(C,/obj/item/reagent_containers/emergency_injector/methamphetamine,0,-3)

		// MID VALUE:
		saa
			create_loot(var/C)
				//spawn_item(C,/obj/item/ammo/bullets/c_45,2,0)
				spawn_item(C,/obj/item/gun/kinetic/colt_saa,0,0)
		money_big
			create_loot(var/C)
				spawn_item(C,/obj/item/spacecash/fivethousand,0,2)
				spawn_item(C,/obj/item/spacecash/fivethousand,0,0)
				spawn_item(C,/obj/item/spacecash/fivethousand,0,-2)
		beretta
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/beretta,0,0)
		hipoint
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/hipoint,0,0)
		robust_donuts
			create_loot(var/C)
				spawn_item(C,/obj/item/reagent_containers/food/snacks/donut/custom/robust,-1,0)
				spawn_item(C,/obj/item/reagent_containers/food/snacks/donut/custom/robust,1,0)
		//
		//LOW VALUE: Gimmicks
		utility_belt
			create_loot(var/C)
				spawn_item(C,/obj/item/storage/belt/utility/prepared,0,1)
				spawn_item(C,/obj/item/storage/belt/utility/prepared,0,-1)
		money
			create_loot(var/C)
				spawn_item(C,/obj/item/spacecash/fivehundred,0,2)
				spawn_item(C,/obj/item/spacecash/fivehundred,0,0)
				spawn_item(C,/obj/item/spacecash/fivehundred,0,-2)

		cigar
			create_loot(var/C)
				spawn_item(C,/obj/item/clothing/mask/cigarette/cigar,0,3)
				spawn_item(C,/obj/item/clothing/mask/cigarette/cigar,0, 0)
				spawn_item(C,/obj/item/clothing/mask/cigarette/cigar,0,-3)

		goldcigar
			create_loot(var/C)
				spawn_item(C,/obj/item/clothing/mask/cigarette/cigar/gold,0,3)
				spawn_item(C,/obj/item/clothing/mask/cigarette/cigar/gold,0, 0)
				spawn_item(C,/obj/item/clothing/mask/cigarette/cigar/gold,0,-3)


		drug_injectors
			create_loot(var/C)
				spawn_item(C,/obj/item/reagent_containers/emergency_injector/random,0,4)
				spawn_item(C,/obj/item/reagent_containers/emergency_injector/random,0,2)
				spawn_item(C,/obj/item/reagent_containers/emergency_injector/random,0,0)
				spawn_item(C,/obj/item/reagent_containers/emergency_injector/random,0,2)
				spawn_item(C,/obj/item/reagent_containers/emergency_injector/random,0,4)


	long //3x1
		choose_loot(C)
			switch(value)
				if(4) //Assault value
					var/chance = rand(1,100)
					if (chance <= 100)
						return new /obj/gangloot_spawner/long/spes(C)

				if(3) //Weapon value
					var/chance = rand(1,100)
					if (chance <= 15)
						return new /obj/gangloot_spawner/long/flaregun(C)
					else if (chance <= 45)
						return new /obj/gangloot_spawner/long/coachgun(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/long/clock(C)
					else if (chance <= 75)
						return new /obj/gangloot_spawner/long/beretta(C)
					else if (chance <= 85)
						return new /obj/gangloot_spawner/long/hipoint(C)
					else if (chance <= 95)
						return new /obj/gangloot_spawner/long/sawnshotty(C)
					else
						return new /obj/gangloot_spawner/long/gl(C)
				if(2) //Gear value
					var/chance = rand(1,100)
					if (chance <= 20)
					else if (chance <= 40)
						return new /obj/gangloot_spawner/long/money_big(C)
					else if (chance <= 50)
						return new /obj/gangloot_spawner/long/money_big(C)
					else
				if(1) //Low value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/long/money(C)
					else
						return new /obj/gangloot_spawner/long/money(C) //TODO
		// HIGH VALUE: Syndie rifels, pistols with amamo
		// MID VALUE:
		//LOW VALUE: Gimmicks
		//loose drugs
		//money
		//meds
		//vuvuzela
		//HIGH VALUE Rifles, Pistols with ammo
		spes
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/spes/engineer,0,0)


		//MID VALUE Staffie-tier Pistols with ammo
		flaregun
			create_loot(var/C)
				spawn_item(C,/obj/item/ammo/bullets/flare,4,0)
				spawn_item(C,/obj/item/gun/kinetic/flaregun,-8,0)
		beretta
			create_loot(var/C)
				spawn_item(C,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,6,0)
				spawn_item(C,/obj/item/gun/kinetic/beretta,-4,0)
		hipoint
			create_loot(var/C)
				spawn_item(C,/obj/item/ammo/bullets/nine_mm_NATO/mag_ten,6,0)
				spawn_item(C,/obj/item/gun/kinetic/hipoint,-4,0)
		clock
			create_loot(var/C)
				spawn_item(C,/obj/item/ammo/bullets/nine_mm_NATO,6,0)
				spawn_item(C,/obj/item/gun/kinetic/clock_188,-4,0)
		gl
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/riot40mm,0,0)
		coachgun
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/coachgun,-4,0)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,5,2)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,7,2)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,5,-2)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,7,-2)
		sawnshotty
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/riotgun/sawnoff,-4,0)


		//LOW VALUE
		money_big
			create_loot(var/C)
				spawn_item(C,/obj/item/spacecash/thousand,-4,2)
				spawn_item(C,/obj/item/spacecash/thousand,4,2)
				spawn_item(C,/obj/item/spacecash/thousand,4,0)
				spawn_item(C,/obj/item/spacecash/thousand,4,-2)
				spawn_item(C,/obj/item/spacecash/thousand,-4,0)
				spawn_item(C,/obj/item/spacecash/thousand,-4,-2)
		money
			create_loot(var/C)
				spawn_item(C,/obj/item/spacecash/fivehundred,-4,2)
				spawn_item(C,/obj/item/spacecash/fivehundred,4,2)
				spawn_item(C,/obj/item/spacecash/fivehundred,4,0)
				spawn_item(C,/obj/item/spacecash/fivehundred,4,-2)
				spawn_item(C,/obj/item/spacecash/fivehundred,-4,0)
				spawn_item(C,/obj/item/spacecash/fivehundred,-4,-2)

	xlong //4x1://TODO, these are rare finds

		// HIGH VALUE: Long rifles


		// MID VALUE: Mid rifles & ammo


		//LOW VALUE: Gimmicks
		//loose drugs
		//money
		//meds
		choose_loot(C)

			switch(value)
				if(3) //Weapon value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/xlong/huntingrifle(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/xlong/handguns_heavy(C)
					else
						return new /obj/gangloot_spawner/xlong/riotgun(C)
				if(2) //Gear value
					var/chance = rand(1,100)
					if (chance <= 30)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/xlong/utility_belt(C)
					else
						return new /obj/gangloot_spawner/xlong/utility_belt(C)
				if(1) //Low value
					var/chance = rand(1,100)
					if (chance <= 30)
						return new /obj/gangloot_spawner/xlong/utility_belt(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/xlong/utility_belt(C)
					else
						return new /obj/gangloot_spawner/xlong/utility_belt(C)
		//HIGH
		ak47s
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/ak47,-6,0)
		huntingrifle
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/hunting_rifle,-6,0)
		riotgun
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,0)
		handguns_heavy //deagle n revolver
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/deagle,-8,0)
				spawn_item(C,/obj/item/gun/kinetic/colt_saa,8,0)
		//MEDIUM
		phasers
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/energy/phaser_gun,-8,0)
				spawn_item(C,/obj/item/gun/energy/phaser_gun,8,0)
		handguns
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/beretta,-8,4)
				spawn_item(C,/obj/item/gun/kinetic/beretta,-8,-4)
		lasers
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,-4)
		riotgun
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,-4)
		utility_belt
			create_loot(var/C)
				spawn_item(C,/obj/item/storage/belt/utility/prepared,0,1)
				spawn_item(C,/obj/item/storage/belt/utility/prepared,0,-1)

	short_tall //1x2
		choose_loot(C)
			switch(value)
				if(3) //High value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/short_tall/syndieomnitool(C)
					else
						return new /obj/gangloot_spawner/short_tall/syndieomnitool(C)
				if(2) //Medium value
					var/chance = rand(1,100)
					if (chance <= 30)
						return new /obj/gangloot_spawner/short_tall/gold(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/short_tall/gold(C)
					else
						return new /obj/gangloot_spawner/short_tall/gold(C)
				if(1) //Low value
					var/chance = rand(1,100)
					if (chance <= 30)
						return new /obj/gangloot_spawner/short_tall/airhorn(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/short_tall/bong(C)
					else
						return new /obj/gangloot_spawner/short_tall/booze(C) //TODO
		// good for tall items, like booze
		// HIGH VALUE: ....
		// Loose strong grenades

		syndieomnitool
			create_loot(var/C)
				spawn_item(C,/obj/item/tool/omnitool/syndicate,0,0)
		// MID VALUE: ...
		// 1~2 Loose grenades

		gold
			create_loot(var/C)
				spawn_item(C,/obj/item/material_piece/gold,0,0)


		//LOW VALUE: Gimmicks
		//Filled Autoinjectors
		//loose drugs
		//money
		bong
			create_loot(var/C)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,0,0)
				spawn_item(C,/obj/item/reagent_containers/glass/water_pipe,0,0)
		booze
			create_loot(var/C)
				spawn_item(C,pick(booze_items),0,0)
//		molotov?
//			create_loot(var/C)
//				spawn_item(C,/obj/item/gun/kinetic/riot40mm,0,0)


		airhorn
			create_loot(var/C)
				spawn_item(C,/obj/item/instrument/bikehorn/airhorn,0,0)
	medium_tall //2x2
		choose_loot(C)
			switch(value)
				if(3) //High value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/medium_tall/gold(C)
					else if (chance <= 50)
						return new /obj/gangloot_spawner/medium_tall/mac10(C)
					else if (chance <= 70)
						return new /obj/gangloot_spawner/medium_tall/frags(C)
					else
						return new /obj/gangloot_spawner/medium_tall/concussions(C)
				if(2) //Medium value
					var/chance = rand(1,100)
					if (chance <= 30)
						return new /obj/gangloot_spawner/medium_tall/mixed_sec(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/medium_tall/stingers(C)
					else
						return new /obj/gangloot_spawner/medium_tall/helmet(C)
				if(1) //Low value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/medium_tall/medkits(C)
					else if (chance <= 40)
						return new /obj/gangloot_spawner/medium_tall/hat(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/medium_tall/money(C)
					else if (chance <= 80)
						return new /obj/gangloot_spawner/medium_tall/booze(C)
					else
						return new /obj/gangloot_spawner/medium_tall/gasmasks(C)
		// HIGH VALUE: Syndie gear
		// mixed grenades
		// Banana grenade pouch
		//hotbox lighter and weed
		//Grenade pouches
		mac10
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/mac10,0,0)
		gold
			create_loot(var/C)
				spawn_item(C,/obj/item/material_piece/gold,-4,0)
				spawn_item(C,/obj/item/material_piece/gold,0,0)
				spawn_item(C,/obj/item/material_piece/gold,4,0)
		frags
			create_loot(var/C)
				spawn_item(C,	/obj/item/old_grenade/stinger/frag,-4,0)
				spawn_item(C,	/obj/item/old_grenade/stinger/frag,4,0)
		concussions //INCENDIARIES BAD!!!!!!  FIX EM
			create_loot(var/C)
				spawn_item(C,/obj/item/old_grenade/energy_concussion,-6,0)
				spawn_item(C,/obj/item/old_grenade/energy_concussion,2,0)
				spawn_item(C,/obj/item/old_grenade/energy_concussion,-2,0,rot=180)
				spawn_item(C,/obj/item/old_grenade/energy_concussion,6,0,rot=180)
		// MID VALUE: Pistols with ammo
		//Noslips
		//~4 Loose Grenades
		//Insuls
		//NVGs
		mixed_sec
			create_loot(var/C)
				spawn_item(C,/obj/item/chem_grenade/flashbang,-4,4)
				spawn_item(C,/obj/item/chem_grenade/flashbang,4,4)
				spawn_item(C,/obj/item/chem_grenade/cryo,-4,-4)
				spawn_item(C,/obj/item/chem_grenade/shock,4,-4)

		stingers
			create_loot(var/C)
				spawn_item(C,/obj/item/old_grenade/stinger,-4,0)
				spawn_item(C,/obj/item/old_grenade/stinger,4,0)
		helmet
			create_loot(var/C)
				spawn_item(C,pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, /proc/filter_trait_hats)),0,-2)
				spawn_item(C,pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, /proc/filter_trait_hats)),0,0)
				spawn_item(C,pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, /proc/filter_trait_hats)),0,2)

		//LOW VALUE: Gimmicks
		//Booze
		//Medkits
		//Big pile of credits
		//gas mask
		booze
			create_loot(var/C)
				spawn_item(C,pick(booze_items),-2,0)
				spawn_item(C,pick(booze_items),0,0)
				spawn_item(C,pick(booze_items),2,0)

		hat
			create_loot(var/C)
				spawn_item(C,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),0,-2)
				spawn_item(C,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),0,0)
				spawn_item(C,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),0,2)
		medkits
			create_loot(var/C)
				spawn_item(C,/obj/item/storage/firstaid/toxin,0,-2)
				spawn_item(C,/obj/item/storage/firstaid/regular,0,0)
				spawn_item(C,/obj/item/storage/firstaid/crit,0,2)
		gasmasks
			create_loot(var/C)
				spawn_item(C,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),0,0)

		money
			create_loot(var/C)
				spawn_item(C,/obj/item/spacecash/fivehundred,-4,4)
				spawn_item(C,/obj/item/spacecash/fivehundred,-4,2)
				spawn_item(C,/obj/item/spacecash/fivehundred,-4,0)
				spawn_item(C,/obj/item/spacecash/fivehundred,4,4)
				spawn_item(C,/obj/item/spacecash/fivehundred,4,2)
				spawn_item(C,/obj/item/spacecash/fivehundred,4,0)
				spawn_item(C,/obj/item/spacecash/fivehundred,-4,-2)
				spawn_item(C,/obj/item/spacecash/fivehundred,-4,-4)
				spawn_item(C,/obj/item/spacecash/fivehundred,-4,-6)
				spawn_item(C,/obj/item/spacecash/fivehundred,4,-2)
				spawn_item(C,/obj/item/spacecash/fivehundred,4,-4)
				spawn_item(C,/obj/item/spacecash/fivehundred,4,-6)
	long_tall //3x2
		choose_loot(C)
			switch(value)
				if(3) //High value
					var/chance = rand(1,100)
					if (chance <= 20)
					else if (chance <= 50)
						return new /obj/gangloot_spawner/long_tall/mac10_set(C)
					else if (chance <= 70)
						return new /obj/gangloot_spawner/long_tall/money_huge(C)
					else
						return new /obj/gangloot_spawner/long_tall/coachguns(C)
				if(2) //Medium value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/long_tall/grenades(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/long_tall/espionage_belts(C)
					else
						return new /obj/gangloot_spawner/long_tall/berettas(C)
				if(1) //Low value
					var/chance = rand(1,100)
					if (chance <= 50)
						return new /obj/gangloot_spawner/long_tall/money(C)
					else
						return new /obj/gangloot_spawner/long_tall/hotbox(C)
		//High value
		mac10_set
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/mac10,-6,0)
				spawn_item(C,/obj/item/ammo/bullets/nine_mm_NATO/mac10,9,0)
				spawn_item(C,/obj/item/ammo/bullets/nine_mm_NATO/mac10,6,0)
		money_huge
			create_loot(var/C)
				spawn_item(C,/obj/item/material_piece/gold,-10,0)
				spawn_item(C,/obj/item/material_piece/gold,-5, 0)
				spawn_item(C,/obj/item/material_piece/gold,0,0)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,-6)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,-4)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,-2)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,0)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,2)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,4)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,6)
		coachguns
			create_loot(var/C)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,5,6)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,7,6)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,5,2)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,7,2)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,5,-2)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,7,-2)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,5,-6)
				spawn_item(C,/obj/item/ammo/bullets/tengauge/loose,7,-6)
				spawn_item(C,/obj/item/gun/kinetic/coachgun,-6,4)
				spawn_item(C,/obj/item/gun/kinetic/coachgun,-6,-4)

		//Mid value
		espionage_belts
			create_loot(var/C)
				spawn_item(C,/obj/item/storage/fanny/syndie,-4,0)
				spawn_item(C,/obj/item/storage/fanny/syndie,4,0)
		berettas
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/beretta,-6,4)
				spawn_item(C,/obj/item/gun/kinetic/beretta,6,4)
				spawn_item(C,/obj/item/gun/kinetic/beretta,-6,-4)
				spawn_item(C,/obj/item/gun/kinetic/beretta,6,-4)

		grenades
			create_loot(var/C)
				spawn_item(C,/obj/item/old_grenade/smoke,-6,-4)
				spawn_item(C,/obj/item/old_grenade/smoke,-6,4)
				spawn_item(C,/obj/item/chem_grenade/flashbang,6,-4)
				spawn_item(C,/obj/item/chem_grenade/flashbang,6,4)
				spawn_item(C,/obj/item/old_grenade/stinger,0,-4)
				spawn_item(C,/obj/item/old_grenade/stinger,0,4)
		money_big
			create_loot(var/C)
				spawn_item(C,/obj/item/spacecash/fivethousand, -6,-6)
				spawn_item(C,/obj/item/spacecash/fivethousand, -6,-4)
				spawn_item(C,/obj/item/spacecash/fivethousand, -6,-2)
				spawn_item(C,/obj/item/spacecash/fivethousand, -6,0)
				spawn_item(C,/obj/item/spacecash/fivethousand, -6,2)
				spawn_item(C,/obj/item/spacecash/fivethousand, -6,4)
				spawn_item(C,/obj/item/spacecash/fivethousand, -6,6)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,-6)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,-4)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,-2)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,0)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,2)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,4)
				spawn_item(C,/obj/item/spacecash/fivethousand, 6,6)
		money
			create_loot(var/C)
				spawn_item(C,/obj/item/spacecash/fivehundred, -6,-6)
				spawn_item(C,/obj/item/spacecash/fivehundred, -6,-4)
				spawn_item(C,/obj/item/spacecash/fivehundred, -6,-2)
				spawn_item(C,/obj/item/spacecash/fivehundred, -6,0)
				spawn_item(C,/obj/item/spacecash/fivehundred, -6,2)
				spawn_item(C,/obj/item/spacecash/fivehundred, -6,4)
				spawn_item(C,/obj/item/spacecash/fivehundred, 6,-6)
				spawn_item(C,/obj/item/spacecash/fivehundred, 6,-4)
				spawn_item(C,/obj/item/spacecash/fivehundred, 6,-2)
				spawn_item(C,/obj/item/spacecash/fivehundred, 6,0)
				spawn_item(C,/obj/item/spacecash/fivehundred, 6,2)
				spawn_item(C,/obj/item/spacecash/fivehundred, 6,4)
		hotbox
			create_loot(var/C)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,-6,-6)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,-6,-3)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,-6,0)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,-6,3)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,-6,6)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,0,-6)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,0,-3)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,0,0)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,0,3)
				spawn_item(C,/obj/item/plant/herb/cannabis/spawnable,0,6)
				spawn_item(C,/obj/item/device/light/zippo/syndicate,6,0)


		//Tactical Espionage Belt Storage

		//Stimulants
		//D-Sabers
		//
	xlong_tall //4x2
		//full, coherent loadouts
		//these should always have good stuff - they're taking up 2/3rds of a crate!
		choose_loot(C)
			switch(value)
				if(3) //High value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/xlong_tall/ak47s(C)
					else if (chance <= 50)
						return new /obj/gangloot_spawner/xlong_tall/huntingrifles(C)
					else if (chance <= 70)
						return new /obj/gangloot_spawner/xlong_tall/riotguns(C)
					else if (chance <= 70)
						return new /obj/gangloot_spawner/xlong_tall/handguns_heavy(C)
					else
						return new /obj/gangloot_spawner/xlong_tall/mac10s(C)
				if(2) //Medium value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/xlong_tall/phasers(C)
					else if (chance <= 40)
						return new /obj/gangloot_spawner/xlong_tall/handguns(C)
					else if (chance <= 60)
						return new /obj/gangloot_spawner/xlong_tall/lasers(C)
					else
						return new /obj/gangloot_spawner/xlong_tall/(C)
				if(1) //Low value
					var/chance = rand(1,100)
					if (chance <= 50)
						return new /obj/gangloot_spawner/xlong_tall/money(C)
					else
						return new /obj/gangloot_spawner/xlong_tall/money(C)
		//HIGH
		ak47s
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/ak47,-6,4)
				spawn_item(C,/obj/item/gun/kinetic/ak47,-6,-4)
		huntingrifles
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/hunting_rifle,-6,4)
				spawn_item(C,/obj/item/gun/kinetic/hunting_rifle,-6,-4)
		riotguns
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,-4)
		mac10s
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/mac10,-12,0)
				spawn_item(C,/obj/item/gun/kinetic/mac10,12,0)
				spawn_item(C,/obj/item/ammo/bullets/nine_mm_NATO/mac10,2,0)
				spawn_item(C,/obj/item/ammo/bullets/nine_mm_NATO/mac10,-2,0)
		handguns_heavy //deagle n revolver
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,-4)
		//MEDIUM
		phasers
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,-4)
		handguns
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,-4)
		lasers
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,-4)
		riotgun
			create_loot(var/C)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,/obj/item/gun/kinetic/riotgun,-8,-4)

		//LOW

		money
			create_loot(var/C)
				spawn_item(C,/obj/item/spacecash/fivehundred, -8,-6)
				spawn_item(C,/obj/item/spacecash/fivehundred, -8,-4)
				spawn_item(C,/obj/item/spacecash/fivehundred, -8,-2)
				spawn_item(C,/obj/item/spacecash/fivehundred, -8,0)
				spawn_item(C,/obj/item/spacecash/fivehundred, -8,2)
				spawn_item(C,/obj/item/spacecash/fivehundred, -8,4)
				spawn_item(C,/obj/item/spacecash/fivehundred, 8,-6)
				spawn_item(C,/obj/item/spacecash/fivehundred, 8,-4)
				spawn_item(C,/obj/item/spacecash/fivehundred, 8,-2)
				spawn_item(C,/obj/item/spacecash/fivehundred, 8,0)
				spawn_item(C,/obj/item/spacecash/fivehundred, 8,2)
				spawn_item(C,/obj/item/spacecash/fivehundred, 8,4)

//drugs!
//medicine?
//autoinjectors
//maybe new, fancy autoinjectors (Quikclot-style, heals you instantly but brings you back down over time til you're back to where you were)
//guns!
//grenades! pipe bombs!
//more spray cans!
//cigarettes, cigarillos, cigars - loose anad boxed
//food? fancy foods
//fancy gear, pocket pouches
//
//fewer items = higher average value!
//more items = some good!  some bad... maybe
//syndie dagger
