

/datum/computer/file/terminal_program/os/terminal_os
	name = "TermOS B"
	size = 6
	var/datum/computer/folder/current_folder = null
	var/net_number = null
	var/tmp/serv_id = null //NetID of connected server
	var/tmp/attempt_id = null //Are we attempting to connect to something?
	var/tmp/last_serv_id = null //Last valid serv_id.
	var/obj/item/peripheral/network/netcard = null
	var/tmp/disconnect_wait = -1 //Are we waiting to disconnect?
	var/tmp/ping_wait = 0 //Are we waiting for a ping reply?
	var/tmp/datum/computer/file/temp_file = null //Temp folder from our server
	var/auto_accept = 1 //Do we automatically accept connection attempts?
	var/ping_filter = null
	//var/tmp/service_mode = 0

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = lowertext(command_list[1])
		command_list -= command_list[1] //Remove the command that we are now processing.

		src.print_text(">[strip_html(text)]")

		if(!current_folder)
			current_folder = src.holding_folder

		if(disconnect_wait > 0)
			src.print_text("Alert: System busy, please hold.")
			return

		if(command == "help" && !src.serv_id)
			var/help_message = {"<b>Terminal Commands:</b><br>
term_status - View current status of terminal.<br>
term_accept - Toggle connection auto-accept.<br>
term_login - Transmit login file (ID Required)<br>
term_ping \[Device ID] - Scan network for devices.<br>
term_break - Send break signal to host.<br>
<b>Connection Commands:</b><br>
connect \[Net ID] - Connect to a specified device.<br>
reconnect - Connect to last valid address<br>
disconnect - Disconnect from current device.<br>
<b>File Commands</b><br>
file_status - View status of loaded file.<br>
file_send - Transmit loaded file.<br>
file_print - Print contents of file.<br>
file_load - Load file from local disk.
file_save - Save file to local disk."}
			src.print_text(help_message)
			return

		switch(command)
			if("term_status")
				if(src.netcard)
					var/statdat = netcard.return_status_text()
					src.print_text("<b>[netcard.func_tag]</b><br>Status: [statdat]")
				else
					src.print_text("No network card detected.")

				src.print_text("Current Server Address: [src.serv_id ? src.serv_id : "NONE"]<br>Auto-accept connections is <b>[src.auto_accept ? "ON" : "OFF"]</b><br>Toggle this with \"term_accept\"")//[src.service_mode ? "<br>Service mode active." : ""]")

			if("term_accept")
				src.auto_accept = !src.auto_accept
				src.print_text("Auto-Accept is now <b>[src.auto_accept ? "ON" : "OFF"]</b>")

			if ("term_break")
				if (!src.serv_id || !netcard)
					return

				var/datum/signal/termsignal = get_free_signal()
				//termsignal.encryption = "\ref[netcard]"
				termsignal.data["address_1"] = src.serv_id
				termsignal.data["command"] = "term_break"

				src.peripheral_command("transmit", termsignal, "\ref[netcard]")

			if("term_ping")
				if(src.serv_id)
					src.print_text("Alert: Cannot ping while connected.")
					return

				if(!src.netcard)
					src.print_text("Alert: No network card detected.")
					return

				if (command_list.len)
					if (ckey(command_list[1]) == "all")
						src.net_number = null
					else
						var/new_net_number = round( text2num_safe(command_list[1]) )
						if (new_net_number != null && new_net_number >= 0 && new_net_number <= 16)
							src.net_number = new_net_number

					src.peripheral_command("subnet[src.net_number]", null, "\ref[src.netcard]")
				if (length(command_list))
					src.ping_filter = lowertext(command_list[1])
				else
					src.ping_filter = null

				src.ping_wait = 4

				src.print_text("Pinging [src.net_number == null ? "All Subnetworks" : "Subnetwork [src.net_number]"]...")
				src.peripheral_command("ping[src.net_number]", null, "\ref[src.netcard]")

			if("term_login")
				if(!src.netcard)
					src.print_text("Alert: No network card detected.")
					return
				if(!src.serv_id)
					src.print_text("Alert: Connection required.")
					return

				if (issilicon(usr) || isAI(usr))
					src.ping_wait = 2
					var/datum/signal/newsig = new
					newsig.data["registered"] = isAI(usr) ? "AI" : "CYBORG"
					newsig.data["assignment"] = "AI"
					newsig.data["access"] = "34"

					src.receive_command(src.master, "card_authed", newsig)
					return

				var/obj/item/peripheral/scanner = find_peripheral("ID_SCANNER")
				if(!scanner)
					src.print_text("Error: No ID scanner detected.")
					return
				src.ping_wait = 2
				switch(src.peripheral_command("scan_card",null,"\ref[scanner]"))
					if("nocard")
						src.print_text("Please insert a card first.")
					if("noreg")
						src.print_text("Notice: No name on card.")
					if("noassign")
						src.print_text("Notice: No assignment on card.")

/*
			if("term_service")
				if (src.serv_id)
					src.print_text("Alert: Cannot switch mode while connected.")
					return

				src.service_mode = !src.service_mode
				src.print_text("Service mode [src.service_mode ? "" : "de"]activated.")
*/
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

				var/datum/signal/termsignal = get_free_signal()
				//termsignal.encryption = "\ref[netcard]"
				termsignal.data["address_1"] = argument1
				termsignal.data["command"] = "term_connect"
				termsignal.data["device"] = "HUI_TERMINAL"
				//termsignal.data["device"] = "[src.service_mode ? "SRV" : "HUI"]_TERMINAL"
				src.disconnect_wait = 4

				src.print_text("Attempting to connect...")
				src.peripheral_command("transmit", termsignal, "\ref[netcard]")

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
				termsignal.data["device"] = "HUI_TERMINAL"
				//termsignal.data["device"] = "[src.service_mode ? "SRV" : "HUI"]_TERMINAL"
				src.disconnect_wait = 4

				src.print_text("Attempting to reconnect to \[[src.attempt_id]]...")
				src.peripheral_command("transmit", termsignal, "\ref[netcard]")


			if("disconnect")
				if(src.serv_id)
					var/datum/signal/termsignal = get_free_signal()
					//termsignal.encryption = "\ref[netcard]"
					termsignal.data["address_1"] = src.serv_id
					termsignal.data["command"] = "term_disconnect"
					src.serv_id = null

					src.peripheral_command("transmit", termsignal, "\ref[netcard]")
					src.print_text("<b>Connection Closed.</b>")
					src.disconnect_wait = -1

			//Tempfile usage commands.
			if("file_status")
				if(!src.temp_file || !istype(src.temp_file))
					src.print_text("Alert: No file loaded.")
					return

				var/file_info = "[temp_file.name] - [temp_file.extension] - \[Size: [temp_file.size]]<br>Enter command \"file_save\" to save to external disk."
				if(istype(temp_file, /datum/computer/file/text))
					file_info += "<br>Enter command \"file_print\" to print."
				else if(istype(temp_file, /datum/computer/file/terminal_program/termapp))
					file_info += "<br>Enter command \"file_run\" to execute."
				else
					file_info += "<br>Unknown filetype."

				src.print_text(file_info)

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

/*
			if("file_read")
				if(!src.temp_file || !istype(temp_file, /datum/computer/file/text))
					src.print_text("Alert: File invalid or missing.")
					return

				src.master.temp = "<b>File Contents:</b><br>"
				src.print_text(src.temp_file:data)
*/
			if("file_load")
				var/toLoadName = "temp"
				if (command_list.len)
					toLoadName = jointext(command_list, "")

				var/datum/computer/file/loadedFile = null
				for (var/obj/item/disk/data/drive in src.master.contents)
					if (drive == src.holder)
						continue

					loadedFile = get_file_name(toLoadName, drive.root)
					if (istype(loadedFile) && !loadedFile.dont_copy)
						src.print_text("File loaded.")
						src.temp_file = loadedFile
						return

					continue

				if (src.master.hd && src.master.hd.root)
					loadedFile = get_file_name(toLoadName, src.master.hd.root)

				if (istype(loadedFile))
					src.print_text("File loaded.")
					src.temp_file = loadedFile
					return

				src.print_text("Alert: File not found (or invalid).")
				return

			if("file_save")
				if (!src.temp_file)
					src.print_text("Alert: No file to save.")
					return
				
				if (src.temp_file.dont_copy)
					src.print_text("Error: File is copy-protected.")
					return

				var/toSaveName = "temp"
				if (command_list.len)
					toSaveName = jointext(command_list, "")

				for (var/obj/item/disk/data/drive in src.master.contents)
					if (drive == src.holder || !drive.root)
						continue

					if (src.temp_file.holder == drive)
						src.print_text("Alert: File already saved to this drive.")
						return

					var/datum/computer/file/oldFile = get_file_name(toSaveName, drive.root)
					if (oldFile)
						if (istype(oldFile, src.temp_file.type))
							oldFile.dispose()

						else
							src.print_text("Alert: File name taken, unable to overwrite.")
							return

					src.temp_file.name = toSaveName
					if (drive.root.add_file(src.temp_file.copy_file()))
						src.print_text("File saved.")
						return

					src.print_text("Alert: Unable to write to disk.")
					return

				src.print_text("Alert: No valid destination drive found.")
				return

			if("file_print")
				if(!src.temp_file || (!istype(temp_file, /datum/computer/file/text) && !istype(temp_file, /datum/computer/file/record)))
					src.print_text("Alert: File invalid or missing.")
					return

				var/to_print = null
				if(istype(temp_file, /datum/computer/file/record))
					for(var/a in temp_file:fields)
						if (temp_file:fields[a])
							to_print += "[a]=[temp_file:fields[a]]<br>"
						else
							to_print += "[a]<br>"
				else
					to_print = temp_file:data
				src.print_text("Sending print command...")
				var/datum/signal/printsig = new
				//printsig.encryption = "\ref[netcard]"
				printsig.data["data"] = to_print
				printsig.data["title"] = "Printout"

				src.peripheral_command("print",printsig, "\ref[netcard]")

			if("file_run") //to-do
				src.print_text("Command currently inoperative.")

			else
				src.send_term_message(text)

		return

	initialize()
		if (..())
			return TRUE
		//src.service_mode = 0
		src.print_text("Loading TermOS, Revision C<br>Copyright 2046-2053 Thinktronic Systems, LTD.")

		if(src.serv_id) //I guess some jerk rebooted us
			var/datum/signal/termsignal = get_free_signal()
			//termsignal.encryption = "\ref[netcard]"
			termsignal.data["address_1"] = src.serv_id
			termsignal.data["command"] = "term_disconnect"

			src.peripheral_command("transmit", termsignal, "\ref[netcard]")

		src.ping_wait = 0
		src.disconnect_wait = 0
		src.attempt_id = null
		src.serv_id = null
		src.netcard = find_peripheral("NET_ADAPTER")
		if(!src.netcard || !istype(src.netcard))
			src.netcard = find_peripheral("RAD_ADAPTER")
			if (istype(src.netcard))
				src.peripheral_command("mode_net", null, "\ref[netcard]")
				src.print_text("Network card detected.<br>Ready.")
			else
				src.netcard = null
				src.print_text("<font color=red>Error: No network card detected.</font><br>Ready.")
		else
			src.print_text("Network card detected.<br>Ready.")

		src.current_folder = src.holder.root
		if(src.setup_string && src.netcard) //Use setup string as tag for startup server.
			var/target_tag = src.setup_string
			var/maybe_netnum = findtext(target_tag, "|")
			if (maybe_netnum)
				src.net_number = text2num_safe( copytext(target_tag, maybe_netnum+1) )
				target_tag = copytext(target_tag, 1, maybe_netnum)
				src.peripheral_command("subnet[src.net_number]", null, "\ref[src.netcard]")

			src.setup_string = null

			var/obj/target_serv = locate(target_tag)
			if(istype(target_serv) && hasvar(target_serv,"net_id"))
				SPAWN(10 SECONDS)
					if (target_serv)
						src.input_text("connect [target_serv:net_id]")

		return

	disk_ejected(var/obj/item/disk/data/thedisk)
		if(!thedisk)
			return

		if(current_folder && (current_folder.holder == thedisk))
			current_folder = src.holding_folder

		if(src.holder == thedisk)
			src.print_text("<font color=red>System Error: Unable to read system file.</font>")
			src.master.active_program = null
			src.master.host_program = null
			return

		if(src.temp_file && (src.temp_file.holder == thedisk))
			src.temp_file = null

		return

	proc/send_term_message(var/message, send_file=0)
		if(!message || !src.serv_id || !netcard)
			return

		message = strip_html(message)

		var/datum/signal/termsignal = get_free_signal()
		//termsignal.encryption = "\ref[netcard]"
		termsignal.data["address_1"] = src.serv_id
		termsignal.data["data"] = message
		termsignal.data["command"] = "term_[send_file ? "file" : "message"]"
		if (send_file && src.temp_file)
			termsignal.data_file = src.temp_file.copy_file()

		src.peripheral_command("transmit", termsignal, "\ref[netcard]")
		return

	restart()
		attempt_id = null
		if(src.serv_id) //I guess some jerk rebooted us
			var/datum/signal/termsignal = get_free_signal()
			//termsignal.encryption = "\ref[netcard]"
			termsignal.data["address_1"] = src.serv_id
			termsignal.data["command"] = "term_disconnect"

			src.peripheral_command("transmit", termsignal, "\ref[netcard]")
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

	receive_command(obj/source, command, datum/signal/signal)
		if((..()) || (!signal))
			return

		if(command == "card_authed" && src.ping_wait && serv_id)

			var/datum/computer/file/record/udat = new
			udat.fields["registered"] = signal.data["registered"]
			udat.fields["assignment"] = signal.data["assignment"]
			udat.fields["access"] = signal.data["access"]
			if (!udat.fields["access"] || !udat.fields["assignment"] || !udat.fields["access"])
				//qdel(udat)
				udat.dispose()
				return

			var/datum/signal/termsignal = get_free_signal()
			//termsignal.encryption = "\ref[netcard]"
			termsignal.data["address_1"] = serv_id
			termsignal.data["command"] = "term_file"
			termsignal.data["data"] = "login"
			termsignal.data_file = udat

			src.peripheral_command("transmit", termsignal, "\ref[netcard]")
			return


		if(!serv_id || signal.data["sender"] != src.serv_id)
			if(signal.data["command"] == "ping_reply" && src.ping_wait)
				if(!signal.data["device"] || !signal.data["netid"])
					return

				var/reply_device = signal.data["device"]
				var/reply_id = signal.data["netid"]

				if(src.ping_filter == null || findtext(lowertext(reply_device), src.ping_filter))
					src.print_text("<b>P:</b> \[[strip_html(reply_id)]]-TYPE: [strip_html(reply_device)]")

			//oh, somebody trying to connect!
			else if(signal.data["command"] == "term_connect" && !src.serv_id)
				if(!attempt_id && signal.data["sender"] && src.auto_accept)
					src.serv_id = signal.data["sender"]
					src.disconnect_wait = -1
					src.print_text("Connection established to [strip_html(serv_id)]!")
					//well okay but now they need to know we've accepted!
					if(signal.data["data"] != "noreply")
						var/datum/signal/termsignal = get_free_signal()
						//termsignal.encryption = "\ref[netcard]"
						termsignal.data["address_1"] = signal.data["sender"]
						termsignal.data["command"] = "term_connect"
						termsignal.data["data"] = "noreply"

						src.peripheral_command("transmit", termsignal, "\ref[netcard]")


				else if(signal.data["sender"] == attempt_id)
					src.attempt_id = null
					src.serv_id = signal.data["sender"]
					src.last_serv_id = src.serv_id
					src.disconnect_wait = -1
					src.print_text("Connection to [serv_id] successful.")

		if(signal.data["sender"] == src.serv_id)
			switch(lowertext(signal.data["command"]))
				if("term_message")
					var/new_message = strip_html(signal.data["data"])
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

					//Will it fit? Check before clearing out our old temp file!
					if((holder.file_used + signal.data_file.size) > holder.file_amount)
						src.print_text("Alert: Unable to accept file transfer, disk is full!")
						return

					if(src.temp_file)
						//qdel(temp_file) //Clear our old temp file!
						temp_file.dispose()

					src.temp_file = signal.data_file.copy_file()
					src.temp_file.name = "temp"
					src.print_text("Alert: File received from remote host!<br>Valid commands: file_status, file_print")

				if("term_ping")
					if(signal.data["data"] == "reply")
						var/datum/signal/termsignal = get_free_signal()
						//termsignal.encryption = "\ref[netcard]"
						termsignal.data["address_1"] = signal.data["sender"]
						termsignal.data["command"] = "term_ping"

						src.peripheral_command("transmit", termsignal, "\ref[netcard]")
					return

				if("term_disconnect")
					src.serv_id = null
					src.attempt_id = null

					src.print_text("<b>Connection closed by remote host.</b>")
					return

		return
