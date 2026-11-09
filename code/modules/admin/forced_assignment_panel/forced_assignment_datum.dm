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
	global.bypassCapCkeys |= src.ckey

/datum/forced_assignment/disposing()
	global.bypassCapCkeys -= src.ckey
	..()

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
			logTheThing(LOG_DIARY, candidate, "forcefully assigned [candidate] (ckey: [forced_assignment.ckey]) to job [forced_job].", "admin")

/datum/forced_assignment/proc/notify_forced_assignment_holder()
	var/client/holder_client = find_client(src.ckey)

	if (!isclient(holder_client))
		return

	var/forced_job_text = src.forced_job ? "Your assigned job is [src.forced_job.name]! " : ""

	var/list/forced_antag_display_names = list()
	for (var/forced_antag_id in src.forced_antags)
		var/datum/forced_antagonist/forced_antag = src.forced_antags[forced_antag_id]
		if (!istype(forced_antag, /datum/forced_antagonist))
			continue
		forced_antag_display_names += forced_antag.display_name

	var/forced_antag_text = length(forced_antag_display_names) ? "Your antagonist role is: [english_list(forced_antag_display_names)]! " : ""

	var/output = "You are set to be forced-spawned! [forced_job_text][forced_antag_text]Please AHelp if this is unexpected!"

	holder_client.mob?.playsound_local_not_inworld('sound/misc/prayerchime.ogg', 100, flags = SOUND_IGNORE_SPACE | SOUND_SKIP_OBSERVERS | SOUND_IGNORE_DEAF)
	boutput(holder_client.mob, SPAN_BLOBALERT(output))


/client/proc/cmd_notify_forced_assignment_holders()
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Notify Forced Assignment Holders"
	set desc = "Subtly message everyone who holds a forced assignment."
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (src.holder.level < LEVEL_MOD)
		return
	if (global.current_state >= GAME_STATE_SETTING_UP)
		boutput(src, SPAN_ALERT("The round is already in progress!"))
		return
	if (!length(job_controls.forced_assignments))
		return

	for (var/forced_assignment_key in job_controls.forced_assignments)
		var/datum/forced_assignment/forced_assignment = job_controls.forced_assignments[forced_assignment_key]
		if (!istype(forced_assignment, /datum/forced_assignment))
			continue
		forced_assignment.notify_forced_assignment_holder()

	message_admins("Admin [key_name(src)] sent out notifications to all forced assignment holders!")
