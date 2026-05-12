/**
 * For forcing the job controller to assign specific ckeys to specific jobs and antagonist roles.
*/
/datum/forced_assignment
	var/ckey = null
	var/datum/job/forced_job = null
	var/list/datum/forced_antagonist/forced_antags = list()

/datum/forced_assignment/New(new_ckey = null, new_forced_job = null, list/new_forced_antags = list())
	. = ..()
	src.ckey = ckey(new_ckey)
	if (istype(new_forced_job, /datum/job))
		src.forced_job = new_forced_job
	var/antags_input_valid = TRUE
	for (var/forced_antags_input_index in new_forced_antags)
		if (istype(new_forced_antags[forced_antags_input_index], /datum/forced_antagonist))
			continue
		antags_input_valid = FALSE
	if (antags_input_valid)
		src.forced_antags = new_forced_antags

/datum/forced_assignment/proc/change_job(datum/job/new_job)
	if (!istype(new_job, /datum/job))
		return
	src.forced_job = new_job

/// Assigns forced jobs at roundstart based off of existing `/datum/forced_assignment`s in `job_controls`.
/proc/handle_forced_job_assignments(list/unassigned_personnel)
	. = unassigned_personnel

	if (!length(job_controls.forced_assignments))
		return

	for (var/forced_assignment_ckey in job_controls.forced_assignments)
		var/datum/forced_assignment/forced_assignment = job_controls.forced_assignments[forced_assignment_ckey]
		if (!istype(forced_assignment, /datum/forced_assignment))
			continue
		var/client/candidate_client = find_client(forced_assignment.ckey)
		if (!isclient(candidate_client))
			continue
		var/mob/new_player/candidate = candidate_client.mob
		if (!istype(candidate, /mob/new_player))
			continue
		var/datum/job/forced_job = forced_assignment.forced_job
		if (istype(forced_job, /datum/job))
			. -= candidate
			forced_job.assigned++
			candidate.mind.assigned_role = forced_job.name
			message_admins("[key_name(forced_assignment.ckey)] assigned to job [forced_job].")
			logTheThing(LOG_DEBUG, candidate, "assigned [candidate] (ckey: [forced_assignment.ckey]) to job [forced_job].")
			logTheThing(LOG_DIARY, candidate, "assigned [candidate] (ckey: [forced_assignment.ckey]) to job [forced_job].", "admin")

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
				source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE))
			var/success = candidate.mind.add_antagonist(forced_antagonist.id, forced_antagonist.do_equipment, forced_antagonist.do_objectives, \
				source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE)
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
