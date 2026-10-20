/datum/map_correctness_check/misconfigured_mail_chutes
	check_name = "Misconfigured Mail Chutes"
	check_prefabs = FALSE

/datum/map_correctness_check/misconfigured_mail_chutes/run_check()
	return CI.ERRORS.mail_chutes


#ifdef CI_RUNTIME_CHECKING

/obj/machinery/disposal/mail/New()
	if (src.z == Z_LEVEL_STATION)
		src.run_checks()

	. = ..()

/obj/machinery/disposal/mail/proc/run_checks()
	var/position = CI.format_position(src)

	if (!isnull(src.mail_tag))
		CI.ERRORS.mail_chutes += "[position] has varedited or overriden `mail_tag` value. Use a mailtag mapping helper (/obj/mapping_helper/mailtag) instead."

	if (!isnull(src.mailgroup))
		CI.ERRORS.mail_chutes += "[position] has varedited or overriden `mailgroup` value. Use a mailtag mapping helper (/obj/mapping_helper/mailtag) instead."

	if (!isnull(src.mailgroup2))
		CI.ERRORS.mail_chutes += "[position] has varedited or overriden `mailgroup2` value. Use a mailtag mapping helper (/obj/mapping_helper/mailtag) instead."

	if (!isnull(src.message))
		CI.ERRORS.mail_chutes += "[position] has varedited or overriden `message` value. Use a mailtag mapping helper (/obj/mapping_helper/mailtag) instead."


/obj/machinery/disposal/mail/qm/run_checks()
	return

#endif
