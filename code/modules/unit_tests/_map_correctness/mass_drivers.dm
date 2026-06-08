/datum/map_correctness_check/mass_drivers
	check_name = "Insufficient Mass Driver Range"

/datum/map_correctness_check/mass_drivers/run_check()
	. = list()

	for (var/obj/machinery/mass_driver/mass_driver as anything in global.machine_registry[MACHINES_MASSDRIVERS])
		if (mass_driver.z != Z_LEVEL_STATION)
			continue

		var/atom/end = global.get_ranged_target_turf(mass_driver, mass_driver.dir, mass_driver.drive_range)
		if (src.is_valid_end(end))
			continue

		var/distance = 0
		var/turf/new_end = end
		while (TRUE)
			new_end = get_step(new_end, mass_driver.dir)
			if (src.is_valid_end(new_end))
				distance = GET_DIST(mass_driver, new_end)
				break

		. += "[src.format_position(mass_driver)] only reaches [end] at ([end.x], [end.y]) - consider a range of [distance] to reach [new_end] ([new_end?.x], [new_end?.y])"

/// Returns TRUE if the passed atom is a valid end point for a mass driver.
/datum/map_correctness_check/mass_drivers/proc/is_valid_end(atom/end)
	if (!istype(end, /turf/space))
		return TRUE
	if (istype(end, /turf/space/fluid/warp_z5))
		return TRUE
	if ((end.x == 1) || (end.x == world.maxx) || (end.y == 1) || (end.y == world.maxy))
		return TRUE

	return FALSE
