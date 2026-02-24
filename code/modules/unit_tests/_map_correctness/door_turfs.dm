/datum/map_correctness_check/door_turfs
	check_name = "Doors On Invalid Turfs"

/datum/map_correctness_check/door_turfs/run_check()
	. = list()

	for_by_tcl(door, /obj/machinery/door)
		var/turf/T = door.loc
		if ((istype(T, /turf/space) && !istype(door, /obj/machinery/door/poddoor)) || T.density)
			. += src.format_position(door)
