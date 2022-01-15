//generates and pixel shifts loot caches
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



	New()
		..()
		generate_gang_crate(list(3,3,3,2,2,2,2,2))

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
		var/done = false
		lootSpawns = list()

		while (!done)
			//scan to find the l
			while (lootGrid[cursor_y][cursor_x] == 1)
				cursor_x++
			lootSize_x = rand(1,min(4,max_loot_x-cursor_x)) //between 1 & largest width that can spawn
			lootSize_y = 1 //this wont work unless you set lootsize_x to account for lootsize_y on another level


			boutput(world,"Chosen loot pos [cursor_x],[cursor_y] to have a [lootSize_x],[lootSize_y]")

			for (var/x=1 to lootSize_x) //mark lootGrid as used
				for (var/y=1 to lootSize_y)
					boutput(world,"Marked [cursor_x+x-1],[cursor_y-1+y]")
					lootGrid[cursor_y-1+y][cursor_x+x-1] = 1

			var/obj/gangloot_spawner/loot = select_loot(src,lootSize_x,lootSize_y)
			loot.size_x = lootSize_x
			loot.size_y = lootSize_y
			loot.set_layer = 3+(max_loot_y-cursor_y)
			loot.offset_x = loot_x_offset + loot_x_pixels*(cursor_x-1) + loot_x_pixels*(lootSize_x/2)
			loot.offset_y = loot_y_offset + loot_y_pixels*(cursor_y-1) + loot_y_pixels*(lootSize_y/2)
			lootSpawns += loot

			boutput(world,"lootGrid is [lootGrid[cursor_y][cursor_x]] at [cursor_x],[cursor_y]")

			while (!done && lootGrid[cursor_y][cursor_x] == 1)
				cursor_x++
				boutput(world,"checking [cursor_x],[cursor_y]")
				if (cursor_x > max_loot_x)
					cursor_x = 1
					cursor_y++
					if (cursor_y > max_loot_y)
						done = true
		boutput(world,"done, lootSpawns is...")
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
			boutput(world,"LootValue of [lootValue] applied to [lootObject]")

		for (var/obj/gangloot_spawner/G in lootSpawns)
			G.create_loot(src)

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
//					var/chance = rand(1,2)
//					if (chance == 1)
//						return new /obj/gangloot_spawner/xlong/huntingrifle(C)
//					else if (chance == 2)
//						return new /obj/gangloot_spawner/xlong/riotgun(C)

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

	
	proc/spawn_item(path,x,y,rot)

	proc/create_loot(var/C)
//		boutput(world,"Gangloot of size [src.size_x],[src.size_y] of [value] added to [C]")
//		var/obj/gangloot_spawner/loot = select_loot(C,value)
		
		boutput(world,"Gangloot is go with [value]")
		var/obj/gangloot_spawner/loot = src.choose_loot(C) // <!!!  MOVE THIS TO GENERATE_LOOT, LET IT RETURN THE COST OF SLOTS SO THAT SMALLS DONT STEAL ALL THE VALUE, OR THINK OF A BETTER COSTING SYSTEM!!!>
		var/list/items = loot.items
		boutput(world,"[items]")
		for (var/list/item in items)
			var/thing = item[1]
			boutput(world,"creating new [thing]")
			var/obj/lootObject = new thing(C)
			boutput(world,"see? [lootObject]")
			if (item.len > 3)
				lootObject.icon = turn(lootObject.icon,item[4])
			lootObject.pixel_x = offset_x + item[2]
			lootObject.pixel_y = offset_y + item[3]
			lootObject.layer = set_layer + 3 // 3 seems to be default
		del(src)


		//Chooses what loot to spawn
	proc/choose_loot()


// 
//DANGEROUS: Combat oriented syndie gear, Assault weapons!!!
//HIGH VALUE: Combat-oriented traitor gear TC - OR - weaker gear that's from nukies. be very careful!
//Medium Value: Gimmick syndicate items and valuable station items
//Low value: Stuff you can find during most rounds, nice to haves.

// Crates:
// 1st crate @ 15m : ~3 Mediums
// 2nd crate @ 25m: 1 High value, 4 medium
// 3rd crate @ 35m: 2 High value, 5 medium
// 4th crate @ 45m: 3 High value, 6 medium
// 4th crate @ 55m: 1 Assault, 4 High value, rest medium
//
// Does this work???
//
// Having high value slots makes small slots bad
// Perhaps have tiny slots refund partial cost
// 

//VALUATION
//Larger items should be somewhat more generous as they reduce the amount of filler
//Perhaps guarantee at least 1 large item? Who knows.
//For instance: 
//An assault-tier 1x1 may be a pile of grenade pouches
//An assault-tier 4x3 could be a few RPGs

//Starting crates will have 1-2 medium tier items,  later crates may contain up to 2 larger items
		//test
			//items = list(list(_,0,0))

	small //1x1
		choose_loot(C)
		
			switch(value)
				if(3) //High value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/small/gold(C) // adjust
					else
						return new /obj/gangloot_spawner/small/money_huge(C) // adjust
				if(2) //Medium value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/small/flashbang(C)
					else if (chance <= 40)
						return new /obj/gangloot_spawner/small/recharge_cell(C)
					else if (chance <= 70)
						return new /obj/gangloot_spawner/small/money_medium(C)
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
					else if (chance <= 70)
						return new /obj/gangloot_spawner/small/weed(C)
					else if (chance <= 80)
						return new /obj/gangloot_spawner/small/meds(C)
					else if (chance <= 85)
						return new /obj/gangloot_spawner/small/goldzippo(C)
					else
						return new /obj/gangloot_spawner/small/money(C)
			del(src)

		// HIGH VALUE: 
		gold
			items = list(list(/obj/item/material_piece/gold,0,0))
		
		// MID VALUE:
		poison_loose
			items = list(list(/obj/item/reagent_containers/glass/bottle/poison,0,0))
		flash
			items = list(list(/obj/item/device/flash,0,0))
		flashbang
			items = list(list(/obj/item/chem_grenade/flashbang,0,0))

		//LOW VALUE: Gimmicks
		//loose drugs
		//No money, it too wide
		//meds
		recharge_cell //maybe good to bribe Sec...
			items = list(list(/obj/item/ammo/power_cell/self_charging/medium,0,0))
		meds
			items = list(list(/obj/item/storage/pill_bottle/epinephrine,0,0))
		jaffacakes
			items = list(
				list(/obj/item/reagent_containers/food/snacks/cookie/jaffa,0,2),
				list(/obj/item/reagent_containers/food/snacks/cookie/jaffa,0,0),
				list(/obj/item/reagent_containers/food/snacks/cookie/jaffa,0,-2),
				list(/obj/item/reagent_containers/food/snacks/cookie/jaffa,0,-4),
			)
		weed
			items = list(
				list(/obj/item/plant/herb/cannabis,0,2),
				list(/obj/item/plant/herb/cannabis,0,0),
				list(/obj/item/plant/herb/cannabis,0,-2),
				list(/obj/item/plant/herb/cannabis,0,-4),
			)
		goldzippo
			items = list(list(/obj/item/device/light/zippo/gold,0,0))
		rillo
			items = list(list(/obj/item/cigpacket/cigarillo,-2,0),
					list(/obj/item/cigpacket/cigarillo,2,0))
		juicerillo
			items = list(list(/obj/item/cigpacket/cigarillo/juicer,-2,0),
					list(/obj/item/cigpacket/cigarillo/juicer,2,0))
		money
			items = list(list(/obj/item/spacecash/thousand,2,-1,90))
		money_medium
			items = list(list(/obj/item/spacecash/fivethousand,2,-1,90))
		money_huge
			items = list(list(/obj/item/spacecash/tenthousand,2,-1,90))

	medium //2x1
	
		choose_loot(C)
			switch(value) 
				if(4) //Assault value - Guaranteed weapon
					var/chance = rand(1,100)
					if (chance <= 50)
						return new /obj/gangloot_spawner/medium/syndie_pistol(C)
					else 
						return new /obj/gangloot_spawner/medium/smart_gun(C)
				if(3) //High value
					var/chance = rand(1,100)
					if (chance <= 25)
						return new /obj/gangloot_spawner/medium/syndie_pistol(C)
					else if (chance <= 50)
						return new /obj/gangloot_spawner/medium/money_huge(C)
					else if (chance <= 75)
						return new /obj/gangloot_spawner/medium/smart_gun(C)
					else 
						return new /obj/gangloot_spawner/medium/donks(C)
				if(2)//Medium value
					var/chance = rand(1,100)
					if(chance <= 10)
						return new /obj/gangloot_spawner/medium/saa(C)
					else if (chance <= 25)
						return new /obj/gangloot_spawner/medium/clock(C)
					else if (chance <= 50)
						return new /obj/gangloot_spawner/medium/money_big(C)
					else if (chance <= 80)
						return new /obj/gangloot_spawner/medium/cigar(C)
					else
						return new /obj/gangloot_spawner/medium/goldcigar(C)
				
				if(1) //Low  value
					var/chance = rand(1,9)
					if (chance <= 50)
						return new /obj/gangloot_spawner/medium/money(C)
					else if (chance <= 80)
						return new /obj/gangloot_spawner/medium/cigar(C)
					else
						return new /obj/gangloot_spawner/medium/goldcigar(C)
			del(src)
		// ASSAULT VALUE: Syndie gear
		syndie_pistol
			items = list(//list(/obj/item/ammo/bullets/bullet_9mm,2,0),
						list(/obj/item/gun/kinetic/pistol,0,0))
		smart_gun
			items = list(//list(/obj/item/ammo/bullets/bullet_22/smartgun,2,0),
						list(/obj/item/gun/kinetic/pistol/smart/mkII,0,0))
		money_huge
			items = list(list(/obj/item/spacecash/tenthousand,0,2),
					list(/obj/item/spacecash/tenthousand,0,0),
					list(/obj/item/spacecash/tenthousand,0,-2))
		// MID VALUE: 

		money_big
			items = list(list(/obj/item/spacecash/fivethousand,0,2),
					list(/obj/item/spacecash/fivethousand,0,0),
					list(/obj/item/spacecash/fivethousand,0,-2))
		saa
			items = list(//list(/obj/item/ammo/bullets/c_45,2,0),
						list(/obj/item/gun/kinetic/colt_saa,0,0))
		clock
			items = list(list(/obj/item/gun/kinetic/clock_188/boomerang,0,0))
		donks
			items = list(list(/obj/item/reagent_containers/emergency_injector/high_capacity/donk_injector,0,3),
			list(/obj/item/reagent_containers/emergency_injector/high_capacity/donk_injector,0,0),
			list(/obj/item/reagent_containers/emergency_injector/high_capacity/donk_injector,0,-3))

		//
		//LOW VALUE: Gimmicks
		money
			items = list(list(/obj/item/spacecash/fivehundred,0,2),
					list(/obj/item/spacecash/fivehundred,0,0),
					list(/obj/item/spacecash/fivehundred,0,-2))

		cigar
			items = list(list(/obj/item/clothing/mask/cigarette/cigar,0,3),
			list(/obj/item/clothing/mask/cigarette/cigar,0, 0),
			list(/obj/item/clothing/mask/cigarette/cigar,0,-3))

		goldcigar
			items = list(list(/obj/item/clothing/mask/cigarette/cigar/gold,0,3),
			list(/obj/item/clothing/mask/cigarette/cigar/gold,0, 0),
			list(/obj/item/clothing/mask/cigarette/cigar/gold,0,-3))


	long //3x1
		choose_loot(C)
			switch(value)
				if(3) //High value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/long/spes(C)
					else
						return new /obj/gangloot_spawner/long/gl(C)
				if(2) //Medium value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/long/flaregun(C)
					else
						return new /obj/gangloot_spawner/long/money_big(C)
				if(1) //Low value
					var/chance = rand(1,100)
					if (chance <= 20)
						return new /obj/gangloot_spawner/long/money(C) 
					else
						return new /obj/gangloot_spawner/long/money(C) //adjust
		

			del(src)

		// HIGH VALUE: Syndie rifels, pistols with amamo
		// MID VALUE: Staffie-tier Pistols
		//LOW VALUE: Gimmicks
		//loose drugs
		//money
		//meds
		//vuvuzela
		flaregun // with ammo
			items = list(list(/obj/item/ammo/bullets/flare,4,0),
						list(/obj/item/gun/kinetic/flaregun,-8,0))
		money_big
			items = list(list(/obj/item/spacecash/thousand,-4,2),
					list(/obj/item/spacecash/thousand,4,2),
					list(/obj/item/spacecash/thousand,4,0),
					list(/obj/item/spacecash/thousand,4,-2),
					list(/obj/item/spacecash/thousand,-4,0),
					list(/obj/item/spacecash/thousand,-4,-2))
		money
			items = list(list(/obj/item/spacecash/fivehundred,-4,2),
					list(/obj/item/spacecash/fivehundred,4,2),
					list(/obj/item/spacecash/fivehundred,4,0),
					list(/obj/item/spacecash/fivehundred,4,-2),
					list(/obj/item/spacecash/fivehundred,-4,0),
					list(/obj/item/spacecash/fivehundred,-4,-2))
		spes
			items = list(list(/obj/item/gun/kinetic/spes/engineer,0,0))
		gl
			items = list(list(/obj/item/gun/kinetic/riot40mm,0,0))

	xlong //4x1:

		// HIGH VALUE: Long rifles


		// MID VALUE: Mid rifles & ammo


		//LOW VALUE: Gimmicks
		//loose drugs
		//money
		//meds
		choose_loot(C)
			var/chance = rand(1,2)
			if (chance == 1)
				return new /obj/gangloot_spawner/xlong/huntingrifle(C)
			else if (chance == 2)
				return new /obj/gangloot_spawner/xlong/riotgun(C)
			del(src)

		money_big
		
		huntingrifle
			items = list(list(/obj/item/gun/kinetic/hunting_rifle,-6,0))
		riotgun
			items = list(list(/obj/item/gun/kinetic/riotgun,0,0))


	short_tall //1x2

		// good for tall items, like booze
		// HIGH VALUE: ....
		// Loose strong grenades

		// MID VALUE: ...
		// 1~2 Loose grenades

		//LOW VALUE: Gimmicks
		//Filled Autoinjectors
		//loose drugs
		//money

		gold
			items = list(list(/obj/item/material_piece/gold,0,0))
		booze
			items = list(list(/obj/item/gun/kinetic/spes/engineer,0,0))
//		molotov?
//			items = list(list(/obj/item/gun/kinetic/riot40mm,0,0))
		syndieomnitool
			items = list(list(/obj/item/tool/omnitool/syndicate,0,0))

	medium_tall //2x2

		// HIGH VALUE: Syndie gear
		// mixed grenades
		// Banana grenade pouch
		//hotbox lighter and weed
		//Grenade pouches

		// MID VALUE: Pistols with ammo
		//Noslips
		//~4 Loose Grenades
		//Insuls
		//NVGs

		//LOW VALUE: Gimmicks
		//Booze
		//Medkits
		//Big pile of credits
		//gas mask

	medium_long //3x2
		//Tactical Espionage Belt Storage

	medium_xtall // 2x3

		//Stimulants
		//D-Sabers
		//


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
