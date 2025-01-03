
#define MENU_MAIN 0
#define MENU_REQUESTS 1
#define MENU_IN_REQUEST 2

#define ANNOUNCEMENT_PREVIEW_LENGTH 30

/datum/computer/file/terminal_program/announcer
	name = "AnnouncerPRO"
	size = 8
	req_access = list(access_heads)
	var/tmp/menu = MENU_MAIN
	var/obj/item/peripheral/network/radio/radiocard = null

	var/list/valid_requests = list() //stored list of valid requests
	var/datum/announcement_request/active_request = null //currently observed request

	initialize()
		if (..())
			return TRUE
		src.master.temp = null

		src.radiocard = locate() in src.master.peripherals
		if(!radiocard || !istype(src.radiocard))
			src.radiocard = null
			src.print_text("<b>Warning:</b> No radio module detected.")

		src.print_intro_text()


	proc/print_intro_text()
		var/intro_text = {"Welcome to AnnouncerPRO!
		<br>Announcing \"poo fart\" since 2047
		<br><b>Commands:</b>
		<br>(Requests) to view current requests.
		<br>(Clear) to clear the screen.
		<br>(Quit) to exit AnnouncerPRO."}
		src.print_text(intro_text)

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1]

		if (isghostdrone(usr))
			src.print_text("<b>Error:</b> Permission denied.")
			return

		switch(menu)
			if(MENU_MAIN)
				switch(lowertext(command))
					if("requests")
						src.menu = MENU_REQUESTS
						src.print_requests()

					if("clear")
						src.master.temp = null
						src.master.temp_add = "Workspace cleared.<br>"

					if("quit")
						src.master.temp = ""
						print_text("Now quitting...")
						src.master.unload_program(src)
						return

					else
						print_text("Unknown command : \"[copytext(strip_html(command), 1, 16)]\"")

			if(MENU_REQUESTS)
				var/index_number = round( max( text2num_safe(command), 0) )
				if (index_number == 0)
					src.menu = MENU_MAIN
					src.master.temp = null
					src.print_intro_text()
					return

				if (index_number > valid_requests.len)
					src.print_text("Invalid request.")
					return

				var/datum/announcement_request/check = src.valid_requests[index_number]
				if(!check || !istype(check))
					src.print_text("<b>Error:</b> Request Data Invalid.")
					return

				src.active_request = check
				if (src.print_active_request())
					src.menu = MENU_IN_REQUEST
				return


			if(MENU_IN_REQUEST)
				var/datum/announcement_request/request = src.active_request
				switch(lowertext(command))
					if("approve")
						if(request.approved)
							src.print_text("<b>Error:</b> Request already approved.")
						else
							request.approve(src.authenticated)
							logTheThing(LOG_SAY, usr, "uses [src.authenticated]'s credentials to approve announcement: \"[request.content]\" requested by [request.requester]'s PDA")
							logTheThing(LOG_DIARY, usr, "uses [src.authenticated]'s credentials to approve announcement: \"[request.content]\" requested by [request.requester]'s PDA", "say")

					if("return")
						src.menu = MENU_REQUESTS
						src.print_requests()

					else
						print_text("Unknown command : \"[copytext(strip_html(command), 1, 16)]\"")

		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return

	proc/print_requests()
		src.master.temp = null
		var/dat = ""
		src.valid_requests = list()
		if(!data_core.announcement_requests || !length(data_core.announcement_requests))
			src.print_text("<b>Error:</b> No requests found in database.")
			src.print_text("<br> Enter (Return) to return to menu.")
			return
		for(var/datum/announcement_request/request in data_core.announcement_requests)
			if(!request.approved)
				valid_requests+=request
		if(!valid_requests || !length(valid_requests))
			src.print_text("<b>Error:</b> No unapproved requests found in database.")
			src.print_text("<br> Enter (Return) to return to menu.")
			return
		else
			dat = "Please select a request:"
			for(var/index = 1, index <= src.valid_requests.len, index++)
				var/datum/announcement_request/request = src.valid_requests[index]
				dat += "<br><br>([index])\"[copytext(request.content, 1, ANNOUNCEMENT_PREVIEW_LENGTH)]...\" - [request.requester]"
		dat += "<br><br>Enter record number, or 0 to return."

		src.print_text(dat)

	proc/print_active_request()
		if (!src.active_request)
			src.print_text("<b>Error:</b> Request data corrupt.")
			src.print_text("<br> Enter (Return) to return to menu.")
			return 0
		src.master.temp = null

		var/view_string = {"
		Requested by [src.active_request.requester] ([src.active_request.requester_job])
		<br>\"[src.active_request.content]\""}

		view_string += "<br>(Approve) to approve this request"
		view_string += "<br>(Return) to return to menu"

		src.print_text("<b>Request Data:</b><br>[view_string]")
		return 1

#undef MENU_MAIN
#undef MENU_REQUESTS
#undef MENU_IN_REQUEST
#undef ANNOUNCEMENT_PREVIEW_LENGTH
