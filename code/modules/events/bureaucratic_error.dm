#define BUREAUCRATIC_JOBS_IGNORE list("Staff Assistant", "Cyborg", "AI")

/datum/random_event/major/bureaucratic_error
	name = "Bureaucratic Error"
	customization_available = TRUE
	centcom_headline = "Bureaucratic Error"
	centcom_message = "A bureaucratic error at Central Command has caused an error in job openings at the station."
	centcom_origin = ALERT_STATION
	var/job_to_increase = null
	var/job_to_decrease = null
	var/amount = null

	admin_call(var/source)
		if (..())
			return
		var/list/jobs = src.get_valid_jobs()
		src.job_to_increase = tgui_input_list(usr, "Pick a job to increase", src.name, jobs)
		src.job_to_increase = tgui_input_list(usr, "Pick a job to decrease", src.name, jobs)
		src.amount = tgui_input_number(usr, "Pick an amount to change by", src.name, 3, 10, -1)
		//confirmation
		if (tgui_alert(usr, "Are you sure?", src.name, list("Yes" "No")) == "Yes")
			event_effect(source)
		else
			src.cleanup()

	cleanup()
		src.job_to_decrease = null
		src.job_to_increase = null
		src.amount = null

	event_effect(source)
		. = ..()

		//How much are we changing each job by?
		if(!src.amount)
			src.amount = rand(1, 10)
			if (prob(20))
				src.amount = -1

		src.determine_jobs()

		var/datum/job/job_up = find_job_in_controller_by_string(job_to_increase)
		var/newcap_up = job_up.limit + src.amount
		if (src.amount == -1)
			newcap_up = -1
		job_up.limit = newcap_up


		var/datum/job/job_down = find_job_in_controller_by_string(job_to_decrease)
		var/newcap_down = job_down.limit - src.amount
		if (src.amount == -1 || newcap_down <= 0)
			if(job_down.assigned == 0)
				job_down.assigned = 1
			job_down.limit = job_down.assigned
			newcap_down = 0
		else
			job_down.limit = newcap_down

		message_admins("Bureaucratic Error event increased [src.job_to_increase] slots to [newcap_up] and decreased [src.job_to_decrease] to [newcap_down].")
		logTheThing(LOG_ADMIN, null, "Bureaucratic Error event increased [src.job_to_increase] slots to [newcap_up] and decreased [src.job_to_decrease] to [newcap_down].")

		src.cleanup()

	proc/get_valid_jobs()
		var/list/valid_jobs = list()
		for(var/datum/job/job in job_controls.staple_jobs)
			if (job.name in BUREAUCRATIC_JOBS_IGNORE || job.admin_set_limit)
				continue
			valid_jobs += job.name
		return valid_jobs

	proc/determine_jobs()
		var/list/valid_jobs = src.get_valid_jobs()

		//Remove decrease job early if set by admin call
		if(src.job_to_decrease)
			valid_jobs -= src.job_to_decrease

		//Pick job to increase then remove from list if called by admin
		if(!src.job_to_increase)
			src.job_to_increase = pick(valid_jobs)
			valid_jobs -= src.job_to_increase

		//Pick a victim job
		if(!src.job_to_decrease)
			src.job_to_decrease = pick(valid_jobs)

#undef BUREAUCRATIC_JOBS_IGNORE
