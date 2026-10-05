/datum/map_correctness_check/misconfigured_mail_junctions
	check_name = "Misconfigured Mail Junctions"
	check_prefabs = FALSE

/datum/map_correctness_check/misconfigured_mail_junctions/run_check()
	return CI.ERRORS.mail_junctions


#ifdef CI_RUNTIME_CHECKING

/obj/disposalpipe/switch_junction/New()
	if (!isnull(src.mail_tag))
		CI.ERRORS.mail_junctions += "[CI.format_position(src)] has varedited or overriden `mail_tag` value. Use a mailtag mapping helper (/obj/mapping_helper/mailtag) instead."

	. = ..()

#endif
