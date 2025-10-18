
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
	var/list/special_job_categories = list(JOB_NANOTRASEN, JOB_SYNDICATE, JOB_HALLOWEEN)// If adding more, make sure to add the category in JobManager.tsx
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
		"allowSpecialJobs" = job_controls.allow_special_jobs
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
