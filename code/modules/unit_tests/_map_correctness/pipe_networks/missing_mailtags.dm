/datum/map_correctness_check/mailtags_chutes
	check_name = "Mail Chutes Without Mailtags"
	check_prefabs = FALSE

/datum/map_correctness_check/mailtags_chutes/run_check()
	. = list()

	for_by_tcl(chute, /obj/machinery/disposal/mail)
		if (istype(chute, /obj/machinery/disposal/mail/qm))
			continue

		if (locate(/obj/mapping_helper/mailtag) in chute.loc)
			continue

		. += CI.format_position(chute)
