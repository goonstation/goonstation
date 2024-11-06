
// LOOT TIER DEFINES -
// NOTE: you need at least 1 'small' (1x1) object' for every loot pool, to fall back on.
#define GANG_CRATE_GUN 5 // guns, but sane for gangs
#define GANG_CRATE_AMMO 4 // ammo - uses the "Ammo_Allowed" tag, falls back to GANG_CRATE_GEAR if there is no gun
#define GANG_CRATE_AMMO_LIMITED 3 // ammo, but keeps magazines per gun to 1~2 so you dont get 2 knives and 1 gun with 3+ mags
#define GANG_CRATE_GEAR 2 // healing, cool stuff that stops you dying or helps you
#define GIMMICK 1 // fun stuff, can be helpful


/// Large storage object that spawns in anchored, then can be unlocked by a gang locker, for gang hotzones.
/obj/storage/crate/gang_crate
	name = "Gang Crate"
	desc = "A surprisingly advanced crate, with an improvised system for locking it into place. It's got gang insignia all over it..."
	is_short = TRUE
	locked = TRUE
	icon_state = "lootcrimegang"
	icon_closed = "lootcrimegang"
	icon_opened = "lootcrimeopengang"
	can_flip_bust = FALSE
	grab_stuff_on_spawn = FALSE
	anchored = ANCHORED
	var/image/light = null
	var/datum/loot_generator/lootMaster


	proc/initialize_loot_master(x,y)
		src.vis_controller = new(src)
		lootMaster =  new /datum/loot_generator(x,y)
	// Default gang crate
	guns_and_gear
		New()
			initialize_loot_master(4,4)
			// 3 guns, ammo, 3 bits of gear
			lootMaster.add_random_loot(src, GANG_CRATE_GUN, 3)
			lootMaster.add_random_loot(src, GANG_CRATE_AMMO_LIMITED, 3)
			lootMaster.add_random_loot(src, GANG_CRATE_GEAR, 3)
			// fill the rest with whatever
			lootMaster.fill_remaining(src, GIMMICK)
			..()
		unlocked
			locked = FALSE
			anchored = UNANCHORED
	guns_and_gear_bonus
		New()
			initialize_loot_master(4,4)
			// 3 guns, ammo, 3 bits of gear
			var/obj/loot_spawner/random/bonus_loot = pick(/obj/loot_spawner/random/xlong/m16,/obj/loot_spawner/random/xlong_tall/a180,/obj/loot_spawner/random/xlong_tall/ks23,/obj/loot_spawner/random/long_tall/draco)
			lootMaster.place_loot_instance(src,1,1,new bonus_loot)
			lootMaster.add_random_loot(src, GANG_CRATE_GUN, 2)
			lootMaster.add_random_loot(src, GANG_CRATE_AMMO_LIMITED, 3)
			lootMaster.add_random_loot(src, GANG_CRATE_GEAR, 3)
			// fill the rest with whatever
			lootMaster.fill_remaining(src, GIMMICK)
			..()

	//debug crate, good for visualizing spawns and diagnosing issues
	guns_and_gear_visualized
		anchored = UNANCHORED
		locked = FALSE
		New()
			initialize_loot_master(4,4)
			src.open()
			// 3 guns, ammo, 3 bits of gear
			for (var/i=1 to 3)
				lootMaster.add_random_loot(src, GANG_CRATE_GUN, 1)
				sleep(1 SECOND)
			for (var/i=1 to 3)
				lootMaster.add_random_loot(src, GANG_CRATE_AMMO_LIMITED, 1)
				sleep(1 SECOND)
			for (var/i=1 to 3)
				lootMaster.add_random_loot(src, GANG_CRATE_GEAR, 1)
				sleep(1 SECOND)
			// fill the rest with whatever
			lootMaster.fill_remaining(src, GIMMICK)
			..()
	shotguns
		New()
			initialize_loot_master(4,4)
			lootMaster.place_loot_instance(src, 1,3, new /obj/loot_spawner/random/long/striker, FALSE)
			lootMaster.place_loot_instance(src, 1,2, new /obj/loot_spawner/random/long/striker, FALSE)
			lootMaster.fill_remaining(src, GANG_CRATE_AMMO, 3)
			..()
		unlocked
			anchored = UNANCHORED
			locked = FALSE
	only_gimmicks
		New()
			lootMaster =  new /datum/loot_generator(4,3)
			lootMaster.fill_remaining(src.loc, GIMMICK)
			..()
		unlocked
			anchored = UNANCHORED
			locked = FALSE
	only_guns
		New()
			initialize_loot_master(4,4)
			lootMaster.fill_remaining(src, GANG_CRATE_GUN)
			..()
	only_gear
		New()
			initialize_loot_master(4,4)
			lootMaster.fill_remaining(src, GANG_CRATE_GEAR)
			..()
	gear_and_gimmicks
		New()
			initialize_loot_master(4,4)
			lootMaster.add_random_loot(src, GANG_CRATE_GEAR, 2)
			lootMaster.fill_remaining(src, GIMMICK)
			..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)
		..()

	New()
		..()
		START_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)
		src.light = image('icons/obj/large_storage.dmi',"gangcratefulllight")
		if (locked)
			SPAWN(GANG_CRATE_LOCK_TIME/3)
				src.light = image('icons/obj/large_storage.dmi',"gangcratehalflight")
				UpdateIcon()
			SPAWN(2*GANG_CRATE_LOCK_TIME/3 )
				src.light = image('icons/obj/large_storage.dmi',"gangcratelowlight")
				UpdateIcon()
			SPAWN((GANG_CRATE_LOCK_TIME - 3 SECONDS) )
				src.light = image('icons/obj/large_storage.dmi',"gangcrateblinkinglight")
				UpdateIcon()
			SPAWN(GANG_CRATE_LOCK_TIME)
				src.light = image('icons/obj/large_storage.dmi',"gangcratefulllight")
				anchored = FALSE
				UpdateIcon()

	ex_act()
		return
	emag_act()
		return

	proc/attempt_open(mob/user)
		for (var/obj/ganglocker/locker in range(1,src))
			if (locker.gang == user.get_gang() && locked)
				locked = FALSE
				UpdateIcon()
				locker.gang.add_points(GANG_CRATE_SCORE, user, get_turf(locker), showText = TRUE)
				locker.gang.score_event += GANG_CRATE_SCORE
				var/datum/gang/userGang = user.get_gang()
				userGang.broadcast_to_gang("[user.name] just opened a gang crate! Keep what's inside, everyone earns [GANG_CRATE_SCORE] points.",locker.gang)
				logTheThing(LOG_GAMEMODE, src, "[src] is unlocked by [user.mind.ckey]/[user.name] at the [locker], for [locker.gang.gang_name].")
				return TRUE
		return FALSE

	attackby(obj/item/I, mob/user)
		if(src.anchored != UNANCHORED)
			if(user.get_gang())
				boutput(user, "This thing's locked into place! You better defend it for a bit.")
			else
				boutput(user, "This is locked into place and has weird gang insignia all over it! You should probably move away.")
		else if(src.locked)
			if(user.get_gang())
				if (!attempt_open(user))
					boutput(user, "Access Denied. Move this next to your gang's locker to unlock it!")
					return
			else
				boutput(user, "This has weird gang insignia all over it! You should probably leave it alone.")
				return
		..()


	update_icon()
		if(open)
			icon_state = icon_opened
		else
			icon_state = icon_closed

		if (src.anchored == ANCHORED)
			light.color = "#FF0000"
		else if (src.locked)
			light.color = "#FF9900"
		else
			light.color = "#00FF00"
		src.UpdateOverlays(src.light, "light")


/// Smaller, handheld loot bags. These can be opened by hand by gang members
/obj/item/gang_loot
	icon = 'icons/obj/items/storage.dmi'
	name = "suspicious looking duffle bag"
	desc = "A greasy, black duffle bag, this isn't station issue, you should probably leave it alone..."
	icon_state = "gang_dufflebag"
	item_state = "bowling"
	p_class = 4 //marginally easier than dragging a whole locker with this in
	throw_range = 4
	always_slow_pull = TRUE
	w_class = W_CLASS_GIGANTIC
	var/hidden = TRUE
	var/open = FALSE
	///Whether this bag's trap is active
	var/trapped = TRUE
	///Whether this bag is tracking its' location
	var/tracking = FALSE
	var/initial_tracking = TRUE
	///Whether this bag is unopened. If TRUE, it will grant points when opened.
	var/sealed = TRUE
	///The gang who should own this duffel bag
	var/datum/gang/owning_gang
	///The name of the informant who knows about this bag
	var/informant
	///The civilian who has this in their hands, if the trap is active.
	var/mob/living/idiot = null
	///The area this bag spawned in.
	var/area/start_area

	///Items that haven't been removed from the bag. These will travel with it.
	var/datum/vis_storage_controller/vis_controller
	var/datum/loot_generator/lootMaster
	level = UNDERFLOOR

	Eat(mob/M, mob/user)
		boutput(user, SPAN_ALERT("You can't eat this! It tastes like [pick(list("a video game cartridge","the inside of a clown's shoe","a hooligan's rancid socks"))]!"))
		return FALSE

	proc/initialize_loot_master(x,y)
		src.vis_controller = new(src)
		lootMaster =  new /datum/loot_generator(x,y)
		toggle_tracking(initial_tracking)

	New()
		src.AddComponent(/datum/component/log_item_pickup, first_time_only=TRUE, authorized_job=null, message_admins_too=FALSE)
		..()
	only_gimmicks
		New()

			initialize_loot_master(3,2)
			lootMaster.fill_remaining(src, GIMMICK)
			..()
	gear_and_gimmicks
		New()
			initialize_loot_master(3,2)
			lootMaster.add_random_loot(src, GANG_CRATE_GEAR, 2)
			lootMaster.fill_remaining(src, GIMMICK)
			..()

	guns_and_gear
		New()
			initialize_loot_master(3,2)
			lootMaster.add_random_loot(src, GANG_CRATE_GUN, 1)
			lootMaster.add_random_loot(src, GANG_CRATE_AMMO, 1)
			lootMaster.add_random_loot(src, GANG_CRATE_GEAR, 2)
			lootMaster.fill_remaining(src, GIMMICK)
			..()

	pickup(mob/user)
		if (open && length(vis_controller.vis_items) > 0)
			close()
		..()
		if (src.layer == UNDERFLOOR)
			src.layer = OVERFLOOR
		var/datum/gang = user.get_gang()
		if (gang && (trapped || tracking))
			trapped = FALSE //if one gang member gets their mitts on it, this has done its job
			toggle_tracking(FALSE)
			boutput(user, SPAN_ALERT("You disarm the trap in the [src]'s handle. It's now safe to carry."))
		if (!gang && !open && trapped && owning_gang && isliving(user))
			var/mob/living/H = user
			idiot = user
			trapped = FALSE
			toggle_tracking(FALSE)
			icon_state = "gang_dufflebag_trap"
			cant_self_remove = TRUE
			cant_drop = TRUE
			var/area/area = get_area(src)
			playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			boutput(user, SPAN_ALERT("As you pick up \the [src.name], a series of barbs emerge from the handle, lodging in your hand!"))
			src.owning_gang.broadcast_to_gang("The bag [src.informant] knew about has just been stolen! Looks like it was in \the [area.name]")
			ON_COOLDOWN(src,"bleed_msg", 30 SECONDS) //set a 30 second timer to remind players to remove this
			idiot.setStatus("gang_trap", duration = INFINITE_STATUS)
			H.emote("scream")
			H.bleeding = max(1,H.bleeding)
			processing_items += src

	handle_other_remove(mob/source, mob/living/carbon/human/target)
		if (!cant_drop || !idiot || !source.get_gang())
			return ..()

		source.visible_message("[source] rips the [src] right off [target]! Ouch!","You rip the duffle bag from [target]'s hand.")
		idiot.emote("scream")
		playsound(idiot.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
		blood_slash(idiot, 2)
		unhook()
		return TRUE

	proc/toggle_tracking(is_tracking)
		if (src.tracking == is_tracking)
			return

		src.tracking = is_tracking

		if (src.tracking)
			RegisterSignal(src, XSIG_MOVABLE_AREA_CHANGED, PROC_REF(alert_gang))
		else
			UnregisterSignal(src, XSIG_MOVABLE_AREA_CHANGED)

	proc/alert_gang(datum/component/component, area/old_area, area/new_area)
		src.owning_gang.broadcast_to_gang("The bag [src.informant] knew about is being moved! Looks like it's been moved to \the [new_area.name]")
		toggle_tracking(FALSE)

	proc/unhook()
		if (!idiot)
			return
		if (istype(idiot.l_hand, /obj/item/gang_loot) && istype(idiot.r_hand, /obj/item/gang_loot)) //this is REALLY stretching it, bub.
			var/obj/item/gang_loot/left_loot = idiot.l_hand //like, if you hit this use case, you're something else. stealing TWO bags at once.
			var/obj/item/gang_loot/right_loot = idiot.r_hand
			if (!(left_loot.idiot && right_loot.idiot)) // if only one trapped bag exists, it means we're untrapping the last one
				idiot.delStatus("gang_trap")
		else
			idiot.delStatus("gang_trap")
		icon_state = "gang_dufflebag"
		cant_self_remove = FALSE
		cant_drop = FALSE
		idiot = null
		processing_items -= src

	dropped()
		unhook()
		..()

	proc/attempt_unhook(mob/user)
		if (user == idiot)
			actions.start(new /datum/action/bar/icon/unhook_gangbag(user, src),user)

	attack_hand(mob/user)
		if (user == idiot)
			attempt_unhook(user)
		else
			..()
	process()
		if(cant_drop)
			if (!ON_COOLDOWN(src,"bleed_msg", 30 SECONDS))
				boutput(idiot, SPAN_ALERT("The hooks in the bag are digging into your hands! You should pluck it out..."))
			bleed(idiot, pick(1,2), 1)//technically doubling bleed. but it looks nice as the loops dont sync perfectly.
			idiot.bleeding = max(1,idiot.bleeding)
		..()

	/// Uses the boolean 'intact' value of the floor it's beneath to hide, if applicable
	hide(var/floor_intact)
		invisibility = floor_intact ? INVIS_ALWAYS : INVIS_NONE	// hide if floor is intact
		if (invisibility)
			anchored = ANCHORED
		else
			anchored = UNANCHORED
		UpdateIcon()

	proc/open(mob/user)
		open = TRUE
		user.drop_item(src)
		vis_controller.show()

	proc/close()
		open = FALSE
		icon_state = "gang_dufflebag"
		vis_controller.hide()


	attack_self(mob/user)
		if (!istype(user, /mob/living/carbon/human))
			return
		if (!open)
			if (idiot && idiot == user)
				attempt_unhook(user)
				return
			var/datum/gang/gang = user.get_gang()
			if (!gang)
				boutput(user, "You don't want to get in trouble with whoever owns this! It's FULL of illegal stuff.")
				return
			unhook() // just in case
			playsound(src.loc, 'sound/misc/zipper.ogg', 100, TRUE)
			boutput(user, "You unzip the duffel bag and its' contents spill out!")
			if (sealed)
				sealed = FALSE
				gang.add_points(GANG_LOOT_SCORE,user, showText = TRUE)
				gang.score_event += GANG_CRATE_SCORE
			open(user)
			icon_state = "gang_dufflebag_open"
			UpdateIcon()
		else
			return ..()



// Handles the weighting and generation
/datum/loot_generator
	var/static/loot_x_pixels = 8 // how many pixels each grid square takes up
	var/static/loot_y_pixels = 8
	/// Whether loot weights have been generated yet.
	var/static/populated = FALSE
	/// The spawner associated with the X & Y Size. so spawners[1][2] is 1 wide, 2 tall
	var/static/list/spawners[4][2]
	/// Associative list, spawners to their childrens' total weight, as a number
	var/static/list/totalWeights[0][0]
	/// Associative list, spawners to their childrens individual weight, as a list
	var/static/list/weights[0][0][0]
	/// The loot grid (inventory grid) this generator is using
	var/datum/loot_grid/lootGrid
	/// List for passing information to spawners (for example, ammo spawners would need to know what guns this spawner made)
	var/tags[]   = new/list()
	/// ASsociative list of loot instances this generator created.
	var/list/spawned_instances[0]

	// LOOT GENERATING METHODS
	//
	// tier = the tier of generated loot, like GANG_CRATE_GUN for gang guns.
	// x = horizontal position on lootGrid
	// y = vertical position on lootGrid
	// xSize = number of horizontal lootGrid tiles this uses
	// ySize = number of vertical lootGrid tiles this uses
	// invisible = mark as TRUE to skip marking the loot grid as used

	/// Add multiple random loot objects. bottom left to top right. this looks gross in practise and prioritises just making large high-ticket items
	proc/add_random_loot_sequential(loc,tier, quantity=1, invisible=FALSE)
		for (var/i=1 to quantity)
			var/pos = lootGrid.get_next_empty_space()
			if (!pos) break
			var/maxSize = lootGrid.get_largest_space(pos[1],pos[2])
			var/lootSize = choose_random_loot_size(maxSize[1],maxSize[2],tier)
			var/override = place_random_loot_sized(loc, pos[1],pos[2],lootSize[1],lootSize[2],tier, invisible)
			if (!invisible && !override)
				lootGrid.mark_used(pos[1],pos[2],lootSize[1],lootSize[2])

	/// Add multiple random loot objects, in random positions
	proc/add_random_loot(loc,tier, quantity=1, invisible=FALSE)
		for (var/i=1 to quantity)
			var/pos = lootGrid.get_random_empty_space()
			if (!pos) break
			var/maxSize = lootGrid.get_largest_space(pos[1],pos[2])
			var/lootSize = choose_random_loot_size(maxSize[1],maxSize[2],tier)
			var/override = place_random_loot_sized(loc, pos[1],pos[2],lootSize[1],lootSize[2],tier, invisible)
			if (!invisible && !override)
				lootGrid.mark_used(pos[1],pos[2],lootSize[1],lootSize[2])



	/// Place a random loot instance at a specific position
	proc/place_random_loot(loc,x,y,tier, invisible=FALSE)
		var/maxSize = lootGrid.get_largest_space(x,y)
		var/lootSize = choose_random_loot_size(maxSize[1],maxSize[2],tier)
		place_random_loot_sized(loc, x,y,lootSize[1],lootSize[2],tier, invisible)

	/// Fills all remaining space with instances of random size
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
			var/lootSize = choose_random_loot_size(maxSize[1],maxSize[2],tier)
			place_random_loot_sized(loc, pos[1],pos[2],lootSize[1],lootSize[2],tier)

		return spawnedLootInstances

	/// place a loot object that's been created externally
	proc/place_loot_instance(loc, x,y,obj/loot_spawner/loot, invisible)
		var/override = add_loot_instance(loc,loot,x,y)
		if (!invisible && !override)
			lootGrid.mark_used(x,y,loot.xSize,loot.ySize)


	/// Fills all remaining space with as many instances as possible of a loot object that's been created externally
	/// Ignores override, due to infinite loop.
	proc/fill_remaining_with_instance(loc, obj/loot_spawner/loot)
		var/done = FALSE
		var/pos = new/list(2)
		pos[1] = 1
		pos[2] = 1
		while (!done)
			pos = lootGrid.get_next_empty_space(pos[1],pos[2])
			if (!pos) break
			var/maxSize = lootGrid.get_largest_space(pos[1],pos[2])
			if (maxSize[1] < loot.xSize)
				pos[2]++
			else
				add_loot_instance(loc,loot,pos[1],pos[2])
				lootGrid.mark_used(pos[1],pos[2],loot.xSize,loot.ySize)


	/// Place a random loot instance of a specific size at a specific position
	proc/place_random_loot_sized(loc, xPos,yPos,sizeX,sizeY, tier, invisible = FALSE)
		var/chosenType = pick_weighted_option(sizeX,sizeY,tier)
		var/obj/new_spawner = new chosenType
		var/override = add_loot_instance(loc,new_spawner,xPos,yPos)
		if (!override && !invisible)
			lootGrid.mark_used(xPos,yPos,sizeX,sizeY)
		return override

	// INTERNAL LOOT GENERATION

	New(xSize, ySize)
		if (!populated)
			populate()
		lootGrid = new/datum/loot_grid(xSize, ySize)
		..()

	/// Initialize spawners & weights for all random loot spawners
	proc/populate()
		// setting these manually to map class names to sizes
		// this avoids having to instantiate them just to read their xSize & ySize
		spawners[1][1] = /obj/loot_spawner/random/short
		spawners[2][1] = /obj/loot_spawner/random/medium
		spawners[3][1] = /obj/loot_spawner/random/long
		spawners[4][1] = /obj/loot_spawner/random/xlong
		spawners[1][2] = /obj/loot_spawner/random/short_tall
		spawners[2][2] = /obj/loot_spawner/random/medium_tall
		spawners[3][2] = /obj/loot_spawner/random/long_tall
		spawners[4][2] = /obj/loot_spawner/random/xlong_tall

		// determine the total weight of all our spawners
		for(var/spawnersByLength in spawners)
			for(var/spawner in spawnersByLength)
				totalWeights[spawner] = new/list(0)
				weights[spawner] = new/list(0)
				var/childtypes = concrete_typesof(spawner)

				for(var/childType in childtypes)
					var/obj/loot_spawner/random/item = new childType()
					if (length(totalWeights[spawner]) < item.tier)
						totalWeights[spawner].len = item.tier
						weights[spawner].len = item.tier

					if (!totalWeights[spawner][item.tier])
						totalWeights[spawner][item.tier] = 0
						weights[spawner][item.tier] = new/list(0)

					totalWeights[spawner][item.tier] += item.weight
					weights[spawner][item.tier][childType] = item.weight

		populated = TRUE

	/// use predefined weights pick a spawner of size xSize, ySize, in chosenTIer
	proc/pick_weighted_option(xSize, ySize, var/chosenTier)
		var/spawnerBase = spawners[xSize][ySize]
		var/roll = rand(1, totalWeights[spawnerBase][chosenTier])
		for (var/item in weights[spawnerBase][chosenTier])
			roll = roll - weights[spawnerBase][chosenTier][item]
			if (roll <= 0)
				return item

	/// Chooses the size of loot to spawn, given a max and min.
	proc/choose_random_loot_size(largestX,largestY,tier)
		var/desiredX  = 1
		var/desiredY  = 1
		//scaling prob for each X size of loot
		while (length(spawners) > desiredX && desiredX < largestX && prob(90-(20*desiredX)))
			desiredX++
		// 40% to make it 2 tiles tall
		while (length(spawners[1]) > desiredY && desiredY < largestY && prob(40))
			desiredY++

		// select the largest valid crate (proritizing X size)
		for (var/xTest = 1 to desiredX)
			for (var/yTest = 1 to desiredY)
				var/obj/loot_spawner/random/chosenSpawner = spawners[1+desiredX-xTest][1+desiredY-yTest]
				if (totalWeights[chosenSpawner][tier])
					var/size = list(1+desiredX-xTest,1+desiredY-yTest)
					return size

	/// creates a loot object and offset info
	proc/add_loot_instance(loc,obj/loot_spawner/instance,xPos,yPos)
		src.spawned_instances += instance
		var/datum/loot_spawner_info/info = new /datum/loot_spawner_info()
		info.parent = src
		info.grid_x = loot_x_pixels
		info.grid_y = loot_y_pixels
		info.position_x = xPos
		info.position_y = yPos
		info.layer = 3+(lootGrid.size_y-yPos)
		info.tags = src.tags
		return instance.handle_loot(loc,info)

	/// Adds an entry to a list in this spawner's tags.
	proc/tag_list(name, value)
		if (!(name in tags))
			tags[name] = new/list()
		tags[name] += value

	/// set the value of this spawner's tag.
	proc/tag_single(name, value)
		tags[name] = value

/// data class representing a grid of goodies (like an inventory grid in RE4).
/datum/loot_grid
	var/list/grid[][]
	var/size_x
	var/size_y

	New(xSize, ySize)
		set_size(xSize,ySize)
		..()

	/// Sets the size of this grid, resetting it in the process.
	proc/set_size(xSize,ySize)
		size_x = xSize
		size_y = ySize
		grid = new/list(size_x,size_y)

	/// Return the coordinates of a random empty grid square
	proc/get_random_empty_space()
		// start at a random X, Y position
		var/pos = new/list(2)
		pos[1] = rand(1,size_x)
		pos[2] = rand(1,size_y)

		// now we loop over every possible X and Y pos, but starting at an offset
		for (var/y_iter=1 to size_y)
			pos[2] = (pos[2]+1)
			if (pos[2] > size_y)
				pos[2] = 1
			for (var/x_iter=1 to size_x)
				pos[1] = (pos[1]+1)
				if (pos[1] > size_x)
					pos[1] = 1
				if (!grid[pos[1]][pos[2]])
					return pos
		return null

	/// Return the coordinates of the next empty grid square from pos_x, pos_y. Fills out one row before moving up.
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

	/// Marks an area of size xSize, ySize as used, starting at xPos, yPos
	proc/mark_used(xPos,yPos,xSize,ySize)
		for (var/x=1 to xSize)
			for (var/y=1 to ySize)
				grid[xPos-1+x][yPos+y-1] = 1

	/// Returns if coordinate x, y is empty
	proc/is_empty(x,y)
		return grid[x][y]

	/// Returns the largest empty rectangle possible, prioritising length rather than area.
	proc/get_largest_space(startX,startY)
		var/size = list(1,1)
		while (startX+size[1]-1 < size_x && !grid[startX+size[1]][startY])
			size[1]++

		var/nextYOccupied = FALSE
		while (!nextYOccupied)
			if ((startY+size[2]) <= size_y) // if we aren't at the bottom row of loot already
				for (var/x=1 to size[1]) // check every X position on the next row down
					if (grid[startX+x-1][startY+size[2]])
						nextYOccupied = TRUE
						break
				if (!nextYOccupied)
					size[2]++
			else
				nextYOccupied = TRUE

		return size


/// Contains positional info and tags to pass to loot spawners, so they can spawn items in the right spot.
/datum/loot_spawner_info
	var/grid_x = 8 		//! how wide a grid square is, in pixels
	var/grid_y = 8		//! how tall a grid square is, in pixels
	var/position_x = 0 	//! The horizontal position, in grid squares, that the spawner should use as its' origin
	var/position_y = 0  //! The vertical position, in grid squares, that the spawner should use as its' origin
	var/layer    = 0 //! The layer the spawner should use
	var/datum/loot_generator/parent //! The loot generator that created this spawner. Used to modify tags if necessary.
	var/tags[] //! The tags that the loot generator currently has. Such as what ammunition types spawned guns use



// You can uncomment this tool to help build item layouts for spawning.
// Use in-hand to set the position arguments, hit an item to see what it'd look like
// By default, each x&y coordinate is roughly 8x8 pixels, so a 2x1 item should take up 16x8 pixels (or 32x16 in 64x64 tilesize etc.)

/obj/item/device/item_placer
	name = "Item transformation viewer"
	icon_state = "multitool"
	flags = TABLEPASS | CONDUCT | ONBELT
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
			object.AddComponent(/datum/component/reset_transform_on_pickup)






// LOOT SPAWNERS
//
// The non-random base exists for loot you don't want to put in a random pool.
// In addition, the loot_spawner/specified child allows for definition of an item and size in New(), useful for live use.

ABSTRACT_TYPE(/obj/loot_spawner)
/obj/loot_spawner
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift2-r"

	var/xSize = 1 //! The width of this spawner
	var/ySize = 1 //! The height of this spawner

	// for testing, or if you want to spawn these into the world for whatever reason
	attack_hand(mob/user as mob)
		var/I = new/datum/loot_spawner_info()
		src.spawn_loot(get_turf(user),I)
		qdel(src)

	// spawn_item(C,I,off_x,off_y,rot,scale_x,scale_y,layer_offset)
	// C = Container
	// I = The spawner info, containing where to spawn this, and tags.
	//
	// Optional positioning arguments:
	// off_x/off_y = Offset of the icon (in pixels)
	// rot = Rotation of the icon
	// scale_x/scale_y = Scale of icon
	// layer_offset = overall offset of layers
	//
	/// spawn a given item with the 'transform on pickup' component. Refer to function definition for better docs.
	proc/spawn_item(loc,datum/loot_spawner_info/I,path,off_x=0,off_y=0, rot=0, scale_x=1,scale_y=1, layer_offset=0)
		var/obj/lootObject
		if (istype(loc, /obj/storage/crate))
			var/obj/storage/container = loc
			lootObject = new path(container)
			container.vis_controller.add_item(lootObject)
		else if (istype(loc, /obj/item/gang_loot))
			var/obj/item/gang_loot/loot = loc
			lootObject = new path(loot)
			loot.vis_controller.add_item(lootObject)
		else
			lootObject = new path(loc)
		lootObject.transform = lootObject.transform.Scale(scale_x,scale_y)
		lootObject.transform = lootObject.transform.Turn(rot)

		lootObject.pixel_x = I.grid_x * ((I.position_x + xSize/2-1)-I.parent?.lootGrid?.size_x/2) + off_x
		lootObject.pixel_y = I.grid_y * ((I.position_y + ySize/2-1)-I.parent?.lootGrid?.size_y/2) + off_y
		lootObject.layer = I.layer + layer_offset
		lootObject.AddComponent(/datum/component/reset_transform_on_pickup)
		return lootObject

	/// Calls spawn_loot, then handles disappearing & overrides
	proc/handle_loot(loc,datum/loot_spawner_info/I)
		var/override = spawn_loot(loc,I)
		qdel(src)
		return override

	/// Spawn the loot for this instance. Return TRUE if this should not take up grid squares.
	proc/spawn_loot(loc,datum/loot_spawner_info/I)

ABSTRACT_TYPE(/obj/loot_spawner/short)
/obj/loot_spawner/short //1x1
	xSize = 1
	ySize = 1

	two_stx_grenades
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/chem_grenade/saxitoxin,off_y=2,scale_x=0.825,scale_y=0.65)
			spawn_item(C,I,/obj/item/chem_grenade/saxitoxin,off_y=-2,scale_x=0.825,scale_y=0.65)
/obj/loot_spawner/medium //1x1
	xSize = 2
	ySize = 1
	ks23_shrapnel
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/ammo/bullets/kuvalda,off_y=3,scale_x=0.5,scale_y=0.5)
			spawn_item(C,I,/obj/item/ammo/bullets/kuvalda,off_y=-3,scale_x=0.5,scale_y=0.5)
	ks23_slug
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/ammo/bullets/kuvalda/slug,off_y=3,scale_x=0.5,scale_y=0.5)
			spawn_item(C,I,/obj/item/ammo/bullets/kuvalda/slug,off_y=-3,scale_x=0.5,scale_y=0.5)

/obj/loot_spawner/xlong_tall //4x2
	xSize = 4
	ySize = 2

	ks23_empty
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/gun/kinetic/pumpweapon/ks23/empty,off_x=-8,scale_x=0.8,scale_y=0.8)

// The random loot master checks all definitions of loot_spawner/random when it's first created.
// To define new random loot, simply create a new child of the appropriate size and tier, and it will be automatically picked up.
// Uncomment the above item_placer if you'd like to scale the items spawned by this.

ABSTRACT_TYPE(/obj/loot_spawner/random)
/obj/loot_spawner/random
	var/tier = GIMMICK	//! what tier must be selected to select this spawner.
	var/weight = 3		//! the weight this spawner has to be selected in its' tier, defaults to 3.

	/// generic booze loot pool
	var/static/booze_items = list(
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
	/// generic drug loot pool
	var/static/drug_items = list(
		/obj/item/storage/pill_bottle/methamphetamine,
		/obj/item/storage/pill_bottle/crank,
		/obj/item/storage/pill_bottle/bathsalts,
		/obj/item/storage/pill_bottle/catdrugs,
		/obj/item/storage/pill_bottle/cyberpunk,
		/obj/item/storage/pill_bottle/epinephrine
	)
	/// uncommon, valuable drugs, for placement in syringes
	var/static/strong_stims = list("omnizine","enriched_msg","triplemeth", "fliptonium","cocktail_triple","energydrink","grog")

ABSTRACT_TYPE(/obj/loot_spawner/random/short)
/obj/loot_spawner/random/short //1x1
	xSize = 1
	ySize = 1

	ammo
		tier = GANG_CRATE_AMMO
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			if ("Ammo_Allowed" in I.tags)
				// Otherwise, make ammo modifications
				var/ammoSelected = pick(I.tags["Ammo_Allowed"])
				if (ispath(ammoSelected,  /obj/item/ammo/bullets/c_45))
					spawn_item(C,I,ammoSelected, scale_x=0.5,scale_y=0.5)
				else if (ispath(ammoSelected, /obj/item/ammo/bullets/a12) || ispath(ammoSelected, /obj/item/ammo/bullets/flare))
					spawn_item(C,I,ammoSelected, scale_x=0.6,scale_y=0.8)
				else if (ispath(ammoSelected, /obj/item/ammo/bullets/abg))
					spawn_item(C,I,ammoSelected, scale_x=0.6,scale_y=0.8)
				else if (ispath(ammoSelected, /obj/item/ammo/bullets/assault_rifle))
					spawn_item(C,I,ammoSelected, scale_x=0.8,scale_y=0.75)
				else if (ispath(ammoSelected, /obj/item/ammo/bullets/webley))
					spawn_item(C,I,ammoSelected, scale_x=0.5,scale_y=0.5)
				else if (ispath(ammoSelected, /obj/item/ammo/bullets/nine_mm_surplus))
					spawn_item(C,I,ammoSelected, scale_y=0.725)
				else if (ispath(ammoSelected,/obj/item/ammo/bullets/flintlock/single))
					var/obj/item/ammo/bullets/newAmmo = spawn_item(C,I,ammoSelected, rot=-45,scale_x=0.8,scale_y=0.8)
					newAmmo.amount = 3
					newAmmo.amount_left = 3
				else if (ispath(ammoSelected, /obj/item/ammo/bullets/smoke))
					I.parent.place_loot_instance(C, I.position_x, I.position_y, new /obj/loot_spawner/random/short/flashbang)
					return TRUE
				else
					spawn_item(C,I,ammoSelected)
			else
				I.parent.place_random_loot_sized(C, I.position_x, I.position_y, 1, 1, GANG_CRATE_GEAR)
				return TRUE // override this

		limited
			tier = GANG_CRATE_AMMO_LIMITED
			// AMMO_LIMITED limits the amount of ammo spawned to 'the amount of guns, plus a 50% chance for a bonus mag'
			// So, if there's 1 gun, there's a 50% chance for 2 mags, 50% for one mag
			// For 2 guns, there's a 50% chance for 3 mags, 50% for 2 mags.
			// any AMMO_LIMITED that spawns thereafter will instead spawn a 1x1 GEAR item.
			spawn_loot(var/C, datum/loot_spawner_info/I)
				var/ammoSpawned = 0
				if (I.tags["Ammo_Spawned"])
					ammoSpawned = I.tags["Ammo_Spawned"] + 1
					I.parent.tag_single("Ammo_Spawned", I.tags["Ammo_Spawned"] + 1)
				else
					ammoSpawned = 1
					I.parent.tag_single("Ammo_Spawned", 1)

				var/skipAmmo = (ammoSpawned-length(I.tags["Ammo_Allowed"]))*50
				// If we've got more ammo than guns, roll gear instead
				if (prob(skipAmmo))
					I.parent.place_random_loot_sized(C, I.position_x, I.position_y, 1, 1, GANG_CRATE_GEAR)
					return TRUE // override this spawn
				. = ..()

	// GANG_CRATE_GUN:
	webley
		weight=10
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/gun/kinetic/gun = spawn_item(C,I,/obj/item/gun/kinetic/webley,scale_x=0.65,scale_y=0.65)
			I.parent?.tag_list("Ammo_Allowed", gun.default_magazine)
	small_nades
		weight=2
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/old_grenade/stinger/frag,off_y=0,scale_x=0.6,scale_y=0.6)
			spawn_item(C,I,/obj/item/old_grenade/stinger/frag,off_y=0,scale_x=0.6,scale_y=0.6)
			spawn_item(C,I,/obj/item/old_grenade/stinger/frag,off_y=0,scale_x=0.6,scale_y=0.6)

	// GANG_CRATE_GEAR
	spraypaint
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/spray_paint_gang,scale_x=0.6,scale_y=0.45,off_x=-2)
			spawn_item(C,I,/obj/item/spray_paint_gang,scale_x=0.6,scale_y=0.45)
			spawn_item(C,I,/obj/item/spray_paint_gang,scale_x=0.6,scale_y=0.45,off_x=2)
	flash
		weight = 1 // it sucks getting more than 1 of these
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/device/flash,off_x=2,off_y=0,rot=0,scale_x=0.6,scale_y=0.6)
			spawn_item(C,I,/obj/item/device/flash,off_x=-2,off_y=0,rot=0,scale_x=0.6,scale_y=0.6)
	flashbang
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_y=2,scale_x=0.825,scale_y=0.65)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_y=-2,scale_x=0.825,scale_y=0.65)
	donk
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donkpocket_w,scale_x=0.75,scale_y=0.75)
	crank
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/storage/pill_bottle/crank,scale_x=0.75,scale_y=0.75)
	meth
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/storage/pill_bottle/methamphetamine,scale_x=0.75,scale_y=0.75)
	quickhacks
		weight = 1
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/tool/quickhack,scale_x=0.6, scale_y = 0.6)


	// GIMMICKS
	recharge_cell // maybe good to bribe sec??
		weight=2
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/ammo/power_cell/self_charging/medium,off_y=2)
	jaffacakes
		tier = GIMMICK
		weight=5
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/prefix = pick("very","somewhat","extremely","", "dangerously") // these ain't standard issue
			for(var/i=1 to 4)
				var/obj/item/cake = spawn_item(C,I,/obj/item/reagent_containers/food/snacks/cookie/jaffa,off_y=2*(2-i),scale_x=0.7,scale_y=0.85)
				cake.name = "[prefix] illegal [cake.name]"
				cake.reagents.add_reagent("omnizine", 5)
				cake.reagents.add_reagent("msg", 1) // make em taste different
	weed
		weight=5
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=-2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,off_y=-4,scale_x = 0.6,scale_y = 0.6)
	whiteweed
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=-2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/white/spawnable,off_y=-4,scale_x = 0.6,scale_y = 0.6)
	omegaweed
		weight=1
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,off_y=2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,off_y=-2,scale_x = 0.6,scale_y = 0.6)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/omega/spawnable,off_y=-4,scale_x = 0.6,scale_y = 0.6)

	goldzippo
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/device/light/zippo/gold,scale_x=0.85,scale_y=0.85)
	rillo
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/cigpacket/cigarillo,off_x=-2,scale_y=0.8)
			spawn_item(C,I,/obj/item/cigpacket/cigarillo,off_x=2,scale_y=0.8)
	juicerillo
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/cigpacket/cigarillo/juicer,off_x=-2,scale_y=0.8)
			spawn_item(C,I,/obj/item/cigpacket/cigarillo/juicer,off_x=2,scale_y=0.8)
	drugs
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,pick(drug_items),scale_x=0.75,scale_y=0.75)

ABSTRACT_TYPE(/obj/loot_spawner/random/medium)
/obj/loot_spawner/random/medium //2x1
	xSize = 2
	ySize = 1
	// GANG_CRATE_GUN:
	lopoint
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/gun/kinetic/gun = spawn_item(C,I,/obj/item/gun/kinetic/lopoint,scale_x=0.75,scale_y=0.75)
			I.parent?.tag_list("Ammo_Allowed", gun.default_magazine)
	lasergat
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/gun/energy/lasergat,scale_y=0.61,scale_x=0.61)
			I.parent?.tag_list("Ammo_Allowed", /obj/item/ammo/power_cell/lasergat )

	saa
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/gun/kinetic/gun = spawn_item(C,I,/obj/item/gun/kinetic/single_action/colt_saa,scale_x=0.7,scale_y=0.7)
			I.parent?.tag_list("Ammo_Allowed", gun.default_magazine)

	dagger
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/dagger/throwing_knife/gang,rot=45,scale_x=0.55,scale_y=0.55)

	// GANG_CRATE_GEAR
	pouch
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/storage/pouch/highcap/midcap,scale_x=0.65,scale_y=0.65)
	amphetamines
		weight = 3
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			for(var/i=1 to 3)
				spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,rot=45,off_y=3-(2*i),scale_x=0.75,scale_y=0.75)
	robust_donuts
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robust,scale_x=0.6,scale_y=0.6,rot=90,off_x=-6)
			spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robust,scale_x=0.6,scale_y=0.6,rot=90,off_x=-2)
			spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robusted,scale_x=0.6,scale_y=0.6,rot=90,off_x=2)
			spawn_item(C,I,/obj/item/reagent_containers/food/snacks/donut/custom/robusted,scale_x=0.6,scale_y=0.6,rot=90,off_x=6)
	moneythousand
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/currency/spacecash/twothousandfivehundred,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/twothousandfivehundred,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/twothousandfivehundred,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
	stims_syringe
		tier = GANG_CRATE_GEAR
		weight=1
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			for(var/i=1 to 3)
				var/obj/item/syringe = spawn_item(C,I,/obj/item/reagent_containers/syringe,off_y=6-3*i,rot=(i*180%360)+45,scale_x=0.7,scale_y=0.7)
				var/stim = pick(strong_stims)
				syringe.reagents.add_reagent(stim, 15)
				syringe.name_suffix("([syringe.reagents.get_master_reagent_name()])")
				syringe.UpdateName()

	// GIMMICKS
	utility_belt
		weight = 1
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_y=1)
			spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_y=-1)
	money
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_y=2,scale_x=0.825,scale_y=0.825, layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
	moneythousand
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)

	drugs_syringe
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,off_y=3,rot=45,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,rot=45,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,/obj/item/reagent_containers/syringe/krokodil,off_y=-3,rot=45,scale_x=0.7,scale_y=0.7)
	syndieomnitool
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/tool/omnitool/syndietool = spawn_item(C,I,/obj/item/tool/omnitool/syndicate,scale_y=0.75,rot=90)
			syndietool.change_mode(OMNI_MODE_PULSING, null, /obj/item/device/multitool)

	cigar
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			for(var/i=1 to 3)
				var/obj/item/cig = spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar,off_y=3*(2-i))
				cig.reagents.add_reagent("salicylic_acid", 5)
				cig.reagents.add_reagent("CBD", 5)

	goldcigar
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			for(var/i=1 to 3)
				var/obj/item/cig = spawn_item(C,I,/obj/item/clothing/mask/cigarette/cigar/gold,off_y=3*(2-i))
				cig.reagents.add_reagent("salicylic_acid", 5)
				cig.reagents.add_reagent("omnizine", 5)

	drug_injectors
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=4,rot=45,scale_x=0.75,scale_y=0.75)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=0,rot=45,scale_x=0.75,scale_y=0.75)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/random,off_y=-4,rot=45,scale_x=0.75,scale_y=0.75)


ABSTRACT_TYPE(/obj/loot_spawner/random/long)
/obj/loot_spawner/random/long //3x1
	xSize = 3
	ySize = 1

	// GANG_CRATE_GUN
	striker
		weight = 15
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/gun/kinetic/gun = spawn_item(C,I,/obj/item/gun/kinetic/striker,off_x=-8,off_y=1,scale_x=0.6,scale_y=0.8)
			I.parent?.tag_list("Ammo_Allowed", gun.default_magazine)

	gl
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/gun/kinetic/gun = spawn_item(C,I,/obj/item/gun/kinetic/riot40mm,scale_x=0.8,scale_y=0.8)
			I.parent?.tag_list("Ammo_Allowed", gun.default_magazine)

			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=5,off_y=-4,rot=90,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=8,off_y=-4,rot=90,scale_x=0.8,scale_y=0.8)

	// GANG_CRATE_GEAR
	glasses
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/clothing/glasses/sunglasses,off_y=-2)
			spawn_item(C,I,/obj/item/clothing/glasses/sunglasses,off_y=2)




	// GIMMICKS
	money_big
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand,off_x=4,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand,off_x=4,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand,off_x=4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand,off_x=-4,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand,off_x=-4,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand,off_x=-4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
	money
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=-4,off_y=2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=4,off_y=2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=4,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=-4,off_y=0,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=-4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)

ABSTRACT_TYPE(/obj/loot_spawner/random/xlong)
/obj/loot_spawner/random/xlong //4x1:// these are rare finds
	xSize = 4
	ySize = 1
	// GANG_CRATE_GUN
	riotgun
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/gun/kinetic/gun = spawn_item(C,I,/obj/item/gun/kinetic/pumpweapon/riotgun,off_x=-8,off_y=0)
			I.parent?.tag_list("Ammo_Allowed", gun.default_magazine)

	m16
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/gun/kinetic/gun = spawn_item(C,I,/obj/item/gun/kinetic/m16,off_x=-8,off_y=0,scale_x=0.7,scale_y=0.7)
			I.parent?.tag_list("Ammo_Allowed", gun.default_magazine)

	// LOW
	utility_belt
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_x=-8)
			spawn_item(C,I,/obj/item/storage/belt/utility/prepared,off_x=8)

ABSTRACT_TYPE(/obj/loot_spawner/random/short_tall)
/obj/loot_spawner/random/short_tall //1x2
	xSize = 1
	ySize = 2
	// good for tall items, like booze


	// GANG_CRATE_GUN
	lasergat
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/gun/energy/lasergat,rot=90,scale_y=0.61,scale_x=0.61)
			I.parent?.tag_list("Ammo_Allowed", /obj/item/ammo/power_cell/lasergat )

	// GANG_CRATE_GEAR
	janktanktwo
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/tool/janktanktwo,rot=135,off_x=2,scale_x=0.65,scale_y=0.65)
	robusttecs
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/implantcase/robust,off_x=-2,off_y= 2,rot=0,scale_x=0.6,scale_y=0.8)
			spawn_item(C,I,/obj/item/implantcase/robust,off_x=-2,off_y=-2,rot=0,scale_x=0.6,scale_y=0.8)
			spawn_item(C,I,/obj/item/implanter,off_x=3,off_y=0,rot=45,scale_x=0.6,scale_y=0.6)
	syndieomnitool
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/tool/omnitool/syndietool = spawn_item(C,I,/obj/item/tool/omnitool/syndicate,scale_y=0.75)
			syndietool.change_mode(OMNI_MODE_PULSING, null, /obj/item/device/multitool)
	autos
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_x=-2,rot=135,scale_x=0.75,scale_y=0.75)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_x=0,rot=135,scale_x=0.75,scale_y=0.75)
			spawn_item(C,I,/obj/item/reagent_containers/emergency_injector/methamphetamine,off_x=2,rot=135,scale_x=0.75,scale_y=0.75)
	edrink
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/reagent_containers/food/drinks/energyshake,off_x=1,scale_y=0.8)
			spawn_item(C,I,/obj/item/reagent_containers/food/drinks/energyshake,off_x=-1,scale_y=0.8)
	patches
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/item_box/medical_patches/mini_synthflesh,scale_x=0.6,scale_y=0.8)


	// GIMMICKS
	bong
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/plant/herb/cannabis/spawnable,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,/obj/item/reagent_containers/glass/water_pipe,scale_x=0.8,scale_y=0.8)
	booze
		weight=6
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,pick(booze_items),off_x=-2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,pick(booze_items),scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,pick(booze_items),off_x=2,scale_x=0.825,scale_y=0.825)
	airhorn
		weight=1
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/instrument/bikehorn/airhorn,scale_x=0.825,scale_y=0.825)

ABSTRACT_TYPE(/obj/loot_spawner/random/medium_tall)
/obj/loot_spawner/random/medium_tall //2x2
	xSize = 2
	ySize = 2

	// GANG_CRATE_GUN
	uzi
		weight = 15
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/gun/kinetic/gun = spawn_item(C,I,/obj/item/gun/kinetic/uzi,scale_x=0.75,scale_y=0.75)
			I.parent?.tag_list("Ammo_Allowed", gun.default_magazine)

	frags
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,	/obj/item/old_grenade/stinger/frag,off_x=-4,off_y=5,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,	/obj/item/old_grenade/stinger/frag,off_x=4, off_y=5,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,	/obj/item/mine/stun,off_x=-4, off_y=-5,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,	/obj/item/mine/stun,off_x=4, off_y=-5,scale_x=0.8,scale_y=0.8)

	// GANG_CRATE_GEAR
	concussions
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=-6,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=2,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=-2,rot=180,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,/obj/item/old_grenade/energy_concussion,off_x=6,rot=180,scale_x=0.8,scale_y=0.8)
	gold
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/stamped_bullion,off_x=-4)
			spawn_item(C,I,/obj/item/stamped_bullion)
			spawn_item(C,I,/obj/item/stamped_bullion,off_x=4)
	mixed_sec
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=-4,off_y=4)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=4,off_y=4)
			spawn_item(C,I,/obj/item/chem_grenade/cryo,off_x=-4,off_y=-4,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,/obj/item/chem_grenade/shock,off_x=4,off_y=-4,scale_x=0.8,scale_y=0.8)
	helmet
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/helmet = pick(filtered_concrete_typesof(/obj/item/clothing/head/helmet, PROC_REF(filter_trait_hats)))
			spawn_item(C,I,helmet,off_y=-2,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,helmet,off_y=0,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,helmet,off_y=2,scale_x=0.7,scale_y=0.7)

	galoshes
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/clothing/shoes/galoshes,off_y=2)
			spawn_item(C,I,/obj/item/clothing/shoes/galoshes,off_y=-2)

	// LOW VALUE: Gimmicks

	booze
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,pick(booze_items),off_x=-2)
			spawn_item(C,I,pick(booze_items))
			spawn_item(C,I,pick(booze_items),off_x=2)

	hat
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, PROC_REF(filter_trait_hats))),off_y=-2,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, PROC_REF(filter_trait_hats))),off_y=0,scale_x=0.7,scale_y=0.7)
			spawn_item(C,I,pick(filtered_concrete_typesof(/obj/item/clothing/head, PROC_REF(filter_trait_hats))),off_y=2,scale_x=0.7,scale_y=0.7)
	medkits
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/storage/firstaid/crit,off_y=2)
			spawn_item(C,I,/obj/item/storage/firstaid/regular,off_y=0)
			spawn_item(C,I,/obj/item/storage/firstaid/toxin,off_y=-2)
	gasmasks
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=2)
			spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=0)
			spawn_item(C,I,/obj/item/clothing/mask/gas,off_y=-2)

	money
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=-4,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=-4,off_y=2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=-4,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=4,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=4,off_y=2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=4,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=-4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=-4,off_y=-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=-4,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=4,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=4,off_y=-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred,off_x=4,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)

ABSTRACT_TYPE(/obj/loot_spawner/random/long_tall)
/obj/loot_spawner/random/long_tall //3x2
	xSize = 3
	ySize = 2

	// GANG_CRATE_GUN
	flintlock // pahahahha
		weight = 1
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/gun/kinetic/gun = spawn_item(C,I,/obj/item/gun/kinetic/single_action/flintlock,off_x=-3,off_y=-3,scale_x=0.8,scale_y=0.8)
			I.parent?.tag_list("Ammo_Allowed", gun.default_magazine)

			var/obj/item/ammo/bullets/A = spawn_item(C,I,/obj/item/ammo/bullets/flintlock,rot=-135,off_x=3,off_y=2,scale_x=0.8,scale_y=0.8)
			A.amount = 3
			A.amount_left = 3

	sawnoff
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/gun/kinetic/sawnoff/birdshot,off_y=3,scale_x=0.8,scale_y=0.8)
			I.parent?.tag_list("Ammo_Allowed", /obj/item/ammo/bullets/a12/bird)

			var/obj/item/ammo/bullets/A = spawn_item(C,I,/obj/item/ammo/bullets/a12/bird,off_x=3,off_y=-2,scale_x=0.6,scale_y=0.8)
			A.amount = 4
			A.amount_left = 4

	draco
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/gun/kinetic/draco,off_x=-7,scale_x=0.8,scale_y=0.8)
			//no mags for you! that would be crazy!

	greasegun
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			var/obj/item/gun/kinetic/gun = spawn_item(C,I,/obj/item/gun/kinetic/greasegun,off_x=-7,scale_x=0.65,scale_y=0.65)
			I.parent?.tag_list("Ammo_Allowed", gun.default_magazine)

	// GANG_CRATE_GEAR
	grenades
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/old_grenade/smoke,off_x=-6,off_y=-4)
			spawn_item(C,I,/obj/item/old_grenade/smoke,off_x=-6,off_y=4)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=6,off_y=4)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=6,off_y=-4)
			spawn_item(C,I,/obj/item/old_grenade/stinger,off_y=-4)
			spawn_item(C,I,/obj/item/old_grenade/stinger,off_y=4)
	// GIMMICKS
	money
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, -6,-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, -6,-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, -6,-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, -6,0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, -6,2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, -6,4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, 6,-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, 6,-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, 6,-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, 6,0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, 6,2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/fivehundred, 6,4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
	hotbox
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
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


ABSTRACT_TYPE(/obj/loot_spawner/random/xlong_tall)
/obj/loot_spawner/random/xlong_tall //4x2, these are INCREDIBLY rare and will take up the majority of a crate. can probably be a lil crazy
	xSize = 4
	ySize = 2

	// GANG_CRATE_GUN
	a180
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/gun/kinetic/american180,off_x=-8,scale_x=0.8,scale_y=0.8)
	ks23
		tier = GANG_CRATE_GUN
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/gun/kinetic/pumpweapon/ks23/empty,off_x=-8,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,/obj/item/ammo/bullets/kuvalda/slug,off_x=-7,off_y=-4,scale_x=0.5,scale_y=0.5)
			spawn_item(C,I,/obj/item/ammo/bullets/kuvalda,off_x=7,off_y=-4,scale_x=0.5,scale_y=0.5)

	// GANG_CRATE_GEAR

	explosives_jackpot
		tier = GANG_CRATE_GEAR
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,	/obj/item/mine/blast,off_x=-10, off_y=-2,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,	/obj/item/mine/blast,off_x=-10, off_y=2,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,	/obj/item/mine/incendiary,off_x=-2, off_y=-2,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,	/obj/item/mine/incendiary,off_x=-2, off_y=2,scale_x=0.8,scale_y=0.8)
			spawn_item(C,I,/obj/item/chem_grenade/shock,off_x=2,off_y=2,scale_y=0.8)
			spawn_item(C,I,/obj/item/chem_grenade/incendiary,off_x=2,off_y=2,scale_y=0.8)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=2,off_y=2,scale_y=0.8)
			spawn_item(C,I,/obj/item/chem_grenade/flashbang,off_x=2,off_y=2,scale_y=0.8)

	// GIMMICKS
	money_jackpot
		spawn_loot(var/C,var/datum/loot_spawner_info/I)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=-8,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=-8,off_y=-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=-8,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=-8,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=-8,off_y=2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=-8,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=8,off_y=-6,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=8,off_y=-4,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=8,off_y=-2,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=8,off_y=0,scale_x=0.825,scale_y=0.825,layer_offset=0.5)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=8,off_y=2,scale_x=0.825,scale_y=0.825)
			spawn_item(C,I,/obj/item/currency/spacecash/thousand, off_x=8,off_y=4,scale_x=0.825,scale_y=0.825,layer_offset=-0.5)
