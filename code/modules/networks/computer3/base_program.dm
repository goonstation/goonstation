


/datum/computer/file/terminal_program
	name = "blank program"
	extension = "TPROG"
	//var/size = 4
	//var/obj/item/disk/data/holder = null
	var/obj/machinery/computer3/master = null
	//var/active_icon = null
	var/list/req_access = list()
	//var/id_tag = null
	var/executable = 1

	var/tmp/authenticated = null //! Are we currently logged in?
	var/datum/computer/file/user_data/account = null
	var/setup_acc_filepath = "/logs/sysusr"//! Where do we look for login data?

	os
		name = "blank system program"
		extension = "TSYS"
		executable = 0
		var/tmp/setup_string = null

		os_call(var/list/call_list, var/datum/computer/file/terminal_program/caller_prog, var/datum/computer/file/file)
			return (!master || master.status & (NOPOWER|BROKEN) || !caller_prog || !call_list)

	termapp //Small applications for the "termos" computer3s.
		name = "blank terminal app"
		extension = "TAPP"
		executable = 0

	New(obj/holding as obj)
		..()
		if(holding)
			src.holder = holding

			if(istype(src.holder.loc,/obj/machinery/computer3))
				src.master = src.holder.loc

	/* new disposing() pattern should handle this. -singh
	disposing()
		master?.processing_programs.Remove(src)
		..()
	*/

	disposing()
		if (master)
			if (master.processing_programs)
				master.processing_programs.Remove(src)
			master = null

		src.req_access = null
		..()

	proc
		os_call(var/list/call_list, var/datum/computer/file/file)
			if(!master || master.status & (NOPOWER|BROKEN))
				return null

			if(master.host_program)
				return master.host_program.os_call(call_list, src, file)
			return null

		print_text(var/text)
			if((!src.holder) || (!src.master) || !text)
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(master.status & (NOPOWER|BROKEN))
				return 1

			if(src != src.master.active_program)
				return 1

			if(!(holder in src.master.contents))
				//boutput(world, "Holder [holder] not in [master] of prg:[src]")
				if(master.active_program == src)
					master.active_program = null
				return 1

			if(!src.holder.root)
				src.holder.root = new /datum/computer/folder
				src.holder.root.holder = src
				src.holder.root.name = "root"

			src.master.temp_add += "[text]<br>"
			src.master.updateUsrDialog()

			return 0

		input_text(var/text)
			if((!src.holder) || (!src.master) || !text)
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(master.status & (NOPOWER|BROKEN))
				return 1

			if(!(holder in src.master.contents))
				//boutput(world, "Holder [holder] not in [master] of prg:[src]")
				if(master.active_program == src)
					master.active_program = null
				return 1

			if(!src.holder.root)
				src.holder.root = new /datum/computer/folder
				src.holder.root.holder = src
				src.holder.root.name = "root"

			return 0

		///Extracted with great pain from the like 6 other fucking programs that copy pasted this, whyyyy
		///Returns true to halt the call stack
		initialize() //Called when a program starts running.
			SHOULD_CALL_PARENT(TRUE)
			src.authenticated = null
			if (!length(src.req_access)) //no access required, don't authenticate user
				return FALSE

			if(!src.find_access_file()) //Find the account information, as it's essentially a ~digital ID card~
				src.print_text("<b>Error:</b> Cannot locate user file.  Quitting...")
				src.master.unload_program(src) //Oh no, couldn't find the file.
				return TRUE
			if(!src.check_access(src.account.access))
				src.print_text("User [src.account.registered] does not have needed access credentials.<br>Quitting...")
				src.master.unload_program(src)
				return TRUE
			src.authenticated = src.account.registered

		///Look for the whimsical account_data file
		find_access_file()
			var/datum/computer/folder/accdir = src.holder.root
			if(src.master.host_program) //Check where the OS is, preferably.
				accdir = src.master.host_program.holder.root

			var/datum/computer/file/user_data/target = parse_file_directory(setup_acc_filepath, accdir)
			if(target && istype(target))
				src.account = target
				return 1

			return 0

		restart()
			return

		process()
			if((!src.holder) || (!src.master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in src.master.contents))
				if(master.active_program == src)
					master.active_program = null
				master.processing_programs.Remove(src)
				return 1

			if(!src.holder.root)
				src.holder.root = new /datum/computer/folder
				src.holder.root.holder = src
				src.holder.root.name = "root"

			return 0

		receive_command(obj/source, command, datum/signal/signal)
			if((!src.holder) || (!src.master) || (!source) || (source != src.master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(master.status & (NOPOWER|BROKEN))
				return 1

			if(!(holder in src.master.contents))
				if(master.active_program == src)
					master.active_program = null
				return 1

			return 0

		peripheral_command(command, datum/signal/signal, target_ref)
			if(master)
				return master.send_command(command, signal, target_ref)
			//else
			//	qdel(signal)

			return null

		//Find a peripheral by func_tag
		find_peripheral(desired_tag)
			if(!src.master || !desired_tag) return

			var/found = null
			for(var/obj/item/peripheral/P in src.master.peripherals)
				if(P.func_tag == desired_tag)
					found = P

			return found

		transfer_holder(obj/item/disk/data/newholder,datum/computer/folder/newfolder)

			if((newholder.file_used + src.size) > newholder.file_amount)
				return 0

			if(!newholder.root)
				newholder.root = new /datum/computer/folder
				newholder.root.holder = newholder
				newholder.root.name = "root"

			if(!newfolder)
				newfolder = newholder.root

			if((src.holder && src.holder.read_only) || newholder.read_only)
				return 0

			if((src.holder) && (src.holder.root))
				src.holder.root.remove_file(src)

			newfolder.add_file(src)

			if(istype(newholder.loc,/obj/machinery/computer3))
				src.master = newholder.loc

			//boutput(world, "Setting [src.holder] to [newholder]")
			src.holder = newholder
			return 1

		parse_string(string)
			var/list/sorted = command2list(string, " ")
			if (!sorted.len) sorted.len++
			return sorted

		//Command2list is a modified version of dd_text2list() designed to eat empty list entries generated by superfluous whitespace.
		//It was born in mainframe2.  Do not forget your history.
		command2list(text, separator)
			var/textlength = length(text)
			var/separatorlength = length(separator)
			var/list/textList = new()
			var/searchPosition = 1
			var/findPosition = 1
			while(1)
				findPosition = findtext(text, separator, searchPosition, 0)
				var/buggyText = copytext(text, searchPosition, findPosition)
				if(buggyText)
					textList += "[buggyText]"
				if(!findPosition)
					return textList
				searchPosition = findPosition + separatorlength
				if(searchPosition > textlength)
					return textList
			return

		parse_directory(string, var/datum/computer/folder/origin)
			if(!string)
				return null

			//boutput(world, "[string]")
			var/datum/computer/folder/current = origin

			if(!origin)
				origin = src.holding_folder

			if(dd_hasprefix(string , "/")) //if it starts with a /
				current = origin.holder.root //Begin the search at root.of current drive
				string = copytext(string,2)
				//boutput(world, "string is now: [string]")

			var/list/sort1 = splittext(string,"/")
			if (sort1.len && copytext(sort1[1], 4, 5) == ":")
				. = lowertext( copytext(sort1[1], 1, 4) )
				if (length(sort1[1]) > 4)
					sort1[1] = copytext(sort1[1], 5)
				else
					sort1.Cut(1,2)
				switch (.)
					if ("hd0")
						if (master.hd)
							current = master.hd.root
						else
							return null

					if ("fd0")
						if (master.diskette)
							current = master.diskette.root
						else
							return null

					else
						if (cmptext(copytext(., 1, 3), "sd"))
							. = text2num_safe(copytext(., 3))
							if (!isnum(.))
								return null

							.++
							for (var/obj/item/disk/data/drive in master.contents)
								if (drive == master.hd || drive == master.diskette)
									continue

								if (--. < 1)
									current = drive.root
									break

							if (. > 0)
								return null

			while(current)

				if(!sort1.len)
					//boutput(world, "finished with [current.name]")
					return current

				var/new_current = 0
				for(var/datum/computer/folder/F in current.contents)
					//boutput(world, "testing: [F.name] -- [sort1[1]] in folder [current]")
					if(ckey(F.name) == ckey(sort1[1]))
						//boutput(world, "matches: [F.name] -- [sort1[1]]")
						sort1 -= sort1[1]
						current = F
						new_current = 1
						break

				if(!new_current)
					//boutput(world, "no new current")
					return null

			return null

		//Find a file at the end of a given dirstring.
		parse_file_directory(string, var/datum/computer/folder/origin)
			if(!string)
				return null

			//boutput(world, "[string]")
			var/datum/computer/folder/current = origin

			if(!origin)
				origin = src.holding_folder

			if(dd_hasprefix(string , "/")) //if it starts with a /
				current = origin.holder.root //Begin the search at root.of current drive
				string = copytext(string,2)
				//boutput(world, "string is now: [string]")

			var/list/sort1 = splittext(string,"/")
			if (sort1.len && copytext(sort1[1], 4, 5) == ":")
				. = lowertext( copytext(sort1[1], 1, 4) )
				if (length(sort1[1]) > 4)
					sort1[1] = copytext(sort1[1], 5)
				else
					sort1.Cut(1,2)
				switch (.)
					if ("hd0")
						if (master.hd)
							current = master.hd.root
						else
							return null

					if ("fd0")
						if (master.diskette)
							current = master.diskette.root
						else
							return null

					else
						if (cmptext(copytext(., 1, 3), "sd"))
							. = text2num_safe(copytext(., 3))
							if (!isnum(.))
								return null

							.++
							for (var/obj/item/disk/data/drive in master.contents)
								if (drive == master.hd || drive == master.diskette)
									continue

								if (--. < 1)
									current = drive.root
									break

							if (. > 0)
								return null

			var/file_name = sort1[sort1.len]
			if(!file_name)
				return null

			sort1 -= sort1[sort1.len]

			while(current)

				if(!sort1.len)
					var/datum/computer/file/check = get_file_name(file_name, current)
					if(check && istype(check))
						return check
					else
						return null

				var/new_current = 0
				for(var/datum/computer/folder/F in current.contents)
					//boutput(world, "testing: [F.name] -- [sort1[1]] in folder [current]")
					if(ckey(F.name) == ckey(sort1[1]))
						//boutput(world, "matches: [F.name] -- [sort1[1]]")
						sort1 -= sort1[1]
						current = F
						new_current = 1
						break

				if(!new_current)
					//boutput(world, "no new current")
					return null

			return null

		disk_ejected(var/obj/item/disk/data/thedisk) //So we can switch out of the floppy if it's ejected or whatever.
			if(!thedisk)
				return

			if(src.holder == thedisk)
				src.print_text("<font color=red>Fatal Error. Returning to system...</font>")
				src.master.unload_program(src)
				return

			return

		//Find a folder with a given name
		get_folder_name(string, var/datum/computer/folder/check_folder)
			if(!string || (!check_folder || !istype(check_folder)))
				return null

			var/datum/computer/taken = null
			for(var/datum/computer/folder/F in check_folder.contents)
				if(ckey(string) == ckey(F.name))
					taken = F
					break

			return taken

		//Find a file with a given name
		get_file_name(string, var/datum/computer/folder/check_folder)
			if(!string || (!check_folder || !istype(check_folder)))
				return null

			var/datum/computer/taken = null
			for(var/datum/computer/file/F in check_folder.contents)
				if(ckey(string) == ckey(F.name))
					taken = F
					break

			return taken

		//Just find any computer datum with this name, gosh
		get_computer_datum(string, var/datum/computer/folder/check_folder)
			if(!string || (!check_folder || !istype(check_folder)))
				return null

			var/datum/computer/taken = null
			for(var/datum/computer/C in check_folder.contents)
				if(ckey(string) == ckey(C.name))
					taken = C
					break

			return taken

		is_name_invalid(string) //Check if a filename is invalid somehow
			if(!string)
				return 1

			if(ckey(string) != replacetext(lowertext(string), " ", null))
				return 1

			if(findtext(string, "/"))
				src.print_text("<b>Error:</b> Invalid character in name.")
				return 1


			return 0


		check_access(var/list/check_list)
			if(!src.req_access) //no requirements
				return 1
			if(!istype(src.req_access, /list)) //something's very wrong
				return 1

			var/list/L = src.req_access
			if(!L.len) //still no requirements
				return 1
			if(!check_list || !istype(check_list, /list)) //invalid or no access
				return 0
			for(var/req in src.req_access)
				if (req == access_fuck_all)
					// access_fuck_all means no special access but needs authentication anyway
					// and everyone should implicitly have that
					continue
				if(!(req in check_list)) //doesn't have this access
					return 0
			return 1
