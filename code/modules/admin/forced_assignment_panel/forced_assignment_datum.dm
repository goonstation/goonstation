// todo
// actually make it apply antag roles

/**
 * For forcing the job controller to assign specific ckeys to specific jobs and antagonist roles.
*/
/datum/forced_assignment
	var/ckey = null
	var/forced_job_input = null
	var/datum/job/forced_job = null
	var/list/forced_antags_input = list()
	var/list/datum/forced_antagonist/forced_antags = list()

/datum/forced_assignment/New(new_ckey = null, new_forced_job = null, list/new_forced_antags = list())
	. = ..()
	src.ckey = ckey(new_ckey)
	if (new_forced_job)
		src.forced_job_input = new_forced_job
	if (istype(src.forced_job_input, /datum/job))
		src.forced_job = src.forced_job_input
	else
		src.forced_job = find_job_in_controller_by_string(src.forced_job_input)
	if (new_forced_antags)
		src.forced_antags_input = new_forced_antags
	var/antags_input_valid = TRUE
	for (var/forced_antags_input_index in src.forced_antags_input)
		if (istype(src.forced_antags_input[forced_antags_input_index], /datum/forced_antagonist))
			continue
		antags_input_valid = FALSE
	if (antags_input_valid)
		src.forced_antags = src.forced_antags_input

/datum/forced_assignment/proc/change_job(new_job_input)
	var/datum/job/new_job
	if (istype(new_job_input, /datum/job))
		new_job = new_job_input
	else
		new_job = find_job_in_controller_by_string(new_job_input)
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
		var/client/C = find_client(forced_assignment.ckey)
		if (!isclient(C))
			continue
		var/mob/new_player/candidate = C.mob
		if (!istype(candidate, /mob/new_player))
			continue
		. -= candidate
		var/datum/job/forced_job = forced_assignment.forced_job
		if (istype(forced_job, /datum/job))
			candidate.mind.assigned_role = forced_job.name
			forced_job.assigned++
			message_admins("[key_name(forced_assignment.ckey)] assigned to job [forced_job].")
			logTheThing(LOG_DEBUG, candidate, "Assigned [candidate] (ckey: [forced_assignment.ckey]) to job [forced_job].")
			logTheThing(LOG_DIARY, candidate, "Assigned [candidate] (ckey: [forced_assignment.ckey]) to job [forced_job].", "admin")
