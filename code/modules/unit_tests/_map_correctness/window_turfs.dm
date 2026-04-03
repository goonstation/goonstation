/datum/map_correctness_check/window_turfs
	check_name = "Windows On Invalid Turfs"

/datum/map_correctness_check/window_turfs/run_check()
	. = list()

	for_by_tcl(window, /obj/window)
		if (QDELETED(window))
			return

		var/turf/T = window.loc
		if (istype(T, /turf/space) || T.density)
			. += src.format_position(window)


SET_UP_CI_TRACKING(/obj/window)
