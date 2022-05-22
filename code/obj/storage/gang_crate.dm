
//for generic booze drops
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
//generic drug drops
var/drug_items = list(
	/obj/item/storage/pill_bottle/methamphetamine,
	/obj/item/storage/pill_bottle/crank,
	/obj/item/storage/pill_bottle/bathsalts,
	/obj/item/storage/pill_bottle/catdrugs,
	/obj/item/storage/pill_bottle/cyberpunk,
	/obj/item/storage/pill_bottle/epinephrine
)
//uncommon drug drops
var/strong_stims = list("omnizine","enriched_msg","triplemeth", "fliptonium","cocktail_triple","energydrink","grog")


//LOOT TIER DEFINES - To define one, currently you'll need one of these for every size of loot instance
//Number value is also spawn priority if there's no room in the crate, higher = more important
#define GANG_CRATE_GUN_WEAK 3 //guns that are *kinda* scary
#define GANG_CRATE_GEAR 2 //healing, cool stuff that stops you dying or helps you
#define GANG_CRATE_GIMMICK 1 //fun stuff, can be a bit helpful



/obj/storage/crate/gang_crate
	name = "Gang Crate"
	desc = "A small, cuboid object with a hinged top and empty interior."
	is_short = 0
	var/image/light = null
	locked = 1
	icon_state = "lootcrime"
	icon_opened = "lootcrimeopen"
	icon_closed = "lootcrime"
	soundproofing = 3
	throwforce = 50 //ouch
	can_flip_bust = 1
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT  | NO_MOUSEDROP_QOL
	var/static/obj/gangloot_master/lootMaster = new /obj/gangloot_master()


	New()
		src.light = image('icons/obj/large_storage.dmi',"lootcratelocklight")
	//	SPAWN(0)
	//		update_icon()


	update_icon()

		if(open) icon_state = icon_opened
		else icon_state = icon_closed

		if (src.locked)
			light.color = "#FF0000"
		else
			light.color = "#00FF00"
		src.UpdateOverlays(src.light, "light")

	//example_class
	//	New()
	//		lootMaster.set_size(4,3)		// Set the size for our container (Imagine an inventory grid)
	//		var/contents[10] 				// Just a list to contain the groups you'll want spawns from
	//		contents[GANG_CRATE_GEAR] = 2 	// Two of our instances should spawn items marked as GANG_CRATE_GEAR
	//		contents[GANG_CRATE_MELEE] = 5 	// Five of our loot drops should spawn items marked as GANG_CRATE_MELEE
	//		lootMaster.generate_loot(src,contents) //Generate the goodies inside!

	only_gimmicks
		New()
			var/contents[10]
			lootMaster.generate_loot(src,contents)
			lootMaster.set_size(4,3)
			..()
	some_gear
		New()
			var/contents[10]
			contents[GANG_CRATE_GEAR] = 3
			lootMaster.set_size(4,3)
			lootMaster.generate_loot(src,contents)
			..()
	only_gear
		New()
			var/contents[10]
			contents[GANG_CRATE_GEAR] = 99
			lootMaster.set_size(4,3)
			lootMaster.generate_loot(src,contents)
			..()
	guns_and_gear
		New()
			var/contents[10]
			contents[GANG_CRATE_GEAR] = 3
			contents[GANG_CRATE_GUN_WEAK] = 3
			lootMaster.set_size(4,3)
			lootMaster.generate_loot(src,contents)
			..()
	only_guns
		New()
			var/contents[10]
			contents[GANG_CRATE_GUN_WEAK] = 99
			lootMaster.set_size(4,3)
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

/obj/gangloot_instance //data class representing a single loot item
	var/size_x=0
	var/size_y=0
	var/offset_x=0
	var/offset_y=0
	var/value=1
	var/set_layer=0

/obj/gangloot_master
	var/list/lootSpawns
	var/max_loot_x = 4 //X grid size for loot items
	var/max_loot_y = 3 //Y grid size for loot items


	var/loot_x_pixels = 8
	var/loot_y_pixels = 8
	var/loot_x_offset = -16
	var/loot_y_offset = -16


	var/lootGrid[][]//boolean representation of available grid
	var/list/spawners[4][4]
	New()
		populate()

	//Set loot container grid size
	proc/set_size(var/x,var/y)
		max_loot_x = x
		max_loot_y = y
		loot_x_offset = -loot_x_pixels*(x/2)
		loot_y_offset = -loot_y_pixels*(y/2)



	//Create an instance of all the relevant spawners,for each given size, so they can initialize
	proc/populate()
		spawners[1][1] = new /obj/gangloot_spawner/small()
		spawners[2][1] = new /obj/gangloot_spawner/medium()
		spawners[3][1] = new /obj/gangloot_spawner/long()
		spawners[4][1] = new /obj/gangloot_spawner/xlong()
		spawners[1][2] = new /obj/gangloot_spawner/short_tall()
		spawners[2][2] = new /obj/gangloot_spawner/medium_tall()
		spawners[3][2] = new /obj/gangloot_spawner/long_tall()
		spawners[4][2] = new /obj/gangloot_spawner/xlong_tall()

	proc/create_loot_grid()
		lootGrid = new/list(max_loot_x,max_loot_y)

	//Generates all loot, totalValue is what types of loot may be spawned
	proc/generate_loot(var/target, var/list/totalValue)
		var/lootSpawns = generate_loot_layout()
		generate_loot_objects(target, lootSpawns, totalValue)

	//Gets the largest square space available in crate, starting from X,Y
	proc/get_largest_space(startX,startY)
		var/size = list(1,1)
		while (startX+size[1] <= max_loot_x && !lootGrid[startX+size[1]][startY])
			size[1]++
		size[2] = min(2,max_loot_y-startY) //lazy, but works since we generate items from top left to bottom right
		return size


	//Chooses the size of loot to spawn, given a max and min
	proc/choose_loot_size(largestX,largestY)
		var/size = list(1,1)
		while (size[1] < largestX && prob(60-(10*size[1]))) //weird probability calc - but we prefer smaller drops
			size[1]++
		while (size[2] < largestY && prob(40))
			size[2]++
		return size


	//Adds a randomized loot instance
	proc/add_random_loot_instance(xPos,yPos,sizeX,sizeY)

		for (var/x=1 to sizeX) //mark lootGrid as used
			for (var/y=1 to sizeY)
				lootGrid[xPos-1+x][yPos+y-1] = 1

		var/obj/gangloot_instance/loot = new /obj/gangloot_instance
		loot.size_x = sizeX
		loot.size_y = sizeY
		loot.set_layer = 3+(max_loot_y-yPos)
		loot.offset_x = loot_x_offset + loot_x_pixels*(xPos-1) + loot_x_pixels*(sizeX/2)
		loot.offset_y = loot_y_offset + loot_y_pixels*(yPos-1) + loot_y_pixels*(sizeY/2)
		return loot

	//Adds a predefined loot instance
	proc/add_loot_instance(xPos,yPos,var/obj/gangloot_instance/lootObject)
		for (var/x=1 to lootObject.size_x) //mark lootGrid as used
			for (var/y=1 to lootObject.size_y)
				lootGrid[xPos-1+x][yPos+y-1] = 1

		lootObject.set_layer = 3+(max_loot_y-yPos)
		lootObject.offset_x = loot_x_offset + loot_x_pixels*(xPos-1) + loot_x_pixels*(xPos/2)
		lootObject.offset_y = loot_y_offset + loot_y_pixels*(yPos-1) + loot_y_pixels*(yPos/2)



	//Called by generate_loot. Fills all remaining space with gangloot instances of random size
	proc/generate_loot_layout()
		create_loot_grid()
		var/cursor_x = 1
		var/cursor_y = 1
		var/done = false
		lootSpawns = list()

		while (!done)
			//scan to find how wide we can make this next item

			var/maxSize = get_largest_space(cursor_x,cursor_y)
			var/lootSize = choose_loot_size(maxSize[1],maxSize[2])

			var/obj/gangloot_instance/loot = add_random_loot_instance(cursor_x,cursor_y,lootSize[1],lootSize[2])
			lootSpawns += loot
			//move cursor to the next unoccupied space
			while (!done && lootGrid[cursor_x][cursor_y] == 1)
				cursor_x++

				if (cursor_x > max_loot_x)
					cursor_x = 1
					cursor_y++
					if (cursor_y > max_loot_y)
						done = true
		return lootSpawns

	//Called by generate_loot, Chooses and spawns all gang loot created by generate_loot_layout
	proc/generate_loot_objects(var/target, var/list/lootSpawns, var/list/lootTypes)
		var/lootPot[] = lootSpawns.Copy(1,0)
		var/lootValues[0] //all types of loot to spawn, in descending priority
		var/lootValue
		var/obj/gangloot_instance/lootObject

		//popualte lootValues
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

	//spawns loot for a given gangloot_instance
	proc/create_loot(var/C, var/obj/gangloot_instance/I)
		var/obj/gangloot_spawner/lootSpawner = spawners[I.size_x][I.size_y]
		var/refund_token = lootSpawner.create_loot(C, I)
		//del(loot)
		//del(src)
		return refund_token








///
///SPAWNS
///spawn_item(C,I,x_off,y_off,rot,scale_x,scale_y)
///C = Container
///I = The lootInstance used to create this, used to get the item value
///
///Optional positioning arguments (for laying out your goods relative to where they spawn)
///x_off/y_off = Pixel offset
///rot = Rotation in degrees
///scale_x/scale_y = Scale of icon
///

// You can uncomment this tool to build item layouts for spawning.
// Use in-hand to set the position arguments, hit an item to see what it'd look like
// Bear in mind for each space a slot takes you'll have roughly 8x8 pixels, so a 2x1 = 16x8 pixels

/obj/item/device/item_placer
	name = "Item transformation viewer"
	icon_state = "multitool"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 5.0
	w_class = W_CLASS_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	var/off_x = 0
	var/off_y = 0
	var/rot = 0
	var/scale_x = 1
	var/scale_y = 1
	desc = ""
	attack_self(var/mob/user as mob)

		off_x = input(usr, "Offset X", "OffX", off_x) as null|num
		off_y = input(usr, "Offset Y", "OffY", off_y) as null|num
		rot = input(usr, "Rotation", "Rot", rot) as null|num
		scale_x = input(usr, "Scale X", "ScaleX", scale_x) as null|num
		scale_y = input(usr, "Scale Y", "ScaleY", scale_y) as null|num


	afterattack(atom/target,mob/user as mob)
		if(istype(target, /obj))
			var/obj/object = target
			object.transform = matrix()
			object.transform = object.transform.Scale(scale_x,scale_y)
			object.transform = object.transform.Turn(rot)
			object.pixel_x = off_x
			object.pixel_y = off_y
			object.AddComponent(/datum/component/transform_on_pickup)
			boutput(world,"set values for [target] to offset=off_x=[off_x],off_y=[off_y],rot=[rot],scale_x=[scale_x],scale_y=[scale_y]")





/obj/gangloot_spawner
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift2-r"
	var/populated = false
	var/list/items[20][0] //xSize, ySize, rarity,
	var/list/size = list(1,1)
	var/weight = 3		//the weighting of this spawn, default 3
	var/tier = GANG_CRATE_GIMMICK	//what tier must be selected to spawn this


	New()

	attack_hand(mob/user as mob)
		var instance = new /obj/gangloot_instance()
		src.create_loot(get_turf(user),instance)
		del(src)

	proc/pick_weighted()


	//create loot for a given instance
	proc/create_loot(var/C, var/obj/gangloot_instance/I)
		if (!populated)
			populate()
			populated = true
		var/obj/gangloot_spawner/weightedSpawner = pick(items[I.value])
		weightedSpawner.create_loot(C,I)

	//spawn a given item with the 'transform on pickup' component
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
			items[spawner_instance.tier] += spawner_instance





	small //1x1
		size = list(1,1)
/*		nadepouch
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/grenade_pouch/mixed_standard,scale_x=0.7,scale_y=0.7)
*/
		// HIGH VALUE:
		derringer
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/derringer,scale_x=0.8,scale_y=0.8)
				return GANG_CRATE_GEAR //give an extra gear item, since these are kinda niche
		small_nades
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/old_grenade/stinger/frag,off_y=2,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/old_grenade/stinger/frag,off_y=-2,scale_x=0.8,scale_y=0.8)
	//	pipebomb //actually, let's not encourage gangs to put holes in the floor
	//		tier = GANG_CRATE_GUN_WEAK
	//		create_loot(var/C,var/I)
	//			spawn_item(C,I,/obj/item/pipebomb/bomb,scale_x=0.6,scale_y=0.8)
	//			return GANG_CRATE_GEAR //give an extra gear item



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
				spawn_item(C,I,/obj/item/spray_paint,scale_x=0.7,scale_y=0.6)
		flash
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/device/flash)
		flashbang
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,scale_y=0.8)
		wiretap
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/device/radio_upgrade)

		//LOW VALUE: Gimmicks
		poison_loose
			weight=1
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/glass/bottle/poison)
		recharge_cell //maybe good to bribe Sec...
			weight=2
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/power_cell/self_charging/medium,off_y=2)
		jaffacakes
			weight=5
			create_loot(var/C,var/I)
				for(var/i=1 to 4)
					var/obj/item/cake = spawn_item(C,I,/obj/item/reagent_containers/food/snacks/cookie/jaffa,off_y=2*(2-i))
					cake.reagents.add_reagent("omnizine", 10)
					cake.reagents.add_reagent("msg", 1) //make em taste different
		weed
			weight=5
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=-2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=-4,scale_x = 0.8,scale_y = 0.8)
		whiteweed
			weight=3
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=-2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=-4,scale_x = 0.8,scale_y = 0.8)
		omegaweed
			weight=1
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,off_y=2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,off_y=-2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,off_y=-4,scale_x = 0.8,scale_y = 0.8)

		goldzippo
			weight=3
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/device/light/zippo/gold)
		rillo
			weight=5
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo,off_x=-2)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo,off_x=2)
		juicerillo
			weight=5
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo/juicer,off_x=-2)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo/juicer,off_x=2)
		drugs
			weight=5
			create_loot(var/C,var/I)
				spawn_item(C,I,pick(drug_items))
		drugs_syringe
			weight=5
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,off_y=3,rot=45,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,rot=45,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,off_y=-3,rot=45,scale_x=0.7,scale_y=0.7)

		stims_syringe
			weight=2
			create_loot(var/C,var/I)
				for(var/i=1 to 3)
					var/obj/item/syringe = spawn_item(C,I,/obj/item/reagent_containers/syringe,off_y=6-3*i,rot=45,scale_x=0.7,scale_y=0.7)
					var/stim = pick(strong_stims)
					syringe.reagents.add_reagent(stim, 15)
					syringe.name_suffix("([syringe.reagents.reagent_list[1]])")
					syringe.UpdateName()


	medium //2x1
		size = list(2,1)
/*		syndie_pistol
			tier = GANG_CRATE_GUN_SYNDIE
			create_loot(var/C,var/I)
				//spawn_item(C,I,//spawn_item(C,I,/obj/item/ammo/bullets/bullet_9mm,2,0)
				spawn_item(C,I,/obj/item/gun/kinetic/pistol)
		smart_gun
			tier = GANG_CRATE_GUN_SYNDIE
			create_loot(var/C,var/I)
				//spawn_item(C,I,//spawn_item(C,I,/obj/item/ammo/bullets/bullet_22/smartgun,2,0)
				spawn_item(C,I,/obj/item/gun/kinetic/pistol/smart/mkII)
		deagle
			tier = GANG_CRATE_GUN_SYNDIE
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/deagle50cal)
				spawn_item(C,I,/obj/item/gun/kinetic/deagle)*/

		// HIGH VALUE:
		clock
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/gun/kinetic/clock_188/boomerang)
		saa
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				//spawn_item(C,I,/obj/item/ammo/bullets/c_45,2,0)
				spawn_item(C,I,/obj/item/gun/kinetic/colt_saa,scale_x=0.7,scale_y=0.7)
		beretta
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,scale_x=0.8,scale_y=0.8)
		dagger
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/dagger/syndicate/specialist,rot=90)
		hipoint
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/hipoint, scale_x=0.8, scale_y=0.8)

		// MID VALUE:
		money_huge
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/tenthousand,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/tenthousand,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/tenthousand,off_y=-2)
		donks
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donkpocket_w,off_x=-4)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donkpocket_w,off_x=4)
		donk_injector
			weight = 1
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_y=3)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/high_capacity/donk_injector,off_y=0)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_y=-3)

		money_big
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivethousand,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/fivethousand,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivethousand,off_y=-2)

		robust_donuts
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robust,scale_x=0.8,scale_y=0.8,rot=90,off_x=-6)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robust,scale_x=0.8,scale_y=0.8,rot=90,off_x=-2)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robusted,scale_x=0.8,scale_y=0.8,rot=90,off_x=2)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robusted,scale_x=0.8,scale_y=0.8,rot=90,off_x=6)
		//
		//LOW VALUE: Gimmicks
		utility_belt
			weight = 1
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_y=1)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_y=-1)
		money
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_y=-2)

		cigar
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar,off_y=3)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar,off_y=0)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar,off_y=-3)

		goldcigar
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar/gold,off_y=3)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar/gold,off_y=0)
				spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar/gold,off_y=-3)


		drug_injectors
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=4)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=0)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=-4)


	long //3x1
		size = list(3,1)
		// HIGH VALUE: Syndie rifels, pistols with amamo
		// MID VALUE:
		//LOW VALUE: Gimmicks
		//loose drugs
		//money
		//meds
		//vuvuzela
		//HIGH VALUE Rifles, Pistols with ammo
/*		spes
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/spes/engineer)*/


		//MID VALUE Staffie-tier Pistols with ammo
		flaregun
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/flare,off_x=4)
				spawn_item(C,I,/obj/item/gun/kinetic/flaregun,off_x=-8)
		beretta
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,off_x=6)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,off_x=-4)
		hipoint
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/a38_mag,off_x=6)
				spawn_item(C,I,/obj/item/gun/kinetic/hipoint,off_x=-4, scale_x=0.8, scale_y=0.8)
		clock
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO,off_x=6)
				spawn_item(C,I,/obj/item/gun/kinetic/clock_188,off_x=-4)
		gl
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riot40mm)
		coachgun
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/coachgun,off_x=-4)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=5,off_y=2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=7,off_y=2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=5,off_y=-2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=7,off_y=-2)
		sawnshotty
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun/sawnoff,off_x=-4)

		dsabre
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/sword/discount,rot=45,scale_x=0.9,scale_y=0.9)

		//LOW VALUE
		ammo_big

		money_big
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_x=-4,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=-2)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_y=-4,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_x=-4,off_y=-2)
		money
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-2)

	xlong //4x1://these are rare finds
		size = list(4,1)
		//MEDIUM
		phasers
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/energy/phaser_gun,off_x=-8)
				spawn_item(C,I,/obj/item/gun/energy/phaser_gun,off_x=8)
		handguns
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,off_x=-8,off_y=4)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,off_x=-8,off_y=-4)
		alastor
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/energy/alastor,rot=45,scale_x=0.8,scale_y=0.8)
		riotgun
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,off_x=-8,off_y=4)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,off_x=-8,off_y=-4)

		//MID
		utility_belt
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_x=-8)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_x=8)
		//LOW
		utility_belt_cheap
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_x=-8)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_x=8)

	short_tall //1x2
		size = list(1,2)
		// good for tall items, like booze

/*		handguns_heavy //deagle n revolver
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/deagle,off_x=-8)
				spawn_item(C,I,/obj/item/gun/kinetic/colt_saa,off_x=8)*/

		phasers
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/energy/phaser_gun,rot=90,scale_y=0.7,scale_x=0.7)

		// MID VALUE: ...
		syndieomnitool
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/tool/omnitool/syndicate)
		autos
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_x=-3,rot=90)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/high_capacity/cardiac,rot=90)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_x=3,rot=90)
		gold
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/material_piece/gold)
		edrink
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/food/drinks/energyshake,off_x=1,scale_y=0.8)
				spawn_item(C,I,/obj/item/reagent_containers/food/drinks/energyshake,off_x=-1,scale_y=0.8)
		patches
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/item_box/medical_patches/mini_synthflesh,scale_x=0.8)


		//LOW VALUE

		bong
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable)
				spawn_item(C,I,/obj/item/reagent_containers/glass/water_pipe)
		booze
			create_loot(var/C,var/I)
				spawn_item(C,I,pick(booze_items))
		airhorn
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/instrument/bikehorn/airhorn)

	medium_tall //2x2
		size = list(2,2)

		// HIGH VALUE:
		mac10
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/mac10,scale_x=0.8,scale_y=0.8)
		frags
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,	/obj/item/old_grenade/stinger/frag,off_x=-4)
				spawn_item(C,I,	/obj/item/old_grenade/stinger/frag,off_x=4)
		concussions
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=-6,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=2,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=-2,rot=180,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=6,rot=180,scale_x=0.8,scale_y=0.8)
		// MID VALUE: Pistols with ammo
		//Noslips
		//~4 Loose Grenades
		//Insuls
		//NVGs

		gold
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/material_piece/gold,off_x=-4)
				spawn_item(C,I,/obj/item/material_piece/gold)
				spawn_item(C,I,/obj/item/material_piece/gold,off_x=4)
		mixed_sec
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=-4,off_y=4)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=4,off_y=4)
				spawn_item(C,I,/obj/item/chem_grenade/cryo,off_x=-4,off_y=-4)
				spawn_item(C,I,/obj/item/chem_grenade/shock,off_x=4,off_y=-4)

		stingers
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/old_grenade/stinger,off_x=-4)
				spawn_item(C,I,/obj/item/old_grenade/stinger,off_x=4)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_y=-6,rot=90)
		helmet
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, /proc/filter_trait_hats)),off_y=-2,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, /proc/filter_trait_hats)),off_y=0,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, /proc/filter_trait_hats)),off_y=2,scale_x=0.7,scale_y=0.7)

		//LOW VALUE: Gimmicks
		//Booze
		//Medkits
		//Big pile of credits
		//gas mask
		booze
			create_loot(var/C,var/I)
				spawn_item(C,I,pick(booze_items),off_x=-2)
				spawn_item(C,I,pick(booze_items))
				spawn_item(C,I,pick(booze_items),off_x=2)

		hat
			create_loot(var/C,var/I)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),off_y=-2,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),off_y=0,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),off_y=2,scale_x=0.7,scale_y=0.7)
		medkits
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/firstaid/crit,off_y=2)
				spawn_item(C,I,/obj/item/storage/firstaid/regular,off_y=0)
				spawn_item(C,I,/obj/item/storage/firstaid/toxin,off_y=-2)
		gasmasks
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=2)
				spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=0)
				spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=-2)

		money
			create_loot(var/C,var/I) //REWORK
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-6)

		//sixpack


	long_tall //3x2
		size = list(3,2)
		//High value
		mac10_set
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/mac10,off_x=-6)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mac10,off_x=9)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mac10,off_x=6)
		coachguns
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=5,off_y=6)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=7,off_y=6)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=5,off_y=2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=7,off_y=2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=5,off_y=-2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=7,off_y=-2)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=5,off_y=-6)
				spawn_item(C,I,/obj/item/ammo/bullets/tengauge/loose,off_x=7,off_y=-6)
				spawn_item(C,I,/obj/item/gun/kinetic/coachgun,off_x=-6,off_y=4)
				spawn_item(C,I,/obj/item/gun/kinetic/coachgun,off_x=-6,off_y=-4)
		berettas
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,off_x=-6,off_y=4, scale_x=0.8, scale_y=0.8)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,off_x=-6,off_y=-4, scale_x=0.8, scale_y=0.8)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,off_x=6,off_y=4)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,off_x=10,off_y=4)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,off_x=6,off_y=-4)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,off_x=10,off_y=-4)

		//Mid value
		money_huge
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/material_piece/gold,off_x=-10,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, off_x=6,off_y=-4)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, off_x=6,off_y=-2)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, off_x=6,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, off_x=6,off_y=4)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, off_x=6,off_y=6)
				spawn_item(C,I,/obj/item/spacecash/fivethousand, off_x=6,off_y=8)
		espionage_belts
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/fanny/syndie,off_x=-4,off_y=0)
				spawn_item(C,I,/obj/item/storage/fanny/syndie,off_x=4,off_y=0)

		grenades
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/old_grenade/smoke,-6,-4)
				spawn_item(C,I,/obj/item/old_grenade/smoke,-6,4)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,6,-4)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,6,4)
				spawn_item(C,I,/obj/item/old_grenade/stinger,-4)
				spawn_item(C,I,/obj/item/old_grenade/stinger,4)
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
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-3)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,3)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,6)
				spawn_item(C,I,/obj/item/device/light/zippo/syndicate,6,0)


		//Tactical Espionage Belt Storage

		//Stimulants
		//D-Sabers
		//
	xlong_tall //4x2, these are very rare and will take up the majority of a crate.
		size = list(4,2)

/*		ak47s
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/ak47,off_x=-6)
		huntingrifles
			tier = GANG_CRATE_GUN_STRONG
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/hunting_rifle,off_x=-6,off_y=4)
				spawn_item(C,I,/obj/item/gun/kinetic/hunting_rifle,off_x=-6,off_y=-4)*/


		mac10s
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/mac10,off_x=-12)
				spawn_item(C,I,/obj/item/gun/kinetic/mac10,off_x=12)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mac10,off_x=2)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mac10,off_x=-2)
		riotgun
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,off_x=-8,off_y=4)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,off_x=-8,off_y=-4)
		tac_beretta
			tier = GANG_CRATE_GUN_WEAK
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,off_x=-8,off_y=4,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/gun/kinetic/beretta,off_x=-8,off_y=-2,rot=180,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,off_x=4,off_y=4)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,off_x=8,off_y=4)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,off_x=4,off_y=-4)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_NATO/mag_fifteen,off_x=8,off_y=-4)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=12,off_y=4,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=12,off_y=-4,scale_x=0.8,scale_y=0.8)


		//MEDIUM

		money
			tier = GANG_CRATE_GEAR
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=8,off_y=-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=8,off_y=-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=8,off_y=-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=8,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=8,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=8,off_y=4)

		//LOW

		money
			create_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=-8,off_y=4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=8,off_y=-6)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=8,off_y=-4)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=8,off_y=-2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=8,off_y=0)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_x=8,off_y=2)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, off_xs=8,off_y=4)

