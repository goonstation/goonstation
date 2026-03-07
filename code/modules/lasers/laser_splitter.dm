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

/obj/laser_sink/splitter/New()
	..()
	RegisterSignal(src, COMSIG_LASER_CONNECTED, PROC_REF(on_laser_incident))
	RegisterSignal(src, COMSIG_LASER_DISCONNECTED, PROC_REF(on_laser_exident))
	RegisterSignal(src, COMSIG_LASER_TRAVERSE, PROC_REF(on_laser_traverse))

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
		for (var/obj/linked_laser/laser in src.laser_sink_comp.in_lasers)
			SEND_SIGNAL(src, COMSIG_LASER_EXIDENT, laser)
		var/obj/linked_laser/found_laser = locate() in get_step(src, turn(src.dir, 180))
		if (found_laser)
			SEND_SIGNAL(src, COMSIG_LASER_INCIDENT, found_laser)
	else
		..()

/obj/laser_sink/splitter/proc/on_laser_incident(datum/source, obj/linked_laser/laser)
	if (laser.dir != src.dir)
		return COMPONENT_LASER_BLOCKED

	src.left = laser.copy_laser(get_turf(src), turn(src.dir, -90))
	src.left.previous = laser
	src.left.power = laser.power / 2
	src.left.icon = null
	src.left.try_propagate()

	src.right = laser.copy_laser(get_turf(src), turn(src.dir, 90))
	src.right.previous = laser
	src.right.power = laser.power / 2
	src.right.icon = null
	src.right.try_propagate()

/obj/laser_sink/splitter/proc/on_laser_exident(datum/source, obj/linked_laser/laser)
	qdel(src.left)
	qdel(src.right)
	src.left = null
	src.right = null

/obj/laser_sink/splitter/proc/on_laser_traverse(datum/source, proc_to_call)
	src.left.traverse(proc_to_call)
	src.right.traverse(proc_to_call)
