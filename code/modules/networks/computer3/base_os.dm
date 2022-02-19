/datum/computer/file/terminal_program/os/main_os/no_login
	setup_needs_authentication = 0

/datum/computer/file/terminal_program/os/main_os
	name = "ThinkDOS"
	size = 12
	var/tmp/datum/computer/folder/current_folder = null
	var/tmp/datum/computer/file/clipboard = null
	var/tmp/datum/computer/file/text/command_log = null
	var/tmp/datum/computer/file/record/help_lib = null
	var/tmp/datum/computer/file/user_data/active_account = null
	var/echo_input = 1
	var/log_errors = 1
	var/list/peripherals = list()
	var/authenticated = null //Is anyone logged in?

	var/setup_version_name = "ThinkDOS 0.7.2"
	var/setup_needs_authentication = 1 //Do we need to present an ID to use this?
	//Setup for data logging
#define SETUP_LOG_DIRECTORY "logs"
#define SETUP_LOG_FILENAME "syslog"
	//Setup for help library
#define SETUP_HELP_FILEPATH "/logs/helplib"
	//Where to put user account data.
#define SETUP_ACC_DIRECTORY "logs"
#define SETUP_ACC_FILENAME "sysusr"

	disposing()
		peripherals = null
		current_folder = null
		clipboard = null
		command_log = null
		help_lib = null
		active_account = null

		..()

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1] //Remove the command we are now processing.

		if(src.echo_input)
			src.print_text(strip_html(text))

		print_to_log(text) //print to log strips html as it logs, no need to do it here!!

		if(!current_folder)
			current_folder = src.holding_folder

		if(!src.authenticated && src.setup_needs_authentication)
			switch(lowertext(command))
				if("login","logon")
					if ((issilicon(usr) || isAI(usr)) && !isghostdrone(usr))
						src.system_login("AIUSR","Station AI", null, 1)
						//src.print_text("Authorization Accepted.<br>Welcome, AIUSR!<br><b>Current Folder: [current_folder.name]</b>")
						//src.authenticated = "AI"
						//src.print_to_log("LOGIN: AIUSR | \[Station AI]")
					else
						var/obj/item/peripheral/scanner = find_peripheral("ID_SCANNER")
						if(!scanner)
							src.print_text("<b>Error:</b> No ID scanner detected.")
							return
						var/datum/signal/login_result = src.peripheral_command("scan_card", null, "\ref[scanner]")
						if(istype(login_result))
							system_login(login_result.data["registered"], login_result.data["assignment"], login_result.data["access"])
						else if(login_result == "nocard")
							src.print_text("<b>Error:</b> No ID card inserted.")

				else
					src.print_text("Login required.  Please use \"login\" command.")

		else
			switch(lowertext(command))
				if("cls", "home") //Clear temp var of master computer3
					src.master.temp = null
					src.master.temp_add = "Screen cleared.<br>" //Okay perhaps not entirely clear.
					src.master.updateUsrDialog()

				if("dir", "catalog", "ls") //Show contents of current folder

					src.print_text("<b>Files on [current_folder.holder.title] - Used: \[[src.current_folder.holder.file_used]/[src.current_folder.holder.file_amount]\]</b>")
					src.print_text("<b>Current Folder: [current_folder.name]</b>")

					var/dir_text = null
					for(var/datum/computer/P in current_folder.contents)
						if(P == src)
							dir_text += "[src.name] -  SYSTEM - \[Size: [src.size]]<br>"
							continue

						dir_text += "[P.name] - [(istype(P,/datum/computer/folder)) ? "FOLDER" : "[P:extension]"] - \[Size: [P.size]]<br>"

					if(dir_text)
						src.print_text(dir_text)

				if("cd", "chdir") //Attempts to set current folder to directory arg1
					var/dir_string = null
					if(command_list.len)
						dir_string = jointext(command_list, " ")
					else
						src.print_text("<b>Syntax:</b> \"cd \[directory string]\" String is relative to current directory.")
						return

					if(dir_string == "/") //If it is seriously just /, act like the root command
						src.current_folder = src.current_folder.holder.root
						src.print_text("<b>Current Directory is now [current_folder.name]</b>")
						return

					var/datum/computer/folder/new_dir = parse_directory(dir_string, src.current_folder)
					if(!new_dir || !istype(new_dir))
						src.print_error_text("<b>Error:</b> Invalid directory or path.")
						return
					else
						src.current_folder = new_dir
						src.print_text("<b>Current Directory is now [new_dir.name]</b>")

				if("root") //Sets current folder to root of current drive
					if(src.current_folder && src.current_folder.holder.root)
						src.current_folder = src.current_folder.holder.root
						src.print_text("<b>Current Directory is now [current_folder.name]</b>")

				if("run") //Runs /datum/computer/file/terminal_program with name arg1
					var/prog_name = null
					if(command_list.len)
						prog_name = jointext(command_list, " ")
					else
						src.print_text("<b>Syntax:</b> \"run \[program filepath].\" Path is relative to current directory.")
						return

					var/datum/computer/file/terminal_program/to_run = src.parse_file_directory(prog_name, current_folder)

					if(isnull(to_run) || !istype(to_run) || istype(to_run, /datum/computer/file/terminal_program/os))
						src.print_error_text("<b>Error:</b> Invalid file name or type.")
					else
						src.master.run_program(to_run)
						src.master.updateUsrDialog()
						return

				if("makedir","mkdir") //Creates folder in current directory with name arg1
					var/new_folder_name = strip_html(jointext(command_list, " "))
					new_folder_name = copytext(new_folder_name, 1, 16)

					if(!new_folder_name)
						src.print_text("<b>Syntax:</b> \"makedir \[new directory name]\"")
						return

					if(src.get_computer_datum(new_folder_name, current_folder))
						src.print_error_text("<b>Error:</b> Directory name in use.")
						return

					if(is_name_invalid(new_folder_name))
						src.print_error_text("<b>Error:</b> Invalid character in name.")
						return

					var/datum/computer/F = new /datum/computer/folder
					F.name = new_folder_name
					if(!current_folder.add_file(F))
						src.print_error_text("<b>Error:</b> Unable to create new directory.")
						//qdel(F)
						F.dispose()
					else
						src.print_text("New directory created.")

				if("rename","ren") //Sets name of file arg1 to arg2
					var/to_rename = null
					var/new_name = null
					if(command_list.len >= 2)
						to_rename = command_list[1]
						new_name = command_list[2]
						new_name = copytext(strip_html(new_name), 1, 16)

					if(!to_rename || !new_name)
						src.print_text("<b>Syntax:</b> \"rename \[name of target] \[new name]\"")
						return

					if(is_name_invalid(new_name))
						src.print_error_text("<b>Error:</b> Invalid character in name.")
						return

					var/datum/computer/target = get_computer_datum(to_rename, current_folder)

					if(!target || !istype(target))
						src.print_error_text("<b>Error:</b> File not found.")
						return

					var/datum/computer/check_existing = get_computer_datum(new_name, src.current_folder)
					if(check_existing && check_existing != target )
						src.print_error_text("<b>Error:</b> Name in use.")
						return

					target.name = new_name
					src.print_text("Done.")

				if("title") //Set the title var of the current drive.
					var/new_name = null
					if(command_list.len)
						new_name = strip_html(jointext(command_list, " "))
						new_name = copytext(new_name, 1, 16)
					else
						src.print_text("<b>Syntax:</b> \"title \[title name]\" Set name of active drive to given title.")
						return

					if(src.current_folder.holder && !src.current_folder.holder.read_only)
						src.current_folder.holder.title = new_name
						src.print_text("Drive title set to <b>[new_name]</b>.")
					else
						src.print_error_text("<b>Error:</b> Unable to set title string.")

				if("delete", "del","era","erase","rm") //Deletes file arg1
					var/file_name = null
					if(command_list.len)
						file_name = ckey(jointext(command_list, " "))
					else
						src.print_text("<b>Syntax:</b> \"del \[file name].\" File must be in current directory.")
						return

					var/datum/computer/target = get_computer_datum(file_name, current_folder)
					if(!target || !istype(target))
						src.print_error_text("<b>Error:</b> File not found.")
						return

					if(target == src)
						src.print_error_text("<b>Error:</b> Access denied.")
						return

					if(src.master.delete_file(target))
						src.print_text("File deleted.")
					else
						src.print_error_text("<b>Error:</b> Unable to delete file.")

				if("copy","cp") //Sets file arg1 to be copied
					var/file_name = null
					if(command_list.len)
						file_name = ckey(jointext(command_list, " "))
					else
						src.print_text("<b>Syntax:</b> \"copy \[file name].\" File must be in current directory.")
						return

					var/datum/computer/target = get_file_name(file_name, current_folder)
					if(!target || !istype(target))
						src.print_error_text("<b>Error:</b> File not found.")
						return

					if(target.dont_copy)
						src.print_error_text("<b>Error:</b> File unable to be copied.")
						return
					src.clipboard = target
					src.print_text("File marked.")

				if("paste","ps") //Pastes clipboard file with name arg1
					var/pasted_name = strip_html(jointext(command_list, " "))
					pasted_name = copytext(pasted_name, 1, 16)

					if(!pasted_name)
						src.print_text("<b>Syntax:</b> \"paste \[new file name].\" File is placed in current directory.")
						return

					if(!src.clipboard || !src.clipboard.holder || !(src.clipboard.holder in src.master.contents))
						src.print_error_text("<b>Error:</b> Unable to locate marked file.")
						return

					if(!istype(src.clipboard))
						src.print_error_text("<b>Error:</b> Invalid or corrupt file type.")
						return

					if(get_computer_datum(pasted_name, src.current_folder))
						src.print_error_text("<b>Error:</b> Name in use.")
						return

					if(is_name_invalid(pasted_name))
						src.print_error_text("<b>Error:</b> Invalid character in name.")
						return

					if(src.clipboard.copy_file_to_folder(current_folder, pasted_name))
						src.print_text("Done")
					else
						src.print_error_text("<b>Error:</b> Unable to paste file (Drive is full?)")

				if("drive","drv") //Sets current folder to root of drive arg1
					var/argument1 = null
					if(command_list.len)
						argument1 = command_list[1]

					var/list/drives = src.get_loaded_drives()

					if(!ckey(argument1))
						var/valid_string = english_list(drives, "None", " ")
						src.print_text("<b>Syntax:</b> \"drive \[drive id].\"<br><b>Valid IDs:</b> ([valid_string]).")
						return

					var/obj/item/disk/data/to_load = drives[argument1]
					if(to_load && istype(to_load) && to_load.root)
						src.current_folder = to_load.root
						src.print_text("<b>Current Drive is now [current_folder.holder.title]</b>")
					else
						src.print_text("<b>Error:</b> Drive invalid.")

				if("initlogs") //Restart logging if log file is deleted or otherwise lost.
					if(src.command_log)
						src.print_error_text("<b>Error:</b> Logging is already active.")
					else
						if(initialize_logs())
							src.print_text("Logging re-initialized.")
						else
							src.print_error_text("<b>Error:</b> Unable to re-initialize logging.")

				if("help") //Allow access to "helplib" record datum.  Should be kept tup to date with system commands, etc
					if(!src.help_lib || !istype(src.help_lib) || help_lib.disposed)
						help_lib = null
						src.print_error_text("<b>Error:</b> Help file missing or corrupt.")
						return
					else
						var/argument1 = "help"
						if(command_list.len)
							argument1 = lowertext(command_list[1])

						var/help_string = src.help_lib.fields[argument1]
						if(help_string)
							src.print_text("<b>[capitalize(argument1)]</b><br>[help_string]")
						else
							src.print_error_text("<b>Error:</b> Invalid field.")

				if("periph","p") //Allow some user interactions with peripheral cards.
					var/argument1 = null
					if(command_list.len)
						argument1 = command_list[1]

					switch(argument1)
						if("view","v") //View installed cards.
							src.print_text("<b>Current active peripheral cards:</b>")
							if(!src.peripherals.len)
								src.print_text("<center>None loaded.</center>")
							else
								for(var/x = 1, x <= src.peripherals.len, x++)
									var/obj/item/peripheral/P = src.peripherals[x]
									if(istype(P))
										var/statdat = P.return_status_text()
										src.print_text("<b>ID: \[[x]] [P.func_tag]</b><br>Status: [statdat]")
									else
										src.peripherals -= P
										continue

						if("command","c")
							var/id = 0
							var/pcommand = null
							var/sig_filename = null

							if(command_list.len >= 3) //These two args are needed for this mode
								id = round(text2num_safe(command_list[2]))
								pcommand = strip_html(command_list[3])

							if(command_list.len >= 4) //Having a signal file is optional, however
								sig_filename = ckey(command_list[4])

							if(!pcommand) //Check for command first, if they skip it they also don't get the id and it complains about that and aaaa
								src.print_error_text("Error: Command argument required.")
								return

							if((!id) || (id > src.peripherals.len) || (id <= 0))
								src.print_error_text("Error: ID invalid or out of bounds.")
								return

							var/datum/computer/file/signal/sig = null
							if(sig_filename)
								sig = get_file_name(sig_filename, src.current_folder)
								if(!sig || (!istype(sig) && !istype(sig, /datum/computer/file/record)))
									src.print_error_text("Error: Signal file missing or invalid.")
									return

							src.print_text("Command: <b>ID:</b> [id] <b>COM:</b> [pcommand]")
							var/datum/signal/signal = get_free_signal()//new
							//signal.encryption = "\ref[src.peripherals[id]]"
							if(sig)
								if (istype(sig,/datum/computer/file/record))
									var/datum/computer/file/record/sigrec = sig
									for (var/entry in sigrec.fields)
										var/equalpos = findtext("=", entry)
										if (equalpos)
											signal.data["[copytext(entry, 1, equalpos)]"] = "[copytext(entry, equalpos)]"
										else
											if (!isnull(sigrec.fields[entry]))
												signal.data["[entry]"] = sigrec.fields[entry]
											else
												signal.data += entry

									if (command_list.len > 4)
										signal.data_file = get_file_name(ckey(command_list[5]), src.current_folder)
										if (istype(signal.data_file, /datum/computer/file))
											signal.data_file = signal.data_file.copy_file()
										else
											signal.data_file = null

								else
									signal.data = sig.data.Copy()
									if(sig.data_file) //For file transfers!
										var/datum/computer/file/tempfile = sig.data_file.copy_file()
										if(tempfile && istype(tempfile))
											signal.data_file = tempfile
							var/result = peripheral_command(pcommand, signal, "\ref[src.peripherals[id]]")
							if (result != 0)
								if (result == 1)
									src.print_text("Error: Command unsuccessful.")
								else if (istext(result))
									src.print_text("Response: [result]")

						else
							src.print_text("Syntax: \"periph \[mode] \[ID] \[command] \[signal file]\"<br><b>Valid modes:</b> (view, command)")

				if("backprog", "bp") //Allow the user to manage programs chilling in the background
					var/argument1 = null
					if(command_list.len)
						argument1 = command_list[1]

					switch(argument1)
						if("view", "v") //View processing programs (other than us)
							src.print_text("<b>Current programs in memory:</b>")
							if(!src.master.processing_programs.len) //This should never happen as we should be in it.
								src.print_text("<center>None detected.</center>")
							else
								for(var/x = 1, x <= src.master.processing_programs.len, x++)
									var/datum/computer/file/terminal_program/T = src.master.processing_programs[x]
									if(istype(T))
										src.print_text("<b>ID: \[[x]]</b> [(T == src) ? "SYSTEM" : T.name]")

						if("kill", "k") //Okay now that we know them it is time to BE RID OF THEM
							var/target_id = 0
							if(command_list.len >= 2)
								target_id = round(text2num_safe(command_list[2]))
							else
								src.print_error_text("Target ID Required.")
								return

							if((!target_id) || (target_id > src.master.processing_programs.len) || (target_id <= 0))
								src.print_error_text("<b>Error:</b> ID invalid or out of bounds.")
								return

							var/datum/computer/file/terminal_program/target = src.master.processing_programs[target_id]
							if(!target || !istype(target) || target == src) //No terminating ourselves!!
								src.print_error_text("<b>Error:</b> Invalid Target.")
								return

							src.master.unload_program(target)
							src.print_text("Program killed.")

						if("switch", "s")
							var/target_id = 0
							if(command_list.len >= 2)
								target_id = round(text2num_safe(command_list[2]))
							else
								src.print_error_text("Target ID Required.")
								return

							if((!target_id) || (target_id > src.master.processing_programs.len) || (target_id <= 0))
								src.print_error_text("<b>Error:</b> ID invalid or out of bounds.")
								return

							var/datum/computer/file/terminal_program/target = src.master.processing_programs[target_id]
							if(!target || !istype(target) || target == src || istype(target, /datum/computer/file/terminal_program/os)) //No re-running ourselves!!
								src.print_error_text("<b>Error:</b> Invalid Target.")
								return

							src.print_text("Switching to target...")
							src.master.run_program(target)
							src.master.updateUsrDialog()
							return


						else
							src.print_text("<b>Syntax:</b> \"backprog \[mode] \[ID]\"<br><b>Valid modes:</b> (view, kill, switch)")


				if("print") //Print text arg1 to screen.
					var/new_text = strip_html(jointext(command_list, " "))
					if(new_text)
						src.print_text(new_text)
					else
						src.print_text("<b>Syntax:</b> \"print \[text to be printed]\"")

				if("goonsay") //Display text arg1 along with goonsay ascii
					var/goon = {" __________<br>
								(--\[ .]-\[ .] /<br>
								(_______0__)<br>
								"}

					var/anger_text = "A clown? On a space station? what"
					if(istype(command_list) && (command_list.len > 0))
						anger_text = strip_html(jointext(command_list, " "))

					src.print_text("<tt>[anger_text]<br>[goon]</tt>")

/*
				if("echo") //Determine if entered commands are printed to screen
					var/argument1 = null
					if(command_list.len)
						argument1 = command_list[1]

					switch(argument1)
						if("on","ON")
							src.echo_input = 1

						if("off","OFF")
							src.echo_input = 0

						else
							src.echo_input = !src.echo_input

					src.print_text("Input Echo is now <b>[src.echo_input ? "ON" : "OFF"]</b>")
*/
				if("user") //Show current user identfication data
					if(!src.setup_needs_authentication)
						src.print_error_text("Account system inactive.")
						return

					if(!src.active_account)
						src.print_error_text("<b>Error:</b> Unable to find account file.")
						return

					src.print_text("Current User: [src.active_account.registered]<br>Rank: [src.active_account.assignment]")

				if("logout","logoff") //Log out if we are currently logged in.
					if(!setup_needs_authentication || !src.authenticated)
						src.print_error_text("Account system inactive.")
						return
					else
						src.print_to_log("<b>LOGOUT:</b> [src.authenticated]",0)
						src.authenticated = null
						src.active_account = null
						src.master.temp = null
						src.echo_input = 1

						//Kill off any background programs that may be running.
						for(var/datum/computer/file/terminal_program/T in src.master.processing_programs)
							if(T == src)
								continue

							src.master.unload_program(T)

						src.print_text("Logout complete. Have a secure day.<br><br>Authentication required.<br>Please insert card and \"Login.\"")


				if("read","type") //Display contents of text file arg1
					var/file_name = null
					if(command_list.len)
						file_name = ckey(jointext(command_list, " "))
					else
						src.print_text("<b>Syntax:</b> \"read \[file name].\" Text file must be in current directory.")
						return

					var/datum/computer/file/text/T = get_file_name(file_name, current_folder)

					if(isnull(T) || !istype(T) || !T.data)
						if(istype(T, /datum/computer/file/record))
							var/print_buffer = null
							var/datum/computer/file/record/R = T
							for(var/i in R.fields)
								if (R.fields[i])
									print_buffer += "[i]: [R.fields[i]]<br>"
								else
									print_buffer += "[i]<br>"
							if(print_buffer)
								src.print_text(print_buffer)
							else
								src.print_error_text("<b>Error:</b> File is empty.")
							return

						src.print_error_text("<b>Error:</b> Invalid or blank file.")
					else
						src.print_text(T.data)

				if("version") //Show the version name.  ~Flavortext~
					src.print_text("[src.setup_version_name]<br>Copyright 2047 Thinktronic Systems, LTD.")

				if("time") //Hello my immersion needs to know the time
					src.print_text("System time: [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [CURRENT_SPACE_YEAR].")

				else
					//Load the program if they just entered a path I guess
					var/prog_name = jointext(command_list, " ")
					prog_name = command + prog_name

					var/datum/computer/file/terminal_program/to_run = src.parse_file_directory(prog_name, current_folder)

					if(isnull(to_run) || !istype(to_run) || istype(to_run, /datum/computer/file/terminal_program/os))
						src.print_text("Syntax Error.")
					else
						src.master.run_program(to_run)
						src.master.updateUsrDialog()
						return

		return

	initialize()
		src.print_text("Loading [src.setup_version_name]<br>Scanning for peripheral cards...")

		src.peripherals = new //Figure out what cards are there now so we can address them later all easy-like
		for(var/obj/item/peripheral/P in src.master.peripherals)
			if(!(P in src.peripherals))
				src.peripherals += P

		src.print_text("Preparing filesystem...")

		src.command_log = null
		src.help_lib = null
		src.authenticated = null

		src.current_folder = src.holder.root

		if(src.initialize_logs()) //Get the logging file ready.
			print_text("<font color=red>Log system failure.</font>")

		if(src.initialize_help()) //Find the help file so it can help people.
			print_text("<font color=red>Help library not found.</font>")

		if(setup_needs_authentication && initialize_accounts())
			print_text("<font color=red>Unable to start account system.</font>")

		if(src.setup_needs_authentication)
			src.print_text("Authentication required.<br>Please insert card and \"Login.\"")

		else
			src.print_text("Ready.")

		return

	disk_ejected(var/obj/item/disk/data/thedisk)
		if(!thedisk)
			return

		if(current_folder && (current_folder.holder == thedisk))
			current_folder = src.holding_folder

		if(src.holder == thedisk)
			src.print_text("<font color=red><b>System Error:</b> Unable to read system file.</font>")
			src.master.active_program = null
			src.master.host_program = null
			return

		return
/*
	receive_command(obj/source, command, datum/signal/signal)
		if((..()))
			return

		if((command == "card_authed") && signal && (!src.authenticated) && src.setup_needs_authentication)

			system_login(signal.data["registered"], signal.data["assignment"], signal.data["access"])
			return

		return
*/

	proc
		//Log this text in the ~system log~ as well as printing it.
		print_error_text(text)
			if(src.log_errors)
				src.print_to_log(text, 0)

			return src.print_text(text)

		initialize_logs() //Man we sure love logging things.  Let's set up a log for our logging.
			var/datum/computer/folder/logdir = parse_directory(SETUP_LOG_DIRECTORY, src.holder.root)
			if(!logdir || !istype(logdir))
				logdir = new /datum/computer/folder
				if(src.holder.root.add_file(logdir))
					logdir.name = SETUP_LOG_DIRECTORY
				else
					return -1 //Must be read-only or something if we can't add a folder. Give up.

			var/datum/computer/file/text/the_log = get_file_name(SETUP_LOG_FILENAME, logdir)
			if(the_log && istype(the_log))
				src.command_log = the_log

			else
				the_log = new /datum/computer/file/text()
				if(logdir.add_file(the_log))
					src.command_log = the_log
					the_log.name = SETUP_LOG_FILENAME

				else
					return -2

			the_log.data += "<br><b>STARTUP:</b> [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [CURRENT_SPACE_YEAR]"
			return 0

		print_to_log(text, strip_input=1)
			if(!text)
				return 0
			if(!command_log || !istype(command_log) || !command_log.holder)
				return 0

			if(!(command_log.holder in src.master.contents))
				return 0

			if(strip_input)
				command_log.data += "<br>[strip_html(text)]"
			else
				command_log.data += "<br>[text]"

			return 1

		initialize_help() //It's pretty similar to initialize_logs(), but unable to recreate the file if missing.

			var/datum/computer/file/record/target_rec = parse_file_directory(SETUP_HELP_FILEPATH)
			if(target_rec && istype(target_rec))
				src.help_lib = target_rec
				print_to_log("Help System Initialized.")
				return 0

			return -1

		initialize_accounts()
			var/datum/computer/folder/accdir = parse_directory(SETUP_ACC_DIRECTORY, src.holder.root)
			if(!accdir || !istype(accdir))
				accdir = new /datum/computer/folder
				if(src.holder.root.add_file(accdir))
					accdir.name = SETUP_ACC_DIRECTORY
				else
					return -1 //Oh welp read only

			var/datum/computer/file/user_data/the_acc = get_file_name(SETUP_ACC_FILENAME, accdir)
			if(the_acc && istype(the_acc))
				src.active_account = the_acc

			else
				the_acc = new /datum/computer/file/user_data()
				if(accdir.add_file(the_acc))
					src.active_account = the_acc
					the_acc.name = SETUP_ACC_FILENAME

				else
					return -1

			return 0

		system_login(var/acc_name, var/acc_job, var/access_string, all_access=0)
			if(!acc_name || !acc_job)
				return

			if(!src.initialize_accounts() && !src.active_account) //Oh welp we can't write it to file
				src.print_text("<b>Error:</b> Unable to write account file.")
				return -1

			src.authenticated = acc_name
			src.active_account.access = list()
			src.active_account.registered = acc_name
			src.active_account.assignment = acc_job
			src.current_folder = src.holder.root

			if(access_string && !all_access)
				var/list/decoding = splittext(access_string, ";")
				for(var/x in decoding)
					src.active_account.access += text2num_safe(x)

			else if(all_access)
				src.active_account.access = get_all_accesses()

			src.print_to_log("<b>LOGIN:</b> [acc_name] | \[[acc_job]]", 0)

			src.print_text("Welcome, [acc_name]!<br><b>Current Folder: [current_folder.name]</b>")
			return 0

		get_loaded_drives() //Return a list of the drives in the master computer3.
			var/list/drives = list()
			var/drive_num = 0
			if(src.master.hd)
				drives["hd0"] = src.master.hd
			if(src.master.diskette)
				drives["fd0"] = src.master.diskette

			for(var/obj/item/disk/data/drive in src.master.contents)
				if(drive == src.master.hd || drive == src.master.diskette)
					continue
				drives["sd[drive_num]"] = drive
				drive_num++

			return drives

#undef SETUP_LOG_DIRECTORY
#undef SETUP_LOG_FILENAME
#undef SETUP_HELP_FILEPATH
#undef SETUP_ACC_DIRECTORY
#undef SETUP_ACC_FILENAME
