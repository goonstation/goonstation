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
	/obj/item/storage/pill_bottle/cyberpunk,
	/obj/item/storage/pill_bottle/epinephrine
)

//Number value is also spawn priority if there's no room in the crate.
#define GANG_CRATE_GUN_SYNDIE 6 //Currently not fully implemented
#define GANG_CRATE_GUN_STRONG 5
#define GANG_CRATE_GUN_WEAK 4
#define GANG_CRATE_GEAR_RARE 3
#define GANG_CRATE_GEAR 2
#define GANG_CRATE_GIMMICK 1


//GANG CRATES!
//Generates a layout of fancy loot with predetermined value
//
//
//5: Dangerous weapons (Actual traitor gear, here just in case)
//4: Strong weapons (non-9mm weapons, balanced for gang)
//3: Weak weapons (9mm NATO handguns, gang-level gear)
//2: Gear items (Health kits, grenades...)
//1: Gimmick items

//So a gang crate with a list of '4, 4, 2' will contain 2 strong weapons, 1 gear item and gimmicks

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

	var/static/obj/gangloot_master/lootMaster = new /obj/gangloot_master()


	only_gimmicks
		New()
			var/contents[10]
			lootMaster.generate_loot(src,contents)
			..()
	some_gear
		New()
			var/contents[10]
			contents[GANG_CRATE_GEAR] = 3
			lootMaster.generate_loot(src,contents)
			..()
	all_gear
		New()
			var/contents[10]
			contents[GANG_CRATE_GEAR] = 99
			lootMaster.generate_loot(src,contents)
			..()
	guns_and_gear
		New()
			var/contents[10]
			contents[GANG_CRATE_GEAR] = 3
			contents[GANG_CRATE_GUN_WEAK] = 3
			lootMaster.generate_loot(src,contents)
			..()
	early_game
		New()
			var/contents[10]
			contents[GANG_CRATE_GEAR] = 5
			contents[GANG_CRATE_GUN_WEAK] = 3
			lootMaster.generate_loot(src,contents)
			..()
	early_game
		New()
			var/contents[10]
			contents[GANG_CRATE_GEAR] = 5
			contents[GANG_CRATE_GUN_STRONG] = 3
			lootMaster.generate_loot(src,contents)
			..()
	only_guns
		New()
			var/contents[10]
			contents[GANG_CRATE_GUN_WEAK] = 99
			lootMaster.generate_loot(src,contents)
			..()



	Cross(atom/movable/mover)
		if(istype(mover, /obj/projectile))
			return 1
		return ..()

	CheckExit(atom/movable/O as mob|obj, target as turf)
		if(istype(O, /obj/projectile))
			return 1
		return ..()


	//also add a chance for something funny as well, like a buttbot or something

/obj/item/gang_loot
	icon = 'icons/obj/items/storage.dmi'
	name = "suspicious looking duffle bag"
	icon_state = "bowling_bag"
	item_state = "bowling"

	var/static/obj/gangloot_master/lootMaster = new /obj/gangloot_master()

	only_gimmicks
		New()
			var/contents[10]
			lootMaster.set_size(3,2)
			lootMaster.generate_loot(src,contents)
			..()
	guns_and_gear
		New()
			var/contents[10]
			lootMaster.set_size(3,2)
			contents[GANG_CRATE_GEAR] = 2
			contents[GANG_CRATE_GUN_WEAK] = 1
			lootMaster.generate_loot(src,contents)


	attack_self(mob/living/carbon/human/user as mob)
		for (var/obj/object in src.contents)
			object.set_loc(user.loc)
		playsound(src.loc, "sound/misc/zipper.ogg", 100,1)
		user.u_equip(src)
		qdel(src)

/obj/gangloot_instance
	var/size_x=0
	var/size_y=0
	var/offset_x=0
	var/offset_y=0
	var/value=1
	var/set_layer=0

/obj/gangloot_master
	var/list/lootSpawns
	var/max_loot_x = 4 //how many loot items can fit, horizontal
	var/loot_x_pixels = 8 //pixels per loot_x
	var/loot_x_offset = -16 //offset for spawns_x
	var/max_loot_y = 3 //samesies, vertical
	var/loot_y_pixels = 8 //pixels per loot_y
	var/loot_y_offset = -16 //offset for spawns_y

	var/list/spawners[4][4]
	New()
		populate()

	proc/set_size(var/x,var/y)
		max_loot_x = x
		max_loot_y = y
		loot_x_offset = -loot_x_pixels*(x/2)
		loot_y_offset = -loot_y_pixels*(y/2)
	//Create an instance of all our child classes,for each given size
	proc/populate()
		spawners[1][1] = new /obj/gangloot_spawner/small()
		spawners[2][1] = new /obj/gangloot_spawner/medium()
		spawners[3][1] = new /obj/gangloot_spawner/long()
		spawners[4][1] = new /obj/gangloot_spawner/xlong()
		spawners[1][2] = new /obj/gangloot_spawner/short_tall()
		spawners[2][2] = new /obj/gangloot_spawner/medium_tall()
		spawners[3][2] = new /obj/gangloot_spawner/long_tall()
		spawners[4][2] = new /obj/gangloot_spawner/xlong_tall()



	proc/generate_loot(var/target, var/list/totalValue)
		var/lootSpawns = generate_loot_layout()
		generate_loot_objects(target, lootSpawns, totalValue)

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

			var/obj/gangloot_instance/loot = new /obj/gangloot_instance
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

	proc/generate_loot_objects(var/target, var/list/lootSpawns, var/list/lootTypes)
		var/lootPot[] = lootSpawns.Copy(1,0)
		var/lootValues[0]
		var/lootValue
		var/obj/gangloot_instance/lootObject

		//add all loot types in descending order
		for (var/lootType=lootTypes.len, lootType>0, lootType--)
			if (lootTypes[lootType] != null)
				for (var/count=lootTypes[lootType], count>0, count--)
					lootValues.Add(lootType)

		//now spawn all loot
		while (lootPot.len > 0)
			if (lootValues.len > 0)
				lootValue = lootValues[1]
				lootValues -= lootValue
			else
				lootValue = 1

			lootObject = pick(lootPot)
			lootObject.value = lootValue
			lootPot -= lootObject
			var/refund = create_loot(target,lootObject)
			if (refund)
				lootValues += refund


	//Spawn loot at C
	proc/create_loot(var/C, var/obj/gangloot_instance/I)
		var/obj/gangloot_spawner/lootSpawner = spawners[I.size_x][I.size_y]
		var/refund_token = lootSpawner.create_loot(C, I)
		//del(loot)
		//del(src)
		return refund_token


/obj/gangloot_spawner
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift2-r"
	var/list/items[20][0]
	var/weight = 3		//the weighting of this spawn, default 3
	var/tier = GANG_CRATE_GIMMICK	//what tier must be selected to spawn this


	New()
		populate()


	attack_hand(mob/user as mob)
		var instance = new /obj/gangloot_instance()
		src.create_loot(get_turf(user),instance)
		del(src)

	//create loot for a given instance
	proc/create_loot(var/C, var/obj/gangloot_instance/I)
		var/obj/gangloot_spawner/weightedSpawner = pick(items[I.value])
		weightedSpawner.create_loot(C,I)

	//spawn a given item
	proc/spawn_item(loc,var/obj/gangloot_instance/I,path,off_x=0,off_y=0, rot=0, scale_x=1,scale_y=1)
		var/obj/lootObject = new path(loc)
		lootObject.transform = lootObject.transform.Scale(scale_x,scale_y)
		lootObject.transform = lootObject.transform.Turn(rot)
		lootObject.pixel_x = I.offset_x + off_x
		lootObject.pixel_y = I.offset_y + off_y
		lootObject.layer = I.set_layer + 3 // 3 seems to be default
		lootObject.AddComponent(/datum/component/transform_on_pickup)
		return lootObject

	//Prepare items & weighting
	proc/populate()
		var/list/childSpawners = typesof(src.type)
		childSpawners -= src.type
		for(var/lootSpawner in childSpawners)
			var/obj/gangloot_spawner/spawner_instance = new lootSpawner()
			for(var/x=0 to spawner_instance.weight)
				items[spawner_instance.tier] += spawner_instance

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

		nadepouch
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/grenade_pouch/mixed_standard,0,0,scale_x=0.7,scale_y=0.7)

		// HIGH VALUE:
		derringer
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/derringer,0,0,scale_x=0.8,scale_y=0.8)
				return GANG_CRATE_GEAR //give an extra gear item, since these are kinda niche
		pipebomb
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/pipebomb/bomb,0,0,scale_x=0.6,scale_y=0.8)
				return GANG_CRATE_GEAR //give an extra gear item
		ammo_nine
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,-2,0)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,2,0)
		// MID VALUE:
		robusttecs
			tier = GANG_CRATE_GEAR
			weight=2
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/implantcase/robust,off_x=-2,off_y= 2,rot=0,scale_x=0.6,scale_y=0.8)
				spawn_item(C,I,/obj/item/implantcase/robust,off_x=-2,off_y=-2,rot=0,scale_x=0.6,scale_y=0.8)
				spawn_item(C,I,/obj/item/implanter,off_x=3,off_y=0,rot=45,scale_x=0.6,scale_y=0.6)
		spraypaint
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spray_paint,0,0,scale_x=0.7,scale_y=0.6)
		flash
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/device/flash,0,0)
		flashbang
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,0,0,scale_y=0.8)
		wiretap
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/device/radio_upgrade,0,0)

		//LOW VALUE: Gimmicks
		//loose drugs
		//No money, it too wide
		//meds
		poison_loose
			weight=1
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/glass/bottle/poison,0,0)
		recharge_cell //maybe good to bribe Sec...
			weight=2
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/power_cell/self_charging/medium,0,2)
		jaffacakes
			weight=5
			create_loot(var/C,var/I)
				for(var/i=1 to 4)
					var/obj/item/cake = spawn_item(C,I,/obj/item/reagent_containers/food/snacks/cookie/jaffa,0,2*(2-i))
					cake.reagents.add_reagent("omnizine", 10)
					cake.reagents.add_reagent("msg", 1) //make em taste different
		weed
			weight=5
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,0,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,-2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,-4,scale_x = 0.8,scale_y = 0.8)
		whiteweed
			weight=3
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,0,2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,0,0,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,0,-2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,0,-4,scale_x = 0.8,scale_y = 0.8)
		omegaweed
			weight=1
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,0,2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,0,0,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,0,-2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,0,-4,scale_x = 0.8,scale_y = 0.8)

		goldzippo
			weight=3
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/device/light/zippo/gold,0,0)
		rillo
			weight=5
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo,-2,0)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo,2,0)
		juicerillo
			weight=5
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo/juicer,-2,0)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo/juicer,2,0)
		drugs
			weight=5
			create_loot(var/C,var/I)
				spawn_item(C,I,pick(drug_items),0,0)
		drugs_syringe
			weight=5
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,0,3,45,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,0,0,225,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,0,-3,45,scale_x=0.7,scale_y=0.7)


	medium //2x1
		// ASSAULT VALUE: Syndie gear
		syndie_pistol
			tier = GANG_CRATE_GUN_SYNDIE
			create_loot(var/C,var/I)
				//spawn_item(C,I,//spawn_item(C,I,/obj/item/ammo/bullets/bullet_9mm,2,0)
				spawn_item(C,I,/obj/item/gun/kinetic/pistol,0,0)
		smart_gun
			tier = GANG_CRATE_GUN_SYNDIE
			create_loot(var/C,var/I)
				//spawn_item(C,I,//spawn_item(C,I,/obj/item/ammo/bullets/bullet_22/smartgun,2,0)
				spawn_item(C,I,/obj/item/gun/kinetic/pistol/smart/mkII,0,0)
		deagle
			tier = GANG_CRATE_GUN_SYNDIE
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/deagle50cal,0,0)
				spawn_item(C,I,/obj/item/gun/kinetic/deagle,0,0)

		// HIGH VALUE:
		clock
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO,0,0,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/gun/kinetic/clock_188/boomerang,0,0)
		saa
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				//spawn_item(C,I,/obj/item/ammo/bullets/c_45,2,0)
				spawn_item(C,I,/obj/item/gun/kinetic/colt_saa,0,0,scale_x=0.7,scale_y=0.7)
		beretta
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,0,0,scale_x=0.8,scale_y=0.8)
		dagger
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/dagger/syndicate/specialist,0,0,rot=90)
		hipoint
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/hipoint,0,0, scale_x=0.8, scale_y=0.8)

		// MID VALUE:
		money_huge
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/tenthousand,0,2)
				spawn_item(C,I,/obj/item/spacecash/tenthousand,0,0)
				spawn_item(C,I,/obj/item/spacecash/tenthousand,0,-2)
		donks
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,0,3)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/high_capacity/donk_injector,0,0)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,0,-3)

		money_big
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivethousand,0,2)
				spawn_item(C,I,/obj/item/spacecash/fivethousand,0,0)
				spawn_item(C,I,/obj/item/spacecash/fivethousand,0,-2)

		robust_donuts
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robust,-1,0)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robust,1,0)
		//
		//LOW VALUE: Gimmicks
		utility_belt
			weight = 1
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,0,1)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,0,-1)
		money
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,0,2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,0,0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,0,-2)

		cigar
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar,0,3)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar,0, 0)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar,0,-3)

		goldcigar
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar/gold,0,3)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar/gold,0, 0)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar/gold,0,-3)


		drug_injectors
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,0,4)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,0,0)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,0,-4)


	long //3x1
		// HIGH VALUE: Syndie rifels, pistols with amamo
		// MID VALUE:
		//LOW VALUE: Gimmicks
		//loose drugs
		//money
		//meds
		//vuvuzela
		//HIGH VALUE Rifles, Pistols with ammo
		spes
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/spes/engineer,0,0)


		//MID VALUE Staffie-tier Pistols with ammo
		flaregun
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/flare,4,0)
				spawn_item(C,I,/obj/item/gun/kinetic/flaregun,-8,0)
		beretta
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,6,0)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,-4,0)
		hipoint
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/a38_mag,6,0)
				spawn_item(C,I,/obj/item/gun/kinetic/hipoint,-4,0, scale_x=0.8, scale_y=0.8)
		clock
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO,6,0)
				spawn_item(C,I,/obj/item/gun/kinetic/clock_188,-4,0)
		gl
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riot40mm,0,0)
		coachgun
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/coachgun,-4,0)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,5,2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,7,2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,5,-2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,7,-2)
		sawnshotty
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun/sawnoff,-4,0)

		dsabre
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/sword/discount,0,0,rot=45,scale_x=0.9,scale_y=0.9)

		//LOW VALUE
		money_big
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/thousand,-4,2)
				spawn_item(C,I,/obj/item/spacecash/thousand,4,2)
				spawn_item(C,I,/obj/item/spacecash/thousand,4,0)
				spawn_item(C,I,/obj/item/spacecash/thousand,4,-2)
				spawn_item(C,I,/obj/item/spacecash/thousand,-4,0)
				spawn_item(C,I,/obj/item/spacecash/thousand,-4,-2)
		money
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,-4,2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,4,2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,4,0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,4,-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,-4,0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,-4,-2)

	xlong //4x1://TODO, these are rare finds

		// HIGH VALUE: Long rifles


		// MID VALUE: Mid rifles & ammo


		//LOW VALUE: Gimmicks
		//loose drugs
		//money
		//meds
		//HIGH
		ak47
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/ak47,-6,0)
		huntingrifle
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/hunting_rifle,-6,0)
		riotgun
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,0)
		handguns_heavy //deagle n revolver
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/deagle,-8,0)
				spawn_item(C,I,/obj/item/gun/kinetic/colt_saa,8,0)
		//MEDIUM
		phasers
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/energy/phaser_gun,-8,0)
				spawn_item(C,I,/obj/item/gun/energy/phaser_gun,8,0)
		handguns
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,-8,4)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,-8,-4)
		alastor
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/energy/alastor,0,0,rot=45,scale_x=0.8,scale_y=0.8)
		riotgun
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,-4)

		//MID
		utility_belt
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,-8,0)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,8,0)
		//LOW
		utility_belt_cheap
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,-8,0)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,8,0)

	short_tall //1x2
		// good for tall items, like booze
		// HIGH VALUE: ....
		// Loose strong grenades

		syndieomnitool
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/tool/omnitool/syndicate,0,0)
		// MID VALUE: ...
		// 1~2 Loose grenades

		autos
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,-3,0,90)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/high_capacity/cardiac,0,0,90)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,3,0,90)
		gold
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/material_piece/gold,0,0)
		edrink
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/food/drinks/energyshake,0,1,scale_y=0.8)
				spawn_item(C,I,/obj/item/reagent_containers/food/drinks/energyshake,0,-1,scale_y=0.8)
		patches
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/item_box/medical_patches/mini_synthflesh,0,0,scale_x=0.8)

		//LOW VALUE: Gimmicks
		//Filled Autoinjectors
		//loose drugs
		//money
		bong
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,0)
				spawn_item(C,I,/obj/item/reagent_containers/glass/water_pipe,0,0)
		booze
			create_loot(var/C,var/I)
				spawn_item(C,I,pick(booze_items),0,0)
//		molotov?
//			create_loot(var/C,var/I)
//				spawn_item(C,I,/obj/item/gun/kinetic/riot40mm,0,0)


		airhorn
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/instrument/bikehorn/airhorn,0,0)
	medium_tall //2x2
		// HIGH VALUE: Syndie gear
		// mixed grenades
		// Banana grenade pouch
		//hotbox lighter and weed
		//Grenade pouches
		mac10
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/mac10,0,0,scale_x=0.8,scale_y=0.8)
		frags
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,	/obj/item/old_grenade/stinger/frag,-4,0)
				spawn_item(C,I,	/obj/item/old_grenade/stinger/frag,4,0)
		concussions
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,-6,0,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,2,0,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,-2,0,rot=180,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,6,0,rot=180,scale_x=0.8,scale_y=0.8)
		// MID VALUE: Pistols with ammo
		//Noslips
		//~4 Loose Grenades
		//Insuls
		//NVGs

		gold
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/material_piece/gold,-4,0)
				spawn_item(C,I,/obj/item/material_piece/gold,0,0)
				spawn_item(C,I,/obj/item/material_piece/gold,4,0)
		mixed_sec
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,-4,4)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,4,4)
				spawn_item(C,I,/obj/item/chem_grenade/cryo,-4,-4)
				spawn_item(C,I,/obj/item/chem_grenade/shock,4,-4)

		stingers
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/old_grenade/stinger,-4,0)
				spawn_item(C,I,/obj/item/old_grenade/stinger,4,0)
		helmet
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, /proc/filter_trait_hats)),0,-2,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, /proc/filter_trait_hats)),0,0,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, /proc/filter_trait_hats)),0,2,scale_x=0.7,scale_y=0.7)

		//LOW VALUE: Gimmicks
		//Booze
		//Medkits
		//Big pile of credits
		//gas mask
		booze
			create_loot(var/C,var/I)
				spawn_item(C,I,pick(booze_items),-2,0)
				spawn_item(C,I,pick(booze_items),0,0)
				spawn_item(C,I,pick(booze_items),2,0)

		hat
			create_loot(var/C,var/I)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),0,-2,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),0,0,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),0,2,scale_x=0.7,scale_y=0.7)
		medkits
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/firstaid/crit,0,2)
				spawn_item(C,I,/obj/item/storage/firstaid/regular,0,0)
				spawn_item(C,I,/obj/item/storage/firstaid/toxin,0,-2)
		gasmasks
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/clothing/mask/gas,0,2)
				spawn_item(C,I,/obj/item/clothing/mask/gas,0,0)
				spawn_item(C,I,/obj/item/clothing/mask/gas,0,-2)

		money
			create_loot(var/C,var/I) //REWORK
				spawn_item(C,I,/obj/item/spacecash/fivehundred,-4,4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,-4,2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,-4,0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,4,4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,4,2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,4,0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,-4,-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,-4,-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,-4,-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,4,-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,4,-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,4,-6)

		//sixpack


	long_tall //3x2
		//High value
		mac10_set
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/mac10,-6,0)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mac10,9,0)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mac10,6,0)
		coachguns
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,5,6)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,7,6)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,5,2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,7,2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,5,-2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,7,-2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,5,-6)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,7,-6)
				spawn_item(C,I,/obj/item/gun/kinetic/coachgun,-6,4)
				spawn_item(C,I,/obj/item/gun/kinetic/coachgun,-6,-4)
		berettas
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,-6,4, scale_x=0.8, scale_y=0.8)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,-6,-4, scale_x=0.8, scale_y=0.8)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,6,4)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,10,4)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,6,-4)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,10,-4)

		//Mid value
		money_huge
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/material_piece/gold,-10,0)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, 6,-4)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, 6,-2)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, 6,0)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, 6,4)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, 6,6)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, 6,8)
		espionage_belts
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/fanny/syndie,-4,0)
				spawn_item(C,I,/obj/item/storage/fanny/syndie,4,0)

		grenades
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/old_grenade/smoke,-6,-4)
				spawn_item(C,I,/obj/item/old_grenade/smoke,-6,4)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,6,-4)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,6,4)
				spawn_item(C,I,/obj/item/old_grenade/stinger,0,-4)
				spawn_item(C,I,/obj/item/old_grenade/stinger,0,4)
		money
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,4)
		hotbox
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6,-6)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6,-3)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6,0)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6,3)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6,6)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,-6)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,-3)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,0)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,3)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,6)
				spawn_item(C,I,/obj/item/device/light/zippo/syndicate,6,0)


		//Tactical Espionage Belt Storage

		//Stimulants
		//D-Sabers
		//
	xlong_tall //4x2

		//HIGH
		ak47s
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/ak47,-6,4)
				spawn_item(C,I,/obj/item/gun/kinetic/ak47,-6,-4)
		huntingrifles
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/hunting_rifle,-6,4)
				spawn_item(C,I,/obj/item/gun/kinetic/hunting_rifle,-6,-4)
		riotguns
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,-4)
		mac10s
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/mac10,-12,0)
				spawn_item(C,I,/obj/item/gun/kinetic/mac10,12,0)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mac10,2,0)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mac10,-2,0)
		//MEDIUM
		phasers
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,-4)
		handguns
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,-4)
		lasers
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,-4)
		riotgun
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,4)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,-8,-4)

		//MEDIUM

		money
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,4)

		//LOW

		money
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -8,4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 8,4)

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
