#define MENU_MAIN 0
#define MENU_REQUEST_COUNT 1
#define MENU_REQUEST_CONFIRM 2

var/datum/job/priority_job = null
/datum/computer/file/terminal_program/job_controls
	name = "RoleControl" //bad pun "placeholder" name
	size = 12 //idk
	req_access = list(access_change_ids) //maybe should just be heads, but I like this being an HoP/captain thing
	var/state = null
	var/datum/job/requested_job = null
	var/request_count = 0

	initialize()
		if (..())
			return TRUE
		src.master.temp = null //clear the screen
		var/intro_text = {"<br>Welcome to RoleControl!
		<br>Recruitment Management System."}
		src.print_text(intro_text)
		src.print_main_menu()

	proc/print_main_menu()
		var/menu_text = {"<br><b>Commands:</b>
		<br>(List) to view currently advertised roles.
		<br>(Info) to view info on a specific role.
		<br>(Priority role name) to prioritize recruiting a specific role. Call without arguments to display currently prioritized role.
		<br>(Request role name) to request job openings for a specific role. Call without arguments to display requestable roles.
		<br>(Clear) to clear the screen.
		<br>(Quit) to exit RoleControl."}
		src.print_text(menu_text)
		state = MENU_MAIN

	input_text(text)
		if(..())
			return TRUE

		var/list/command_list = parse_string(text)
		var/command = lowertext(command_list[1])
		command_list.Cut(1,2)
		switch(state)
			if(MENU_MAIN)
				switch(command)
					if ("clear")
						src.master.temp = null
						src.master.temp_add = "Workspace cleared.<br>"
					if ("help","menu")
						src.print_main_menu()
					if ("list")
						var/list/output = list("All roles currently being advertised:")
						for (var/datum/job/job in job_controls.staple_jobs | job_controls.special_jobs)
							if (job.limit == 0 || !job.add_to_manifest || job.no_late_join)
								continue
							output += src.job_info(job)
						src.print_text(output.Join("<br>"))

					if ("prio","priority")
						var/job_name = command_list.Join(" ") //all later arguments are assumed to just be parts of the job name
						if (!length(job_name))
							if (job_controls.priority_job)
								src.print_text("Current priority role: [src.job_info(job_controls.priority_job)]<br>Type \"prio none\" to clear.")
							else
								src.print_text("No currently specified priority role.")
							return
						if (cmptext(job_name, "None"))
							job_controls.priority_job = null
							src.print_text("Cleared priority job listing.")
							return
						var/datum/job/job = find_job_in_controller_by_string(job_name, soft = TRUE, case_sensitive = FALSE, latejoin_only = TRUE)
						if (!job)
							src.print_text("Error: unable to identify role with name \[[job_name]\]")
							return
						if (job.limit == 0 || job.limit == job.assigned)
							src.print_text("Error: job already at maximum limit")
							return
						job_controls.priority_job = job
						src.print_text("Success: priority role set to: \[[job.name]\]")
						src.send_pda_message("RoleControl notification: [job.name] set to priority role by [src.account.assignment] [src.account.registered]")

					if ("req", "request")
						var/job_name = command_list.Join(" ") //all later arguments are assumed to just be parts of the job name
						if(!length(job_name))
							var/list/output = list("All roles that can be requested:")
							for (var/datum/job/job in (job_controls.staple_jobs | job_controls.special_jobs))
								if (job.request_limit <= job.limit || job.limit == -1 || !job.add_to_manifest || job.no_late_join || !job.request_cost)
									continue
								output += src.job_info(job, include_requests = TRUE)
							src.print_text(output.Join("<br>"))
							return
						var/datum/job/job = find_job_in_controller_by_string(job_name, soft = TRUE, case_sensitive = FALSE, latejoin_only = TRUE)
						if (!job)
							src.print_text("Error: unable to identify role with name \[[job_name]\]")
							return
						if (job.request_limit <= job.limit || job.limit == -1 || !job.add_to_manifest || job.no_late_join || !job.request_cost)
							src.print_text("Error: can not request more job openings for that role")
							return
						requested_job = job
						src.print_text("Enter the number of job openings to request (max [job.request_limit - job.limit]), or type X to cancel")
						state = MENU_REQUEST_COUNT


					if ("info")
						var/job_name = command_list.Join(" ") //all later arguments are assumed to just be parts of the job name
						var/datum/job/job = find_job_in_controller_by_string(job_name, soft = TRUE, case_sensitive = FALSE, latejoin_only = TRUE)
						if (!job)
							src.print_text("Error: unable to identify role with name \[[job_name]\]")
							return
						src.print_text("Job Information:")
						src.print_text(src.job_info(job, include_requests = (job.request_limit > job.limit)))

					if("quit","exit")
						src.master.temp = ""
						print_text("Now quitting...")
						src.master.unload_program(src)

					else
						print_text("Unknown command : \"[copytext(strip_html(command), 1, 16)]\"")

			if(MENU_REQUEST_COUNT)
				if(!requested_job)
					src.print_text("Error: no job selected, aborting...")
					src.print_main_menu()
					return
				if(command == "x" || text2num(command) == 0)
					src.print_text("Cancelling job request...")
					requested_job = null
					src.print_main_menu()
					return
				else if(text2num(command))
					request_count = text2num(command)
					if (request_count > (requested_job.request_limit - requested_job.limit))
						src.print_text("Error: cannot request that many slots")
						src.print_text("Enter the number of job openings to request (max [requested_job.request_limit - requested_job.limit]), or type X to cancel")
						request_count = 0
						state = MENU_REQUEST_COUNT
						return
					if(isnull(requested_job.request_cost))
						src.print_text("Error: invalid request cost, aborting...")
						requested_job = null
						request_count = 0
						src.print_main_menu()
						return
					src.print_text("This will deduct [requested_job.request_cost * request_count][CREDIT_SIGN] from the payroll budget. Current payroll budget: [global.wagesystem.station_budget][CREDIT_SIGN]")
					src.print_text("Confirm job request? (Y/N)")
					state = MENU_REQUEST_CONFIRM
			if(MENU_REQUEST_CONFIRM)
				switch(command)
					if("n")
						src.print_text("Cancelling job request...")
						requested_job = null
						request_count = 0
						src.print_main_menu()
					if("y")
						var/total_cost = requested_job.request_cost * request_count
						if(global.wagesystem.station_budget < total_cost)
							src.print_text("Error: insufficient funds, request cancelled...")
						else
							requested_job.limit += request_count
							requested_job.player_requested = TRUE
							global.wagesystem.station_budget -= total_cost
							src.print_text("Sucess: Requested [request_count] job opening[s_es(request_count)] for the [requested_job.name] role")
							src.send_pda_message("RoleControl notification: [request_count] [requested_job.name] opening[s_es(request_count)] requested by [src.account.assignment] [src.account.registered]")
							src.notify_respawnable_players(SPAN_NOTICE("New job opening[s_es(request_count)] for the [requested_job.name] role!"))

						requested_job = null
						request_count = 0
						src.print_main_menu()

	proc/job_info(datum/job/job, var/include_requests = FALSE)
		var/job_text = "[job.name] \[[job.assigned]/[job.limit >= 0 ? job.limit : "∞"]\]"
		if (job.player_requested)
			job_text += " (REQUESTED)"
		if (job_controls.priority_job == job)
			job_text += " (PRIORITY)"
		if(include_requests && (job.request_limit > job.limit))
			job_text += ", can request [job.request_limit - job.limit] more ([job.request_cost][CREDIT_SIGN] per)"
		return job_text

	proc/send_pda_message(message)
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="COMMAND-MAILBOT", "group"=list(MGD_COMMAND), "sender"="00000000", "message"=message)
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)

	proc/notify_respawnable_players(message)
		var/list/mob/potential_new_hires = list()
		for (var/datum/respawnee/R in respawn_controller.respawnees)
			if(R.checkValid() == RESPAWNEE_STATE_ELIGIBLE)
				potential_new_hires += ckey_to_mob(R.ckey)
		for (var/mob/new_player/M in mobs)
			potential_new_hires += M
		for (var/mob/who in potential_new_hires)
			who.playsound_local_not_inworld('sound/misc/lawnotify.ogg', 50, flags=SOUND_IGNORE_SPACE | SOUND_IGNORE_DEAF)
			boutput(who, message)


#undef MENU_MAIN
#undef MENU_REQUEST_COUNT
#undef MENU_REQUEST_CONFIRM
