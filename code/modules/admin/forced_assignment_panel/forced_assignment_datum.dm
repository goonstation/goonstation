/**
 * For forcing the job controller to assign specific ckeys to specific jobs.
*/
/datum/forced_assignment
	var/ckey = null
	var/forced_job_input = null
	var/datum/job/forced_job = null

/datum/forced_assignment/New(new_ckey = null, new_forced_job = null, list/new_forced_antag_roles = list())
	. = ..()
	src.ckey = new_ckey
	if (new_forced_job)
		src.forced_job = find_job_in_controller_by_string(new_forced_job)
	if (src.ckey)
		return
	if (src in job_controls.forced_assignments)
		logTheThing(LOG_DEBUG, src, "Forced assignment generated without ckey! Removing from forced assignments list!")
		job_controls.forced_assignments -= src
		qdel(src)

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
		else
			message_admins("[key_name(forced_assignment.ckey)] assigned to no job at all.")
			logTheThing(LOG_DEBUG, candidate, "Assigned [candidate] (ckey: [forced_assignment.ckey]) to no job at all.")
			logTheThing(LOG_DIARY, candidate, "Assigned [candidate] (ckey: [forced_assignment.ckey]) to no job at all.", "admin")
