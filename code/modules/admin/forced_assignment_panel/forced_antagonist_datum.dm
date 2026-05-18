/datum/forced_antagonist
	/// Selected antagonist display name.
	var/display_name = ""
	/// Selected antagonist id.
	var/id = ""
	var/do_equipment = FALSE
	var/do_objectives = FALSE
	/// Text for custom antag objective.
	var/custom_objective = ""

/datum/forced_antagonist/New(antagonist_id_input, do_equipment_input, do_objectives_input, custom_objective_input)
	. = ..()
	if (!istext(antagonist_id_input))
		qdel(src)
		return
	var/datum/antagonist/antagonist_instance = get_antagonist_datum_type(antagonist_id_input)
	if (!ispath(antagonist_instance, /datum/antagonist))
		qdel(src)
		return
	src.display_name = initial(antagonist_instance.display_name)
	src.id = initial(antagonist_instance.id)
	src.do_equipment = do_equipment_input
	src.do_objectives = do_objectives_input
	if (istext(custom_objective_input))
		src.custom_objective = custom_objective_input

/**
 * Assigns forced antagonist roles at roundstart based off of existing `/datum/forced_assignment`s in `job_controls`. Cargo cult from
 * `code\modules\admin\admin.dm`.
 */
/proc/handle_forced_antag_assignments()
	if (!length(job_controls.forced_assignments))
		return

	for (var/forced_assignment_ckey in job_controls.forced_assignments)
		var/datum/forced_assignment/forced_assignment = job_controls.forced_assignments[forced_assignment_ckey]
		if (!istype(forced_assignment, /datum/forced_assignment))
			continue
		if (!length(forced_assignment.forced_antags))
			continue
		var/client/candidate_client = find_client(forced_assignment.ckey)
		if (!isclient(candidate_client))
			continue
		var/mob/candidate = candidate_client.mob
		if (!ismob(candidate))
			continue
		var/antagonist_roles_added = list()
		for (var/forced_antagonist_index in forced_assignment.forced_antags)
			var/datum/forced_antagonist/forced_antagonist = forced_assignment.forced_antags[forced_antagonist_index]
			if (!istype(forced_antagonist, /datum/forced_antagonist))
				continue
			var/success = candidate.mind.add_antagonist(forced_antagonist.id, forced_antagonist.do_equipment, forced_antagonist.do_objectives, \
				source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE)
			if (!success)
				message_admins("Could not assign forced antagonist [forced_antagonist.display_name] to [key_name(candidate.ckey)]!")
				logTheThing(LOG_DEBUG, candidate, "could not assign forced antagonist [forced_antagonist.display_name] to [key_name(candidate.ckey)].")
				logTheThing(LOG_DIARY, candidate, "could not assign forced antagonist [forced_antagonist.display_name] to [key_name(candidate.ckey)].", "admin")
				continue
			if (length(forced_antagonist.custom_objective))
				SPAWN(0)
					new /datum/objective/regular(forced_antagonist.custom_objective, candidate.mind, candidate.mind.get_antagonist(forced_antagonist.id))
					tgui_alert(candidate, "Your objective is: [forced_antagonist.custom_objective]", "Objective")
			antagonist_roles_added += forced_antagonist.display_name
		if (!length(antagonist_roles_added))
			continue
		message_admins("[key_name(forced_assignment.ckey)] assigned antagonist role(s) [english_list(antagonist_roles_added)].")
		logTheThing(LOG_DEBUG, candidate, "assigned [candidate] (ckey: [forced_assignment.ckey]) to antagonist role(s) [english_list(antagonist_roles_added)].")
		logTheThing(LOG_DIARY, candidate, "assigned [candidate] (ckey: [forced_assignment.ckey]) to antagonist role(s) [english_list(antagonist_roles_added)].", \
			"admin")
