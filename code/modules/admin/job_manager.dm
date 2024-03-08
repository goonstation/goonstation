
/datum/job_manager
	/// Toggle for filtering out 'command' jobs
	var/filter_command = FALSE
	/// Toggle for filtering out 'security' jobs
	var/filter_security = FALSE
	/// Toggle for filtering out 'research' jobs
	var/filter_research = FALSE
	/// Toggle for filtering out 'engineering' jobs
	var/filter_engineering = FALSE
	/// Toggle for filtering out 'civilian' jobs
	var/filter_civilian = FALSE
	/// Toggle for filtering out 'special' jobs
	var/filter_special = FALSE
	/// Toggle for filtering out 'created' jobs
	var/filter_created = FALSE
	///
	var/list/job_data

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
	for (var/datum/job/JOB in job_controls.staple_jobs)
		staple_job_data += list(list(name = JOB.name, type = JOB.job_category, count = countJob(JOB.name), limit = JOB.limit))

	. = list(
			"stapleJobs" = staple_job_data,
			"specialJobs" = list(),
			"allowSpecialJobs" = TRUE
		)



