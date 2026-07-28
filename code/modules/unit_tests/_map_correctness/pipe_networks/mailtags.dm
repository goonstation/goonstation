/datum/map_correctness_check/mailtags
	check_name = "Misconfigured Mail Chutes"
	check_prefabs = FALSE

/datum/map_correctness_check/mailtags/run_check()
	. = list()

	for_by_tcl(chute, /obj/machinery/disposal/mail)
		if ((chute.z != Z_LEVEL_STATION))
			continue

		var/position = src.format_position(chute)
		for (var/error as anything in chute.ci_errors)
			. += position + error


/// A list of correctness check errors that this mail chute has run into. Only populated if `CI_RUNTIME_CHECKING` is enabled.
/obj/machinery/disposal/mail/var/list/ci_errors = null

#ifdef CI_RUNTIME_CHECKING

/obj/machinery/disposal/mail/New()
	src.run_checks()
	. = ..()

/obj/machinery/disposal/mail/proc/run_checks()
	src.ci_errors = list()

	if (!(locate(/obj/mapping_helper/mailtag) in src.loc))
		src.ci_errors += " has no mailtag mapping helper (/obj/mapping_helper/mailtag)."

	if (!isnull(src.mail_tag))
		src.ci_errors += " has varedited or overriden `mail_tag` value. Use a mailtag mapping helper (/obj/mapping_helper/mailtag) instead."

	if (!isnull(src.mailgroup))
		src.ci_errors += " has varedited or overriden `mailgroup` value. Use a mailtag mapping helper (/obj/mapping_helper/mailtag) instead."

	if (!isnull(src.mailgroup2))
		src.ci_errors += " has varedited or overriden `mailgroup2` value. Use a mailtag mapping helper (/obj/mapping_helper/mailtag) instead."

	if (!isnull(src.message))
		src.ci_errors += " has varedited or overriden `message` value. Use a mailtag mapping helper (/obj/mapping_helper/mailtag) instead."


/obj/machinery/disposal/mail/qm/run_checks()
	return

#endif
