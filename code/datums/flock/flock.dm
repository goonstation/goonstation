// flockdrone stuff, ask cirr or do a search for "flockdrone"

/////////////////////////////
// FLOCK DATUM
/////////////////////////////
// used to manage and share information between members of a flock/nest
/var/list/flocks = list()
/datum/flock
	var/name
	var/list/all_owned_tiles = list()
	var/list/busy_tiles = list()
	var/list/priority_tiles = list()
	var/list/traces = list()
	var/list/units = list()
	var/list/enemies = list()
	var/list/annotation_viewers = list()
	var/list/annotations = list() // key is atom ref, value is image
	var/mob/living/intangible/flock/flockmind/flockmind
	var/snoop_clarity = 80 // how easily we can see silicon messages, how easily silicons can see this flock's messages
	var/snooping = 0 //are both sides of communication currently accessible?
	var/chui/window/flockpanel/panel

/datum/flock/New()
	..()
	src.name = "[pick(consonants_lower)][pick(vowels_lower)].[pick(consonants_lower)][pick(vowels_lower)]"
	flocks[src.name] = src
	processing_items |= src
	panel = new(src)

/datum/flock/proc/describe_state()
	var/list/state = list()
	state["update"] = "flock"

	// DESCRIBE TRACES
	var/list/tracelist = list()
	for(var/mob/living/intangible/flock/trace/T in src.traces)
		tracelist[++tracelist.len] = T.describe_state()
	state["partitions"] = tracelist

	// DESCRIBE DRONES
	var/list/dronelist = list()
	for(var/mob/living/critter/flock/drone/F in src.units)
		dronelist[++dronelist.len] = F.describe_state()
	state["drones"] = dronelist

	// DESCRIBE ENEMIES
	var/list/enemylist = list()
	for(var/name in src.enemies)
		var/list/enemy_stats = src.enemies[name]
		var/mob/living/M = enemy_stats["mob"]
		if(istype(M)) // fix runtime: Cannot read null.name
			var/list/enemy = list()
			enemy["name"] = M.name
			enemy["area"] = enemy_stats["last_seen"]
			enemy["ref"] = "\ref[M]"
			enemylist[++enemylist.len] = enemy
		else
			// enemy no longer exists, let's do something about that
			src.enemies -= name
	state["enemies"] = enemylist

	// DESCRIBE VITALS (do this last so we can report list lengths)
	var/list/vitals = list()
	vitals["name"] = src.name
	vitals["drones"] = dronelist.len
	vitals["partitions"] = tracelist.len
	state["vitals"] = vitals

	return state

/datum/flock/disposing()
	flocks[src.name] = null
	processing_items -= src
	..()

/datum/flock/proc/total_health_percentage()
	var/hp = 0
	var/max_hp = 0
	for(var/mob/living/critter/flock/F in src.units)
		F.count_healths()
		hp += F.health
		max_hp += F.max_health
	if(max_hp != 0)
		return hp/max_hp
	else
		return 0

/datum/flock/proc/total_resources()
	var/res = 0
	for(var/mob/living/critter/flock/F in src.units)
		res += F.resources
	return res

/datum/flock/proc/registerFlockmind(var/mob/living/intangible/flock/flockmind/F)
	if(!F)
		return
	src.flockmind = F

/datum/flock/proc/addTrace(var/mob/living/intangible/flock/trace/T)
	if(!T)
		return
	src.traces |= T

	// update the flock control panel
	var/list/update = T.describe_state()
	update["update"] = "add"
	update["key"] = "partitions"
	// ref is already provided
	panel.PushUpdate(update)

/datum/flock/proc/removeTrace(var/mob/living/intangible/flock/trace/T)
	if(!T)
		return
	src.traces -= T

	// update the flock control panel
	var/list/update = list()
	update["update"] = "remove"
	update["key"] = "partitions"
	update["ref"] = "\ref[T]"
	panel.PushUpdate(update)

// ANNOTATIONS

// currently both flockmind and player units get the same annotations: what tiles are marked for conversion, and who is shitlisted
/datum/flock/proc/showAnnotations(var/mob/M)
	if(!M)
		return
	src.annotation_viewers |= M
	var/client/C = M.client
	if(C)
		var/image/I
		for(var/atom/key in src.annotations)
			I = src.annotations[key]
			if(istype(I, /image))
				C.images |= I

/datum/flock/proc/hideAnnotations(var/mob/M)
	if(!M)
		return
	src.annotation_viewers -= M
	var/client/C = M.client
	if(C)
		var/image/I
		for(var/atom/key in src.annotations)
			I = src.annotations[key]
			C.images -= I

// if anyone thinks they can optimise this PLEASE DO OH GOD - cirr, 2017
/datum/flock/proc/updateAnnotations()
	var/image/I
	var/list/valid_keys = list()
	var/list/images_to_add = list()
	// highlight priority tiles
	for(var/turf/T in src.priority_tiles)
		if(!(T in src.annotations))
			// create a new image
			I = image('icons/misc/featherzone.dmi', T, "frontier")
			I.blend_mode = BLEND_ADD
			I.alpha = 180
			I.plane = PLANE_SELFILLUM + 1.1
			// add to subscribers for annotations
			images_to_add |= I
			src.annotations[T] = I
		// add key to list
		valid_keys |= T
	// highlight reserved tiles
	for(var/name in src.busy_tiles)
		var/turf/T = src.busy_tiles[name]
		if(isturf(T) && !(T in src.annotations))
			// create a new image
			I = image('icons/misc/featherzone.dmi', T, "frontier")
			I.blend_mode = BLEND_ADD
			I.alpha = 80
			I.plane = PLANE_SELFILLUM + 1.1
			// add to subscribers for annotations
			images_to_add |= I
			src.annotations[T] = I
		// add key to list
		valid_keys |= T
	// highlight enemies
	for(var/name in src.enemies)
		var/mob/B = src.enemies[name]["mob"]
		if(!(B in src.annotations))
			// create a new image
			I = image('icons/misc/featherzone.dmi', B, "hazard")
			I.blend_mode = BLEND_ADD
			I.pixel_y = 16
			I.plane = PLANE_SELFILLUM + 1.1
			I.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			// add to subscribers for annotations
			images_to_add |= I
			src.annotations[B] = I
		// add key to list
		valid_keys |= B
	var/list/to_remove = list()
	for(var/atom/key in src.annotations)
		if(!(key in valid_keys))
			to_remove |= key
	// add images
	for(I in images_to_add)
		for(var/mob/M in src.annotation_viewers)
			var/client/C = M.client
			if(C)
				C.images += I
	// purge images & annotation entries
	for(var/atom/key in to_remove)
		I = src.annotations[key]
		src.annotations -= key
		for(var/mob/M in src.annotation_viewers)
			var/client/C = M.client
			if(C)
				C.images -= I

// UNITS

/datum/flock/proc/registerUnit(var/atom/movable/D)
	if(isflock(D) || isflockstructure(D))
		src.units |= D

		if(src.panel && istype(D, /mob/living/critter/flock/drone))
			var/mob/living/critter/flock/drone/drone = D

			// update the flock control panel
			var/list/update = drone.describe_state()
			update["update"] = "add"
			update["key"] = "drones"
			// ref is already provided
			panel.PushUpdate(update)

/datum/flock/proc/removeDrone(var/atom/movable/D)
	if(isflock(D) || isflockstructure(D))
		src.units -= D

		if(src.panel && istype(D, /mob/living/critter/flock/drone))
			// update the flock control panel
			var/list/update = list()
			update["update"] = "remove"
			update["key"] = "drones"
			update["ref"] = "\ref[D]"
			panel.PushUpdate(update)

		if(D:real_name && busy_tiles[D:real_name])
			src.busy_tiles[D:real_name] = null

/datum/flock/proc/getComplexDroneCount()
	var/count = 0
	for(var/mob/living/critter/flock/drone/D in src.units)
		count++
	return count

// ENEMIES

/datum/flock/proc/updateEnemy(var/mob/living/M)
	if(!M)
		return
	var/enemy_name = lowertext(M.name)
	var/list/enemy_deets
	if(!(enemy_name in src.enemies))
		// add new
		var/area/enemy_area = get_area(M)
		enemy_deets = list()
		enemy_deets["mob"] = M
		enemy_deets["last_seen"] = enemy_area
		src.enemies[enemy_name] = enemy_deets

		// update the flock control panel
		var/list/update = list()
		update["update"] = "add"
		update["key"] = "enemies"
		update["ref"] = "\ref[M]"
		update["name"] = M.name
		update["area"] = enemy_area
		panel.PushUpdate(update)
	else
		enemy_deets = src.enemies[enemy_name]
		enemy_deets["last_seen"] = get_area(M)
	// update annotations indicating enemies for flockmind and co
	src.updateAnnotations()

/datum/flock/proc/removeEnemy(var/mob/living/M)
	// call off all drones attacking this guy
	for(var/name in src.enemies)
		var/list/enemy_stats = src.enemies[name]
		if(enemy_stats["mob"] == M)
			src.enemies -= name
			// update the flock control panel
			var/list/update = list()
			update["update"] = "remove"
			update["key"] = "enemies"
			update["ref"] = "\ref[M]"
			panel.PushUpdate(update)
	src.updateAnnotations()

/datum/flock/proc/isEnemy(var/mob/living/M)
	var/enemy_name = lowertext(M.name)
	return (enemy_name in src.enemies)

// DEATH

/datum/flock/proc/perish()
	//cleanup as necessary
	if(src.flockmind)
		hideAnnotations(src.flockmind)
	for(var/mob/M in src.units)
		hideAnnotations(M)
	all_owned_tiles = null
	busy_tiles = null
	priority_tiles = null
	units = null
	enemies = null
	annotations = null
	flockmind = null
	qdel(src)

// TURFS

/datum/flock/proc/reserveTurf(var/turf/simulated/T, var/name)
	if(T in all_owned_tiles)
		return
	src.busy_tiles[name] = T
	src.updateAnnotations()

/datum/flock/proc/unreserveTurf(var/name)
	src.busy_tiles -= name
	src.updateAnnotations()

/datum/flock/proc/claimTurf(var/turf/simulated/T)
	src.all_owned_tiles |= T
	src.priority_tiles -= T // we have it now, it's no longer priority
	src.updateAnnotations()

/datum/flock/proc/isTurfFree(var/turf/simulated/T, var/queryName) // provide the drone's name here: if they own the turf it's free _to them_
	for(var/name in src.busy_tiles)
		if(name == queryName)
			continue
		if(src.busy_tiles[name] == T)
			return 0
	return 1

/datum/flock/proc/togglePriorityTurf(var/turf/simulated/T)
    if(!T)
        return 1 // error!!
    if(T in priority_tiles)
        priority_tiles -= T
    else
        priority_tiles |= T
    src.updateAnnotations()

// get closest unclaimed tile to requester
/datum/flock/proc/getPriorityTurfs(var/mob/living/critter/flock/drone/requester)
	if(!requester)
		return
	if(src.busy_tiles[requester.name])
		return src.busy_tiles[requester.name] // work on your claimed tile first you JERK
	if(length(priority_tiles))
		var/list/available_tiles = priority_tiles
		for(var/owner in src.busy_tiles)
			available_tiles -= src.busy_tiles[owner]
		return available_tiles

// PROCESS

/datum/flock/proc/process()
	var/list/floors_no_longer_existing = list()
	// check all active floors
	for(var/turf/simulated/floor/feather/T in src.all_owned_tiles)
		if(!T || T.loc == null || T.broken)
			// tile got killed, remove it
			floors_no_longer_existing |= T
			continue
		// check adjacent tiles to see if we've been surrounded and can start generating, or if we're no longer surrounded and can't generate
		// var/validNeighbors = 0
		// var/list/neighbors = getNeighbors(T, cardinal)
		// for(var/turf/simulated/floor/feather/F in neighbors)
		// 	validNeighbors += 1
		// if(validNeighbors < 4 && T.generating)
		// 	T.off()
		// else if(validNeighbors >= 4 && !T.generating)
		// 	T.on()

	if(floors_no_longer_existing.len > 0)
		src.all_owned_tiles -= floors_no_longer_existing

/datum/flock/proc/convert_turf(var/turf/T, var/converterName)
	src.unreserveTurf(converterName)
	src.claimTurf(flock_convert_turf(T))
	playsound(T, "sound/items/Deconstruct.ogg", 70, 1)

////////////////////
// GLOBAL PROCS!!
////////////////////

// made into a global proc so a reagent can use it
// simple enough: if object path matches key, replace with instance of value
// if value is null, just delete object
/var/list/flock_conversion_paths = list(
	/obj/grille = /obj/grille/flock,
	/obj/window = /obj/window/feather,
	/obj/machinery/door/airlock = /obj/machinery/door/feather,
	/obj/machinery/door = null,
	/obj/stool = /obj/stool/chair/comfy/flock,
	/obj/table = /obj/table/flock/auto,
	/obj/lattice = /obj/lattice/flock,
	/obj/machinery/light = /obj/machinery/light/flock,
	/obj/storage/closet = /obj/storage/closet/flock,
	/obj/storage/secure/closet = /obj/storage/closet/flock
	)
/proc/flock_convert_turf(var/turf/T)
	if(!T)
		return

	// take light values to copy over
	var/RL_LumR = T.RL_LumR
	var/RL_LumG = T.RL_LumG
	var/RL_LumB = T.RL_LumB
	var/RL_AddLumR = T.RL_AddLumR
	var/RL_AddLumG = T.RL_AddLumG
	var/RL_AddLumB = T.RL_AddLumB

	for(var/obj/O in T)
		if(istype(O, /obj/machinery/door/feather))
			// repair door
			var/obj/machinery/door/feather/door = O
			door.heal_damage()
			animate_flock_convert_complete(O)
		for(var/keyPath in flock_conversion_paths)
			var/obj/replacementPath = flock_conversion_paths[keyPath]
			if(istype(O, keyPath))
				if(isnull(replacementPath))
					qdel(O)
				else
					var/dir = O.dir
					var/obj/converted = new replacementPath(T)
					// if the object is a closet, it might not have spawned its contents yet
					// so force it to do that first
					if(istype(O, /obj/storage))
						var/obj/storage/S = O
						if(!isnull(S.spawn_contents))
							S.make_my_stuff()
					// if the object has contents, move them over!!
					for (var/obj/OO in O)
						OO.set_loc(converted)
					for (var/mob/M in O)
						M.set_loc(converted)
					qdel(O)
					converted.set_dir(dir)
					animate_flock_convert_complete(converted)

	// if floor, turn to floor, if wall, turn to wall
	if(istype(T, /turf/simulated/floor))
		if(istype(T, /turf/simulated/floor/feather))
			// fix instead of replace
			var/turf/simulated/floor/feather/TF = T
			TF.repair()
			animate_flock_convert_complete(T)
		else
			T.ReplaceWith("/turf/simulated/floor/feather", 0)
			animate_flock_convert_complete(T)
	if(istype(T, /turf/simulated/wall))
		T.ReplaceWith("/turf/simulated/wall/auto/feather", 0)
		animate_flock_convert_complete(T)


	if(istype(T, /turf/space))
		// if we have a fibrenet, make it a floor
		var/obj/lattice/flock/FL = locate(/obj/lattice/flock) in T
		if(istype(FL))
			qdel(FL)
			T.ReplaceWith("/turf/simulated/floor/feather", 0)
			animate_flock_convert_complete(T)
		// if we have no fibrenet, make one
		else
			FL = new(T)
			animate_flock_convert_complete(FL)
	else // don't do this stuff if the turf is space, it fucks it up more
		T.RL_Cleanup()
		T.RL_LumR = RL_LumR
		T.RL_LumG = RL_LumG
		T.RL_LumB = RL_LumB
		T.RL_AddLumR = RL_AddLumR
		T.RL_AddLumG = RL_AddLumG
		T.RL_AddLumB = RL_AddLumB
		if (RL_Started) RL_UPDATE_LIGHT(T)

	return T

/proc/mass_flock_convert_turf(var/turf/T)
	// a terrible idea
	if(!T)
		T = get_turf(usr)
	if(!T)
		return // not sure if this can happen, so it will

	flock_spiral_conversion(T)

/proc/radial_flock_conversion(var/atom/movable/source, var/max_radius=20)
	if(!source) return
	var/turf/T = get_turf(source)
	var/radius = 1
	while(radius <= max_radius)
		var/list/turfs = circular_range(T, radius)
		LAGCHECK(LAG_LOW)
		for(var/turf/tile in turfs)
			if(istype(tile, /turf/simulated) && !isfeathertile(tile))
				flock_convert_turf(tile)
				sleep(0.5)
		LAGCHECK(LAG_LOW)
		radius++
		sleep(radius * 10)
		if(isnull(source))
			return // our source is gone, stop the process


/proc/flock_spiral_conversion(var/turf/T)
	if(!T) return
	// spiral algorithm adapted from https://stackoverflow.com/questions/398299/looping-in-a-spiral
	var/ox = T.x
	var/oy = T.y
	var/x = 0
	var/y = 0
	var/z = T.z
	var/dx = 0
	var/dy = -1
	var/temp = 0

	while(isturf(T))
		if(istype(T, /turf/simulated) && !isfeathertile(T))
			// do stuff to turf
			flock_convert_turf(T)
			sleep(0.2 SECONDS)
		LAGCHECK(LAG_LOW)
		// figure out where next turf is
		if (x == y || (x < 0 && x == -y) || (x > 0 && x == 1-y))
			temp = dx
			dx = -dy
			dy = temp
		x += dx
		y += dy
		// get next turf
		T = locate(ox + x, oy + y, z)


