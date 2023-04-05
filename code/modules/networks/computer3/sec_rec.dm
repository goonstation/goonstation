


#define MENU_MAIN 0 //Byond. Enums.  Lacks them. Etc
#define MENU_INDEX 1
#define MENU_IN_RECORD 2
#define MENU_FIELD_INPUT 3
#define MENU_SEARCH_INPUT 4
#define MENU_SETTINGS 5
#define MENU_SELECT_PRINTER 6
#define MENU_SEARCH_PICK 7

#define FIELDNUM_NAME 1
#define FIELDNUM_FULLNAME 2
#define FIELDNUM_SEX 3
#define FIELDNUM_AGE 4
#define FIELDNUM_RANK 5
#define FIELDNUM_PRINT 6
#define FIELDNUM_PHOTO 7
#define FIELDNUM_CRIMSTAT 8
#define FIELDNUM_SECFLAG 9
#define FIELDNUM_MINCRIM 10
#define FIELDNUM_MINDET 11
#define FIELDNUM_MAJCRIM 12
#define FIELDNUM_MAJDET 13
#define FIELDNUM_NOTES 14

#define FIELDNUM_DELETE "d"
#define FIELDNUM_NEWREC "new"

/datum/computer/file/terminal_program/secure_records
	name = "SecMate"
	size = 12
	req_access = list(access_security)
	var/tmp/menu = MENU_MAIN
	var/tmp/field_input = 0
	var/tmp/authenticated = null //Are we currently logged in?
	var/tmp/datum/computer/file/user_data/account = null
	var/datum/record_database/record_database = list()  //List of records, for jumping direclty to a specific ID
	var/datum/db_record/active_general = null //General record
	var/datum/db_record/active_secure = null //Security record
	var/log_string = null //Log usage of record system, can be dumped to a text file.
	var/obj/item/peripheral/network/radio/radiocard = null
	var/tmp/last_arrest_report = 0 //When did we last report an arrest?
	var/list/datum/db_record/possible_active = null

	var/tmp/connected = 0
	var/tmp/server_netid = null
	var/tmp/potential_server_netid = null
	var/tmp/selected_printer = null
	var/tmp/list/known_printers = list()
	var/tmp/printer_status = "???"

	var/setup_acc_filepath = "/logs/sysusr"//Where do we look for login data?
	var/setup_logdump_name = "seclog" //What name do we give our logdump textfile?
	var/setup_mailgroup = MGD_SECURITY //The PDA mailgroup used when alerting security pdas to an arrest set.
	var/setup_mail_freq = FREQ_PDA //Which frequency do we transmit PDA alerts on?

	initialize() //Forms "SECMATE" ascii art. Oh boy.
	/*
		var/title_art = {"<pre> ____________________    _ __________________
\\  ___\\  ___\\  ___\\ -./  \\  __ \\ _  _\\  ___\\
\\ \\___  \\  __\\\\ \\___\\ \\-./\\ \\  __ \\/\\ \\ \\  __\\
 \\/\\_____\\_____\\_____\\ \\_\\ \\ \\ \\_\\ \\ \\ \\ \\_____\\
  \\/_____/_____/_____/_/  \\/_/_/\\/_/\\/_/\\/_____/ </pre>"}
*/
		src.authenticated = null
		src.record_database = data_core.general
		src.master.temp = null
		src.menu = MENU_MAIN
		src.field_input = 0
		//src.print_text(" [title_art]")
		if(!src.find_access_file()) //Find the account information, as it's essentially a ~digital ID card~
			src.print_text("<b>Error:</b> Cannot locate user file.  Quitting...")
			src.master.unload_program(src) //Oh no, couldn't find the file.
			return

		src.radiocard = locate() in src.master.peripherals
		if(!radiocard || !istype(src.radiocard))
			src.radiocard = null
			src.print_text("<b>Warning:</b> No radio module detected.")

		if(!src.check_access(src.account.access))
			src.print_text("User [src.account.registered] does not have needed access credentials.<br>Quitting...")
			src.master.unload_program(src)
			return

		src.authenticated = src.account.registered
		src.log_string += "<br><b>LOGIN:</b> [src.authenticated]"

		src.print_text(mainmenu_text())
		return


	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1]

		switch(menu)
			if (MENU_MAIN)
				switch (command)
					if ("0") //Exit program
						src.print_text("Quitting...")
						src.master.unload_program(src)
						return

					if ("1") //View records
						src.record_database = data_core.general

						src.menu = MENU_INDEX
						src.print_index()

					if ("2") //Search records
						src.print_text("Please enter target name, ID, DNA, rank, or fingerprint.")

						src.menu = MENU_SEARCH_INPUT
						return

					if ("3")
						src.print_settings()

						src.menu = MENU_SETTINGS
						return

			if (MENU_SETTINGS)
				switch (command)
					if ("0")
						src.menu = MENU_MAIN
						src.master.temp = null
						src.print_text(mainmenu_text())
						return

					if ("1")
						if (src.connected)
							disconnect_server()
							src.connected = 0
							src.master.temp = null
							src.print_settings()
							return
						else
							if (server_netid)
								//Attempt to connect to server
								src.menu = -1
								connect_printserver(server_netid, 1)
								if (connected)
									src.master.temp = null
									src.print_text("Connection established to \[[server_netid]]!")
									src.print_settings()
									src.menu = MENU_SETTINGS
									return

								src.menu = MENU_SETTINGS
								src.print_text("Connection failed.")
								return
							else
								//Attempt to autodetect server & connect
								src.menu = -1
								src.print_text("Searching for printserver...")
								if (ping_server(1))
									src.print_text("Unable to detect printserver!")
									src.menu = MENU_SETTINGS
									return

								src.print_text("Printserver detected at \[[potential_server_netid]]<br>Connecting...")
								connect_printserver(potential_server_netid, 1)

								src.menu = MENU_SETTINGS
								if (connected)
									src.master.temp = null
									src.print_text("Connection established to \[[server_netid]]!")
									src.print_settings()
									return

								src.print_text("Connection failed.")
								return

					if ("2")
						src.menu = -1
						message_server("command=print&args=index")
						sleep(0.8 SECONDS)
						var/dat = "Known Printers:"
						if (!src.known_printers || !length(src.known_printers))
							dat += "<br> \[__] No printers known."

						else
							var/leadingZeroCount = length("[src.known_printers.len]")
							for (var/kp_index=1, kp_index <= src.known_printers.len, kp_index++)
								dat += "<br> \[[add_zero("[kp_index]",leadingZeroCount)]] [src.known_printers[kp_index]]"

						src.master.temp = null
						src.print_text("[dat]<br> (0) Return")
						src.menu = MENU_SELECT_PRINTER
						return

			if (MENU_SELECT_PRINTER)
				var/printerNumber = round(text2num_safe(command))
				if (printerNumber == 0)
					src.menu = MENU_SETTINGS
					src.master.temp = null
					src.print_settings()
					return

				if (printerNumber < 1 || printerNumber > src.known_printers.len)
					return

				src.selected_printer = src.known_printers[printerNumber]
				src.menu = MENU_SETTINGS
				src.master.temp = null
				src.print_text("Printer set.")
				src.print_settings()


			if (MENU_INDEX)

				if (lowertext(command) == FIELDNUM_NEWREC)
					var/datum/db_record/G = new /datum/db_record(  )
					G["name"] = "New Record"
					G["full_name"] = "New Record"
					G["id"] = "[num2hex(rand(1, 1.6777215E7), 6)]"
					G["rank"] = "Unassigned"
					G["sex"] = "Other"
					G["age"] = "Unknown"
					G["fingerprint"] = "Unknown"
					G["p_stat"] = "Active"
					G["m_stat"] = "Stable"
					data_core.general.add_record(G)
					src.active_general = G
					src.active_secure = null
					src.log_string += "<br>Log created: [G["id"]]"

					if (src.print_active_record())
						src.menu = MENU_IN_RECORD

					return

				var/index_number = round( max( text2num_safe(command), 0) )
				if (index_number == 0)
					src.menu = MENU_MAIN
					src.master.temp = null
					src.print_text(mainmenu_text())
					return

				if (!istype(record_database) || index_number > record_database.records.len)
					src.print_text("Invalid record.")
					return

				var/datum/db_record/check = src.record_database.records[index_number]
				if(!check || !istype(check))
					src.print_text("<b>Error:</b> Record Data Invalid.")
					return

				src.active_general = check
				src.active_secure = null
				if (data_core.general.has_record(check))
					src.active_secure = data_core.security.find_record("id", src.active_general["id"])
					if(!src.active_secure)
						data_core.security.find_record("name", src.active_general["name"])

				src.log_string += "<br>Log loaded: [src.active_general["id"]]"

				if (src.print_active_record())
					src.menu = MENU_IN_RECORD
				return

			if (MENU_IN_RECORD)
				switch(lowertext(command))
					if ("r")
						src.print_active_record()
						return
					if ("d")
						src.print_text("Are you sure? (Y/N)")
						src.field_input = FIELDNUM_DELETE
						src.menu = MENU_FIELD_INPUT
						return
					if ("p")

						if ((src.connected && src.selected_printer) && !src.network_print())
							src.print_text("Print instruction sent.")
						else
							if (local_print())
								src.print_text("<b>Error:</b> No printer detected.")
							else
								src.print_text("Print instruction sent.")

						return

					if (FIELDNUM_NEWREC)
						if (src.active_secure)
							return

						var/datum/db_record/R = new /datum/db_record(  )
						R["name"] = src.active_general["name"]
						R["full_name"] = src.active_general["full_name"]
						R["id"] = src.active_general["id"]
						R["criminal"] = "None"
						R["sec_flag"] = "None"
						R["mi_crim"] = "None"
						R["mi_crim_d"] = "No minor crime convictions."
						R["ma_crim"] = "None"
						R["ma_crim_d"] = "No major crime convictions."
						R["notes"] = "No notes."
						data_core.security.add_record(R)
						src.active_secure = R

						src.print_active_record()
						src.menu = MENU_IN_RECORD
						return

				var/field_number = round( max( text2num_safe(command), 0) )
				if (field_number == 0)
					src.menu = MENU_INDEX
					src.print_index()
					return

				src.field_input = field_number
				switch(field_number)
					if (FIELDNUM_NAME, FIELDNUM_FULLNAME, FIELDNUM_AGE, FIELDNUM_RANK, FIELDNUM_PRINT, FIELDNUM_MINCRIM, FIELDNUM_MINDET, FIELDNUM_MAJCRIM, FIELDNUM_MAJDET, FIELDNUM_NOTES)
						src.print_text("Please enter new value.")
						src.menu = MENU_FIELD_INPUT
						return

					if (FIELDNUM_PHOTO)
						src.print_text("Please select: (1) View (2) Print (3) Delete (0) Back")
						src.menu = MENU_FIELD_INPUT
						return

					if (FIELDNUM_SEX)
						src.print_text("Please select: (1) Female (2) Male (3) Other (0) Back")
						src.menu = MENU_FIELD_INPUT
						return

					if (FIELDNUM_CRIMSTAT)
						src.print_text("Please select: (1) Arrest (2) None (3) Incarcerated<br>(4) Parolled (5) Released (0) Back")
						src.menu = MENU_FIELD_INPUT
						return

					if (FIELDNUM_SECFLAG)
						src.print_text("Please enter new value ([SECHUD_FLAG_MAX_CHARS] characters max), or \"None\".")
						src.menu = MENU_FIELD_INPUT
						return

			if (MENU_FIELD_INPUT)
				if (!src.active_general)
					src.print_text("<b>Error:</b> Record invalid.")
					src.menu = MENU_INDEX
					return

				var/inputText = strip_html(text)
				switch (field_input)
					if (FIELDNUM_NAME)
						if (ckey(inputText))
							src.active_general["name"] = copytext(inputText, 1, FULLNAME_MAX)
						else
							return

					if (FIELDNUM_FULLNAME)
						if (ckey(inputText))
							src.active_general["full_name"] = copytext(inputText, 1, FULLNAME_MAX)
						else
							return

					if (FIELDNUM_SEX)
						switch (round( max( text2num_safe(command), 0) ))
							if (1)
								src.active_general["sex"] = "Female"
							if (2)
								src.active_general["sex"] = "Male"
							if (3)
								src.active_general["sex"] = "Other"
							if (0)
								src.menu = MENU_IN_RECORD
								return
							else
								return

					if (FIELDNUM_AGE)
						var/newAge = round( min( text2num_safe(command), 99) )
						if (newAge < 1)
							src.print_text("Invalid age value. Please re-enter.")
							return

						src.active_general["age"] = newAge

					if (FIELDNUM_RANK)
						if (ckey(inputText))
							src.active_general["rank"] = copytext(inputText, 1, 33)
						else
							return

					if (FIELDNUM_PRINT)
						if (ckey(inputText))
							src.active_general["fingerprint"] = copytext(inputText, 1, 35)
						else
							return

					if (FIELDNUM_PHOTO)
						switch (round( max( text2num_safe(command), 0) ))
							if (1) // view
								var/datum/computer/file/image/IMG = src.active_general["file_photo"]
								if (!istype(IMG) || !IMG.ourIcon)
									src.print_text("Photo data is corrupt!")
									src.menu = MENU_IN_RECORD
									return
								src.print_text(replacetext(IMG.asText(), "|n", "<br>"))
								src.menu = MENU_IN_RECORD
								return
							if (2) // print
								if ((src.connected && src.selected_printer) && !src.network_print(1))
									src.print_text("Print instruction sent.")
								else
									if (local_print())
										src.print_text("<b>Error:</b> No printer detected.")
									else
										src.print_text("Print instruction sent.")
								src.menu = MENU_IN_RECORD
								return
							if (3) // delete
								src.active_general["file_photo"] = null
							if (0)
								src.menu = MENU_IN_RECORD
								return

					if (FIELDNUM_CRIMSTAT)
						if (!src.active_secure)
							src.print_text("No security record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (lowertext(command) == "clown")
							src.active_secure["criminal"] = "Clown"
							return

						switch (round( max( text2num_safe(command), 0) ))
							if (1)
								if (src.active_secure["criminal"] != "*Arrest*")
									src.report_arrest(src.active_general["name"])
								src.active_secure["criminal"] = "*Arrest*"
							if (2)
								src.active_secure["criminal"] = "None"
								src.active_secure["sec_flag"] = "None"
							if (3)
								src.active_secure["criminal"] = "Incarcerated"
							if (4)
								src.active_secure["criminal"] = "Parolled"
							if (5)
								src.active_secure["criminal"] = "Released"
							if (0)
								src.menu = MENU_IN_RECORD
								return
							else
								return

					if (FIELDNUM_SECFLAG)
						if (!src.active_secure)
							src.print_text("No security record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_secure["sec_flag"] = copytext(inputText, 1, SECHUD_FLAG_MAX_CHARS + 1)
						else
							return

					if (FIELDNUM_MINCRIM)
						if (!src.active_secure)
							src.print_text("No security record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_secure["mi_crim"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_MINDET)
						if (!src.active_secure)
							src.print_text("No security record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_secure["mi_crim_d"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_MAJCRIM)
						if (!src.active_secure)
							src.print_text("No security record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_secure["ma_crim"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_MAJDET)
						if (!src.active_secure)
							src.print_text("No security record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_secure["ma_crim_d"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_NOTES)
						if (!src.active_secure)
							src.print_text("No security record loaded!")
							src.menu = MENU_IN_RECORD
							return

						if (ckey(inputText))
							src.active_secure["notes"] = copytext(inputText, 1, MAX_MESSAGE_LEN)
						else
							return

					if (FIELDNUM_DELETE)
						switch (ckey(inputText))
							if ("y")
								if (src.active_secure)
									src.log_string += "<br>S-Record [src.active_secure["id"]] deleted."
									qdel(src.active_secure)
									src.print_active_record()
									src.menu = MENU_IN_RECORD

								else if (src.active_general)

									src.log_string += "<br>Record [src.active_general["id"]] deleted."
									qdel(src.active_general)
									src.menu = MENU_INDEX
									src.print_index()

							if ("n")
								src.menu = MENU_IN_RECORD
								src.print_text("Record preserved.")

						return

				src.print_text("Field updated.")
				src.menu = MENU_IN_RECORD
				return

			if (MENU_SEARCH_PICK)
				var/input = text2num_safe(ckey(strip_html(text)))
				if(isnull(input) || input < 1 || input >> length(src.possible_active))
					src.master.temp = null
					src.print_text(mainmenu_text())
					src.print_text("Previous operation cancelled.")
					src.menu = MENU_MAIN
					return

				var/datum/db_record/result = src.possible_active[input]
				src.active_general = result
				src.active_secure = data_core.security.find_record("id", src.active_general["id"])
				if(!src.active_secure)
					data_core.security.find_record("name", src.active_general["name"])

				src.menu = MENU_IN_RECORD
				src.print_active_record()

			if (MENU_SEARCH_INPUT)
				var/searchText = ckey(strip_html(text))
				if (!searchText)
					return

				var/list/datum/db_record/results = list()
				for(var/datum/db_record/R as anything in data_core.general.records)
					var/haystack = jointext(list(ckey(R["name"]), ckey(R["dna"]), ckey(R["id"]), ckey(R["fingerprint"]), ckey(R["rank"])), " ")
					if(findtext(haystack, searchText))
						results += R

				var/datum/db_record/result = null
				if(length(results) == 1)
					result = results[1]
				else if(length(results) > 1)
					src.print_text("Multiple results found:")
					var/i = 1
					for(var/datum/db_record/R as anything in results)
						src.print_text("\[[i++]\] [R["name"]]")
					src.print_text("\[0\] Cancel")
					src.menu = MENU_SEARCH_PICK
					src.possible_active = results
					return

				if(!result)
					src.print_text("No results found.")
					src.menu = MENU_MAIN
					return

				src.active_general = result
				src.active_secure = data_core.security.find_record("id", src.active_general["id"])
				if(!src.active_secure)
					data_core.security.find_record("name", src.active_general["name"])

				src.menu = MENU_IN_RECORD
				src.print_active_record()
				return


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

					src.peripheral_command("transmit", termsignal, "\ref[find_peripheral("NET_ADAPTER")]")

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
							if (commandList.len > 1)
								known_printers = commandList.Copy(2)
							else
								known_printers = list()

						if ("print_status")
							if (commandList.len > 1)
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

						src.peripheral_command("transmit", termsignal, "\ref[find_peripheral("NET_ADAPTER")]")


		return

	proc
		mainmenu_text()
			var/dat = {"<center>S E C M A T E 7</center><br>
			Welcome to SecMate 7<br>
			<b>Commands:</b>
			<br>(1) View security records.
			<br>(2) Search for a record.
			<br>(3) Adjust settings.
			<br>(0) Quit."}

			return dat

		print_active_record()
			if (!src.active_general)
				src.print_text("<b>Error:</b> General record data corrupt.")
				return 0
			src.master.temp = null

			var/view_string = {"
			\[01]Name: [src.active_general["name"]] ID: [src.active_general["id"]]
			<br>\[02]Full Name: [src.active_general["full_name"]]
			<br>\[03]<b>Sex:</b> [src.active_general["sex"]]
			<br>\[04]<b>Age:</b> [src.active_general["age"]]
			<br>\[05]<b>Rank:</b> [src.active_general["rank"]]
			<br>\[06]<b>Fingerprint:</b> [src.active_general["fingerprint"]]
			<br>\[__]<b>DNA:</b> [src.active_general["dna"]]
			<br>\[07]Photo: [istype(src.active_general["file_photo"], /datum/computer/file/image) ? "On File" : "None"]
			<br>\[__]Physical Status: [src.active_general["p_stat"]]
			<br>\[__]Mental Status: [src.active_general["m_stat"]]"}

			if ((istype(src.active_secure, /datum/db_record) && data_core.security.has_record(src.active_secure)))
				view_string +={"
				<br><center><b>Security Data</b></center>
				<br>\[08]<b>Criminal Status:</b> [src.active_secure["criminal"]]
				<br>\[09]<b>SecHUD Flag:</b> [src.active_secure["sec_flag"]]
				<br>\[10]<b>Minor Crimes:</b> [src.active_secure["mi_crim"]]
				<br>\[11]<b>Details:</b> [src.active_secure["mi_crim_d"]]
				<br>\[12]<b><br>Major Crimes:</b> [src.active_secure["ma_crim"]]
				<br>\[13]<b>Details:</b> [src.active_secure["ma_crim_d"]]
				<br>\[14]<b>Important Notes:</b> [src.active_secure["notes"]]"}
			else
				view_string += "<br><br><b>Security Record Lost!</b>"
				view_string += "<br>\[[FIELDNUM_NEWREC]] Create New Security Record.<br>"

			view_string += "<br>Enter field number to edit a field<br>(R) Redraw (D) Delete (P) Print (0) Return to index."

			src.print_text("<b>Record Data:</b><br>[view_string]")
			return 1

		print_index()
			src.master.temp = null
			var/dat = ""
			if(!src.record_database || !length(src.record_database.records))
				src.print_text("<b>Error:</b> No records found in database.")
				dat += "<br><b>\[[FIELDNUM_NEWREC]]</b> Create New Record.<br>"

			else
				dat = "Please select a record:"
				var/leadingZeroCount = length("[src.record_database.records.len]")
				for(var/x = 1, x <= src.record_database.records.len, x++)
					var/datum/db_record/R = src.record_database.records[x]
					if(!R || !istype(R))
						dat += "<br><b>\[[add_zero("[x]",leadingZeroCount)]]</b><font color=red>ERR: REDACTED</font>"
						continue

					dat += "<br><b>\[[add_zero("[x]",leadingZeroCount)]]</b>[R["id"]]: [R["name"]]"

				dat += "<br><b>\[[FIELDNUM_NEWREC]]</b> Create New Record.<br>"
			dat += "<br><br>Enter record number, or 0 to return."

			src.print_text(dat)
			return 1

		print_settings()
			var/dat = "Options:"

			if (src.connected)
				dat += "<br>(1) Disconnect from print server."
				dat += "<br>(2) Select printer."

			else
				dat += "<br>(1) Connect to print server."

			dat += "<br>(0) Back."

			src.print_text(dat)
			return 1

		report_arrest(var/perp_name)
			if(!perp_name || !src.radiocard)
				return

			if (usr)
				logTheThing(LOG_STATION, usr, "[perp_name] is set to arrest by [usr] (using the ID card of [src.authenticated]) [log_loc(src.master)]")

			//Unlikely that this would be a problem but OH WELL
			if(last_arrest_report && world.time < (last_arrest_report + 10))
				return

			//Set card frequency if it isn't already.
			if(src.radiocard.frequency != src.setup_mail_freq && !src.radiocard.setup_freq_locked)
				var/datum/signal/freqsignal = get_free_signal()
				//freqsignal.encryption = "\ref[src.radiocard]"
				peripheral_command("[src.setup_mail_freq]", freqsignal, "\ref[src.radiocard]")
				src.log_string += "<br>Adjusting frequency... \[[src.setup_mail_freq]]."

			var/datum/signal/signal = get_free_signal()
			//signal.encryption = "\ref[src.radiocard]"

			//Create a PDA mass-message string.
			signal.data["command"] = "text_message"
			signal.data["sender_name"] = "SEC-MAILBOT"
			signal.data["group"] = list(src.setup_mailgroup, MGA_ARREST) //Only security PDAs should be informed.
			signal.data["message"] = "Alert! Crewman \"[perp_name]\" has been flagged for arrest by [src.authenticated]!"

			src.log_string += "<br>Arrest notification sent."
			last_arrest_report = world.time
			peripheral_command("transmit", signal, "\ref[src.radiocard]")
			return

		find_access_file() //Look for the whimsical account_data file
			var/datum/computer/folder/accdir = src.holder.root
			if(src.master.host_program) //Check where the OS is, preferably.
				accdir = src.master.host_program.holder.root

			var/datum/computer/file/user_data/target = parse_file_directory(setup_acc_filepath, accdir)
			if(target && istype(target))
				src.account = target
				return 1

			return 0

		local_print()
			var/obj/item/peripheral/printcard = find_peripheral("LAR_PRINTER")
			if(!printcard)
				return 1

			//Okay, let's put together something to print.
			var/info = "<center><B>Security Record</B></center><br>"
			if (istype(src.active_general, /datum/db_record) && data_core.general.has_record(src.active_general))
				info += {"
				Full Name: [src.active_general["full_name"]] ID: [src.active_general["id"]]
				<br><br>Sex: [src.active_general["sex"]]
				<br><br>Age: [src.active_general["age"]]
				<br><br>Rank: [src.active_general["rank"]]
				<br><br>Fingerprint: [src.active_general["fingerprint"]]
				<br><br>DNA: [src.active_general["dna"]]
				<br><br>Photo: [istype(src.active_general["file_photo"], /datum/computer/file/image) ? "On File" : "None"]
				<br><br>Physical Status: [src.active_general["p_stat"]]
				<br><br>Mental Status: [src.active_general["m_stat"]]"}
			else
				info += "<b>General Record Lost!</b><br>"
			if ((istype(src.active_secure, /datum/db_record) && data_core.security.has_record(src.active_secure)))
				info += {"
				<br><br><center><b>Security Data</b></center><br>
				<br>Criminal Status: [src.active_secure["criminal"]]
				<br><br>Minor Crimes: [src.active_secure["mi_crim"]]
				<br><br>Details: [src.active_secure["mi_crim_d"]]
				<br><br><br>Major Crimes: [src.active_secure["ma_crim"]]
				<br><br>Details: [src.active_secure["ma_crim_d"]]
				<br><br>Important Notes: [src.active_secure["notes"]]"}

			else
				info += "<br><center><b>Security Record Lost!</b></center><br>"
			info += "</tt>"

			var/datum/signal/signal = get_free_signal()
			signal.data["data"] = info
			signal.data["title"] = "Security Record"
			src.peripheral_command("print",signal, "\ref[printcard]")
			return 0

		network_print(var/photo = 0)
			if (!connected || !selected_printer || !server_netid)
				return 1

			var/datum/computer/file/record/printRecord = new

			if (photo)
				var/datum/computer/file/image/IMG = src.active_general["file_photo"]
				if (!istype(IMG) || !IMG.ourIcon)
					printRecord.fields += "Photo data is corrupt!"
				else
					printRecord.fields += replacetext(IMG.asText(), "|n", "<br>")

			else
				printRecord.fields += "title=Security Record"
				printRecord.fields += "Security Record"
				if (istype(src.active_general, /datum/db_record) && data_core.general.has_record(src.active_general))

					printRecord.fields += "Full Name: [src.active_general["full_name"]] ID: [src.active_general["id"]]"
					printRecord.fields += "Sex: [src.active_general["sex"]]"
					printRecord.fields += "Age: [src.active_general["age"]]"
					printRecord.fields += "Rank: [src.active_general["rank"]]"
					printRecord.fields += "Fingerprint: [src.active_general["fingerprint"]]"
					printRecord.fields += "DNA: [src.active_general["dna"]]"
					printRecord.fields += "Photo: [istype(src.active_general["file_photo"], /datum/computer/file/image) ? "On File" : "None"]"
					printRecord.fields += "Physical Status: [src.active_general["p_stat"]]"
					printRecord.fields += "Mental Status: [src.active_general["m_stat"]]"
				else
					printRecord.fields += "General Record Lost!"

				if ((istype(src.active_secure, /datum/db_record) && data_core.security.has_record(src.active_secure)))

					printRecord.fields += "Security Data"
					printRecord.fields += "Criminal Status: [src.active_secure["criminal"]]"
					printRecord.fields += "Minor Crimes: [src.active_secure["mi_crim"]]"
					printRecord.fields += "Details: [src.active_secure["mi_crim_d"]]"
					printRecord.fields += "Major Crimes: [src.active_secure["ma_crim"]]"
					printRecord.fields += "Details: [src.active_secure["ma_crim_d"]]"
					printRecord.fields += "Important Notes: [src.active_secure["notes"]]"

				else
					printRecord.fields += "Security Record Lost!"

			//printRecord.name = "printout"

			message_server("command=print&args=print [selected_printer]", printRecord)
			return 0

		message_server(var/message, var/datum/computer/file/toSend)
			if (!connected || !server_netid || !message)
				return 1

			var/netCard = find_peripheral("NET_ADAPTER")
			if (!netCard)
				return 1

			var/datum/signal/termsignal = get_free_signal()

			termsignal.data["address_1"] = server_netid
			termsignal.data["data"] = message
			termsignal.data["command"] = "term_message"
			if (toSend)
				termsignal.data_file = toSend

			src.peripheral_command("transmit", termsignal, "\ref[netCard]")
			return 0

		connect_printserver(var/address, delayCaller=0)
			if (connected)
				return 1

			var/netCard = find_peripheral("NET_ADAPTER")
			if (!netCard)
				return 1

			var/datum/signal/signal = get_free_signal()

			signal.data["address_1"] = address
			signal.data["command"] = "term_connect"
			signal.data["device"] = "SRV_TERMINAL"
			var/datum/computer/file/user_data/user_data = account
			var/datum/computer/file/record/udat = null
			if (istype(user_data))
				udat = new

				var/userid = format_username(user_data.registered)

				udat.fields["userid"] = userid
				udat.fields["access"] = list2params(user_data.access)
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
			if (!server_netid)
				return 1

			var/netCard = find_peripheral("NET_ADAPTER")
			if (!netCard)
				return 1

			var/datum/signal/signal = get_free_signal()

			signal.data["address_1"] = server_netid
			signal.data["command"] = "term_disconnect"

			src.peripheral_command("transmit", signal, "\ref[netCard]")

			return 0

		ping_server(delayCaller=0)
			if (connected)
				return 1

			var/netCard = find_peripheral("NET_ADAPTER")
			if (!netCard)
				return 1

			potential_server_netid = null
			src.peripheral_command("ping", null, "\ref[netCard]")

			if (delayCaller)
				sleep(0.8 SECONDS)
				return (potential_server_netid == null)

			return 0

#undef MENU_MAIN
#undef MENU_INDEX
#undef MENU_IN_RECORD
#undef MENU_FIELD_INPUT
#undef MENU_SEARCH_INPUT
#undef MENU_SETTINGS
#undef MENU_SELECT_PRINTER
#undef MENU_SEARCH_PICK

#undef FIELDNUM_NAME
#undef FIELDNUM_FULLNAME
#undef FIELDNUM_SEX
#undef FIELDNUM_AGE
#undef FIELDNUM_RANK
#undef FIELDNUM_PRINT
#undef FIELDNUM_CRIMSTAT
#undef FIELDNUM_SECFLAG
#undef FIELDNUM_MINCRIM
#undef FIELDNUM_MINDET
#undef FIELDNUM_MAJCRIM
#undef FIELDNUM_MAJDET
#undef FIELDNUM_NOTES

#undef FIELDNUM_DELETE
#undef FIELDNUM_NEWREC
