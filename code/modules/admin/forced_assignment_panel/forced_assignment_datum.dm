// todo
// actually make it apply antag roles

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

/proc/handle_forced_antag_assignments()
	return
