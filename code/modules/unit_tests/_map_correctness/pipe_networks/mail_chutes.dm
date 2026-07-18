/datum/map_correctness_check/mail_chutes
	check_name = "Faulty Mail Chutes"
	check_prefabs = FALSE
	skip_check_on = list(
		// Donut2's Zeta Outpost, in not being directly connected via pipe, breaks `mail_tag` routing.
		/datum/map_settings/donut2,
	)

/datum/map_correctness_check/mail_chutes/run_check()
	. = list()

	global.instant_pipe_network()

	var/list/obj/item/pipenet_test_dummy/mail/dummy_list = list()
	for_by_tcl(chute, /obj/machinery/disposal/mail)
		if (chute.z != Z_LEVEL_STATION)
			continue

		for (var/destination as anything in chute.destinations)
			dummy_list += new /obj/item/pipenet_test_dummy/mail(chute, destination)
			chute.destination_tag = destination
			chute.flush(destination)

	sleep(5 SECONDS)
	for (var/obj/item/pipenet_test_dummy/mail/dummy as anything in dummy_list)
		if (istype(dummy.ejection_chute) && (dummy.ejection_chute.mail_tag == dummy.destination_tag))
			continue

		var/endpoint = null
		if (istype(dummy.ejection_chute))
			endpoint = "[src.format_position(dummy.ejection_chute, FALSE)] with mail_tag \"[dummy.ejection_chute.mail_tag]\""
		else if (dummy.ejection_turf)
			endpoint = "([dummy.ejection_turf.x], [dummy.ejection_turf.y], [dummy.ejection_turf.z]) in [dummy.ejection_turf.loc]"
		else
			endpoint = "(null)"

		. += "[src.format_position(dummy.chute)] misroutes objects addressed to \"[dummy.destination_tag]\" to [endpoint]."


SET_UP_CI_TRACKING(/obj/machinery/disposal/mail)
