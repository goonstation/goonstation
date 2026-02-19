TYPEINFO(/obj/laser_sink/splitter)
	mats = list("metal" = 20,
				"crystal_dense" = 20,
				"reflective" = 30)
/obj/laser_sink/splitter
	name = "beam splitter"
	icon = 'icons/obj/lasers/laser_devices.dmi'
	icon_state = "laser_splitter"
	density = 1
	var/obj/linked_laser/left = null
	var/obj/linked_laser/right = null

//todo: componentize anchoring behaviour
/obj/laser_sink/splitter/attackby(obj/item/I, mob/user)
	if (isscrewingtool(I))
		playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
		user.visible_message(SPAN_NOTICE("[user] [src.anchored ? "un" : ""]screws [src] [src.anchored ? "from" : "to"] the floor."))
		src.anchored = !src.anchored
	else if (ispryingtool(I))
		if (ON_COOLDOWN(src, "rotate", 0.3 SECONDS))
			return
		playsound(src, 'sound/items/Crowbar.ogg', 50, TRUE)
		src.set_dir(turn(src.dir, 90))
		if (src.in_laser)
			src.exident(src.in_laser)
		var/obj/linked_laser/found_laser = locate() in get_step(src, turn(src.dir, 180))
		if (found_laser)
			src.incident(found_laser)
	else
		..()

/obj/laser_sink/splitter/incident(obj/linked_laser/laser)
	if (src.in_laser)
		return FALSE
	if (laser.dir != src.dir)
		return FALSE

	src.in_laser = laser

	src.left = src.in_laser.copy_laser(get_turf(src), turn(src.dir, -90))
	src.left.power = laser.power / 2
	src.left.icon = null
	src.left.try_propagate()

	src.right = src.in_laser.copy_laser(get_turf(src), turn(src.dir, 90))
	src.right.power = laser.power / 2
	src.right.icon = null
	src.right.try_propagate()

	return TRUE

/obj/laser_sink/splitter/exident(obj/linked_laser/laser)
	qdel(src.left)
	qdel(src.right)
	src.left = null
	src.right = null
	..()

/obj/laser_sink/splitter/traverse(proc_to_call)
	src.left.traverse(proc_to_call)
	src.right.traverse(proc_to_call)
