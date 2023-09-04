
//TODO: Repath to /unary
/obj/machinery/atmospherics/pipe/vent
	icon = 'icons/obj/atmospherics/pipe_vent.dmi'
	icon_state = "intact"
	name = "Vent"
	desc = "A large air vent"
	level = UNDERFLOOR
	volume = 250
	var/obj/machinery/atmospherics/node1

/obj/machinery/atmospherics/pipe/vent/New()
	..()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/vent/process()
	..()
	if(parent)
		parent.mingle_with_turf(loc, 250)

/obj/machinery/atmospherics/pipe/vent/disposing()
	node1?.disconnect(src)
	parent = null
	..()

/obj/machinery/atmospherics/pipe/vent/pipeline_expansion()
	return list(node1)

/obj/machinery/atmospherics/pipe/vent/update_icon()
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/atmospherics/pipe/vent/initialize()
	var/connect_direction = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break

	UpdateIcon()

/obj/machinery/atmospherics/pipe/vent/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			if (parent)
				parent.dispose()
			parent = null
		node1 = null

	UpdateIcon()

/obj/machinery/atmospherics/pipe/vent/hide(var/intact) //to make the little pipe section invisible, the icon changes.
	if (intact && issimulatedturf(src.loc) && level == UNDERFLOOR)
		src.icon_state = "hvent"
	else
		src.icon_state = src.node1 ? "intact" : ""
