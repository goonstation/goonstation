/// Minimum gravity for the area.
/area/var/gforce_minimum = 1
/// Gravity supplied by registered tethers.
/area/var/gforce_tether = 0

/area/space/gforce_minimum = 0
/area/noGenerate/gforce_minimum = 0
/area/allowGenerate/gforce_minimum = 0
/area/abandonedship/gforce_minimum = 0
/area/abandonedmedicalship/gforce_minimum = 0
/area/abandonedmedicalship/robot_trader/gforce_minimum = 1 // for D.O.C., who is on the ISS and not the abandoned medical ship
/area/fermid_hive/gforce_minimum = 0

/// List of gravity tethers tracking this region
/area/var/list/obj/machinery/gravity_tether/registered_tethers = list()

/// Reset all turf gravity based on cached area gravity values
/area/proc/reset_all_turf_gravity()
	src.set_turf_gravity(src.gforce_tether)

/// Recalculate the tether gforces on an area
/area/proc/recalc_tether_gforce()
	var/new_gforce = 0
	for (var/obj/machinery/gravity_tether/tether in src.registered_tethers)
		if (tether.has_no_power())
			continue
		new_gforce += tether.intensity
	if (src.gforce_tether != new_gforce)
		src.gforce_tether = new_gforce
		src.set_turf_gravity(src.gforce_tether)

/area/proc/set_turf_gravity(gforce)
	for (var/turf/T in src)
		T.set_gravity(src.gforce_minimum, gforce)

/area/proc/register_tether(obj/machinery/gravity_tether/tether)
	src.registered_tethers |= tether
	src.recalc_tether_gforce()

/area/proc/unregister_tether(obj/machinery/gravity_tether/tether)
	src.registered_tethers -= tether
	src.recalc_tether_gforce()

/area/proc/set_gforce_minimum(new_gforce)
	if (src.gforce_minimum != new_gforce)
		src.gforce_minimum = new_gforce
		src.reset_all_turf_gravity()
