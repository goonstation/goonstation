//Small programs not worthy of their own file
//CONTENTS
//Background program base
//Signal interceptor program
//Ping program
//Terminal client / File transfer program
//Signal file creator/editor
//Disease research program
//Artifact research program
//Crew manifest program
//Robotics research.

#define MAX_BACKGROUND_PROGS 7//If staying resident would leave us with more than this, don't do it.

//A program designed to remain processing while the user executes more interesting programs
/datum/computer/file/terminal_program/background
	name = "Background"
	size = 4


	//It's like having the master unload it, but it remains processing.
	proc/exit_stay_resident()
		if((!src.holder) || (!src.master))
			return 1

		if((!istype(holder)) || (!istype(master)))
			return 1

		if(!(holder in src.master.contents))
			if(master.active_program == src)
				master.active_program = null
			master.processing_programs.Remove(src)
			return 1

		if(length(src.master.processing_programs) > MAX_BACKGROUND_PROGS) //Don't want too many background programs.
			return 1

		if(!(src in src.master.processing_programs))
			src.master.processing_programs.Add(src)

		src.master.active_program = src.master.host_program

		return 0

//Signal interception program
/datum/computer/file/terminal_program/background/signal_catcher
	name = "SigCatcher"
	var/active = 1 //Are we currently catching signals?
	var/logging = 0
	var/list/working_signal = list()
	var/last_command = null
	var/datum/computer/file/text/logfile = null

	var/const/max_working_signal_len = 8
	var/const/logfile_path = "signal_log"

	initialize()
		if (..())
			return TRUE
		src.print_text("Signal Catcher 1.2<br>Commands: \"active \[ON/OFF/AUTO],\" \"Save \[filename]\" as signal, \"View\" current signal.<br>\"Quit\" to exit but remain in memory, \"FQuit\" to quit normally.")

	disposing()
		working_signal = null
		logfile = null

		..()

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1]

		src.print_text(strip_html(text))

		switch(lowertext(command))
			if("active") //Determine whether we are catching incoming signals or not
				var/argument1 = null
				if(command_list.len)
					argument1 = command_list[1]

				switch(lowertext(argument1))
					if("on")
						src.active = 1

					if("off")
						src.active = 0

					if("auto")
						src.active = 2

					else
						src.active = !src.active

				src.print_text("Signal Catching is now [src.active ? "ON" : "OFF"]")

			if("log") //Determine whether we should log incoming signals.
				var/argument1 = null
				if(command_list.len)
					argument1 = command_list[1]

				switch(lowertext(argument1))
					if("on")
						src.logging = 1

					if("off")
						src.logging = 0

					else
						src.logging = !logging

				src.print_text("Signal Logging is now [src.logging ? "ON" : "OFF"]")


			if("view")
				if(!src.working_signal || !length(src.working_signal))
					src.print_text("Error, no signal loaded.")
					return
				else
					src.print_text("Current signal:<br>Last Command: [last_command ? last_command : "None"]")
					for(var/x = 1, x <= src.working_signal.len, x++)
						var/part = "\[UNUSED]"
						if(x <= working_signal.len)
							var/title_text = working_signal[x]
							var/main_text = working_signal[title_text]
							part = " \[[isnull(title_text) ? "Untitled" : title_text]] \[[isnull(main_text) ? "Blank" : copytext(strip_html(main_text), 1, 25)]]"

						src.print_text("\[[x]] [part]")

			if("save")
				var/new_name = strip_html(jointext(command_list, " "))
				new_name = copytext(new_name, 1, 16)

				if(!new_name)
					src.print_text("Syntax: \"save \[file name]\"")
					return

				var/datum/computer/file/signal/saved = get_file_name(new_name, src.holding_folder)
				if(saved && !istype(saved) || get_folder_name(new_name, src.holding_folder))
					src.print_text("Error: Name in use.")
					return

				if(is_name_invalid(new_name))
					src.print_text("Error: Invalid character in name.")
					return

				if(saved && istype(saved))
					saved.data = src.working_signal.Copy()
				else
					saved = new /datum/computer/file/signal
					saved.name = new_name
					saved.data = src.working_signal.Copy()
					if(!src.holding_folder.add_file(saved))
						//qdel(saved)
						saved.dispose()
						src.print_text("Error: Cannot save to disk.")
						return

				src.print_text("Signal \"[new_name]\" saved.")

			if("help")
				src.print_text("Commands: \"active \[ON/OFF],\" \"Save \[filename]\" as signal, \"View\" current signal.<br>\"Quit\" to exit but remain in memory, \"FQuit\" to quit normally.")

			if("quit")
				src.print_text("Now returning to OS. Program will remain in background.")
				if(src.exit_stay_resident())
					src.print_text("Error: Background Memory full.")

					src.master.unload_program(src)
					return

			if("fquit")
				src.print_text("Now Fully Quitting...")
				src.master.unload_program(src)
				return

			else
				src.print_text("Unknown Command.")

		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return

	receive_command(obj/source, command, datum/signal/signal)
		if((..()) || (!signal) || !src.active)
			return

		//Auto mode means shutoff after next signal
		if(src.active == 2) src.active = 0

		src.working_signal = signal.data:Copy()
		src.working_signal.len = min(src.working_signal.len, max_working_signal_len)
		src.last_command = command
		if(src.logging && !src.holder.read_only)
			if(!src.logfile)
				src.logfile = parse_file_directory(src.logfile_path)
				if(!istype(src.logfile))
					src.logfile = new /datum/computer/file/text
					src.logfile.name = src.logfile_path
					if(!src.holding_folder.add_file(src.logfile))
						//qdel(src.logfile)
						src.logfile.dispose()
						return

			src.logfile.data += "<br>"
			for(var/i = 1, i <= src.working_signal.len, i++)
				src.logfile.data += "<br>[src.working_signal[i]]: [src.working_signal[src.working_signal[i]]]"

		return

//Pnet ping program.
/datum/computer/file/terminal_program/background/ping
	name = "Ping"
	var/active = 1
	var/list/replies = list() //Replies to our ping request.
	var/obj/item/peripheral/network/ping_card = null //The card we are actually going to use to send pings.

	initialize()
		if (..())
			return TRUE
		src.ping_card = null
		src.print_text("Ping! V4.92<br>Commands: \"Ping\" to ping network. \"View\" to view prevous ping data.<br>\"Quit\" to exit but remain in memory, \"FQuit\" to quit normally.")

		src.ping_card = find_peripheral("NET_ADAPTER")
		if(!src.ping_card || !istype(src.ping_card))
			src.ping_card = null
			src.print_text("Error:No network card detected.")

		return

	disposing()
		ping_card = null
		replies = null

		..()

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1]

		src.print_text(strip_html(text))

		switch(lowertext(command))
			if("ping")
				if(!src.ping_card)
					src.print_text("Error: Network card required.")
					return

				var/datum/signal/newsignal = get_free_signal()
				newsignal.encryption = "\ref[src.ping_card]" //No need to actually set data on it
				//The signal is really only needed to target our ping card for the job.

				src.print_text("Pinging...")
				src.replies = new
				src.peripheral_command("ping", null, "\ref[src.ping_card]")

			if("view")
				if(!src.replies || !length(src.replies))
					src.print_text("Error, no reply data found.")
					return
				else
					src.print_text("Reply List:")
					var/part = null
					for(var/x = 1, x <= src.replies.len, x++)
						var/reply_id = replies[x]
						var/reply_device = replies[reply_id]
						part += " \[[isnull(reply_id) ? "ERR: ID" : reply_id]]-TYPE: [isnull(reply_device) ? "ERR: DEVICE" : reply_device]<br>"

					if(part)
						src.print_text(part)


			if("help")
				src.print_text("Commands: \"Ping\" to ping network. \"View\" to view prevous ping data.<br>\"Quit\" to exit but remain in memory, \"FQuit\" to quit normally.")

			if("quit")
				src.print_text("Now returning to OS. Program will remain in background.")
				if(src.exit_stay_resident())
					src.print_text("Error: Background Memory full.")

					src.master.unload_program(src)
					return

			if("fquit")
				src.print_text("Now Fully Quitting...")
				src.master.unload_program(src)
				return

			else
				src.print_text("Unknown Command.")

		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return

	receive_command(obj/source, command, datum/signal/signal)
		if((..()) || (!signal) || !src.active)
			return

		//If we get a ping reply, add it to the list and print it.
		if(signal.data["command"] == "ping_reply")
			if(!signal.data["device"] || !signal.data["netid"])
				return

			var/reply_device = signal.data["device"]
			var/reply_id = signal.data["netid"]
			//boutput(world, "device: [reply_device] id: [reply_id]")
			src.replies[reply_id] = reply_device
			src.print_text("\[[reply_id]]-TYPE: [reply_device]")

		return

//Pnet file transfer program.
/datum/computer/file/terminal_program/file_transfer
	name = "FROG"
	var/tmp/serv_id = null //NetID of connected server
	var/tmp/last_serv_id = null //Last valid serv_id.
	var/tmp/attempt_id = null //Are we attempting to connect to something?
	var/obj/item/peripheral/network/pnet_card = null
	var/tmp/disconnect_wait = -1 //Are we waiting to disconnect?
	var/tmp/ping_wait = 0 //Are we waiting for a ping reply?
	var/auto_accept = 1 //Do we automatically accept connection attempts?
	var/tmp/service_mode = 0
	var/ping_filter = null

	var/tmp/datum/computer/file/temp_file

	initialize()
		if (..())
			return TRUE
		attempt_id = null
		src.pnet_card = null
		var/introdat = "FROG Terminal Client V1.3<br>Copyright 2053 Thinktronic Systems, LTD."

		src.pnet_card = find_peripheral("NET_ADAPTER")
		if (!src.pnet_card || !istype(src.pnet_card))
			src.pnet_card = find_peripheral("RAD_ADAPTER")
			if (istype(src.pnet_card))
				src.peripheral_command("mode_net", null, "\ref[pnet_card]")
				introdat += "<br>Network card detected."
			else
				if (src.serv_id)
					src.serv_id = null

				src.ping_wait = 0
				src.disconnect_wait = 0
				src.serv_id = null

				src.pnet_card = null
				introdat += "<br>Error: No network card detected."

		if (src.pnet_card)
			introdat += "<br>Network ID: [pnet_card.net_id]"

			if (src.serv_id) //We have been rebooted or force-closed OR SOMETHING, so disconnect.
				var/datum/signal/termsignal = get_free_signal()

				termsignal.data["address_1"] = src.serv_id
				termsignal.data["command"] = "term_disconnect"

				src.peripheral_command("transmit", termsignal, "\ref[pnet_card]")

				src.ping_wait = 0
				src.disconnect_wait = 0
				src.serv_id = null

		src.print_text(introdat + "<br>Ready.")

		return

	process()
		if(..())
			return

		if(src.ping_wait)
			src.ping_wait--

		if(src.disconnect_wait > 0)
			src.disconnect_wait--
			if(src.disconnect_wait == 0)
				src.print_text("Timed out. Please retry.")
				src.serv_id = null
				src.attempt_id = null

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = lowertext(command_list[1])
		command_list -= command_list[1]

		src.print_text(">[strip_html(text)]")

		if(disconnect_wait > 0)
			src.print_text("Alert: System busy, please hold.")
			return

		if(command == "help" && !src.serv_id)
			var/help_message = {"Terminal Commands:<br>
term_status - View current status of terminal.<br>
term_accept - Toggle connection auto-accept.<br>
term_login - Transmit login file (ID Required)<br>
term_ping - Scan network for terminal devices.<br>
term_break - Send break signal to host.<br>
Connection Commands:<br>
connect \[Net ID] - Connect to a specified device.<br>
disconnect - Disconnect from current device.
File Commands<br>
file_status - View status of loaded file.<br>
file_send - Transmit loaded file.<br>
file_print - Print contents of file.<br>
file_load - Load file from local disk.
file_save - Save file to local disk."}
			src.print_text(help_message)
			return

		switch(command)
			if("term_status")
				if(src.pnet_card)
					var/statdat = pnet_card.return_status_text()
					src.print_text("[pnet_card.func_tag]<br>Status: [statdat]")
				else
					src.print_text("No network card detected.")

				src.print_text("Current Server Address: [src.serv_id ? src.serv_id : "NONE"]<br>Auto-accept connections is [src.auto_accept ? "ON" : "OFF"]<br>Toggle this with \"term_accept\"[src.service_mode ? "<br>Service mode active." : ""]")

			if("term_accept")
				src.auto_accept = !src.auto_accept
				src.print_text("Auto-Accept is now [src.auto_accept ? "ON" : "OFF"]")


			if ("term_break")
				if (!src.serv_id || !pnet_card)
					return

				var/datum/signal/termsignal = get_free_signal()
				//termsignal.encryption = "\ref[netcard]"
				termsignal.data["address_1"] = src.serv_id
				termsignal.data["command"] = "term_break"

				src.peripheral_command("transmit", termsignal, "\ref[pnet_card]")

			if("term_ping")
				if(src.serv_id)
					src.print_text("Alert: Cannot ping while connected.")
					return

				if(!src.pnet_card)
					src.print_text("Alert: No network card detected.")
					return

				var/datum/signal/newsignal = get_free_signal()
				newsignal.encryption = "\ref[src.pnet_card]"

				if (length(command_list)) // shamelessly stolen from terminal.dm
					src.ping_filter = lowertext(command_list[1]) // actual filtering is done in the section handling ping_reply packets
				else
					src.ping_filter = null

				src.ping_wait = 4

				src.print_text("Pinging...")
				src.peripheral_command("ping", newsignal, "\ref[src.pnet_card]")

			if("term_service")
				if (src.serv_id)
					src.print_text("Alert: Cannot switch mode while connected.")
					return

				src.service_mode = !src.service_mode
				src.print_text("Service mode [src.service_mode ? "" : "de"]activated.")

			if("term_login")
				if(!src.pnet_card)
					src.print_text("Alert: No network card detected.")
					return
				if(!src.serv_id)
					src.print_text("Alert: Connection required.")
					return

				var/datum/computer/file/record/udat = new // what name, assignment, and access do we have??
				var/obj/item/peripheral/scanner = find_peripheral("ID_SCANNER")
				if (issilicon(usr) || isAI(usr)) // silicons dont have IDs and we want them to override any inserted ID
					udat.fields["registered"] = isAI(usr) ? "AIUSR" : "CYBORG" // should probably make all logins use the actual name of the silicon at some point
					udat.fields["assignment"] = "AI"
					udat.fields["access"] = "34"
				else
					if(!scanner)
						src.print_text("Error: No ID scanner detected.")
						return
				src.ping_wait = 2
				if(!udat.fields["registered"]) // if a name hasn't been assigned yet (i.e. not a silicon, need to scan id)
					var/datum/signal/scansignal = src.peripheral_command("scan_card",null,"\ref[scanner]")
					if (istype(scansignal))
						udat.fields["registered"] = scansignal.data["registered"]
						udat.fields["assignment"] = scansignal.data["assignment"]
						udat.fields["access"] = scansignal.data["access"]
				if (!udat.fields["registered"] || !udat.fields["assignment"] || !udat.fields["access"])
					udat.dispose()
					src.print_text("Error: User credential validity error.")
					return

				var/datum/signal/termsignal = get_free_signal()
				//termsignal.encryption = "\ref[netcard]"
				termsignal.data["address_1"] = serv_id
				termsignal.data["command"] = "term_file"
				termsignal.data["data"] = "login"
				termsignal.data_file = udat

				src.peripheral_command("transmit", termsignal, "\ref[pnet_card]")
				return


			if("connect")
				if(src.serv_id)
					src.print_text("Alert: Terminal is already connected.")
					return

				if(src.attempt_id)
					src.print_text("Alert: Already attempting to connect.")
					return

				var/argument1 = null
				if(command_list.len)
					argument1 = command_list[1]

				argument1 = ckey(copytext(argument1, 1, 9))
				if(!argument1 || (length(argument1) != 8))
					src.print_text("Alert: Invalid ID. (Must be 8 characters.)")
					return

				src.attempt_id = argument1

				var/datum/computer/file/record/udat = null
				if (istype(src.account))
					udat = new
					udat.fields["registered"] = src.account.registered
					if (src.service_mode)
						udat.fields["userid"] = format_username(src.account.registered)

					udat.fields["assignment"] = src.account.assignment
					udat.fields["access"] = list2params(src.account.access)
					if (!udat.fields["registered"] || !udat.fields["assignment"] || !udat.fields["access"])
						//qdel(udat)
						udat.dispose()
						src.print_text("Error: User credential validity error.")
						return

				var/datum/signal/termsignal = get_free_signal()

				termsignal.data["address_1"] = argument1
				termsignal.data["command"] = "term_connect"
				termsignal.data["device"] = "[src.service_mode ? "SRV" : "HUI"]_TERMINAL"
				if (istype(udat))
					termsignal.data_file = udat

				src.disconnect_wait = 4

				src.print_text("Attempting to connect...")
				src.peripheral_command("transmit", termsignal, "\ref[pnet_card]")

			if("reconnect")
				if (src.serv_id)
					src.print_text("Alert: Terminal is already connected.")
					return

				if (src.attempt_id)
					src.print_text("Alert: Already attempting to connect.")
					return

				if (!src.last_serv_id)
					src.print_text("Alert: No prior connection address in memory.")
					return

				src.attempt_id = src.last_serv_id

				var/datum/signal/termsignal = get_free_signal()
				//termsignal.encryption = "\ref[netcard]"
				termsignal.data["address_1"] = src.attempt_id
				termsignal.data["command"] = "term_connect"
				termsignal.data["device"] = "[src.service_mode ? "SRV" : "HUI"]_TERMINAL"
				src.disconnect_wait = 4

				src.print_text("Attempting to reconnect to \[[src.attempt_id]]...")
				src.peripheral_command("transmit", termsignal, "\ref[pnet_card]")

			if("disconnect")
				if(src.serv_id)
					var/datum/signal/termsignal = get_free_signal()

					termsignal.data["address_1"] = src.serv_id
					termsignal.data["command"] = "term_disconnect"
					src.serv_id = null

					src.peripheral_command("transmit", termsignal, "\ref[pnet_card]")
					src.print_text("Connection Closed.")
					src.disconnect_wait = -1

			if ("file_load")
				var/toLoadName = "temp"
				if (command_list.len)
					toLoadName = jointext(command_list, "")

				var/datum/computer/file/loadedFile = parse_file_directory(toLoadName,src.holding_folder)

				if (istype(loadedFile) && !loadedFile.dont_copy)
					src.print_text("File loaded.")
					src.temp_file = loadedFile
					return

				src.print_text("Alert: File not found (or invalid).")
				return

			if("file_save")
				if (!src.temp_file)
					src.print_text("Error: No file to save!")
					return
				if (src.temp_file.dont_copy)
					src.print_text("Error: File is copy-protected.")
					return

				var/toSaveName = "temp"
				if (command_list.len)
					toSaveName = jointext(command_list, "")

				var/datum/computer/file/record/saved = get_file_name(toSaveName, src.holding_folder)
				if(saved || get_folder_name(toSaveName, src.holding_folder))
					src.print_text("Error: Name in use.")
					return

				if(is_name_invalid(toSaveName))
					src.print_text("Error: Invalid character in name.")
					return

				saved = src.temp_file.copy_file()
				saved.name = toSaveName
				if (!saved)
					src.print_text("Error: Cannot save to disk.")
					return

				if (!src.holding_folder.add_file(saved))
					saved.dispose()
					src.print_text("Error: Cannot save to disk.")
					return

				src.print_text("File saved.")
				return

			if("file_send")
				if (!istype(src.temp_file))
					src.print_text("Alert: No file loaded.")
					return

				if(!src.serv_id)
					src.print_text("Alert: Connection required.")
					return

				var/sendText = "login"
				if (command_list.len)
					sendText = jointext(command_list, " ")

				src.send_term_message(sendText, 1)
				src.print_text("File sent.")

			if ("file_status")
				if(!src.temp_file || !istype(src.temp_file))
					src.print_text("Alert: No file loaded.")
					return

				var/file_info = "[temp_file.name] - [temp_file.extension] - \[Size: [temp_file.size]]<br>Enter command \"file_save\" to save to external disk."
				if(istype(temp_file, /datum/computer/file/text))
					file_info += "<br>Enter command \"file_print\" to print."
				else
					file_info += "<br>Unrecognized filetype."

				src.print_text(file_info)

			if("file_print")
				if(!src.temp_file)
					src.print_text("Alert: File invalid or missing.")
					return

				var/to_print = src.temp_file.asText()
				if (!to_print)
					src.print_text("Alert: Nothing to print.")
					return

				src.print_text("Sending print command...")
				var/datum/signal/printsig = new
				printsig.data["data"] = to_print
				printsig.data["title"] = "Printout"

				src.peripheral_command("print",printsig)

			if ("quit")
				if(src.serv_id)
					var/datum/signal/termsignal = get_free_signal()

					termsignal.data["address_1"] = src.serv_id
					termsignal.data["command"] = "term_disconnect"
					src.serv_id = null

					src.peripheral_command("transmit", termsignal, "\ref[pnet_card]")
					src.print_text("Connection Closed.")
					src.disconnect_wait = -1

				src.print_text("Now Quitting...")
				src.master.unload_program(src)
				return

			else
				src.send_term_message(text)

		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return

	disk_ejected(var/obj/item/disk/data/thedisk)
		if(!thedisk)
			return

		if(src.holder == thedisk)
			if(src.serv_id)
				var/datum/signal/termsignal = get_free_signal()

				termsignal.data["address_1"] = src.serv_id
				termsignal.data["command"] = "term_disconnect"
				src.serv_id = null

				src.peripheral_command("transmit", termsignal, "\ref[pnet_card]")
				src.disconnect_wait = -1

			src.print_text("<font color=red>Fatal Error. Returning to system...</font>")
			src.master.unload_program(src)
			return

		return

	receive_command(obj/source, command, datum/signal/signal)
		if((..()) || (!signal))
			return

		if(!serv_id || signal.data["sender"] != src.serv_id)
			if(cmptext(signal.data["command"], "ping_reply") && src.ping_wait)
				if(!signal.data["device"] || !signal.data["netid"])
					return

				var/reply_device = signal.data["device"]
				var/reply_id = signal.data["netid"]

				if(src.ping_filter == null || findtext(lowertext(reply_device), src.ping_filter))
					src.print_text("<b>P:</b> \[[reply_id]]-TYPE: [reply_device]")

			//oh, somebody trying to connect!
			else if(cmptext(signal.data["command"], "term_connect") && !src.serv_id)
				if(!attempt_id && signal.data["sender"] && src.auto_accept)
					src.serv_id = signal.data["sender"]
					src.disconnect_wait = -1
					src.print_text("Connection established to [serv_id]!")
					//well okay but now they need to know we've accepted!
					if(signal.data["data"] != "noreply")
						var/datum/signal/termsignal = get_free_signal()

						termsignal.data["address_1"] = signal.data["sender"]
						termsignal.data["command"] = "term_connect"

						src.peripheral_command("transmit", termsignal, "\ref[pnet_card]")


				else if(cmptext(signal.data["sender"], attempt_id))
					src.attempt_id = null
					src.serv_id = signal.data["sender"]
					src.disconnect_wait = -1
					src.print_text("Connection to [serv_id] successful.")

		if(cmptext(signal.data["sender"], src.serv_id))
			switch(lowertext(signal.data["command"]))
				if("term_message")
					var/new_message = signal.data["data"]
					if(!new_message)
						return

					switch(lowertext(signal.data["render"]))
						if("clear") //They want the screen clear before printing
							src.master.temp = null

						if("multiline") //Oh, they want multiple lines of stuff.
							new_message = replacetext(new_message, "|n", "<br>]")

						if ("multiline|clear","clear|multiline") //Both of the above!
							src.master.temp = null
							new_message = replacetext(new_message, "|n", "<br>]")

					src.print_text("][new_message]")
					return

				if("term_file") //oh boy, a file!
					if(!signal.data_file || !istype(signal.data_file))
						return //oh no the file is bad
/*
					//Will it fit? Check before clearing out our old temp file!
					if((holder.file_used + signal.data_file.size) > holder.file_amount)
						src.print_text("Alert: Unable to accept file transfer, disk is full!")
						return
*/
					if(src.temp_file && !src.temp_file.holding_folder)
						temp_file.dispose()

					src.temp_file = signal.data_file.copy_file()
					src.temp_file.name = "temp"
					src.print_text("Alert: File received from remote host!<br>Valid commands: file_status, file_print")

				if("term_ping")
					if(signal.data["data"] == "reply")
						var/datum/signal/termsignal = get_free_signal()

						termsignal.data["address_1"] = signal.data["sender"]
						termsignal.data["command"] = "term_ping"

						src.peripheral_command("transmit", termsignal, "\ref[pnet_card]")
					return

				if("term_disconnect")
					src.serv_id = null
					src.attempt_id = null

					src.print_text("Connection closed by remote host.")
					return

		return

	proc/send_term_message(var/message, send_file)
		if(!message || !src.serv_id || !pnet_card)
			return

		message = strip_html(message)

		var/datum/signal/termsignal = get_free_signal()

		termsignal.data["address_1"] = src.serv_id
		termsignal.data["data"] = message
		termsignal.data["command"] = "term_[send_file ? "file" : "message"]"
		if (send_file && src.temp_file)
			termsignal.data_file = src.temp_file.copy_file()

		src.peripheral_command("transmit", termsignal, "\ref[pnet_card]")
		return

#define WORKING_PACKET_MAX 32

/datum/computer/file/terminal_program/sigpal
	name = "SigPal"
	size = 4
	var/list/working_signal = list()
	var/obj/item/peripheral/network/pnet_card
	var/datum/computer/file/attached_file = null

	disposing()
		pnet_card = null
		working_signal = null
		attached_file = null
		..()

	initialize()
		if (..())
			return TRUE
		working_signal = list()
		src.pnet_card = null
		attached_file = null
		var/introdat = "SigPal Signal Manager<br>Copyright 2053 Thinktronic Systems, LTD."

		src.pnet_card = find_peripheral("NET_ADAPTER")
		if (!src.pnet_card || !istype(src.pnet_card))
			src.pnet_card = find_peripheral("RAD_ADAPTER")
			if (istype(src.pnet_card))
				src.peripheral_command("mode_net", null, "\ref[pnet_card]")
				introdat += "<br>Network card detected (Radio)."
			else

				src.pnet_card = null
				introdat += "<br>Error: No network card detected."

		if (src.pnet_card)
			introdat += "<br>Network ID: [pnet_card.net_id]"


		src.print_text("[introdat]<br>Type \"help\" for commands.")


	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1] //Remove the command we are now processing.

		switch(lowertext(command))
			if ("help")
				src.print_text("Command List:<br> ADD \[key] \[data]  to add (or replace) a key-value pair to the packet.<br> REMOVE \[key]  to remove existing key pair <br> VIEW  to view current packet.<br> SEND  to transmit packet over network card.<br> SAVE/LOAD \[file name] to save/load the signal as a record.<br> NEW to clear current signal.<br> FILE to set an attachment to send (This is not saved to disk)")
				return

			if ("add")
				var/key = null
				var/data = null
				. = 0
				if(length(command_list) >= 2)

					key = command_list[1]
					command_list -= command_list[1]
					key = copytext(lowertext(strip_html(key)), 1, 128)

					data = jointext(command_list, " ")
					data = copytext(strip_html(data), 1, 256)

				if(!ckey(key) || ckey(!data))
					src.print_text("Syntax: \"add \[key] \[data]\"")
					return

				if(length(src.working_signal) >= WORKING_PACKET_MAX)
					src.print_text("Error: Maximum packet keys reached.")
					return

				if(!isnull(src.working_signal[key]))
					. = 1

				src.working_signal[key] = data
				src.print_text("Addition complete. (Signal length: \[[src.working_signal.len]])[. ? "<br>That key was already present and has been modified." : ""]")

			if ("remove")
				var/key = lowertext(command_list[1])
				if (key in working_signal)
					working_signal -= key
					src.print_text("Key removed. (Signal length: \[[src.working_signal.len]])")
				else
					src.print_text("Key not present.")

			if ("send","transmit")
				if (!src.working_signal.len)
					src.print_text("Error: Cannot send empty packet.")
					return

				if (!src.pnet_card)
					src.print_text("Error: No network card present!")
					return

				var/datum/signal/sig = get_free_signal()
				for (var/entry in working_signal)
					var/equalpos = findtext("=", entry)
					if (equalpos)
						sig.data["[copytext(entry, 1, equalpos)]"] = "[copytext(entry, equalpos)]"
					else
						if (!isnull(working_signal[entry]))
							sig.data["[entry]"] = working_signal[entry]
						else
							sig.data += entry

				if (attached_file)
					sig.data_file = attached_file

				src.peripheral_command("transmit", sig, "\ref[pnet_card]")
				src.print_text("Packet sent.")

			if ("view")
				if (!src.working_signal.len)
					src.print_text("The current packet is empty.")
					return

				. = ""
				for (var/key in src.working_signal)
					. += "[key] = [src.working_signal[key]]<br>"


				src.print_text(.)
				return

			if ("save")
				var/new_name = strip_html(jointext(command_list, " "))
				new_name = copytext(new_name, 1, 16)

				if(!new_name)
					src.print_text("Syntax: \"SAVE \[file name]\"")
					return

				var/datum/computer/file/record/saved = get_file_name(new_name, src.holding_folder)
				if(saved && !istype(saved) || get_folder_name(new_name, src.holding_folder))
					src.print_text("Error: Name in use.")
					return

				if(is_name_invalid(new_name))
					src.print_text("Error: Invalid character in name.")
					return

				if(saved && istype(saved))
					saved.fields = src.working_signal.Copy()
				else
					saved = new /datum/computer/file/record
					saved.name = new_name
					saved.fields = src.working_signal.Copy()
					if(!src.holding_folder.add_file(saved))
						//qdel(saved)
						saved.dispose()
						src.print_text("Error: Cannot save to disk.")
						return

				src.print_text("Record \"[new_name]\" saved.")

			if ("load")
				var/file_name = ckey(jointext(command_list, " "))

				if(!file_name)
					src.print_text("Syntax: \"LOAD \[file name]\"")
					return

				var/datum/computer/file/record/to_load = get_file_name(file_name, src.holding_folder)
				if(!to_load || !istype(to_load))
					src.print_text("Error: File not found or corrupt.")
					return

				src.working_signal = to_load.fields.Copy()
				src.working_signal.len = min(src.working_signal.len, WORKING_PACKET_MAX)

				src.print_text("Load complete.")

			if ("new")
				src.working_signal = list()
				src.attached_file = null
				src.print_text("Signal cleared.")

			if ("file")
				var/file_name = ckey(jointext(command_list, " "))

				if(!file_name)
					src.attached_file = null
					src.print_text("File attachment cleared.")
					return

				var/datum/computer/file/to_load = get_file_name(file_name, src.holding_folder)
				if(!istype(to_load))
					src.print_text("Error: File not found or corrupt.")
					return

				attached_file = to_load.copy_file()

			if ("quit","exit")
				src.master.temp = ""
				print_text("Now quitting...")
				src.master.unload_program(src)
				return

			else
				src.print_text("Unknown command.")

#undef WORKING_PACKET_MAX

/datum/computer/file/terminal_program/sigcrafter
	name = "SigCraft"
	size = 4
	var/temp= null
	var/datum/computer/file/included_file = null //File to include in signal file.
	var/list/text_buffer = list()
	var/list/working_signal = list()
	var/selected_line = 1 //Which line of the signal are we working on?

#define WORKING_DISPLAY_LENGTH 8 //How many lines is the working portion?

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1] //Remove the command we are now processing.

		switch(lowertext(command))
			if("line") //Set working line to provided num.
				var/target_line = 0
				if(command_list.len)
					target_line = round(text2num_safe(command_list[1]))
				else
					src.print_half_text("Line number required.")
					return


				if((!target_line) || (target_line > WORKING_DISPLAY_LENGTH) || (target_line <= 0))
					src.print_half_text("Error: Line invalid or out of bounds.")
					return

				src.selected_line = target_line
				src.print_half_text("Active line set to [target_line].")

			if("add") //Add new line to signal if possible.
				var/title = null
				var/data = null
				if(length(command_list) >= 2)

					title = command_list[1]
					command_list -= command_list[1]
					title = copytext(lowertext(strip_html(title)), 1, 16)

					data = jointext(command_list, " ")
					data = copytext(strip_html(data), 1, 255)

				if(!ckey(title) || ckey(!data))
					src.print_half_text("Syntax: \"add \[title] \[data]\"")
					return

				if(length(src.working_signal) >= WORKING_DISPLAY_LENGTH)
					src.print_half_text("Error: Working Signal Full.")
					return

				if(!isnull(src.working_signal[title]))
					src.print_half_text("Error: Title already in use.")
					return

				src.working_signal[title] = data
				src.print_half_text("Addition complete. (Signal length: \[[src.working_signal.len]])")

			if("view")
				if((selected_line > src.working_signal.len) || (selected_line <= 0))
					src.print_half_text("Error: Working line out of bounds.")
					return

				src.print_half_text("L\[[selected_line]]: [src.working_signal[src.working_signal[selected_line]]]")

			if("remove")
				if((selected_line > src.working_signal.len) || (selected_line <= 0))
					src.print_half_text("Error: Working line out of bounds.")
					return

				src.working_signal -= src.working_signal[selected_line]

				src.print_half_text("Line \[[selected_line]] cleared.")

			if("load")
				var/file_name = ckey(jointext(command_list, " "))

				if(!file_name)
					src.print_half_text("Syntax: \"load \[file name]\"")
					return

				var/datum/computer/file/signal/to_load = get_file_name(file_name, src.holding_folder)
				if(!to_load || !istype(to_load))
					src.print_half_text("Error: File not found or corrupt.")
					return

				src.working_signal = to_load.data.Copy()
				src.working_signal.len = min(src.working_signal.len, WORKING_DISPLAY_LENGTH)
				src.included_file = null
				if(to_load.data_file)
					src.included_file = to_load.data_file.copy_file()

				src.print_half_text("Load complete.")

			if("save")
				var/new_name = strip_html(jointext(command_list, " "))
				new_name = copytext(new_name, 1, 16)

				if(!new_name)
					src.print_half_text("Syntax: \"save \[file name]\"")
					return

				var/datum/computer/file/signal/saved = get_file_name(new_name, src.holding_folder)
				if(saved && !istype(saved) || get_folder_name(new_name, src.holding_folder))
					src.print_half_text("Error: Name in use.")
					return

				if(is_name_invalid(new_name))
					src.print_half_text("Error: Invalid character in name.")
					return

				if(saved && istype(saved))
					saved.data = src.working_signal.Copy()
					if(saved.data_file)
						//qdel(saved.data_file)
						saved.data_file.dispose()
					if(src.included_file)
						saved.data_file = src.included_file.copy_file()
				else
					saved = new /datum/computer/file/signal
					saved.name = new_name
					saved.data = src.working_signal.Copy()
					if(src.included_file)
						saved.data_file = src.included_file.copy_file()
					if(!src.holding_folder.add_file(saved))
//						qdel(saved)
						saved.dispose()
						src.print_half_text("Error: Cannot save to disk.")
						return

				src.print_half_text("Signal \"[new_name]\" saved.")

			if("recsave")
				var/new_name = strip_html(jointext(command_list, " "))
				new_name = copytext(new_name, 1, 16)

				if(!new_name)
					src.print_half_text("Syntax: \"recsave \[file name]\"")
					return

				var/datum/computer/file/record/saved = get_file_name(new_name, src.holding_folder)
				if(saved && !istype(saved) || get_folder_name(new_name, src.holding_folder))
					src.print_half_text("Error: Name in use.")
					return

				if(is_name_invalid(new_name))
					src.print_half_text("Error: Invalid character in name.")
					return

				if(saved && istype(saved))
					saved.fields = src.working_signal.Copy()
				else
					saved = new /datum/computer/file/record
					saved.name = new_name
					saved.fields = src.working_signal.Copy()
					if(!src.holding_folder.add_file(saved))
						//qdel(saved)
						saved.dispose()
						src.print_half_text("Error: Cannot save to disk.")
						return

				src.print_half_text("Record \"[new_name]\" saved.")

			if("file")
				var/inc_path = jointext(command_list, " ")
				if(!ckey(inc_path))
					src.print_half_text("Syntax: \"file \[filepath]\"")
					src.print_half_text("Path of file to include in signal.")
					src.print_half_text("Current: [istype(src.included_file) ? src.included_file.name : "NONE"]")
					return

				var/datum/computer/file/to_inc = src.parse_file_directory(inc_path, holding_folder)
				if(!istype(to_inc))
					src.print_half_text("Error: Invalid filepath!")
					return

				src.included_file = to_inc.copy_file()
				src.print_half_text("File set.")

			if("new")
				src.working_signal = get_free_signal()
				if(src.included_file)
					//qdel(src.included_file)
					src.included_file.dispose()
				src.print_half_text("Work cleared.")

			if("help")
				src.print_half_text("Commands: Add \[Title] \[Data], Line \[line],")
				src.print_half_text("Load/Save/RecSave \[file], File \[path], New, Remove")
				src.print_half_text("Help, Quit.")

			if("quit")
				src.master.temp = ""
				print_text("Now quitting...")
				src.master.unload_program(src)
				return

			else
				print_half_text("Unknown command : \"[copytext(strip_html(command), 1, 16)]\"")

		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return

	initialize()
		if (..())
			return TRUE
		//Set working lists back to normal...
		src.text_buffer = new
		src.working_signal = get_free_signal()
		//Their length should be fixed up by the first print_half_text call
		src.print_half_text("Signal Crafter 2.0")
		src.print_half_text("Commands: Add \[Title] \[Data], Line \[line],")
		src.print_half_text("Load/Save \[file], File \[path], New, Remove, Recsave \[file]")
		src.print_half_text("Help, Quit.")

	/* new disposing() pattern should handle this. -singh
	disposing()
		if(src.included_file)
			qdel(src.included_file)
		..()
	*/

	disposing()
		if (src.included_file)
			src.included_file.dispose()
			src.included_file = null

		src.text_buffer = null
		src.working_signal = null
		..()

	proc
		print_half_text(var/text) //Print stuff to the screen while keeping the signal info up
			if((!src.holder) || (!src.master) || !text || disposed)
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(master.status & (NOPOWER|BROKEN))
				return 1

			if(!(holder in src.master.contents))
				if(master.active_program == src)
					master.active_program = null
				return 1

			if(!src.holder.root)
				src.holder.root = new /datum/computer/folder
				src.holder.root.holder = src
				src.holder.root.name = "root"

			if(length(src.text_buffer) >= 6)
				src.text_buffer -= src.text_buffer[1]

			src.text_buffer += text

			src.selected_line = clamp(src.selected_line, 1, 8)

			if (!istype(working_signal, /list))
				working_signal = list()

			var/dat = "<center>Current Signal</center><br>"
			for(var/x = 1, x <= WORKING_DISPLAY_LENGTH, x++)
				var/part = "\[UNUSED]"
				if(x <= working_signal.len)
					var/title_text = working_signal[x]
					var/main_text = working_signal[title_text]
					part = " \[[isnull(title_text) ? "Untitled" : title_text]] \[[isnull(main_text) ? "Blank" : copytext(main_text, 1, 25)]]"
				if(src.selected_line == x)
					dat += ">\[[x]] [part]<br>"
				else
					dat += "|\[[x]] [part]<br>"

			dat += "<hr>"

			for(var/x in src.text_buffer)
				dat += "[x]<br>"

			src.master.temp = null
			src.master.temp_add = "[dat]"
			src.master.updateUsrDialog()

			return 0

#undef WORKING_DISPLAY_LENGTH

/datum/computer/file/terminal_program/disease_research

/datum/computer/file/terminal_program/artifact_research

/datum/computer/file/terminal_program/manifest
	name = "Manifest"
	size = 4


	initialize()
		if (..())
			return TRUE

		var/dat = "Crew Manifest<br>Entries cannot be modified from this terminal.<br>"


		dat += get_manifest(FALSE)


		src.master.temp = null
		src.print_text("[dat]Now exiting...")
		src.master.unload_program(src)

		return

/datum/computer/file/terminal_program/robotics_research

#undef MAX_BACKGROUND_PROGS
