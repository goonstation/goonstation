/obj/machinery/mass_driver
	name = "mass driver"
	icon = 'icons/obj/stationobjs.dmi'
	desc = "A device that launches objects on it at great velocity when activated."
	icon_state = "mass_driver"
	machine_registry_idx = MACHINES_MASSDRIVERS
	var/power = 1
	var/code = 1
	var/id = 1
	anchored = ANCHORED
	layer = 2.6
	var/drive_range = 200 //only relevant for drivers launching over solid ground on terrestrial maps and terrainify
	var/bonus_range = 1 // when tossing stuff over turfs with gravity, add this range
	var/throw_type = THROW_NORMAL
	var/throw_params = null

/obj/machinery/mass_driver/proc/drive()
	if(status & (BROKEN|NOPOWER))
		return
	use_power(500)
	var/O_limit
	var/atom/target = get_edge_target_turf(src, src.dir)
	for(var/atom/movable/O in src.loc)
		if(O.anchored || HAS_ATOM_PROPERTY(O, PROP_ATOM_FLOATING)) continue
		O_limit++
		if(O_limit >= 20)
			src.visible_message(SPAN_NOTICE("The mass driver lets out a screech, it mustn't be able to handle any more items."))
			break
		use_power(500)
		O.throw_at(target, src.get_throw_range(), src.power, throw_type=src.throw_type, params=src.throw_params)
	FLICK("mass_driver1", src)
	return

/obj/machinery/mass_driver/proc/get_throw_range()
	if (global.zlevels[src.z].gforce > 0)
		return src.drive_range * src.power
	return src.power + src.bonus_range
