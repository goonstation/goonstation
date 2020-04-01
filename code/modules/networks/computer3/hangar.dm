#define HANGAR_AREATYPE "/area/hangar"
/datum/computer/file/terminal_program/hangar_control
	name = "HangarControl"
	size = 16
	req_access = list(access_hangar)
	var/tmp/authenticated = null //Are we currently logged in?
	var/datum/computer/file/user_data/account = null
	var/tmp/reply_wait = -1 //How long do we wait for replies? -1 is not waiting.
	var/setup_acc_filepath = "/logs/sysusr"//Where do we look for login data?

	initialize()

		src.authenticated = null
		src.master.temp = null
		if(!src.find_access_file()) //Find the account information, as it's essentially a ~digital ID card~
			src.print_text("<b>Error:</b> Cannot locate user file.  Quitting...")
			src.master.unload_program(src) //Oh no, couldn't find the file.
			return

		if(!src.check_access(src.account.access))
			src.print_text("User [src.account.registered] does not have needed access credentials.<br>Quitting...")
			src.master.unload_program(src)
			return

		src.reply_wait = -1
		src.authenticated = src.account.registered
		var/intro_text = {"<br>Welcome to HangarControl!
		<br>Hangar Management System.
		<br><b>Commands:</b>
		<br>(Status) to view current status.
		<br>(ResetPass) to reset a hangar door's password.
		<br>(CloseAll) to close all hangar doors.
		<br>(Toggle) to toggle a hangar door.
		<br>(Clear) to clear the screen.
		<br>(Quit) to exit HangarControl."}
		src.print_text(intro_text)

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1] //Remove the command we are now processing.

		switch(lowertext(command))
			if("status")
				print_status()
			if("clear")
				src.master.temp = null
				src.master.temp_add = "Workspace cleared.<br>"
			if("closeall")
				close_all()
			if("toggle")
				var/door_name = ckey(jointext(command_list, " "))
				if(!door_name)
					var/dat = "<b>Available Hangar Doors:</b><br>"
					for(var/turf/T in get_area_turfs(HANGAR_AREATYPE))
						for(var/obj/machinery/r_door_control/R in T)
							if(R.open)
								dat+="[R.name]<BR>"
							else
								dat+="[R.name]<BR>"
					src.print_text(dat)
				else
					for(var/turf/T in get_area_turfs(HANGAR_AREATYPE))
						for(var/obj/machinery/r_door_control/R in T)
							if(cmptext(door_name,R.id))
								if(R.open)
									src.print_text("Closing Door...")
								else
									src.print_text("Opening Door...")
								R.open_door()
								src.print_text("Done.<BR>")
								src.master.add_fingerprint(usr)
								src.master.updateUsrDialog()
								return
					src.print_text("Invalid Hangar Door!<BR>")
			if("resetpass")
				var/door_name = ckey(jointext(command_list, " "))
				if(!door_name)
					var/dat = "<b>Available Hangar Doors:</b><br>"
					for(var/turf/T in get_area_turfs(HANGAR_AREATYPE))
						for(var/obj/machinery/r_door_control/R in T)
							if(R.open)
								dat+="[R.name]<BR>"
							else
								dat+="[R.name]<BR>"
					src.print_text(dat)
				else
					for(var/turf/T in get_area_turfs(HANGAR_AREATYPE))
						for(var/obj/machinery/r_door_control/R in T)
							if(cmptext(door_name,R.id))
								R.pass = "[R.id]-[rand(100,999)]"
								src.print_text("[R.name] New Pass: [R.pass]")
								src.master.add_fingerprint(usr)
								src.master.updateUsrDialog()
								return
					src.print_text("Invalid Hangar Door!<BR>")

			if("help")
				var/intro_text = {"<br>Welcome to HangarControl!
				<br>Hangar Management System.
				<br><b>Commands:</b>
				<br>(Status) to view current status.
				<br>(ResetPass) to reset a hangar door's password.
				<br>(CloseAll) to close all hangar doors.
				<br>(Toggle) to toggle a hangar door.
				<br>(Clear) to clear the screen.
				<br>(Quit) to exit HangarControl."}
				src.print_text(intro_text)
			if("quit")
				src.master.temp = ""
				print_text("Now quitting...")
				src.master.unload_program(src)
				return
			else
				print_text("Unknown command : \"[copytext(strip_html(command), 1, 16)]\"")


		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return

	proc
		find_access_file() //Look for the whimsical account_data file
			var/datum/computer/folder/accdir = src.holder.root
			if(src.master.host_program) //Check where the OS is, preferably.
				accdir = src.master.host_program.holder.root

			var/datum/computer/file/user_data/target = parse_file_directory(setup_acc_filepath, accdir)
			if(target && istype(target))
				src.account = target
				return 1

			return 0
		print_status()
			var/dat="<b>Status</b>:<BR>"
			for(var/turf/T in get_area_turfs(HANGAR_AREATYPE))
				for(var/obj/machinery/r_door_control/R in T)
					if(R.open)
						dat+="[R.name] (Open): [R.pass]<BR>"
					else
						dat+="[R.name] (Closed): [R.pass]<BR>"
			src.print_text(dat)
		close_all()
			src.print_text("Closing All Doors...")
			for(var/turf/T in get_area_turfs(HANGAR_AREATYPE))
				for(var/obj/machinery/r_door_control/R in T)
					if(R.open)
						R.open_door()
			src.print_text("Done.<BR>")

/datum/computer/file/terminal_program/hangar_research
	name = "HangarHelper"
	size = 16
	req_access = list(access_hangar)
	var/tmp/authenticated = null //Are we currently logged in?
	var/datum/computer/file/user_data/account = null
	var/tmp/reply_wait = -1 //How long do we wait for replies? -1 is not waiting.
	var/setup_acc_filepath = "/logs/sysusr"//Where do we look for login data?

	initialize()

		src.authenticated = null
		src.master.temp = null
		if(!src.find_access_file()) //Find the account information, as it's essentially a ~digital ID card~
			src.print_text("<b>Error:</b> Cannot locate user file.  Quitting...")
			src.master.unload_program(src) //Oh no, couldn't find the file.
			return

		if(!src.check_access(src.account.access))
			src.print_text("User [src.account.registered] does not have needed access credentials.<br>Quitting...")
			src.master.unload_program(src)
			return

		src.reply_wait = -1
		src.authenticated = src.account.registered
		src.print_research_status()
		var/intro_text = {"<br>HangarHelper
		<br>Bringing You the Latest in Ship Technology!.
		<br><b>Commands:</b>
		<br>(Status) to view current progress.
		<br>(Research) to view research topics.
		<br>(Cancel) to halt current research.
		<br>(Complete) to view completed research.
		<br>(Clear) to clear the screen.
		<br>(Quit) to exit HangarHelper"}
		src.print_text(intro_text)

	proc
		find_access_file() //Look for the whimsical account_data file
			var/datum/computer/folder/accdir = src.holder.root
			if(src.master.host_program) //Check where the OS is, preferably.
				accdir = src.master.host_program.holder.root

			var/datum/computer/file/user_data/target = parse_file_directory(setup_acc_filepath, accdir)
			if(target && istype(target))
				src.account = target
				return 1

			return 0

		print_research_status()
			var/dat = "<b>Tier [robotics_research.tier] Hangar Research</b><br>"
			if(robotics_research.is_researching)
				var/timeleft = robotics_research.get_research_timeleft()
				var/text = robotics_research.current_research
				dat += "Current Research: [text ? text : "None"]. ETA: [timeleft ? timeleft : "Completed"]."
			else
				dat += "Currently not researching."
			src.print_text(dat)
			return
