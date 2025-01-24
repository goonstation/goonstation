//CONTENTS:
//ls	 List directory
//cd	 Change current directory
//rm	 Remove files/folders
//cp	 Copy files
//mv	 Move files
//cat	 Print from files (Records or text)
//ln	 Create links
//mkdir	 Create directories
//chmod	 Change file/folder permissions
//chown	 Change file/folder owner/group (Sysop only)
//su	 Ascend to sysop status!!
//mount	 Mount (mountable) device drivers (Sysop only)
//grep	 Regexes and stuff.  idk.  nerds
//scnt	 Rescan device drivers (Sysop only)
//getopt POSIX getopt: -- rearrange arguments for easier processing and validate options
//date   Time manipulation utility.
//tar    Archiving utility

//pwd    Print current directory

//List directory
/datum/computer/file/mainframe_program/utility/ls
	name = "ls"
	size = 1

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		var/descriptive = 0

		if (initparams)
			var/list/initlist = splittext(initparams, " ")
			if (initlist.len && initlist[1] == "-l")
				initparams = jointext(initlist - initlist[1], "")
				descriptive = 1

		var/current = read_user_field("curpath")
		if (!initparams)
			initparams = current
			if(!initparams)
				initparams = "/"

		else if (!dd_hasprefix(initparams, "/"))
			initparams = "[current]" + (current == "/" ? null : "/") + initparams

		var/datum/computer/folder/listfolder = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=initparams))

		if (istype(listfolder))
			var/message
			for(var/datum/computer/P in listfolder.contents)
				if (!check_read_permission(P, useracc))
					continue

				if (descriptive)
					if (!P.metadata)
						P.metadata = list()

					var/is_folder = istype(P, /datum/computer/folder)
					message += "\[[add_zero("[is_folder ? "--" : P.size]", 2)]] [add_zero( (P.metadata && ("group" in P.metadata) && isnum(text2num_safe(P.metadata["group"])) ? "[P.metadata["group"]]" : "ANY"), 3)][print_file_permissions(P)] [is_folder ? "DIR" : "[copytext(P:extension,1,4)]"]"
					message += " [pad_leading((!P.metadata || isnull(P.metadata["owner"]) ? "Nobody" : P.metadata["owner"]), 16)] [P.name]|n"
				else
					if (dd_hasprefix(P.name, "_"))
						continue
					message += "[P.name]|n"

			if(!message)
				message = " No files.|n"

			message_user("Contents of [initparams]|n" + message,"multiline")

		else
			if (descriptive && istype(listfolder, /datum/computer/file))
				var/datum/computer/file/P = listfolder
				var/message = "\[[add_zero("[P.size]", 2)]] "
				message += add_zero((P.metadata && P.metadata.Find("group") && isnum(text2num_safe(P.metadata["group"])) ? "[P.metadata["group"]]" : "ANY"), 3)
				message += "[print_file_permissions(P)] [copytext(P.extension,1,4)]"
				message += " [pad_leading(( (!P.metadata || !P.metadata.Find("owner") || isnull(P.metadata["owner"])) ? "Nobody" : P.metadata["owner"]), 16)] [P.name]|n"
				message_user(message, "multiline")
			else
				message_user("Error: Invalid resource or directory.")

		mainframe_prog_exit
		return

	proc/print_file_permissions(var/datum/computer/cdatum)
		if (!cdatum)
			return

		. = ""

		var/permissions
		if (cdatum.metadata && cdatum.metadata.Find("permission"))
			permissions = cdatum.metadata["permission"]

		if (!isnum(permissions))
			. = "srwsrwsrw"
		else
			. += "[permissions & COMP_DOWNER ? "s" : "-"][permissions & COMP_ROWNER ? "r" : "-"][permissions & COMP_WOWNER ? "w" : "-"]"
			. += "[permissions & COMP_DGROUP ? "s" : "-"][permissions & COMP_RGROUP ? "r" : "-"][permissions & COMP_WGROUP ? "w" : "-"]"
			. += "[permissions & COMP_DOTHER ? "s" : "-"][permissions & COMP_ROTHER ? "r" : "-"][permissions & COMP_WOTHER ? "w" : "-"]"

		//return dat

//Change current directory.
/datum/computer/file/mainframe_program/utility/cd
	name = "cd"
	size = 1

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		if (!initparams)
/*
			message_user("Error: No path specified.")
			mainframe_prog_exit
			return
*/
			initparams = "/home/usr[read_user_field("name")]"

		var/current = read_user_field("curpath")

		if (!dd_hasprefix(initparams, "/"))
			initparams = "[current]" + (current == "/" ? null : "/") + initparams

		var/datum/computer/folder/checkfolder = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=initparams))
		if (!istype(checkfolder))
			message_user("Error: Invalid path.")
		else
			initparams = trim_path(initparams)
			if (initparams != "/" && copytext(initparams, length(initparams)) == "/")
				initparams = copytext(initparams, 1, length(initparams))
			write_user_field("curpath", initparams)

		mainframe_prog_exit
		return

	proc/trim_path(var/filepath)
		var/list/filelist = splittext(filepath, "/")
		var/list/newfilelist = list()
		for (var/x = 1, x <= filelist.len, x++)
			switch(filelist[x])
				if("..")
					if (newfilelist.len)
						newfilelist.len--
				if(".")
					continue
				else
					newfilelist += filelist[x]

		if (!newfilelist.len)
			newfilelist += "/"

		return jointext(newfilelist, "/")

//Delete files/directories
/datum/computer/file/mainframe_program/utility/rm
	name = "rm"
	size = 1
	var/tmp/target_path = null //For interactive mode
	var/tmp/recursive = 0 //Can remove directories
	var/tmp/silent = 0 //Do not report errors

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		recursive = 0
		silent = 0
		var/set_interactive = 0

		if (initparams)

			var/list/initlist = splittext(initparams, " ")
			if (initlist.len)
				var/argstring = initlist[1]
				if (dd_hasprefix(argstring, "-"))
					initlist -= initlist[1]
					initparams = jointext(initlist, " ")

					var/x = 2
					while (x <= length(argstring))
						var/checkchar = copytext(argstring, x, x+1)
						x++
						switch(lowertext(checkchar))
							if ("r")
								recursive = 1
							if ("i")
								if (silent) continue
								set_interactive = 1
							if ("f")
								set_interactive = 0
								silent = 1
							else
								break

		if (!initparams)
			message_user("Error: No name or path specified.")
			mainframe_prog_exit
			return

		var/current = read_user_field("curpath")

		if (!dd_hasprefix(initparams, "/"))
			initparams = "[current]" + (current == "/" ? null : "/") + initparams

		var/datum/computer/checkdatum = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=initparams))
		if (!istype(checkdatum))
			message_user("Error: Invalid path.")
		else
			if (istype(checkdatum, /datum/computer/folder) && !recursive)
				message_user("Error: Cannot remove target (Is a directory).")
			else
				if (set_interactive)
					target_path = initparams
					message_user("Remove target '[checkdatum.name]'?")
					return

				if (signal_program(1, list("command"=DWAINE_COMMAND_FKILL,"path"=initparams)) != ESIG_SUCCESS)
					message_user("Error: Cannot remove target.")

		mainframe_prog_exit
		return

	input_text(var/text)
		if(..() || !useracc)
			mainframe_prog_exit
			return

		if (!target_path)
			mainframe_prog_exit
			return

		var/list/command_list = parse_string(text)
		var/command = lowertext(command_list[1])

		if (command == "yes" || command == "y")
			var/datum/computer/checkdatum = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=target_path))
			if (!istype(checkdatum))
				message_user("Error: Unable to locate target.")
			else
				if (istype(checkdatum, /datum/computer/folder) && !recursive)
					message_user("Error: Cannot remove target (Is a directory).")
				else
					if (signal_program(1, list("command"=DWAINE_COMMAND_FKILL,"path"=target_path)) != ESIG_SUCCESS)
						message_user("Error: Cannot remove target.")

		mainframe_prog_exit
		return

	message_user(var/msg, var/render=null)
		if (silent)
			return null

		return ..()

//Copy files
/datum/computer/file/mainframe_program/utility/cp
	name = "cp"
	size = 1

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initparams || length(initlist) < 2)
			message_user("Error: Filepaths of target and destination must be specified.")
			mainframe_prog_exit
			return

		var/current = read_user_field("curpath")
		if (!dd_hasprefix(initlist[1], "/"))
			initlist[1] = "[current]" + (current == "/" ? null : "/") + initlist[1]
		if (!dd_hasprefix(initlist[2], "/"))
			initlist[2] = "[current]" + (current == "/" ? null : "/") + initlist[2]

		var/datum/computer/file/prototype = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"=initlist[1]))
		if (!istype(prototype))
			message_user("Error: Invalid target path.")
			mainframe_prog_exit
			return

		var/dest_check = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"=initlist[2]))

		var/adjust_name = null
		if (dest_check != ESIG_NOFILE)
			if (istype(dest_check, /datum/computer/folder) && !get_computer_datum(prototype.name, dest_check))
				adjust_name = prototype.name
			else
				message_user("Error: Invalid destination path (Path already taken?).")
				mainframe_prog_exit
				return

		var/prefixroot = dd_hasprefix(initlist[2], "/")
		var/list/copypath = splittext(initlist[2], "/")
		var/copyname = null
		if (adjust_name)
			copypath += adjust_name
		if (copypath.len)
			copyname = copytext(copypath[copypath.len], 1, 16)
			copypath.len--

		if (copypath.len)
			initlist[2] = jointext(copypath, "/")
			if (prefixroot && !dd_hasprefix(initlist[2], "/"))
				initlist[2] = "/" + initlist[2]
		else
			initlist[2] = "/"

		var/datum/computer/file/copy = prototype.copy_file()
		copy.name = copyname
		copy.metadata["owner"] = read_user_field("name")
		copy.metadata["permission"] = COMP_ALLACC
		if (signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"=initlist[2]), copy) != ESIG_SUCCESS)
			//qdel(copy)
			copy.dispose()
			message_user("Error: Could not copy file.")

		mainframe_prog_exit
		return

//Move files
/datum/computer/file/mainframe_program/utility/mv
	name = "mv"
	size = 1

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initparams || length(initlist) < 2)
			message_user("Error: Filepaths of target and new location must be specified.")
			mainframe_prog_exit
			return

		var/current = read_user_field("curpath")
		if (!dd_hasprefix(initlist[1], "/"))
			initlist[1] = "[current]" + (current == "/" ? null : "/") + initlist[1]
		if (!dd_hasprefix(initlist[2], "/"))
			initlist[2] = "[current]" + (current == "/" ? null : "/") + initlist[2]

		var/datum/computer/file/prototype = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"=initlist[1]))
		if (!istype(prototype))
			message_user("Error: Invalid target path.")
			mainframe_prog_exit
			return

		var/dest_check = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"=initlist[2]))

		var/adjust_name = null
		if (dest_check != ESIG_NOFILE)
			if (istype(dest_check, /datum/computer/folder) && !get_computer_datum(prototype.name, dest_check))
				adjust_name = prototype.name
			else
				message_user("Error: Invalid destination path (Path already taken?).")
				mainframe_prog_exit
				return

		var/prefixroot = dd_hasprefix(initlist[2], "/")
		var/list/copypath = splittext(initlist[2], "/")
		var/copyname = null
		if (adjust_name)
			copypath += adjust_name
		if (copypath.len)
			copyname = copytext(copypath[copypath.len], 1, 16)
			copypath.len--

		if (copypath.len)
			initlist[2] = jointext(copypath, "/")
			if (prefixroot && !dd_hasprefix(initlist[2], "/"))
				initlist[2] = "/" + initlist[2]
		else
			initlist[2] = "/"

		var/datum/computer/file/copy = prototype.copy_file()
		copy.name = copyname
		copy.metadata["owner"] = read_user_field("name")
		copy.metadata["permission"] = COMP_ALLACC
		if (signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"=initlist[2]), copy) != ESIG_SUCCESS)
			//qdel(copy)
			copy.dispose()
			message_user("Error: Could not move file.")
		else
			signal_program(1, list("command"=DWAINE_COMMAND_FKILL,"path"=initlist[1]))

		mainframe_prog_exit
		return



//Concatenate...stuff
/datum/computer/file/mainframe_program/utility/cat
	name = "cat"
	size = 1

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initlist.len || !initparams)
			message_user("Error: No filepath(s) specified.")
			mainframe_prog_exit
			return

		var/bulkmessage = ""
		while (initlist.len)
			if (!initlist[1]) break
			var/current = read_user_field("curpath")

			if (!dd_hasprefix(initlist[1], "/"))
				initlist[1] = "[current]" + (current == "/" ? null : "/") + initlist[1]

			var/datum/computer/file/currfile = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=initlist[1]))
			initlist -= initlist[1]
			if (!istype(currfile))
				break

			var/toAdd = currfile.asText()
			if (toAdd)
				bulkmessage += toAdd

/*
			if (istype(currfile, /datum/computer/file/record))
				for (var/x in currfile:fields)
					bulkmessage += "[x]"
					if (isnull(currfile:fields[x]))
						bulkmessage += "|n"
					else
						bulkmessage += ": [currfile:fields[x]]|n"

			else if (istype(currfile, /datum/computer/file/text))
				bulkmessage += currfile:data + "|n"
			else
				//message_user("Error: Unknown filetype for '[currfile.name]'")
				bulkmessage += corruptText(pick("Error: Unknown filetype for '[currfile.name]'", "Imagine four balls on the edge of a cliff.  Time works the same way.","Packet five loss packet six echo loss packet nine loss packet ten loss gain signal."),60)
				break
*/
			continue

		if (bulkmessage)
			message_user(copytext(bulkmessage, 1, MAX_MESSAGE_LEN),"multiline")

		mainframe_prog_exit
		return

//Link folders
/datum/computer/file/mainframe_program/utility/ln
	name = "ln"
	size = 1

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initparams || length(initlist) < 2)
			message_user("Error: Must specify target and link paths.")
			mainframe_prog_exit
			return

		var/current = read_user_field("curpath")
		if (!dd_hasprefix(initlist[1], "/"))
			initlist[1] = "[current]" + (current == "/" ? null : "/") + initlist[1]
		if (!dd_hasprefix(initlist[2], "/"))
			initlist[2] = "[current]" + (current == "/" ? null : "/") + initlist[2]

		var/datum/computer/folder/target_folder = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=initlist[1]))
		var/link_check = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=initlist[2]))

		if (!istype(target_folder))
			message_user("Error: Invalid target path.")
			mainframe_prog_exit
			return

		if (link_check != ESIG_NOFILE)
			message_user("Error: Invalid link path (Path already taken?).")
			mainframe_prog_exit
			return

		var/prefixroot = dd_hasprefix(initlist[2], "/")
		var/list/linkpath = splittext(initlist[2], "/")
		var/linkname = null
		if (linkpath.len)
			linkname = copytext(linkpath[linkpath.len], 1, 16)
			linkpath.len--

		if (linkpath.len)
			initlist[2] = jointext(linkpath, "/")
			if (prefixroot && !dd_hasprefix(initlist[2], "/"))
				initlist[2] = "/" + initlist[2]
		else
			initlist[2] = "/"

		var/datum/computer/folder/link/symlink = new /datum/computer/folder/link(target_folder)
		symlink.name = linkname
		symlink.metadata["owner"] = read_user_field("name")
		symlink.metadata["permission"] = COMP_ALLACC & ~(COMP_WOTHER|COMP_DOTHER)
		if (signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"=initlist[2]), symlink) != ESIG_SUCCESS)
			//qdel(symlink)
			symlink.dispose()
			message_user("Error: Could not create link.")

		mainframe_prog_exit
		return

//Make a directory. Woah!!
/datum/computer/file/mainframe_program/utility/mkdir
	name = "mkdir"
	size = 1

	initialize(var/initparams)
		if (..() || !useracc)
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initlist.len || !initparams)
			message_user("Error: No filepath(s) specified.")
			mainframe_prog_exit
			return

		initlist.len = min(initlist.len, 4)

		var/create_full = 0
		if (initlist[1] == "-p")
			initlist -= initlist[1]
			create_full = 1

		while (initlist.len)
			if (!initlist[1]) break
			var/current = read_user_field("curpath")

			var/prefixroot = dd_hasprefix(initlist[1], "/")
			if (!prefixroot)
				initlist[1] = "[current]" + (current == "/" ? null : "/") + initlist[1]

			var/list/dirpath = splittext(initlist[1], "/")
			var/dirname = null
			if (dirpath.len)
				dirname = copytext(dirpath[dirpath.len], 1, 16)
				dirpath.len--

			if (dirpath.len)
				initlist[1] = jointext(dirpath, "/")
				if (prefixroot && !dd_hasprefix(initlist[1], "/"))
					initlist[1] = "/" + initlist[1]

			if (!initlist[1])
				initlist[1] = "/"

			//boutput(world, "The Path: \"[initlist[1]]\"")
			var/datum/computer/folder/new_folder = new /datum/computer/folder(  )
			new_folder.name = dirname
			new_folder.metadata["owner"] = read_user_field("name")
			new_folder.metadata["permission"] = COMP_ALLACC & ~(COMP_WOTHER|COMP_DOTHER)
			if (signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"=initlist[1],"mkdir"=create_full), new_folder) != ESIG_SUCCESS)
				//qdel(new_folder)
				new_folder.dispose()

			initlist -= initlist[1]

		mainframe_prog_exit
		return

//Change file permissions.
/datum/computer/file/mainframe_program/utility/chmod
	name = "chmod"
	size = 1

	initialize(var/initparams)
		if (..() || !useracc)
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initparams || length(initlist) < 2)
			message_user("Error: Must specify permission value and target path.")
			mainframe_prog_exit
			return

		var/newpermissions = text2num_safe(initlist[1])
		if (!isnum(newpermissions))
			message_user("Error: Invalid permission value.")
			mainframe_prog_exit
			return

		newpermissions = process_permissions(newpermissions)
		if (newpermissions < 0)
			message_user("Error: Invalid permission value.")
			mainframe_prog_exit
			return

		var/current = read_user_field("curpath")
		if (!dd_hasprefix(initlist[2], "/"))
			initlist[2] = "[current]" + (current == "/" ? null : "/") + initlist[2]

		var/outcome = signal_program(1, list("command"=DWAINE_COMMAND_FMODE,"path"=initlist[2], "permission"=newpermissions))
		switch(outcome)
			if (ESIG_NOFILE, ESIG_NOTARGET)
				message_user("Error: Invalid target path.")

			if (ESIG_GENERIC)
				message_user("Error: Access denied.")

		mainframe_prog_exit
		return

	proc/process_permissions(var/permissions)
		if (permissions < 0 || permissions > 888)
			return -1

		var/otherperm = permissions % 10
		permissions /= 10
		var/groupperm = permissions % 10
		permissions /= 10
		var/ownerperm = permissions % 10

		. = 0
		if (otherperm & 4)
			. |= COMP_ROTHER
		if (otherperm & 2)
			. |= COMP_WOTHER
		if (otherperm & 1)
			. |= COMP_DOTHER

		if (groupperm & 4)
			. |= COMP_RGROUP
		if (groupperm & 2)
			. |= COMP_WGROUP
		if (groupperm & 1)
			. |= COMP_DGROUP

		if (ownerperm & 4)
			. |= COMP_ROWNER
		if (ownerperm & 2)
			. |= COMP_WOWNER
		if (ownerperm & 1)
			. |= COMP_DOWNER

		//return newpermissions

//Change file owner/group information
/datum/computer/file/mainframe_program/utility/chown
	name = "chown"
	size = 1

	initialize(var/initparams)
		if (..() || !useracc)
			mainframe_prog_exit
			return

		. = read_user_field("group")
		if ((. > src.metadata["group"]) && (. != 0)) //User isn't sysop.
			message_user("Error: Access denied.")
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initparams || length(initlist) < 2)
			message_user("Error: Must specify owner/group value(s) and target path.")
			mainframe_prog_exit
			return

		var/newowner = null
		var/newgroup = null

		var/list/newlist = splittext(initlist[1], ":") //New owner/group values should given in form owner:group
		if (!newlist.len || length(newlist) > 2)
			message_user("Error: Input values should be of form \[owner]:\[group]")
			mainframe_prog_exit
			return

		if (length(newlist) == 2)
			newgroup = text2num_safe(newlist[2])
			if (isnull(newgroup))
				message_user("Error: Invalid group ID.")
				mainframe_prog_exit
				return

		newowner = copytext(ckeyEx(newlist[1]), 1, 16)

		var/current = read_user_field("curpath")
		if (!dd_hasprefix(initlist[2], "/"))
			initlist[2] = "[current]" + (current == "/" ? null : "/") + initlist[2]

		var/outcome = signal_program(1, list("command"=DWAINE_COMMAND_FOWNER,"path"=initlist[2], "owner"=newowner, "group"=newgroup))
		switch(outcome)
			if (ESIG_NOFILE, ESIG_NOTARGET)
				message_user("Error: Invalid target path.")

			if (ESIG_GENERIC)
				message_user("Error: Access denied.")

		mainframe_prog_exit
		return

//Ascend to sysop status.
/datum/computer/file/mainframe_program/utility/su
	name = "su"
	size = 1

	initialize(var/initparams)
		if (..() || (read_user_field("group") == 0))
			mainframe_prog_exit
			return

		message_user("Please enter *authorized* card and \"term_login\"")
		return

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..() || (data["command"] != DWAINE_COMMAND_RECVFILE) || !istype(file, /datum/computer/file/record))
			return ESIG_GENERIC

		if (!src.useracc)
			return ESIG_NOUSR

		var/datum/computer/file/record/usdat = file
		if (!usdat.fields["registered"] || !usdat.fields["assignment"])
			return ESIG_GENERIC

		var/list/accessList = splittext(usdat.fields["access"] + ";", ";")
		if ("[access_dwaine_superuser]" in accessList)
			if(signal_program(1, list("command"=DWAINE_COMMAND_UGROUP, "group"=0)) == ESIG_SUCCESS)
				message_user("You are now authorized.")
				usr.unlock_medal("I'm in", 1)
			else
				message_user("Error: Unable to authorize.")
		else
			message_user("Error: Insufficient credentials.")

		mainframe_prog_exit
		return

	input_text(var/text) //We're only going to see this if they are at a login prompt and type something else. Assumedly that is because they want to exit (Or had a typo)
		mainframe_prog_exit
		return

//Mount eligible device drivers
/datum/computer/file/mainframe_program/utility/mount
	name = "mount"
	size = 1

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		. = read_user_field("group")
		if ((. > src.metadata["group"]) && (. != 0))
			message_user("Error: Access denied.")
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initparams || length(initlist) < 2)
			message_user("Error: Must specify device file and mount point names.")
			mainframe_prog_exit
			return

		var/driver_id = initlist[1]
		if (!driver_id)
			message_user("Error: Invalid device file id.")
			mainframe_prog_exit
			return

		var/mountname = copytext(initlist[2], 1, 16)
		if (!mountname || is_name_invalid(mountname))
			message_user("Error: Invalid mountpoint name.")
			mainframe_prog_exit
			return

		if (signal_program(1, list("command"=DWAINE_COMMAND_MOUNT, "id"=driver_id, "link"=mountname)) != ESIG_SUCCESS)
			message_user("Error: Could not mount filesystem.")

		mainframe_prog_exit
		return

//Grep.  Sorta. Searching for text in text. Look, I'm not going to redo the regex library for High Nerd Marquesas
/datum/computer/file/mainframe_program/utility/grep
	name = "grep"
	size = 1

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (length(initlist) > 1)
			var/case_sensitive = 1
			var/print_only_match = 0
			var/recursive = 0
			var/no_messages = 1
			var/plain = 0
			. = ""

			if (copytext(initlist[1], 1, 2) == "-")
				var/options = (copytext(initlist[1], 2, 6))

				if (findtext(options, "i"))
					case_sensitive = 0
				if (findtext(options, "o"))
					print_only_match = 1
				if (findtext(options, "r"))
					recursive = 1
				if (findtext(options, "s"))
					no_messages = 0
				if (findtext(options, "h"))
					plain = 1
				initlist.Cut(1,2)
				if (length(initlist) < 2)
					. += "No pattern or target file. Try 'help grep'"
					mainframe_prog_exit
					return

			var/pattern = copytext(initlist[1], 1, 20)
			if (!case_sensitive)
				pattern = lowertext(pattern)

			var/regex/R = new (pattern)
			if (!istype(R))
				. += "No regular expression found."
				mainframe_prog_exit
				return

			var/current = read_user_field("curpath")

			var/list/grep_results = list()
			for (var/i = 2, i <= initlist.len, i++)
				if (!dd_hasprefix(initlist[i], "/"))
					initlist[i] = "[current]" + (current == "/" ? null : "/") + initlist[i]

				var/datum/computer/to_check = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=initlist[i]))

				if (!istype(to_check))
					break

				if (!check_read_permission(to_check, useracc))
					continue

				if (recursive && istype(to_check, /datum/computer/folder))
					var/datum/computer/folder/listfolder = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=initlist[i]))
					if (istype(listfolder))
						for(var/datum/computer/P in listfolder.contents)
							initlist.Add(initlist[i]+"/"+P.name)
				else if (istype(to_check, /datum/computer/file/record))
					var/j = 0
					for (var/textLine in to_check:fields)
						j += 1
						if (!R)
							R = new (pattern)

						if (R.Find(case_sensitive ? "[textLine][to_check:fields[textLine]]" : lowertext("[textLine][to_check:fields[textLine]]")))
							if (print_only_match)
								grep_results += "[R.match]"
							else if (plain)
								grep_results += "[textLine][to_check:fields[textLine]]"
							else
								grep_results += "[to_check.name]:[j]:" + "[textLine][to_check:fields[textLine]]"
						R = null
				else
					if(no_messages)
						grep_results += "[to_check] could not be read."

			if (length(grep_results))
				message_user("[jointext(grep_results, "|n")]", "multiline")
			else if (.)
				message_user(., "multiline")

		mainframe_prog_exit
		return

//Force a rescan for network devices.
/datum/computer/file/mainframe_program/utility/scnt
	name = "scnt"
	size = 1

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		if(initparams)
			var/list/initlist = splittext(initparams," ")
			if (initlist.len)
				for (var/x in initlist)
					x = ckey(x)
					if (length(x) != 8 || !is_hex(x))
						message_user("Error: Invalid net ID format")
						mainframe_prog_exit
						return

					src.master.reconnect_device(x)

				message_user("Now scanning for device(s).")
				mainframe_prog_exit
				return

		. = read_user_field("group")
		if ((. > src.metadata["group"]) && (. != 0))
			message_user("Error: Access denied.")
			mainframe_prog_exit
			return

		if (signal_program(1, list("command"=DWAINE_COMMAND_DSCAN)) == ESIG_SUCCESS)
			message_user("Now scanning for devices -- This may take a few seconds.")
		else
			message_user("Scan already in progress -- Please be patient.")

		mainframe_prog_exit
		return

// Getopt, process command line options into a digestible form.
// Does not process longopts.
// Programs currently using this will workaround by using invoke(), until $() is implemented.
/datum/computer/file/mainframe_program/utility/getopt
	name = "getopt"
	size = 1
	var/err = null

	proc/message_reply_and_user(var/message)
		var/list/data = list("command"=DWAINE_COMMAND_REPLY, "data" = message, "sender_tag" = "getopt")
		if (useracc)
			data["term"] = useracc.user_id
		var/sig = signal_program(parent_task.progid, data)
		if (sig != ESIG_USR4)
			message_user(message)

	proc/invoke(var/str)
		err = null
		var/list/unaff = list()
		var/list/strlist = bash_explode(str)
		if (!strlist.len)
			err = "getopt: requires at least one parameter"
			return err
		var/list/opts = list()
		var/def = strlist[1]
		var/def_len = length(def)
		var/cc = null
		// Parse getopt option definition: /([a-zA-Z]:?)+/i
		for (var/i = 1, i <= def_len, i++)
			var/pc = chs(def, i)
			var/asc = text2ascii(pc)
			if (pc == ":")
				if (!cc)
					err = "getopt: unexpected : in definition following no option"
					return err
				opts[cc] = ""
				cc = null
			else if ((65 <= asc && asc <= 90) || (97 <= asc && 122 >= asc))
				cc = pc
				opts[cc] = 0
			else
				err = "getopt: unexpected [pc] in definition"
				return err
		cc = null

		// Parse $@, the list of parameters provided to the original command
		for (var/i = 2, i <= strlist.len, i++)
			// -- resets parameters, eg. for: command -p -- something; something is not a parameter of -p
			if (strlist[i] == "--")
				cc = null
				continue
			var/sc = chs(strlist[i], 1)
			if (sc == "-")
				if (cc && istext(opts[cc]))
					err = "getopt: -[cc] expecting parameter, found [strlist[i]]"
					return err // expecting parameter
				def = strlist[i]
				def_len = length(def)
				for (var/j = 2, j <= def_len, j++)
					cc = chs(def, j)
					if (!(cc in opts))
						err = "getopt: unexpected option -[cc]"
						return err // unexpected option
					if (opts[cc] == "" && j != def_len)
						err = "getopt: -[cc] expecting parameter in [def]"
						return err // expecting parameter
					else if (isnum(opts[cc]))
						opts[cc] = 1
			else
				if (!cc)
					unaff += strlist[i]
					continue
				else if (isnum(opts[cc]))
					err = "getopt: unexpected parameter for -[cc]"
					return err // unexpected parameter
				else
					opts[cc] = strlist[i]
					cc = null

		if (cc)
			if (opts[cc] == "")
				err = "getopt: -[cc] expecting parameter, found EOL"
				return err // expecting parameter

		var/list/ret = list()
		for (var/opt in opts)
			if (opts[opt] == 1)
				ret[opt] = 1
			else if (istext(opts[opt]) && opts[opt] != "")
				ret[opt] = opts[opt]

		return list(ret, unaff)

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		if (initparams)
			if (!initparams)
				message_user("Expected arguments.")
				mainframe_prog_exit
				return
			var/list/params = bash_explode(initparams)
			if (!params)
				message_user("Invalid input: [initparams]")
				mainframe_prog_exit
				return
			var/list/all = invoke(initparams)
			if (!istype(all))
				message_user(err)
				mainframe_prog_exit
				return
			var/list/opts = all[1]
			var/list/unaff = all[2]
			var/printed = ""
			for (var/opt in opts)
				printed += "-[opt] "
				if (istext(opts[opt]))
					printed += "[opts[opt]] "
			printed += "--"
			for (var/elem in unaff)
				printed += " [elem]"
			message_reply_and_user(printed)

		mainframe_prog_exit
		return

/proc/optparse(var/data)
	var/list/L = bash_explode(data)
	var/list/OD = list()
	var/i = 1
	var/cc = null
	while (i <= L.len && L[i] != "--")
		if (ascii2text(text2ascii(L[i], 1)) != "-")
			if (!cc)
				return null
			OD[cc] = L[i]
			cc = null
		else
			if (length(L[i]) != 2)
				return null
			if (cc)
				OD[cc] = 1
			cc = ascii2text(text2ascii(L[i], 2))
		i++
	if (cc)
		OD[cc] = 1
	if (i > L.len)
		return null
	var/list/U = list()
	i++
	while (i <= L.len)
		U += L[i]
		i++
	return list(OD, U)

/proc/abspath(var/path, var/curpath)
	if (chs(path, 1) == "/")
		return path
	return "[curpath]/[path]"

//
/datum/computer/file/mainframe_program/utility/date
	name = "date"
	size = 1
	var/opt_data

	proc/message_reply_and_user(var/message)
		var/list/data = list("command"=DWAINE_COMMAND_REPLY, "data" = message, "sender_tag" = "date")
		if (useracc)
			data["term"] = useracc.user_id
		var/sig = signal_program(parent_task.progid, data)
		if (sig != ESIG_USR4)
			message_user(message)

	proc/usage()
		message_user("Date and time utility. Without parameters, outputs current Spacetime Stamp.")
		message_user("Format specifiers: %h hour, %m minute, %s second, %t one-tenth of a second.")
		message_user("Usage:")
		message_user("[name] \[-t FORMAT\]")

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		. = ..()
		if (!.)
			if (data["command"] == DWAINE_COMMAND_REPLY)
				if (data["sender_tag"] == "getopt")
					opt_data = data["data"]
					return ESIG_USR4
				else
					return ESIG_GENERIC
			else if (data["command"] == DWAINE_COMMAND_MSG_TERM)
				message_user(data["data"])
			else
				return ESIG_GENERIC
			return ESIG_SUCCESS

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return
		if (!initparams)
			initparams = ""
		opt_data = null
		var/status = signal_program(1, list("command"=DWAINE_COMMAND_TSPAWN, "passusr" = 1, "path" = "/bin/getopt", "args" = "ht: [initparams]"))
		if (status == ESIG_NOTARGET)
			message_user("getopt: command not found")
			mainframe_prog_exit
			return
		if (!opt_data)
			message_user("date: No response from getopt.")
			mainframe_prog_exit
			return
		if (copytext(opt_data, 1, 7) == "getopt")
			message_user(opt_data)
			mainframe_prog_exit
			return
		var/list/OU = optparse(opt_data)
		if (!OU)
			message_user("date: Error parsing options: [opt_data]")
			usage()
			mainframe_prog_exit
			return
		var/list/opts = OU[1]
		if (opts["h"])
			usage()
			mainframe_prog_exit
			return
		if (!opts["t"])
			message_reply_and_user("[ticker.round_elapsed_ticks]")
			mainframe_prog_exit
			return
		else
			var/format = opts["t"]
			var/t = ticker.round_elapsed_ticks % 10
			format = replacetext(format, "%t", "[t]")
			var/s = round(ticker.round_elapsed_ticks / 10) % 60
			format = replacetext(format, "%s", "[s]")
			var/m = round(ticker.round_elapsed_ticks / 600) % 60
			format = replacetext(format, "%m", "[m]")
			var/h = round(ticker.round_elapsed_ticks / 36000)
			format = replacetext(format, "%h", "[h]")
			message_reply_and_user(format)
			mainframe_prog_exit
			return

// Archiving utility. Used for sending multiple files in one packet. By sending an archive.
/datum/computer/file/mainframe_program/utility/tar
	name = "tar"
	size = 3
	var/opt_data

	proc/message_reply_and_user(var/message)
		var/list/data = list("command"=DWAINE_COMMAND_REPLY, "data" = message, "sender_tag" = "tar")
		if (useracc)
			data["term"] = useracc.user_id
		var/sig = signal_program(parent_task.progid, data)
		if (sig != ESIG_USR4)
			message_user(message)

	proc/usage()
		message_user("Usage:")
		message_user("[name] -x \[-kqv\] -f ARCHIVE \[PATH\]")
		message_user("[name] -c \[-v\] (-t|-f ARCHIVE) FILE ...")
		message_user("[name] -l -f ARCHIVE")

	proc/recursive_list(var/datum/computer/F, cpath = "", depth = 0)
		if (depth >= 8)
			message_user("tar: Stack overflow.")
			return null
		message_reply_and_user("[cpath][F.name]")
		if (istype(F, /datum/computer/folder))
			var/datum/computer/folder/FO = F
			var/lpath = "[cpath][FO.name]/"
			for (var/datum/computer/C in FO.contents)
				recursive_list(C, lpath, depth + 1)

	proc/recursive_extract(var/datum/computer/C, var/datum/computer/folder/F, target, var/list/opts, cpath = "", depth = 0)
		if (depth >= 8)
			if (!opts["q"])
				message_user("tar: Stack overflow.")
			return null
		var/datum/computer/T = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="[target][C.name]"))
		if (opts["v"])
			message_reply_and_user("[cpath][C.name]")
		if (istype(C, /datum/computer/folder))
			if (istype(T))
				if (opts["k"])
					if (!opts["q"])
						message_user("[target][C.name] already exists, skipping")
				else
					if (!opts["q"])
						message_user("tar: [target][C.name] already exists, cannot overwrite folder - skipping.")
			else
				if (signal_program(1, list("command"=DWAINE_COMMAND_TSPAWN, "passusr" = 1, "path"="/bin/mkdir", "args"="[target][C.name]")) == ESIG_NOTARGET && !opts["q"])
					message_user("mkdir: command not found")
				T = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="[target][C.name]"))
				var/datum/computer/folder/FO = C
				if (!istype(T) && !opts["q"])
					message_user("tar: Failed to create directory [C.name]")
				var/dtarget = "[target][C.name]/"
				var/dcpath = "[cpath][C.name]/"
				for (var/datum/computer/C2 in FO.contents)
					recursive_extract(C2, T, dtarget, opts, dcpath, depth + 1)
		else if (istype(C, /datum/computer/file))
			if (istype(T) && opts["k"])
				if (!opts["q"])
					message_user("[target][C.name] already exists, skipping")
			else if ((istype(T) && !opts["k"]) || !istype(T))
				var/outcome = signal_program(1, list("command" = DWAINE_COMMAND_FWRITE, "path" = "[target]", "mkdir" = 1, "replace" = 1), C)
				if (!opts["q"])
					if (outcome == ESIG_NOWRITE)
						message_user("[target][C.name]: permission denied")
					else if (outcome == ESIG_GENERIC)
						message_user("Error extracting [target][C.name]")
					else if (outcome == ESIG_NOTARGET)
						message_user("Bad path: [target] for file [C.name]")
		else
			if (!opts["q"])
				message_user("tar: Unknown data type: [C.name]")

	proc/deep_copy(var/datum/computer/C, var/list/opts, var/cpath = "", var/depth = 0)
		if (depth >= 8)
			if (!opts["q"])
				message_user("tar: Stack overflow.")
			return null
		if (istype(C, /datum/computer/file/archive))
			if (!opts["q"])
				message_user("tar: Cannot handle file [cpath][C]")
			return null
		if (istype(C, /datum/computer/folder))
			var/datum/computer/folder/F = new()
			for (var/datum/computer/C2 in C:contents)
				var/dcpath = "[cpath][C.name]/"
				var/datum/computer/NC = deep_copy(C2, opts, dcpath, depth + 1)
				if (istype(NC))
					F.add_file(NC)
			return F
		else if (istype(C, /datum/computer/file))
			if (opts["v"])
				message_reply_and_user("[cpath][C.name]")
			return C:copy_file()
		else
			if (!opts["q"])
				message_user("tar: Unknown data type: [C.name]")
			return null

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		. = ..()
		if (!.)
			if (data["command"] == DWAINE_COMMAND_REPLY)
				if (data["sender_tag"] == "getopt")
					opt_data = data["data"]
					return ESIG_USR4
				else
					return ESIG_GENERIC
			else if (data["command"] == DWAINE_COMMAND_MSG_TERM)
				message_user(data["data"])
			else
				return ESIG_GENERIC
			return ESIG_SUCCESS

	proc/temp_file_name()
		var/filename = "tmp"
		for (var/i = 0, i < 12, i++)
			filename += "[num2hex(rand(0, 15), 1)]"
		return filename

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return
		if (initparams)
			if (!initparams)
				message_user("tar: Expected arguments.")
				mainframe_prog_exit
				return
			opt_data = null
			var/status = signal_program(1, list("command"=DWAINE_COMMAND_TSPAWN, "passusr" = 1, "path" = "/bin/getopt", "args" = "cf:ltqvx [initparams]"))
			if (status == ESIG_NOTARGET)
				message_user("getopt: command not found")
				mainframe_prog_exit
				return
			if (!opt_data)
				message_user("tar: No response from getopt.")
				mainframe_prog_exit
				return
			if (copytext(opt_data, 1, 7) == "getopt")
				message_user(opt_data)
				mainframe_prog_exit
				return
			var/list/OU = optparse(opt_data)
			if (!OU)
				message_user("tar: Error parsing options: [opt_data]")
				mainframe_prog_exit
				return
			var/list/opts = OU[1]
			var/list/unaff = OU[2]
			if (!opts["f"] && !(opts["c"] && opts["t"]))
				usage()
				mainframe_prog_exit
				return
			if (opts["t"] && opts["f"])
				message_user("tar: Cannot create both temporary and targeted file.")
				mainframe_prog_exit
				return
			if (opts["q"] && opts["v"])
				message_user("tar: Cannot run in quiet verbose mode.")
				mainframe_prog_exit
				return
			var/commands = (opts["c"] ? 1 : 0) + (opts["x"] ? 1 : 0) + (opts["l"] ? 1 : 0)
			if (commands != 1)
				usage()
				mainframe_prog_exit
				return

			var/curpath = read_user_field("curpath")
			var/arcfile
			if (opts["f"])
				arcfile = abspath(opts["f"], curpath)
			else
				arcfile = "/tmp/[temp_file_name()]"

			if (opts["l"] || opts["x"])
				var/datum/computer/file/archive/archive = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=arcfile))
				if (!istype(archive))
					message_user("tar: Cannot locate archive [opts["f"]]")
					mainframe_prog_exit
					return
				if (!istype(archive))
					message_user("tar: [opts["f"]] is not a valid archive.")
					mainframe_prog_exit
					return

				if (opts["l"])
					for (var/datum/computer/F in archive.contained_files)
						recursive_list(F, "")
				else if (opts["x"])
					var/target = curpath
					if (unaff.len)
						target = abspath(unaff[1], curpath)
					var/datum/computer/folder/F = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=target))
					if (!istype(F))
						message_user("tar: cannot read target directory [target]")
						mainframe_prog_exit
						return
					if (copytext(target, length(target)) != "/")
						target += "/"
					for (var/datum/computer/C in archive.contained_files)
						recursive_extract(C, F, target, opts, "")
			else if (opts["c"])
				if (!unaff.len)
					message_user("tar: No files to add to archive.")
					mainframe_prog_exit
					return
				var/datum/computer/file/archive/archive = new()
				for (var/path in unaff)
					var/datum/computer/C = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"=abspath(path, curpath)))
					if (!istype(C))
						message_user("tar: File [path] does not exist.")
						mainframe_prog_exit
						return
					var/datum/computer/C2 = deep_copy(C, opts)
					if (!istype(C2))
						message_user("tar: Failed to replicate [path].")
						mainframe_prog_exit
						return
					archive.add_file(C2)
				var/list/arcparts = splittext(arcfile, "/")
				archive.name = arcparts[arcparts.len]
				arcparts.Cut(arcparts.len, 0)
				var/arcbase = "/"
				if (arcparts.len)
					arcbase = "[jointext(arcparts, "/")]"
				if (chs(arcbase, 1) != "/")
					arcbase = "/[arcbase]"
				var/outcome = signal_program(1, list("command"=DWAINE_COMMAND_FWRITE, "path"=arcbase, "mkdir"=1, "replace" = 1), archive)
				if (outcome == ESIG_NOWRITE)
					message_user("tar: Cannot write destination [opts["f"]]")
				else if (outcome == ESIG_NOTARGET)
					message_user("tar: Error creating path to archive.")
				else if (outcome == ESIG_GENERIC)
					message_user("tar: Error while creating archive.")
				if (opts["t"])
					message_reply_and_user(arcfile)

		mainframe_prog_exit
		return
/datum/computer/file/mainframe_program/utility/pwd
	name = "pwd"
	size = 1
	initialize(var/initparams)
		message_user(read_user_field("curpath"))
		mainframe_prog_exit

