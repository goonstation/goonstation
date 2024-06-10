//CONTENTS
//Writing/printing program


#define MODE_EDIT 0
#define MODE_CONFIG 1
#define MODE_SELECT_PRINTER 2

//Text editor program
/datum/computer/file/terminal_program/writewizard
	name = "WizWrite"
	size = 2
	var/tmp/mode = 0
	var/tmp/connected = 0
	var/tmp/server_netid = null
	var/tmp/potential_server_netid = null
	var/tmp/obj/item/peripheral/network/netCard = null
	var/list/notelist = list()
	var/tmp/working_line = 0
	var/tmp/selected_printer = null
	var/tmp/list/known_printers = list()
	var/tmp/printer_status = "???"

	// No special permissions required, but authentication is required to use print server
	req_access = list(access_fuck_all)

	initialize()
		if (..())
			return TRUE
		src.print_text("WizWrite V3.0")
		src.connected = 0
		src.mode = 0
		src.server_netid = null
		src.netCard = find_peripheral("NET_ADAPTER")
		if (src.known_printers)
			src.known_printers.len = 0
		else
			src.known_printers = list()

		//src.print_text("Commands: !view to view note, !new to start new note, !del to remove current line<br>!load to load file, !save to save file.<br>!\[line number] to set current line, !print to print. !quit to quit.<br>Anything else to type a line.")
		src.print_text(get_help_text())
		return

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1]

		if (src.mode != MODE_EDIT)
			switch(src.mode)
				if (MODE_CONFIG)
					switch(lowertext(copytext(command,1,2)))
						if ("0")
							src.mode = MODE_EDIT
							src.print_text("Now editing.  !help to list commands.")
						if ("1")
							if (src.connected)
								disconnect_server()
								src.connected = 0
								src.master.temp = null
								src.print_text(get_config_menu())
								return
							else
								if (server_netid)
									//Attempt to connect to server
									src.mode = -1
									connect_printserver(server_netid, 1)
									if (connected)
										src.master.temp = null
										src.print_text("Connection established to \[[server_netid]]!<br>[get_config_menu()]")
										src.mode = MODE_CONFIG
										return

									src.print_text("Connection failed.")
									return
								else
									//Attempt to autodetect server & connect
									src.mode = -1
									src.print_text("Searching for printserver...")
									if (ping_server(1))
										src.print_text("Unable to detect printserver!")
										src.mode = MODE_CONFIG
										return

									src.print_text("Printserver detected at \[[potential_server_netid]]<br>Connecting...")
									connect_printserver(potential_server_netid, 1)

									src.mode = MODE_CONFIG
									if (connected)
										src.master.temp = null
										src.print_text("Connection established to \[[server_netid]]!<br>[get_config_menu()]")
										return

									src.print_text("Connection failed.")
									return
						if ("2")
							src.mode = -1
							message_server("command=print&args=index")
							sleep(0.8 SECONDS)
							var/dat = "Known Printers:"
							if (!src.known_printers || !length(src.known_printers))
								dat += "<br> \[__] No printers known."

							else
								var/leadingZeroCount = length("[src.known_printers.len]")
								for (var/kp_index=1, kp_index <= src.known_printers.len, kp_index++)
									dat += "<br> \[[add_zero("[kp_index]",leadingZeroCount)]] [src.known_printers[kp_index]]"
								dat += "<br> \[A] Print to All."

							src.master.temp = null
							src.print_text("[dat]<br> (0) Return")
							src.mode = MODE_SELECT_PRINTER
							return

				if (MODE_SELECT_PRINTER)
					if (lowertext(command) == "a")
						src.selected_printer = "!all!"
					else
						var/printerNumber = round(text2num_safe(command))
						if (printerNumber == 0)
							src.mode = MODE_CONFIG
							src.master.temp = null
							src.print_text(get_config_menu())
							return

						if (printerNumber < 1 || printerNumber > src.known_printers.len)
							return

						src.selected_printer = src.known_printers[printerNumber]

					src.mode = MODE_CONFIG
					src.master.temp = null
					src.print_text("Printer set.<br>[get_config_menu()]")
					return

			return

		if(dd_hasprefix(command, "!"))
			switch(lowertext(command))
				if ("!view","!v")
					if(src.notelist.len)
						var/to_print = null
						for(var/t=1, t <= notelist.len, t++)
							to_print += "\[[add_zero("[t]",3)]] [notelist[t]] [notelist[ notelist[t] ] ? "=[notelist[ notelist[t] ]]": null]<br>"
						src.print_text(to_print)
					else
						src.print_text("No document loaded.")
				if ("!new","!n")
					src.notelist = new
					src.print_text("Current note cleared")

				if ("!del","!d")
					if(src.working_line && src.working_line < notelist.len)
						src.notelist.Cut(src.working_line,src.working_line+1)
						src.print_text("Line [src.working_line] removed.")
					else
						src.print_text("Line [src.notelist.len] removed.")
						src.notelist.len--
					src.working_line = 0

				if ("!load","!l")
					var/file_name = ckey(jointext(command_list, " "))

					if (!file_name)
						src.print_text("Syntax: \"!load \[file name]\"")
						return

					var/datum/computer/file/record/to_load = get_file_name(file_name, src.holding_folder)
					if(!to_load || (!istype(to_load) && !istype(to_load, /datum/computer/file/text)))
						src.print_text("Error: File not found (Or invalid).")
						return

					if (istype(to_load, /datum/computer/file/text))
						var/datum/computer/file/text/loadText = to_load
						src.notelist = splittext(loadText.data, "<br>")
					else
						src.notelist = to_load.fields.Copy()

					src.print_text("Load successful.")

				if ("!save", "!s")
					var/new_name = strip_html(jointext(command_list, " "))
					new_name = copytext(new_name, 1, 16)

					if(!new_name)
						src.print_text("Syntax: \"!save \[file name]\"")
						return

					var/datum/computer/file/record/saved = get_file_name(new_name, src.holding_folder)
					if(saved && !istype(saved) || get_folder_name(new_name, src.holding_folder))
						src.print_text("Error: Name in use.")
						return

					if(is_name_invalid(new_name))
						src.print_text("Error: Invalid character in name.")
						return

					if(saved && istype(saved))
						saved.fields = src.notelist.Copy()
					else
						saved = new /datum/computer/file/record
						saved.name = new_name
						saved.fields = src.notelist.Copy()
						if(!src.holding_folder.add_file(saved))
							//qdel(saved)
							saved.dispose()
							src.print_text("Error: Cannot save to disk.")
							return

					src.print_text("File saved.")

				if ("!help", "!h")
					src.print_text(get_help_text())

				if ("!print", "!p")
					var/print_name = strip_html(jointext(command_list, " "))
					print_name = copytext(print_name, 1, 16)

					var/networked = (src.connected && src.selected_printer)

					if(!print_name && !networked)
						src.print_text("<b>Syntax:</b> \"!print \[title].\" Prints current loaded document")
						return

					if(!notelist.len)
						src.print_text("<b>Error:</b> No document loaded.")

					else
						if (networked && !src.network_print(print_name))
							src.print_text("Print instruction sent.")
						else
							if (local_print(print_name))
								src.print_text("<b>Error:</b> No printer detected.")
							else
								src.print_text("Print instruction sent.")

				if ("!config","!c","!conf")
					src.mode = MODE_CONFIG
					src.master.temp = null
					src.print_text("[get_config_menu()]")

					return

				if ("!quit","!q")
					src.print_text("Quitting...")
					if (connected)
						connected = 0
						disconnect_server()
					src.master.unload_program(src)
					return

				else
					var/line_num = round( text2num_safe( copytext(command, 2) ) )
					if(isnull(line_num))
						src.print_text("Unknown command.")
						return
					if(line_num <= 0)
						src.working_line = 0
						src.print_text("Now working from end of document.")
						return

					if(line_num > notelist.len)
						src.print_text("Line outside of document scope.")
						return

					src.working_line = line_num
					src.print_text("\[[add_zero("[working_line]",3)]] [notelist[working_line]]")
					return

		else
			var/adding = strip_html(text)
			var/adding_associative = null
			src.print_text("\[[add_zero("[working_line == 0 ? notelist.len+1 : working_line]",3)]] [adding]")
			//src.oldnote = src.note
			var/split_point = findtext(adding, "=")
			if (split_point)
				adding_associative = copytext(adding, split_point+1)
				adding = copytext(adding, 1, split_point)

			adding = copytext(adding, 1, 256)
			if(src.working_line && src.working_line <= notelist.len)
				src.notelist[src.working_line] = "[adding]"
				if (adding_associative)
					src.notelist["[adding]"] = adding_associative
				src.working_line++
				if(src.working_line > notelist.len)
					src.working_line = 0
			else
				src.notelist += "[adding]"
				if (adding_associative)
					src.notelist["[adding]"] = adding_associative

		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return

	receive_command(obj/source, command, datum/signal/signal)
		if ((..()) || (!signal))
			return

		if (!connected)
			if (signal.data["command"] == "ping_reply" && !potential_server_netid)

				if (signal.data["device"] == "PNET_MAINFRAME" && signal.data["sender"] && is_hex(signal.data["sender"]))
					potential_server_netid = signal.data["sender"]
					return

			else if (signal.data["command"] == "term_connect")
				server_netid = ckey(signal.data["sender"])
				connected = 1
				potential_server_netid = null
				if(signal.data["data"] != "noreply")
					var/datum/signal/termsignal = get_free_signal()

					termsignal.data["address_1"] = signal.data["sender"]
					termsignal.data["command"] = "term_connect"
					termsignal.data["device"] = "SRV_TERMINAL"
					termsignal.data["data"] = "noreply"

					src.peripheral_command("transmit", termsignal, "\ref[netCard]")

			return
		else
			if (signal.data["sender"] != server_netid)
				return

			if (!server_netid)
				connected = 0
				return

			switch(lowertext(signal.data["command"]))
				if ("term_message","term_file")
					var/list/data = params2list(signal.data["data"])
					if(!data || !data["command"])
						return

					var/list/commandList = splittext(data["command"], "|n")
					if (!commandList || !length(commandList))
						return

					switch (commandList[1])
						if ("print_index")
							if (length(commandList) > 1)
								known_printers = commandList.Copy(2)
							else
								known_printers = list()

						if ("print_status")
							if (length(commandList) > 1)
								printer_status = commandList[2]
							else
								printer_status = "???"
					return

				if ("term_disconnect")
					src.connected = 0
					src.server_netid = null
					src.print_text("Connection closed by printserver.")

				if("term_ping")
					if(signal.data["data"] == "reply")
						var/datum/signal/termsignal = get_free_signal()

						termsignal.data["address_1"] = signal.data["sender"]
						termsignal.data["command"] = "term_ping"

						src.peripheral_command("transmit", termsignal, "\ref[netCard]")


		return

	proc
		connect_printserver(var/address, delayCaller=0)
			if (connected || !netCard)
				return 1

			var/datum/signal/signal = get_free_signal()

			signal.data["address_1"] = address
			signal.data["command"] = "term_connect"
			signal.data["device"] = "SRV_TERMINAL"
			var/datum/computer/file/record/udat = null
			if (istype(src.account))
				udat = new

				var/userid = format_username(src.account.registered)

				udat.fields["userid"] = userid
				udat.fields["access"] = list2params(src.account.access)
				if (!udat.fields["access"] || !udat.fields["userid"])
//					qdel(udat)
					udat.dispose()
					return 1

				udat.fields["service"] = "print"

			if (udat)
				signal.data_file = udat

			src.peripheral_command("transmit", signal, "\ref[netCard]")
			if (delayCaller)
				sleep(0.8 SECONDS)
				return 0

			return 0

		disconnect_server()
			if (!server_netid || !netCard)
				return 1

			var/datum/signal/signal = get_free_signal()

			signal.data["address_1"] = server_netid
			signal.data["command"] = "term_disconnect"

			src.peripheral_command("transmit", signal, "\ref[netCard]")

			return 0

		ping_server(delayCaller=0)
			if (connected || !netCard)
				return 1

			potential_server_netid = null
			src.peripheral_command("ping", null, "\ref[netCard]")

			if (delayCaller)
				sleep(0.8 SECONDS)
				return (potential_server_netid == null)

			return 0

		message_server(var/message, var/datum/computer/file/toSend)
			if (!connected || !server_netid || !netCard || !message)
				return 1

			var/datum/signal/termsignal = get_free_signal()

			termsignal.data["address_1"] = server_netid
			termsignal.data["data"] = message
			termsignal.data["command"] = "term_message"
			if (toSend)
				termsignal.data_file = toSend

			src.peripheral_command("transmit", termsignal, "\ref[netCard]")
			return 0

		network_print(var/print_title = "Printout")
			if (!connected || !netCard || !selected_printer || !server_netid || !src.notelist || !length(src.notelist))
				return 1

			var/datum/computer/file/record/printRecord = new
			printRecord.fields = src.notelist.Copy()
			if (print_title)
				printRecord.fields.Insert(1, "title=[print_title]")
			printRecord.name = "printout"

			if (selected_printer == "!all!")
				message_server("command=print&args=printall", printRecord)
			else
				message_server("command=print&args=print [selected_printer]", printRecord)
			return 0

		local_print(var/print_title = "Printout")
			var/obj/item/peripheral/printcard = find_peripheral("LAR_PRINTER")
			if(!printcard)
				printcard = find_peripheral("NET_ADAPTER") // terminal card
				if (!istype(printcard, /obj/item/peripheral/network/powernet_card/terminal))
					return 1

			if(!src.notelist || !length(src.notelist))
				return 1

			var/datum/signal/signal = get_free_signal()
			signal.data["data"] = jointext(src.notelist, "<br>")
			signal.data["title"] = print_title
			src.peripheral_command("print",signal, "\ref[printcard]")
			return 0

		get_config_menu()
			if (src.connected && src.server_netid)
				var/confText = "Currently connected to printserver \[[src.server_netid]]"
				confText += "<br> (1) Disconnect"
				confText += "<br> (2) Select Printer"
				confText += "<br> (0) Back"
				return confText

			return "No printserver connection<br> (1) Connect<br> (0) Back"

		get_help_text()

			var/help_text = {"Commands:
	<br> \"!view\" to view note
	<br> \"!del\" to remove current line
	<br> \"!\[integer]" to set current line
	<br> \"!save \[name]\" to save note
	<br> \"!load \[name]\" to load note
	<br> \"!print\" to print current note.
	<br> \"!config\" to configure network printing.
	<br> Anything else to type."}
			return help_text

#undef MODE_EDIT
#undef MODE_CONFIG
#undef MODE_SELECT_PRINTER
