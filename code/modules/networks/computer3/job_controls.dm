var/datum/job/priority_job = null
/datum/computer/file/terminal_program/job_controls
	name = "RoleControl" //bad pun "placeholder" name
	size = 12 //idk
	req_access = list(access_change_ids) //maybe should just be heads, but I like this being an HoP/captain thing

	initialize()
		if (..())
			return TRUE
		src.master.temp = null //clear the screen
		var/intro_text = {"<br>Welcome to RoleControl!
		<br>Recruitment management system.
		<br><b>Commands:</b>
		<br>(List) to view currently advertised roles.
		<br>(Info) to view info on a specific role.
		<br>(Prio role name) to prioritize recruiting a specific role. Call without arguments to display currently prioritized role.
		<br>(Quit) to exit RoleControl.
		"}
		src.print_text(intro_text)

	input_text(text)
		if(..())
			return TRUE

		var/list/command_list = parse_string(text)
		var/command = lowertext(command_list[1])
		command_list.Cut(1,2)

		switch(command)
			if ("list")
				var/list/output = list("All roles currently being advertised:")
				for (var/datum/job/job in job_controls.staple_jobs)
					if (job.limit <= 0 || !job.add_to_manifest || job.no_late_join)
						continue

					output += src.job_info(job)
				src.print_text(output.Join("<br>"))

			if ("prio")
				var/job_name = command_list.Join(" ") //all later arguments are assumed to just be parts of the job name
				if (!length(job_name))
					if (global.priority_job)
						src.print_text("Current priority role: [src.job_info(global.priority_job)]<br>Type \"prio none\" to clear.")
					else
						src.print_text("No currently specified priority role.")
					return
				if (cmptext(job_name, "None"))
					global.priority_job = null
					src.print_text("Cleared priority job listing.")
					return
				var/datum/job/job = find_job_in_controller_by_string(job_name, soft = TRUE, case_sensitive = FALSE)
				if (!job)
					src.print_text("Error: unable to identify role with name \[[job_name]\]")
					return
				global.priority_job = job
				src.print_text("Success: priority role set to: \[[job.name]\]")
				src.send_pda_message("RoleControl notification: priority role set to [job.name] by [src.account.assignment] [src.account.registered]")

			if ("info")
				var/job_name = command_list.Join(" ") //all later arguments are assumed to just be parts of the job name
				var/datum/job/job = find_job_in_controller_by_string(job_name, soft = TRUE, case_sensitive = FALSE)
				if (!job)
					src.print_text("Error: unable to identify role with name \[[job_name]\]")
					return
				src.print_text(src.job_info(job))

			if("quit")
				src.master.temp = ""
				print_text("Now quitting...")
				src.master.unload_program(src)

	proc/job_info(datum/job/job)
		var/job_text = "[job.name] \[[job.assigned]/[job.limit >= 0 ? job.limit : "∞"]\]"
		if (job.is_highlighted())
			job_text += " (PRIORITY)"
		return job_text

	proc/send_pda_message(message)
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="COMMAND-MAILBOT", "group"=list(MGD_COMMAND), "sender"="00000000", "message"=message)
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)
