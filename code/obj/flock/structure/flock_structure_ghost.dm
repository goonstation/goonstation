/obj/flock_structure/ghost
	name = "weird lookin ghost building"
	desc = "It's some weird looking ghost building. Seems like its under construction, You can see faint strands of material floating in it."
	flock_desc = "A Flock structure not yet realised. Provide it resources to bring it into existence."
	var/goal = 0 //mats needed to make the thing actually build
	var/obj/flock_structure/building = null //thing thats being built
	var/currentmats = 0 //mats currently in the thing.
	var/fake = FALSE
	flock_id = "Construction Tealprint"
	density = FALSE


/obj/flock_structure/ghost/building_specific_info()
	return {"<span class='bold'>Construction Percentage:</span> [!src.goal == 0 ? round((src.currentmats/src.goal)*100) : 0]%
	<br><span class='bold'>Construction Progress:</span> [currentmats] materials added, [goal] needed"}

/obj/flock_structure/ghost/New(atom/location, datum/flock/F, obj/flock_structure/building = null, goal = 0)
	..(location, F)
	START_TRACKING
	if(building)
		var/obj/flock_structure/b = building
		icon = initial(b.icon)
		icon_state = initial(b.icon_state)
		src.color = COLOR_MATRIX_FLOCKMIND
		src.alpha = 104
		src.goal = goal
		src.building = building
		src.bound_width = initial(b.bound_width)
		src.bound_height = initial(b.bound_height)
		src.pixel_x = initial(b.pixel_x)
		src.pixel_y = initial(b.pixel_y)
		src.bound_x = initial(b.bound_x)
		src.bound_y = initial(b.bound_y)
	else
		flock_speak(null, "ERROR: No Structure Tealprint Assigned, Deleting", flock)
		qdel(src)
		return

	//bounds checking goes here
	var/blocked = FALSE
	for(var/turf/T in src.locs)
		if(flock_is_blocked_turf(T))
			blocked = TRUE
			T.AddComponent(/datum/component/flock_ping/obstruction)

	if(blocked)
		qdel(src)
		flock_speak(null, "ERROR: Build area is blocked by an obstruction.", flock)

	if (src.flock)
		if(building == /obj/flock_structure/relay)
			src.flock.relay_in_progress = TRUE
			src.uses_health_icon = FALSE
			src.flock.removeAnnotation(src, FLOCK_ANNOTATION_HEALTH)
			src.info_tag?.set_tag_offset(64, -4) // see comments for same numbers in relay file

	src.info_tag?.set_info_tag("Resources: [src.currentmats]/[src.goal]")

/obj/flock_structure/ghost/disposing()
	if (src.flock)
		if (src.flock.relay_in_progress && src.building == /obj/flock_structure/relay && !(locate(/obj/flock_structure/relay) in src.flock.structures))
			src.flock.relay_in_progress = FALSE
	STOP_TRACKING
	. = ..()

/obj/flock_structure/ghost/deconstruct()
	cancelBuild()

/obj/flock_structure/ghost/gib()
	visible_message("<span class='alert'>[src] suddenly dissolves!</span>")
	playsound(src.loc, 'sound/impact_sounds/Glass_Shatter_2.ogg', 80, 1)
	if (currentmats > 0)
		var/obj/item/flockcache/cache = new(get_turf(src))
		cache.resources = src.currentmats
	qdel(src)

/obj/flock_structure/ghost/proc/updatealpha()
	alpha = lerp(104, 255, currentmats / goal)

/obj/flock_structure/ghost/proc/add_mats(mats)
	if (src.fake)
		return
	src.currentmats += mats

	if(currentmats > goal)
		var/obj/item/flockcache/c = new(get_turf(src))
		flock_speak(src, "ALERT: Material excess detected, ejecting excess", flock)
		c.resources = (currentmats - goal)
		src.completebuild()
		return
	else if(currentmats == goal)
		src.completebuild()
		return

	updatealpha()
	src.info_tag.set_info_tag("Resources: [src.currentmats]/[src.goal]")

/obj/flock_structure/ghost/proc/completebuild()
	if(src.building)
		var/obj/flock_structure/structure = new src.building(get_turf(src), src.flock)
		if (src.flock) //can't do flock?.stats due to http://www.byond.com/forum/post/2841585
			src.flock.stats.structures_made++
			src.flock.flockmind?.tutorial?.PerformSilentAction(FLOCK_ACTION_TEALPRINT_COMPLETE, structure)
	qdel(src)

/obj/flock_structure/ghost/proc/cancelBuild()
	var/typeinfo/obj/flock_structure/info = get_type_typeinfo(src.building)
	if (!info.cancellable)
		return
	if (currentmats > 0)
		var/obj/item/flockcache/cache = new(get_turf(src))
		cache.resources = currentmats
	flock_speak(src, "Tealprint derealizing", flock)
	playsound(src, 'sound/misc/flockmind/flockdrone_door_deny.ogg', 30, 1, extrarange = -10)
	qdel(src)
