/obj/machinery/mass_driver
	name = "mass driver"
	icon = 'icons/obj/stationobjs.dmi'
	desc = "A device that launches objects on it at great velocity when activated."
	icon_state = "mass_driver"
	machine_registry_idx = MACHINES_MASSDRIVERS
	var/power = 1
	var/code = 1
	var/id = 1
	anchored = 1
	layer = 2.6
	var/drive_range = 200 //this is mostly irrelevant since current mass drivers throw into space, but you could make a lower-range mass driver for interstation transport or something I guess.
	plane = PLANE_NOSHADOW_BELOW

/obj/machinery/mass_driver/proc/drive(amount)
	if(status & (BROKEN|NOPOWER))
		return
	use_power(500)
	var/O_limit
	var/atom/target = get_edge_target_turf(src, src.dir)
	for(var/atom/movable/O in src.loc)
		if(O.anchored || isobserver(O) || isintangible(O) || HAS_ATOM_PROPERTY(O, PROP_ATOM_FLOATING)) continue
		O_limit++
		if(O_limit >= 20)
			for(var/mob/M in hearers(src, null))
				boutput(M, "<span class='notice'>The mass driver lets out a screech, it mustn't be able to handle any more items.</span>")
			break
		use_power(500)
		O.throw_at(target, drive_range * src.power, src.power)
	flick("mass_driver1", src)
	return
