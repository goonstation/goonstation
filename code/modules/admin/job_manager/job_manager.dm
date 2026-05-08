
/datum/job_manager

/datum/job_manager/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/job_manager/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/job_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "JobManager")
		ui.open()

#define JOB_DATA list(list(name = job.name, type = job.job_category, count = countJob(job.name), limit = job.limit))
/datum/job_manager/ui_data(mob/user)
	var/list/staple_job_data = list()
	var/list/special_job_data = list()
	var/list/categorised_special_job_data = list()
	var/list/hidden_job_data = list()
	var/list/staple_job_categories = list(JOB_COMMAND, JOB_SECURITY, JOB_RESEARCH, JOB_MEDICAL, JOB_ENGINEERING, JOB_CIVILIAN)
	// If adding more, make sure to add the category in JobManager.tsx
	var/list/special_job_categories = list(JOB_NANOTRASEN, JOB_SYNDICATE, JOB_HALLOWEEN, JOB_CLOWN, JOB_RANDOM, JOB_DAILY)
	for (var/datum/job/job in job_controls.staple_jobs)
		if(!(job.job_category in staple_job_categories))// If its not in this list its not a staple job so should be sorted under special jobs
			if(job.job_category in special_job_categories)
				categorised_special_job_data += JOB_DATA
			else
				special_job_data += JOB_DATA
			continue
		staple_job_data += JOB_DATA
	for (var/datum/job/job in job_controls.special_jobs)
		if(job.job_category in special_job_categories)
			categorised_special_job_data += JOB_DATA
			continue
		special_job_data += JOB_DATA
	for (var/datum/job/job in job_controls.hidden_jobs)
		hidden_job_data += JOB_DATA
	. = list(
		"stapleJobs" = staple_job_data,
		"specialJobs" = special_job_data,
		"categorisedSpecialJobs" = categorised_special_job_data,
		"hiddenJobs" = hidden_job_data,
		"allowSpecialJobs" = job_controls.allow_special_jobs,
		"forcedAssignments" = src.serialise_forced_assignments(),
	)
#undef JOB_DATA

/datum/job_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	USR_ADMIN_ONLY
	switch(action)
		if ("alter_cap")
			var/datum/job/job = find_job_in_controller_by_string(params["job"])
			var/newcap = tgui_input_number(ui.user, "Enter a new job cap", "Alter Cap", job.limit, 100, -1)
			if (isnull(newcap)) return
			job.limit = newcap
			job.admin_set_limit = TRUE
			message_admins("Admin [key_name(ui.user)] altered [job.name] job cap to [newcap]")
			logTheThing(LOG_ADMIN, ui.user, "altered [job.name] job cap to [newcap]")
			logTheThing(LOG_DIARY, ui.user, "altered [job.name] job cap to [newcap]", "admin")
			. = TRUE

		if ("edit")
			var/datum/job/job = find_job_in_controller_by_string(params["job"])
			// invoke the job creator through its accursed var edit proc call thing...
			job_controls.job_creator = job
			job_controls.job_creator()

		if ("job_creator")
			// need to ensure theres no existing reference to an existing job...
			job_controls.job_creator = new
			job_controls.job_creator()

		if ("toggle_special_jobs")
			job_controls.allow_special_jobs = !job_controls.allow_special_jobs
			message_admins("Admin [key_name(ui.user)] toggled Special Jobs [job_controls.allow_special_jobs ? "On" : "Off"]")
			logTheThing(LOG_ADMIN, ui.user, "toggled Special Jobs [job_controls.allow_special_jobs ? "On" : "Off"]")
			logTheThing(LOG_DIARY, ui.user, "toggled Special Jobs [job_controls.allow_special_jobs ? "On" : "Off"]", "admin")
			. = TRUE

		if ("remove_job")
			var/datum/job/job = find_job_in_controller_by_string(params["job"])
			if (!istype(job, /datum/job/created))
				return
			message_admins("Admin [key_name(ui.user)] removed special job [job.name]")
			logTheThing(LOG_ADMIN, ui.user, "removed special job [job.name]")
			logTheThing(LOG_DIARY, ui.user, "removed special job [job.name]", "admin")
			job_controls.special_jobs -= job
			job_controls.hidden_jobs -= job
			. = TRUE

		if ("add_forced_assignment")
			var/ckey = ckey(tgui_input_text(usr, "Designate ckey to assign forced assignment.", "Designate ckey"))
			if (!ckey)
				return FALSE
			if (global.job_controls.forced_assignments[ckey])
				boutput(usr, SPAN_ALERT("Requested ckey [ckey] already has a forced assignment!"))
				return FALSE
			var/datum/job/assignment = tgui_input_list(usr, "Designate forced job to assign.", "Designate job", \
										(global.job_controls.staple_jobs|global.job_controls.special_jobs|global.job_controls.hidden_jobs))
			var/assignment_name = assignment.name
			if (tgui_alert(usr, "Create forced assignment with parameters (ckey: [ckey], job: [assignment ? assignment_name : "n/a"])?", \
				"Confirmation", list("Create", "Cancel")) != "Create")
				return FALSE
			var/datum/forced_assignment/forced_assignment = new(ckey, assignment_name)
			global.job_controls.forced_assignments[ckey] = forced_assignment
			message_admins("Admin [key_name(ui.user)] forced ckey [find_player(forced_assignment.ckey) ? key_name(forced_assignment.ckey) : \
				forced_assignment.ckey] to roll [!!assignment && " [assignment_name]"] on round start!")
			logTheThing(LOG_ADMIN, ui.user, "added forced assignment [!!assignment && " [assignment_name]"] to ckey [forced_assignment.ckey]")
			logTheThing(LOG_DIARY, ui.user, "added forced assignment [!!assignment && " [assignment_name]"] to ckey [forced_assignment.ckey]", "admin")
			. = TRUE

		if ("remove_forced_assignment")
			var/ckey = ckey(params["ckey"])
			if (!(ckey in global.job_controls.forced_assignments))
				boutput(usr, SPAN_ALERT("Unable to find forced assignment attached to ckey [ckey]!"))
				return FALSE
			var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[ckey]
			if (!istype(forced_assignment, /datum/forced_assignment))
				return FALSE
			message_admins("Admin [key_name(ui.user)] removed ckey [find_player(forced_assignment.ckey) ? key_name(forced_assignment.ckey) : forced_assignment.ckey] \
							from forced assignments on round start!")
			logTheThing(LOG_ADMIN, ui.user, "removed forced assignments from ckey [forced_assignment.ckey]")
			logTheThing(LOG_DIARY, ui.user, "removed forced assignments from ckey [forced_assignment.ckey]", "admin")
			qdel(forced_assignment)
			global.job_controls.forced_assignments -= ckey
			. = TRUE

		if ("clear_forced_assignments")
			if (!length(global.job_controls.forced_assignments))
				boutput(usr, SPAN_ALERT("No forced assignments to clear!"))
				return FALSE
			if (tgui_alert(usr, "Clear all forced assignments?", "Confirmation", list("Clear all", "Cancel")) != "Clear all")
				return FALSE
			src.clear_forced_assignments()
			message_admins("Admin [key_name(ui.user)] cleared all forced assignments!")
			logTheThing(LOG_ADMIN, ui.user, "cleared all forced assignments")
			logTheThing(LOG_DIARY, ui.user, "cleared all forced assignments", "admin")
			. = TRUE

		if ("import_forced_assignments")
			var/forced_assignment_import = input("Input forced assignment JSON.", "Import Forced Assignments") as message
			if (!length(forced_assignment_import))
				return FALSE
			if (tgui_alert(usr, "Confirm forced assignment import. This may override any existing assignments!", "Confirmation", list("Import", "Cancel")) != "Import")
				return FALSE
			var/list/forced_assignment_import_list = json_decode(forced_assignment_import)
			var/list/datum/forced_assignment/decoded_forced_assignments = src.decode_forced_assignments(forced_assignment_import_list)
			if (!length(decoded_forced_assignments))
				boutput(usr, SPAN_ALERT("Forced assignment JSON decoder returned an empty list!"))
				return FALSE
			src.clear_forced_assignments()
			global.job_controls.forced_assignments = decoded_forced_assignments
			message_admins("Admin [key_name(ui.user)] imported new forced assignments!")
			logTheThing(LOG_ADMIN, ui.user, "imported new forced assignments")
			logTheThing(LOG_DIARY, ui.user, "imported new forced assignments", "admin")
			. = TRUE

		if ("export_forced_assignments")
			if (!length(global.job_controls.forced_assignments))
				return
			var/forced_assignment_export = json_encode(src.serialise_forced_assignments(), JSON_PRETTY_PRINT)
			usr.Browse("<title>Forced Assignment Export</title><pre>[forced_assignment_export]</pre>", "window=forced_assignment_export;size=500x700")

/datum/job_manager/proc/clear_forced_assignments()
	for (var/forced_assignment_index in global.job_controls.forced_assignments)
		var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[forced_assignment_index]
		qdel(forced_assignment)
	global.job_controls.forced_assignments = list()

/datum/job_manager/proc/serialise_forced_assignments()
	. = list()
	for (var/forced_assignment_index in global.job_controls.forced_assignments)
		var/datum/forced_assignment/forced_assignment = global.job_controls.forced_assignments[forced_assignment_index]
		if (!istype(forced_assignment, /datum/forced_assignment))
			continue
		var/datum/player/ckey_player = find_player(forced_assignment.ckey)
		.[forced_assignment.ckey] = list(
			"ckey" = forced_assignment.ckey,
			"playerName" = ckey_player?.client?.mob?.name || null,
			"forcedJob" = forced_assignment.forced_job?.name || null,
		)

/datum/job_manager/proc/decode_forced_assignments(list/decode_list)
	var/list/datum/forced_assignment/forced_assignment_buffer = list()
	for (var/forced_assignment_item_index in decode_list)
		var/forced_assignment_item = decode_list[forced_assignment_item_index]
		var/ckey = null
		var/job_name = null
		if (length(forced_assignment_item["ckey"]))
			ckey = forced_assignment_item["ckey"]
		if (length(forced_assignment_item["forcedJob"]))
			job_name = forced_assignment_item["forcedJob"]
		var/datum/forced_assignment/forced_assignment = new(ckey, job_name)
		forced_assignment_buffer[forced_assignment.ckey] = forced_assignment
	if (!length(forced_assignment_buffer))
		return FALSE
	return forced_assignment_buffer
