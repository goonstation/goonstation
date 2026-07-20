/datum/map_correctness_check/disposal_chutes
	check_name = "Faulty Disposal Chutes"
	check_prefabs = FALSE

/datum/map_correctness_check/disposal_chutes/run_check()
	. = list()

	global.instant_pipe_network()

	if (!length(global.landmarks[LANDMARK_DISPOSALS_ENDPOINT]))
		. += "No disposals endpoints configured."
		return

	var/list/obj/item/pipenet_test_dummy/dummy_list = list()
	for_by_tcl(chute, /obj/machinery/disposal)
		// Only check *disposal* disposal chutes. An abstract base class will eventually be made for chutes.
		if (!istype_exact(chute, /obj/machinery/disposal) && !istype(chute, /obj/machinery/disposal/small))
			continue

		if (chute.z != Z_LEVEL_STATION)
			continue

		dummy_list += new /obj/item/pipenet_test_dummy(chute)
		SPAWN(0)
			chute.flush()

	sleep(5 SECONDS)
	for (var/obj/item/pipenet_test_dummy/dummy as anything in dummy_list)
		var/turf/T = get_turf(dummy)
		if (T in global.landmarks[LANDMARK_DISPOSALS_ENDPOINT])
			continue

		var/endpoint = T ? "([T.x], [T.y], [T.z]) in [T.loc]" : "(null)"
		. += "[src.format_position(dummy.chute)] sends objects to non-disposals-endpoint at [endpoint]."


/obj/landmark/disposals_endpoint
	name = LANDMARK_DISPOSALS_ENDPOINT
	desc = "The turf that objects flushed down a disposal chute should end up. Usually the last bit of conveyor belt in front of the crusher door."
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "disposals_endpoint"
#ifdef CI_RUNTIME_CHECKING
	add_to_landmarks = TRUE
#else
	add_to_landmarks = FALSE
#endif
