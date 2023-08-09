
//LOOT TIER DEFINES - To define one, currently there needs to be an entry for every size of loot spawn
//Numerical value is also spawn priority in case the crate fills up

#define GANG_CRATE_GUN_WEAK 3 //guns, but sane for gangs
#define GANG_CRATE_GEAR 2 //healing, cool stuff that stops you dying or helps you
#define GANG_CRATE_GIMMICK 1 //fun stuff, can be helpful



/obj/storage/crate/gang_crate
	name = "Gang Crate"
	desc = "A small, cuboid object with a hinged top and empty interior."
	is_short = 1
	var/image/light = null
	locked = 1
	icon_state = "lootcrime"
	icon_opened = "lootcrimeopen"
	icon_closed = "lootcrime"
	can_flip_bust = 0
	anchored = 1
	var/datum/loot_generator/lootMaster

	only_gimmicks
		New()
			lootMaster =  new /datum/loot_generator(4,2)
			lootMaster.fill_remaining(src.loc, GANG_CRATE_GIMMICK)
			..()
		unlocked
			New()
				..()
				anchored = 0
				locked = 0
				src.light = image('icons/obj/large_storage.dmi',"lootcratelocklight")
				UpdateIcon()

	only_guns
		New()
			lootMaster =  new /datum/loot_generator(4,2)
			lootMaster.fill_remaining(src.loc, GANG_CRATE_GUN_WEAK)
			..()
	only_gear
		New()
			lootMaster =  new /datum/loot_generator(4,2)
			lootMaster.fill_remaining(src.loc, GANG_CRATE_GUN_WEAK)
			..()
	gear_and_gimmicks
		New()
			..()
	guns_and_gear
		New()
			lootMaster.add_random_loot_instance(src.loc, 1,1,1,1, GANG_CRATE_GUN_WEAK, FALSE)
			..()
		unlocked
			New()
				..()
				anchored = 0
				locked = 0
				src.light = image('icons/obj/large_storage.dmi',"lootcratelocklight")
				UpdateIcon()

	New()
		..()
		src.light = image('icons/obj/large_storage.dmi',"lootcratelocklight")
		SPAWN(60 SECONDS)
			anchored = 0
			UpdateIcon()
	ex_act()
		return
	proc/attempt_open(mob/user as mob)
		for (var/obj/ganglocker/locker in range(1,src))
			if (locker.gang == user.get_gang() && locked == 1)
				locked = 0
				UpdateIcon()
				locker.gang.add_points(500)
				user.get_gang().broadcast_to_gang("[user.name] just opened a gang crate! Keep what's inside, and take 500 points.",locker.gang)
				return TRUE
		return FALSE

	attackby(obj/item/I as obj, mob/user as mob)
		if(src.anchored)
			if(user.get_gang() != null)
				user.show_text("This thing's locked into place! You better defend it for a bit.", "red")
			else
				user.show_text("This is locked into place and has weird gang signs all over it! You should probably move away.", "red")
		else if(src.locked)
			if(user.get_gang() != null)
				if (!attempt_open(user))
					user.show_text("Access Denied. Bring to a gang locker to unlock it!", "red")
					return
			else
				user.show_text("This has weird gang signs all over it! You should probably leave it alone.", "red")
				return
		..()


	update_icon()
		if(open)
			icon_state = icon_opened
		else
			icon_state = icon_closed

		if (src.anchored)
			light.color = "#FF0000"
		else if (src.locked)
			light.color = "#FF9900"
		else
			light.color = "#00FF00"
		src.UpdateOverlays(src.light, "light")


/obj/item/gang_loot
	icon = 'icons/obj/items/storage.dmi'
	name = "suspicious looking duffle bag"
	icon_state = "gang_dufflebag"
	item_state = "bowling"
	var/hidden = 1
	level = 1


	only_gimmicks
		New()
			..()
	gear_and_gimmicks
		New()

	guns_and_gear
		New()

	proc/update()
		var/turf/T = src.loc
		if (T && hidden) hide(T.intact && !istype(T,/turf/space))

	hide(var/intact)
		invisibility = intact ? INVIS_ALWAYS : INVIS_NONE	// hide if floor is intact
		if (!invisibility)
			hidden = 0
			level = 3
		else
			hidden = 1
			level = 1
		UpdateIcon()


	attack_self(mob/living/carbon/human/user as mob)
		for (var/obj/object in src.contents)
			object.set_loc(user.loc)
		playsound(src.loc, "sound/misc/zipper.ogg", 100,1)
		user.u_equip(src)
		qdel(src)




/datum/loot_grid //data class representing a grid of goodies
	var/list/grid[][]
	var/size_x
	var/size_y

	New(xSize, ySize)
		set_size(xSize,ySize)

	proc/set_size(xSize,ySize)
		size_x = xSize
		size_y = ySize
		grid = new/list(size_x,size_y)

	proc/get_random_empty_space()
		var/pos = new/list(2)
		pos[1] = rand(1,size_x)
		pos[2] = rand(1,size_y)
		for (var/y_iter=1, y_iter<=size_y)
			pos[2] = (pos[2]+1)%size_y
			for (var/x_iter=1, x_iter<=size_x)
				pos[1] = (pos[1]+1)%size_x
				if (!grid[pos[1]][pos[2]])
					return pos
		return null

	proc/get_next_empty_space(pos_x = 1, pos_y = 1)
		var/pos = new/list(2)
		for (var/y_iter=pos_y to size_y)
			for (var/x_iter=pos_x to size_x)
				if (!grid[x_iter][y_iter])
					pos[1] = x_iter
					pos[2] = y_iter
					return pos
			pos_x = 1
		return FALSE


	proc/mark_used(xPos,yPos,xSize,ySize)
		for (var/x=1 to xSize)
			for (var/y=1 to ySize)
				grid[xPos-1+x][yPos+y-1] = 1

	proc/is_empty(x,y)
		return grid[x][y]

	proc/get_largest_space(startX,startY)
		var/size = new/list(2)
		size[1] = 1
		size[2] = 1
		while (startX+size[1]-1 < size_x && !grid[startX+size[1]][startY])
			size[1]++

		var/nextYOccupied = FALSE
		while (!nextYOccupied)
			if ((startY+size[2]) <= size_y) // if we aren't at the bottom row of loot already
				for (var/x=1 to size[1]) //check every X position on the next row down
					if (grid[startX+x-1][startY+size[2]-1])
						nextYOccupied = TRUE
						break

				size[2]++
			else
				nextYOccupied = TRUE

		return size


///
///SPAWNS
///spawn_item(C,I,off_x,off_y,rot,scale_x,scale_y,layer_offset)
///C = Container
///I = The lootInstance used to create this, telling the spawner its' position in the crate
///
///Optional positioning arguments (for laying out your goods relative to where they spawn)
///off_x/off_y = Offset of the icon (in pixels)
///rot = Rotation of the icon
///scale_x/scale_y = Scale of icon
///layer_offset = overall offset of layers


// You can uncomment this tool to help build item layouts for spawning.
// Use in-hand to set the position arguments, hit an item to see what it'd look like
// Bear in mind each x&y coordinate is roughly 8x8 pixels, so a 2x1 item = 16x8 pixels

/obj/item/device/item_placer
	name = "Item transformation viewer"
	icon_state = "multitool"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	w_class = W_CLASS_SMALL
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



/datum/loot_generator
	var/list/lootInstances
	var/static/loot_x_pixels = 8 //how many pixels each grid square takes up
	var/static/loot_y_pixels = 8
	var/static/populated = FALSE
	var/static/list/spawners[4][2]
	var/static/list/totalWeights[0][0] //associative list, spawners to their childrens' total weight
	var/static/list/weights[0][0] //associative list, spawners to their childrens individual weight
	var/datum/loot_grid/lootGrid


	// Public methods for generating loot

	//spawn a previously-defined loot object
	//set 'invisible' to true to make this not take up the loot grid
	proc/place_loot_instance(loc, x,y,obj/randomloot_spawner/loot, invisible)
		if (!invisible)
			lootGrid.mark_used(x,y,loot.xSize[1],loot.ySize[2])
		add_loot_instance(loc,loot,x,y)

	//Add multiple random loot objects
	proc/add_random_loot(loc,tier, quantity=1, invisible=FALSE)
		for (var/i=1 to quantity)
			var/pos = lootGrid.get_random_empty_space()
			if (!pos) break
			if (!invisible)
				lootGrid.mark_used(pos[1],pos[2],lootSize[1],lootSize[2])
			var/maxSize = lootGrid.get_largest_space(pos[1],pos[2])
			var/lootSize = choose_random_loot_size(maxSize[1],maxSize[2])
			var/obj/randomloot_spawner/loot = add_random_loot_instance(loc, pos[1],pos[2],lootSize[1],lootSize[2],tier, invisible)
			add_loot_instance(loc,loot,pos[1],pos[2])

	//Place a random object at a specific position
	proc/place_random_loot(loc,x,y,tier, invisible=FALSE)
		var/maxSize = lootGrid.get_largest_space(x,y)
		var/lootSize = choose_random_loot_size(maxSize[1],maxSize[2])
		var/obj/randomloot_spawner/loot = add_random_loot_instance(loc, x,y,lootSize[1],lootSize[2],tier, invisible)
		add_loot_instance(loc,loot,x,y)

	//Place a random object of some size at a specific position
	proc/place_random_loot(loc,x,y,xSize,ySize, tier, invisible=FALSE)
		var/obj/randomloot_spawner/loot = add_random_loot_instance(loc,x,y,xSize,ySize,tier, invisible)
		add_loot_instance(loc,loot,x,y)

	//Fills all remaining space with instances of random size
	proc/fill_remaining(loc, tier)
		var/done = FALSE
		var/spawnedLootInstances = list()
		var/pos = new/list(2)
		pos[1] = 1
		pos[2] = 1
		while (!done)
			pos = lootGrid.get_next_empty_space(pos[1],pos[2])
			if (!pos) break

			var/maxSize = lootGrid.get_largest_space(pos[1],pos[2])
			boutput(world, "maxsize is [maxSize[1]],[maxSize[2]].")
			var/lootSize = choose_random_loot_size(maxSize[1],maxSize[2])

			var/obj/randomloot_spawner/loot = add_random_loot_instance(loc, pos[1],pos[2],lootSize[1],lootSize[2],tier)
			lootGrid.mark_used(pos[1],pos[2],lootSize[1],lootSize[2])
			sleep(10)

		return spawnedLootInstances


	// INTERNAL LOOT GENERATION


	New(xSize, ySize)
		lootGrid = new/datum/loot_grid(xSize, ySize)

	proc/populate()
		//setting these manually to map class names to sizes
		//this avoids having to instantiate them just to read their xSize & ySize
		spawners[1][1] = /obj/randomloot_spawner/short
		spawners[2][1] = /obj/randomloot_spawner/medium
		spawners[3][1] = /obj/randomloot_spawner/long
		spawners[4][1] = /obj/randomloot_spawner/xlong
		spawners[1][2] = /obj/randomloot_spawner/short_tall
		spawners[2][2] = /obj/randomloot_spawner/medium_tall
		spawners[3][2] = /obj/randomloot_spawner/long_tall
		spawners[4][2] = /obj/randomloot_spawner/xlong_tall

		for(var/spawnersByLength in spawners)
			for(var/spawner in spawnersByLength)
				totalWeights[spawner] = new/list(0)
				weights[spawner] = new/list(0)
				var/childtypes = concrete_typesof(spawner)

				for(var/childType in childtypes)
					var/obj/randomloot_spawner/item = new childType()
					if (totalWeights[spawner].len < item.tier)
						totalWeights[spawner].len = item.tier
						weights[spawner].len = item.tier

					if (!totalWeights[spawner][item.tier])
						totalWeights[spawner][item.tier] = 0
						weights[spawner][item.tier] = new/list(0)

					totalWeights[spawner][item.tier] += item.weight
					weights[spawner][item.tier][childType] = item.weight


	proc/pick_weighted_option(xSize, ySize, var/chosenTier)
		populate()
		var/spawnerBase = spawners[xSize][ySize]
		var/roll = rand(1, totalWeights[spawnerBase][chosenTier])
		for (var/item in weights[spawnerBase][chosenTier])
			roll = roll - weights[spawnerBase][chosenTier][item]
			if (roll <= 0)
				return item

	//get an empty grid square, then choose a random size loot spawn
	proc/get_random_loot_position()
		var/pos = lootGrid.get_random_empty_space()
		var/maxSize = lootGrid.get_largest_space(pos[1],pos[2])
		var/chosenSize = choose_random_loot_size(maxSize[1],maxSize[2])
		var/result = pos + chosenSize
		return result


	//Chooses the size of loot to spawn, given a max and min.
	proc/choose_random_loot_size(largestX,largestY)
		var/size = list(1,1)
		while (spawners.len >= size[1] +1 && size[1] < largestX && prob(80-(20*size[1]))) //make each progressive increase less likely
			boutput(world, "x increased!")
			size[1]++
		while (spawners[size[1]].len >= size[2] +1  && size[2] < largestY && prob(20))
			boutput(world, "y increased!")
			size[2]++
		return size

	proc/add_loot_instance(loc,obj/randomloot_spawner/instance,xPos,yPos)

		var/datum/loot_spawner_info/info = new /datum/loot_spawner_info()
		info.position_x = loot_x_pixels*(xPos+instance.sizeX/2-1) -(loot_x_pixels*lootGrid.size_x/2)
		info.position_y= loot_y_pixels *(yPos+instance.sizeY/2-1)-(loot_y_pixels*lootGrid.size_y/2)
		info.layer = 3+(lootGrid.size_y-yPos)

		var/obj/randomloot_spawner/spawner = new chosenType(loc)
		spawner.handle_loot(loc,info)

	proc/add_random_loot_instance(loc, xPos,yPos,sizeX,sizeY, tier, invisible = FALSE)
		lootGrid.mark_used(xPos,yPos,sizeX,sizeY)
		var/chosenType = pick_weighted_option(sizeX,sizeY,tier)
		add_loot_instance(loc,chosenType,xPos,yPos)




/datum/loot_spawner_info //information to be passed to spawners when they create loot
	var/position_x = 0
	var/position_y = 0
	var/layer    = 0
	var/tags[] //associative list for passing flags to spawners, for conditional spawns



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
//uncommon drugs, for placement in syringes
var/strong_stims = list("omnizine","enriched_msg","triplemeth", "fliptonium","cocktail_triple","energydrink","grog")


//there is probably a better way to do this
ABSTRACT_TYPE(/obj/randomloot_spawner)
ABSTRACT_TYPE(/obj/randomloot_spawner/short)
ABSTRACT_TYPE(/obj/randomloot_spawner/medium)
ABSTRACT_TYPE(/obj/randomloot_spawner/long)
ABSTRACT_TYPE(/obj/randomloot_spawner/xlong)
ABSTRACT_TYPE(/obj/randomloot_spawner/short_tall)
ABSTRACT_TYPE(/obj/randomloot_spawner/medium_tall)
ABSTRACT_TYPE(/obj/randomloot_spawner/long_tall)
ABSTRACT_TYPE(/obj/randomloot_spawner/xlong_tall)

/obj/randomloot_spawner
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift2-r"
	var/weight = 3		//the weighting of this spawn, default 3
	var/tier = GANG_CRATE_GIMMICK	//what tier must be selected to spawn this

	var/xSize
	var/ySize

	//for testing, or if you want to spawn these
	attack_hand(mob/user as mob)
		var/I = new/datum/loot_spawner_info()
		src.spawn_loot(get_turf(user),I)
		qdel(src)

	//spawn a given item with the 'transform on pickup' component
	proc/spawn_item(loc,datum/loot_spawner_info/I,path,off_x=0,off_y=0, rot=0, scale_x=1,scale_y=1, layer_offset=0)
		boutput(world,"spawning at [off_x] + [I.position_x],[off_y] + [I.position_y]")
		var/obj/lootObject = new path(loc)
		lootObject.transform = lootObject.transform.Scale(scale_x,scale_y)
		lootObject.transform = lootObject.transform.Turn(rot)
		lootObject.pixel_x = I.position_x + off_x
		lootObject.pixel_y = I.position_y + off_y
		lootObject.layer = I.layer + layer_offset
		lootObject.AddComponent(/datum/component/transform_on_pickup)
		return lootObject

	proc/handle_loot(loc,datum/loot_spawner_info/I)
		spawn_loot(loc,I)
		qdel(src)

	proc/spawn_loot(loc,datum/loot_spawner_info/I)

	short //1x1
		xSize = 1
		ySize = 1
		// HIGH VALUE:
		derringer
			weight = 2
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/derringer,rot=90,scale_x=0.8,scale_y=0.8)
		makarov
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/makarov,scale_x=0.725,scale_y=0.725)
		microphaser
			weight = 3
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/energy/phaser_small,rot=90,scale_x=0.8,scale_y=0.725)
		small_nades
			weight=2
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/old_grenade/stinger/frag,off_y=2,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,/obj/item/old_grenade/stinger/frag,off_y=-2,scale_x=0.7,scale_y=0.7)
		small_stingers
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/old_grenade/stinger,off_y=2,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,/obj/item/old_grenade/stinger,off_y=-2,scale_x=0.7,scale_y=0.7)

		// MID VALUE:
		spraypaint
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spray_paint,scale_x=0.7,scale_y=0.6)
		flash
			weight = 2
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/device/flash,off_x=2,off_y=0,rot=0,scale_x=0.6,scale_y=0.6)
				spawn_item(C,I,/obj/item/device/flash,off_x=-2,off_y=0,rot=0,scale_x=0.6,scale_y=0.6)
		flashbang
			weight = 4
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_y=2,scale_y=0.8)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_y=-2,scale_y=0.8)
		wiretap
			weight = 2
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/device/radio_upgrade)


		//LOW VALUE: Gimmicks
		poison_loose
			weight=1
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/glass/bottle/poison)
		recharge_cell //maybe good to bribe Sec...
			weight=2
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/power_cell/self_charging/medium,off_y=2)
		jaffacakes
			tier = GANG_CRATE_GIMMICK
			weight=5
			spawn_loot(var/C,var/I)
				for(var/i=1 to 4)
					var/obj/item/cake = spawn_item(C,I,/obj/item/reagent_containers/food/snacks/cookie/jaffa,off_y=2*(2-i),scale_x=0.85,scale_y=0.85)
					cake.reagents.add_reagent("omnizine", 10)
					cake.reagents.add_reagent("msg", 1) //make em taste different
		weed
			weight=5
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=-2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=-4,scale_x = 0.8,scale_y = 0.8)
		whiteweed
			weight=3
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=-2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=-4,scale_x = 0.8,scale_y = 0.8)
		omegaweed
			weight=1
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,off_y=2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,off_y=-2,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,off_y=-4,scale_x = 0.8,scale_y = 0.8)

		goldzippo
			weight=3
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/device/light/zippo/gold,scale_x=0.85,scale_y=0.85)
		rillo
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo,off_x=-2)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo,off_x=2)
		juicerillo
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo/juicer,off_x=-2)
				spawn_item(C,I,/obj/item/cigpacket/cigarillo/juicer,off_x=2)
		drugs
			spawn_loot(var/C,var/I)
				spawn_item(C,I,pick(drug_items))
		drugs_syringe
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,off_y=3,rot=45,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,rot=45,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,off_y=-3,rot=45,scale_x=0.7,scale_y=0.7)

		stims_syringe
			weight=2
			spawn_loot(var/C,var/I)
				for(var/i=1 to 3)
					var/obj/item/syringe = spawn_item(C,I,/obj/item/reagent_containers/syringe,off_y=6-3*i,rot=45,scale_x=0.7,scale_y=0.7)
					var/stim = pick(strong_stims)
					syringe.reagents.add_reagent(stim, 15)
					syringe.name_suffix("([syringe.reagents.reagent_list[1]])")
					syringe.UpdateName()


	medium //2x1
		xSize = 2
		ySize = 1
		// HIGH VALUE:
		lopoint
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/lopoint,scale_x=0.75,scale_y=0.75)
		saa
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/single_action/colt_saa,scale_x=0.7,scale_y=0.7)
		dagger
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/dagger/syndicate/specialist,rot=45,scale_x=0.55,scale_y=0.55)

		// MID VALUE:
		donks
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donkpocket_w,off_x=-4)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donkpocket_w,off_x=4)
		amphetamines
			weight = 3
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_y=3)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_y=0)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_y=-3)

		robust_donuts
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robust,scale_x=0.8,scale_y=0.8,rot=90,off_x=-6)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robust,scale_x=0.8,scale_y=0.8,rot=90,off_x=-2)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robusted,scale_x=0.8,scale_y=0.8,rot=90,off_x=2)
				spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robusted,scale_x=0.8,scale_y=0.8,rot=90,off_x=6)
		//
		//LOW VALUE: Gimmicks
		utility_belt
			weight = 1
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_y=1)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_y=-1)
		money
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_y=2,scale_x=0.825,scale_y=0.825, layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_y=0,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
		moneythousand
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_y=0,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)

		cigar
			spawn_loot(var/C,var/I)
				for(var/i=1 to 3)
					var/obj/item/cig = spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar,off_y=3*(2-i))
					cig.reagents.add_reagent("salicylic_acid", 5)
					cig.reagents.add_reagent("CBD", 5)

		goldcigar
			spawn_loot(var/C,var/I)
				for(var/i=1 to 3)
					var/obj/item/cig = spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar/gold,off_y=3*(2-i))
					cig.reagents.add_reagent("salicylic_acid", 5)
					cig.reagents.add_reagent("omnizine", 5)

		drug_injectors
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=4)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=0)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=-4)


	long //3x1
		xSize = 3
		ySize = 1
		flaregun
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/ammo/bullets/flare,off_x=4,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/gun/kinetic/flaregun,off_x=-8,scale_x=0.75,scale_x=0.75)
		striker
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/striker,off_x=-8,scale_x=0.75,scale_x=0.75)
		gl
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riot40mm,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=5,off_y=-4,rot=90,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=8,off_y=-4,rot=90,scale_x=0.8,scale_y=0.8)
		dsabre
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/sword/discount,rot=45,scale_x=0.9,scale_y=0.9)

		//GEAR
		glasses
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/clothing/glasses/sunglasses,off_y=-2)
				spawn_item(C,I,/obj/item/clothing/glasses/sunglasses,off_y=2)

		quickhacks
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/tool/quickhack,rot=90)



		//LOW VALUE
		money_big
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=0,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_x=4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_x=-4,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_x=-4,off_y=0,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/thousand,off_x=-4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
		money
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=2,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=0,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)

	xlong //4x1://these are rare finds
		xSize = 4
		ySize = 1
		//MEDIUM
		phasers
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/energy/phaser_gun,off_x=-8,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/gun/energy/phaser_gun,off_x=8,scale_x=0.8,scale_y=0.8)
		riotgun
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,off_x=-8,off_y=0)
		m16
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/m16,off_x=-8,off_y=0,scale_x=0.7,scale_y=0.7)
		//MID
		utility_belt
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_x=-8)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_x=8)
		//LOW
		utility_belt_cheap
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_x=-8)
				spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_x=8)

	short_tall //1x2
		xSize = 1
		ySize = 2
		// good for tall items, like booze
		phasers
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/energy/phaser_gun,rot=90,scale_y=0.8,scale_x=0.8)

		// MID VALUE: ...
		robusttecs
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/implantcase/robust,off_x=-2,off_y= 2,rot=0,scale_x=0.6,scale_y=0.8)
				spawn_item(C,I,/obj/item/implantcase/robust,off_x=-2,off_y=-2,rot=0,scale_x=0.6,scale_y=0.8)
				spawn_item(C,I,/obj/item/implanter,off_x=3,off_y=0,rot=45,scale_x=0.6,scale_y=0.6)
		syndieomnitool
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/tool/omnitool/syndicate,0,0,scale_y=0.8)
		autos
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_x=-3,rot=90)
				var/obj/item/reagent_containers/emergency_injector/inj = spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/high_capacity/cardiac,rot=90)
				inj.amount_per_transfer_from_this = 10
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_x=3,rot=90)
		edrink
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/reagent_containers/food/drinks/energyshake,off_x=1,scale_y=0.8)
				spawn_item(C,I,/obj/item/reagent_containers/food/drinks/energyshake,off_x=-1,scale_y=0.8)
		patches
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/item_box/medical_patches/mini_synthflesh,scale_x=0.8)


		//LOW VALUE

		bong
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/reagent_containers/glass/water_pipe,scale_x=0.8,scale_y=0.8)
		booze
			weight=6
			spawn_loot(var/C,var/I)
				spawn_item(C,I,pick(booze_items),off_x=-2,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,pick(booze_items),scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,pick(booze_items),off_x=2,scale_x=0.825,scale_y=0.825)
		airhorn
			weight=1
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/instrument/bikehorn/airhorn,scale_x=0.825,scale_y=0.825)


		airhorn
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/instrument/bikehorn/airhorn)

	medium_tall //2x2
		xSize = 2
		ySize = 2
		// HIGH VALUE:
		uzi
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/uzi,scale_x=0.75,scale_y=0.75)
		frags
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,	/obj/item/old_grenade/stinger/frag,off_x=-4,off_y=5,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,	/obj/item/old_grenade/stinger/frag,off_x=4, off_y=5,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,	/obj/item/mine/stun,off_x=-4, off_y=-5,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,	/obj/item/mine/stun,off_x=4, off_y=-5,scale_x=0.8,scale_y=0.8)
		makarov
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/makarov,off_x=-4,rot=90,scale_x=0.725,scale_y=0.725)
				spawn_item(C,I,/obj/item/ammo/bullets/nine_mm_soviet,off_x=4)



		// MID VALUE: Pistols with ammo
		//Noslips
		//~4 Loose Grenades
		//Insuls
		//NVGs

		concussions
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=-6,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=2,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=-2,rot=180,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=6,rot=180,scale_x=0.8,scale_y=0.8)
		gold
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/stamped_bullion,off_x=-4)
				spawn_item(C,I,/obj/item/stamped_bullion)
				spawn_item(C,I,/obj/item/stamped_bullion,off_x=4)
		mixed_sec
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=-4,off_y=4)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=4,off_y=4)
				spawn_item(C,I,/obj/item/chem_grenade/cryo,off_x=-4,off_y=-4,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/chem_grenade/shock,off_x=4,off_y=-4,scale_x=0.8,scale_y=0.8)
		helmet
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				var/helmet = pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, /proc/filter_trait_hats))
				spawn_item(C,I,helmet,off_y=-2,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,helmet,off_y=0,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,helmet,off_y=2,scale_x=0.7,scale_y=0.7)

		galoshes
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/clothing/shoes/galoshes,off_y=2)
				spawn_item(C,I,/obj/item/clothing/shoes/galoshes,off_y=-2)

		//LOW VALUE: Gimmicks

		booze
			spawn_loot(var/C,var/I)
				spawn_item(C,I,pick(booze_items),off_x=-2)
				spawn_item(C,I,pick(booze_items))
				spawn_item(C,I,pick(booze_items),off_x=2)

		hat
			spawn_loot(var/C,var/I)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),off_y=-2,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),off_y=0,scale_x=0.7,scale_y=0.7)
				spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, /proc/filter_trait_hats)),off_y=2,scale_x=0.7,scale_y=0.7)
		medkits
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/firstaid/crit,off_y=2)
				spawn_item(C,I,/obj/item/storage/firstaid/regular,off_y=0)
				spawn_item(C,I,/obj/item/storage/firstaid/toxin,off_y=-2)
		gasmasks
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=2)
				spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=0)
				spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=-2)

		money
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=2,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=2,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-4,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=-4,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-4,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/fivehundred,off_x=4,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)

		//sixpack


	long_tall //3x2
		xSize = 3
		ySize = 2
		//Guns
		flintlock //pahahahha
			weight = 3
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/single_action/flintlock,off_x=-3,off_y=-3,scale_x=0.8,scale_y=0.8)
				var/obj/item/ammo/bullets/A = spawn_item(C,I,/obj/item/ammo/bullets/flintlock,rot=-135,off_x=3,off_y=2,scale_x=0.8,scale_y=0.8)
				A.amount = 3
				A.amount_left = 3

		sawnoff
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/sawnoff,off_y=3,scale_x=0.8,scale_y=0.8)
				var/obj/item/ammo/bullets/A = spawn_item(C,I,/obj/item/ammo/bullets/abg,off_x=3,off_y=-2,scale_x=0.8,scale_y=0.8)
				A.amount = 4
				A.amount_left = 4
		//Gear
		espionage_belts
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/storage/fanny/syndie,off_x=-4,off_y=0,scale_x=0.6,scale_y=0.6)
				spawn_item(C,I,/obj/item/storage/fanny/syndie,off_x=4,off_y=0,scale_x=0.6,scale_y=0.6)

		grenades
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/old_grenade/smoke,off_x=-6,off_y=-4)
				spawn_item(C,I,/obj/item/old_grenade/smoke,off_x=-6,off_y=4)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=6,off_y=4)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=6,off_y=-4)
				spawn_item(C,I,/obj/item/old_grenade/stinger,off_y=-4)
				spawn_item(C,I,/obj/item/old_grenade/stinger,off_y=4)
		money
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,-4,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,2,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, -6,4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,-4,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,2,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/fivehundred, 6,4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
		hotbox
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6,-6,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6,-3,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-6,0,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-3,3,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-3,6,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,-3,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,-6,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,-3,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,0,0,scale_x = 0.8,scale_y = 0.8)
				spawn_item(C,I,/obj/item/device/light/zippo/syndicate,6,0,scale_x=0.85,scale_y=0.85)


	xlong_tall //4x2, these are very rare and will take up the majority of a crate. can probably be a lil crazy
		xSize = 4
		ySize = 2
		//LOW
		phaser_jackpot
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/energy/phaser_huge,scale_x=0.8,scale_y=0.8)
		riotgun_jackpot
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,off_x=-8,off_y=3)
				spawn_item(C,I,/obj/item/gun/kinetic/riotgun,off_x=-8,off_y=-3)
		alastor_jackpot
			weight = 2
			tier = GANG_CRATE_GUN_WEAK
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/gun/energy/alastor,rot=45,off_x=-3,off_y=-2,scale_x=0.8,scale_y=0.8)

		//MEDIUM

		explosives_jackpot
			tier = GANG_CRATE_GEAR
			spawn_loot(var/C,var/I)
				spawn_item(C,I,	/obj/item/mine/stun,off_x=-10, off_y=-2,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,	/obj/item/mine/stun,off_x=-10, off_y=2,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,	/obj/item/mine/stun,off_x=-2, off_y=-2,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,	/obj/item/mine/stun,off_x=-2, off_y=2,scale_x=0.8,scale_y=0.8)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=2,off_y=2,scale_y=0.8)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=2,off_y=2,scale_y=0.8)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=2,off_y=2,scale_y=0.8)
				spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=2,off_y=2,scale_y=0.8)

		//LOW, these will basically never spawn
		money_jackpot
			spawn_loot(var/C,var/I)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=-4,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=2,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_x=-8,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_x=8,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_x=8,off_y=-4,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_x=8,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_x=8,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_x=8,off_y=2,scale_x=0.825,scale_y=0.825)
				spawn_item(C,I,/obj/item/spacecash/thousand, off_xs=8,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
