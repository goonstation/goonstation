
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

/datum/job_manager/ui_data(mob/user)
	var/list/staple_job_data = list()
	var/list/special_job_data = list()
	var/list/hidden_job_data = list()
	for (var/datum/job/JOB in job_controls.staple_jobs)
		staple_job_data += list(list(name = JOB.name, type = JOB.job_category, count = countJob(JOB.name), limit = JOB.limit))
	for (var/datum/job/JOB in job_controls.special_jobs)
		special_job_data += list(list(name = JOB.name, type = JOB.job_category, count = countJob(JOB.name), limit = JOB.limit))
	for (var/datum/job/JOB in job_controls.hidden_jobs)
		hidden_job_data += list(list(name = JOB.name, type = JOB.job_category, count = countJob(JOB.name), limit = JOB.limit))
	. = list(
		"stapleJobs" = staple_job_data,
		"specialJobs" = special_job_data,
		"hiddenJobs" = hidden_job_data,
		"allowSpecialJobs" = job_controls.allow_special_jobs
	)

/datum/job_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if (!isadmin(ui.user))
		return
	switch(action)
		if ("alter_cap")
			var/datum/job/JOB = find_job_in_controller_by_string(params["job"])
			var/newcap = tgui_input_number(ui.user, "Enter a new job cap", "Alter Cap", JOB.limit, 100, -1)
			if (isnull(newcap)) return
			JOB.limit = newcap
			message_admins("Admin [key_name(ui.user)] altered [JOB.name] job cap to [newcap]")
			logTheThing(LOG_ADMIN, ui.user, "altered [JOB.name] job cap to [newcap]")
			logTheThing(LOG_DIARY, ui.user, "altered [JOB.name] job cap to [newcap]", "admin")
			. = TRUE

		if ("edit")
			var/datum/job/JOB = find_job_in_controller_by_string(params["job"])
			// invoke the job creator through its accursed var edit proc call thing...
			job_controls.job_creator = JOB
			job_controls.savefile_fix(ui.user)
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
			var/datum/job/JOB = find_job_in_controller_by_string(params["job"])
			if (!istype(JOB, /datum/job/created))
				return
			message_admins("Admin [key_name(ui.user)] removed special job [JOB.name]")
			logTheThing(LOG_ADMIN, ui.user, "removed special job [JOB.name]")
			logTheThing(LOG_DIARY, ui.user, "removed special job [JOB.name]", "admin")
			job_controls.special_jobs -= JOB
			job_controls.hidden_jobs -= JOB
			. = TRUE
