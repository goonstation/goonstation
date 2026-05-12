/datum/forced_antagonist
	/// Selected antagonist as type path.
	var/antagonist_path = null
	/// Selected antagonist display name.
	var/display_name = ""
	/// Selected antagonist id.
	var/id = ""
	var/do_equipment = FALSE
	var/do_objectives = FALSE
	/// Text for custom antag objective.
	var/custom_objective = "Fuck shit up."

/datum/forced_antagonist/New(antagonist_path_input, do_equipment_input, do_objectives_input, custom_objective_input)
	. = ..()
	if (istext(antagonist_path_input))
		antagonist_path_input = text2path(antagonist_path_input)
	if (!ispath(antagonist_path_input, /datum/antagonist))
		qdel(src)
		return
	src.antagonist_path = antagonist_path_input
	var/datum/antagonist/antagonist_instance = src.antagonist_path
	src.display_name = initial(antagonist_instance.display_name)
	src.id = initial(antagonist_instance.id)
	src.do_equipment = do_equipment_input ? TRUE : FALSE
	src.do_objectives = do_objectives_input ? TRUE : FALSE
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
			candidate.onProcCalled("add_antagonist", list(forced_antagonist.id, forced_antagonist.do_equipment, forced_antagonist.do_objectives, \
				silent = FALSE, source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE))
			var/success = candidate.mind.add_antagonist(forced_antagonist.id, forced_antagonist.do_equipment, forced_antagonist.do_objectives, \
				silent = FALSE, source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE)
			if (!success)
				message_admins("Could not assign forced antagonist [forced_antagonist.display_name] to [key_name(candidate.ckey)]!")
				logTheThing(LOG_DEBUG, candidate, "could not assign forced antagonist [forced_antagonist.display_name] to [key_name(candidate.ckey)].")
				logTheThing(LOG_DIARY, candidate, "could not assign forced antagonist [forced_antagonist.display_name] to [key_name(candidate.ckey)].", "admin")
				continue
			if (length(forced_antagonist.custom_objective))
				new /datum/objective/regular(forced_antagonist.custom_objective, candidate.mind, candidate.mind.get_antagonist(forced_antagonist.id))
				tgui_alert(candidate, "Your objective is: [forced_antagonist.custom_objective]", "Objective")
			antagonist_roles_added += forced_antagonist.display_name
		if (!length(antagonist_roles_added))
			continue
		message_admins("[key_name(forced_assignment.ckey)] assigned antagonist role(s) [english_list(antagonist_roles_added)].")
		logTheThing(LOG_DEBUG, candidate, "assigned [candidate] (ckey: [forced_assignment.ckey]) to antagonist role(s) [english_list(antagonist_roles_added)].")
		logTheThing(LOG_DIARY, candidate, "assigned [candidate] (ckey: [forced_assignment.ckey]) to antagonist role(s) [english_list(antagonist_roles_added)].", \
			"admin")
