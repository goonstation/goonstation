//CONTENTS:
//Mainframe program parent type
//Mainframe user account datum


/*
 *	Mainframe Software
 */

/datum/computer/file/mainframe_program
	name = "mainframe program"
	extension = "MPG"
	var/obj/machinery/networked/mainframe/master = null
	var/executable = 1
	var/needs_holder = 1
	var/tmp/datum/computer/file/mainframe_program/parent_task = null
	var/tmp/progid = 0
	var/tmp/parent_id = 0
	var/tmp/initialized = 0
	var/tmp/datum/mainframe2_user_data/useracc = null

	os
		name = "Base OS"
		size = 16
		extension = "SYS"
		executable = 0
		var/tmp/setup_string = null

		proc
			//Called by the mainframe when a new terminal connection is made so as to alert the OS
			new_connection(datum/terminal_connection/conn)
				return

			//Called by the mainframe upon termination of a connection, conn is deleted afterwards
			closed_connection(datum/terminal_connection/conn)
				return

			//The data string (And, optionally, file) sent to us by a connected terminal (Identified by network ID in termid)
			//Note: The passed file will be completely temporary and is deleted after the function returns.
			term_input(var/data, var/termid, var/datum/computer/file/file)
				if(!src.master || !data || !termid)
					return 1

				if(master.status & (NOPOWER|BROKEN|MAINT))
					return 1

				if(src.needs_holder)
					if(!(holder in src.master.contents))
						return 1

					if(!src.holder.root)
						src.holder.root = new /datum/computer/folder
						src.holder.root.holder = src
						src.holder.root.name = "root"

				return 0

			//Called by the mainframe upon receipt of a ping_reply network signal. This does not a terminal_connection because we are not necessarily connected to the responding device.
			ping_reply(var/senderid,var/sendertype)
				return (!master || !senderid || !sendertype)


			//Send a message to a connected terminal device (Using term_message)
			message_term(var/message, var/termid, var/render=null)

				if(!istype(master) || !message || !termid)
					return 1

				if(master.status & (NOPOWER|BROKEN|MAINT))
					return 1

				if(src.needs_holder)
					if (!holder || !(holder in src.master.contents))
						return 1

					if(!src.holder.root)
						src.holder.root = new /datum/computer/folder
						src.holder.root.holder = src
						src.holder.root.name = "root"

				SPAWN(1 DECI SECOND)
					src.master.post_status(termid, "command", "term_message", "data", message, "render", render)
				return 0

			//Send a file and message to a connected terminal device (Using term_file)
			file_term(var/datum/computer/file/file, var/termid, var/exdata)


				if(!istype(master) || !istype(file) || !termid)
					return 1

				if(master.status & (NOPOWER|BROKEN|MAINT))
					return 1

				if(src.needs_holder)
					if (!holder || !(holder in src.master.contents))
						return 1

					if(!src.holder.root)
						src.holder.root = new /datum/computer/folder
						src.holder.root.holder = src
						src.holder.root.name = "root"

				SPAWN(1 DECI SECOND)
					src.master.post_file(termid, "data", exdata, file)
				return 0

/*
 *	The parse_* functions parse the filesystem to locate a computer datum of some sort (Be it directory, file, or either)
 *	with a supplied filepath string, origin point, and user. Create_if_missing determines whether intermediary folders in the path should be created if not present.
 *	Notes: A '/' prefixing the filepath will cause the search to start at the origin point
 *	'.' refers to the current folder in the search, while '..' refers to its parent folder
 *	Results will be filtered based on the supplied user's permissions -- If they do not have permission to read a file, they will not find said file.
 *	If a user datum is not supplied, it is assumed that the system made the call desiring full access.
 */

			parse_directory(string, var/datum/computer/folder/origin, var/create_if_missing, var/datum/mainframe2_user_data/user)
				if(!string)
					return null

				var/datum/computer/folder/current = origin

				if(!origin)
					origin = src.holder.root

				if(dd_hasprefix(string , "/")) //if it starts with a /
					if (string == "/")
						return origin
					current = origin
					string = copytext(string,2)

				var/list/sort1 = list()
				sort1 = splittext(string,"/")
				if (sort1.len && !sort1[sort1.len])
					sort1.len--

				while(current)

					if(!sort1.len)
						return current

					if(sort1[1] == "..")
						if (current == origin)
							return null
						current = current.holding_folder
						sort1 -= sort1[1]
						continue
					else if (sort1[1] == ".")
						sort1 -= sort1[1]
						continue

					else if (!sort1[1] && !create_if_missing)
						return current

					var/new_current = 0
					for(var/datum/computer/folder/F in current.contents)
						if(ckey(F.name) == ckey(sort1[1]) && (!user || check_read_permission(F, user)))
							sort1 -= sort1[1]
							current = F
							new_current = 1
							break

					if(!new_current)
						if (!create_if_missing)
							return null

						var/datum/computer/folder/F = new /datum/computer/folder(  )
						F.name = sort1[1]

						if (is_name_invalid(F.name))
							//qdel(F)
							F.dispose()
							return null

						. = current.add_file(F)
						if (!.)
							if (F)
								F.dispose()
								return null

						else if (istype(., /datum/computer/folder))
							F = .

						sort1 -= sort1[1]
						current = F
						new_current = 1

				return null

			//Find a file at the end of a given dirstring.
			parse_file_directory(string, var/datum/computer/folder/origin, var/create_if_missing, var/datum/mainframe2_user_data/user)
				if(!string)
					return null

				var/datum/computer/folder/current = origin

				if(!origin)
					origin = src.holder.root

				if(dd_hasprefix(string , "/")) //if it starts with a /
					current = origin
					string = copytext(string,2)

				var/list/sort1 = list()
				sort1 = splittext(string,"/")

				var/file_name = sort1[sort1.len]
				if(!file_name)
					return null

				sort1 -= sort1[sort1.len]

				while(current)

					if(!sort1.len)
						var/datum/computer/file/check = get_file_name(file_name, current, user)
						if(check && istype(check))
							return check
						else
							return null

					if(sort1[1] == "..")
						if (current == origin)
							return null
						current = current.holding_folder
						sort1 -= sort1[1]
						continue
					else if (sort1[1] == ".")
						sort1 -= sort1[1]
						continue

					var/new_current = 0
					for(var/datum/computer/folder/F in current.contents)
						if(ckey(F.name) == ckey(sort1[1]) && (!user || check_read_permission(F, user)))
							sort1 -= sort1[1]
							current = F
							new_current = 1
							break

					if(!new_current)
						if (!create_if_missing)
							return null

						var/datum/computer/folder/F = new /datum/computer/folder
						F.name = sort1[1]

						if (is_name_invalid(F.name) || !current.add_file(F))
							//qdel(F)
							F.dispose()
							return null

						sort1 -= sort1[1]
						current = F
						new_current = 1

				return null

			//If we are willing to accept either a file or folder as the return value.
			parse_datum_directory(string, var/datum/computer/folder/origin, var/create_if_missing, var/datum/mainframe2_user_data/user)
				if(!string)
					return null

				var/datum/computer/folder/current = origin

				if(!origin)
					origin = src.holder.root

				if(dd_hasprefix(string , "/")) //if it starts with a /
					if (string == "/")
						return origin
					current = origin
					string = copytext(string,2)

				var/list/sort1 = list()
				sort1 = splittext(string,"/")

				var/datum_name = sort1[sort1.len]
				if(!datum_name)
					//return null
					sort1.len--
					while (sort1.len)
						datum_name = sort1[sort1.len]
						if (!datum_name)
							sort1.len--
							continue
						break

				sort1.len = max(0, sort1.len-1)

				while(current)

					if(!sort1.len)
						switch(datum_name)
							if ("..")
								if (current == origin)
									return null
								return current.holding_folder
							if (".")
								return current
						var/datum/computer/check = get_computer_datum(datum_name, current, user)
						if(check && istype(check))
							return check
						else
							return null

					if(sort1[1] == "..")
						current = current.holding_folder
						sort1 -= sort1[1]
						continue
					else if (sort1[1] == ".")
						sort1 -= sort1[1]
						continue

					var/new_current = 0
					for(var/datum/computer/folder/F in current.contents)
						if(ckey(F.name) == ckey(sort1[1]) && (!user || check_read_permission(F, user)))
							sort1 -= sort1[1]
							current = F
							new_current = 1
							break

					if(!new_current)
						if (!create_if_missing)
							return null

						var/datum/computer/folder/F = new /datum/computer/folder
						F.name = sort1[1]

						if (is_name_invalid(F.name) || !current.add_file(F))
							//qdel(F)
							F.dispose()
							return null

						sort1 -= sort1[1]
						current = F
						new_current = 1

				return null

	New(obj/holding as obj)
		..()
		if(holding)
			src.holder = holding

			if(istype(src.holder.loc,/obj/machinery/networked/mainframe))
				src.master = src.holder.loc

	disposing()
		if(master && (src in master.processing))
			master.processing[src] = null
			master = null
		..()

	asText()
		return initialized ? "[progid]" : ..()

	proc
		input_text(var/text)
			if(!istype(src.master) || !text || !useracc)
				return 1

			if(src.needs_holder)
				if(!istype(holder))
					return 1

				if(!(holder in src.master.contents))
					return 1

			if(master.status & (NOPOWER|BROKEN|MAINT))
				return 1

			if(src.needs_holder && !src.holder.root)
				src.holder.root = new /datum/computer/folder
				src.holder.root.holder = src
				src.holder.root.name = "root"

			return 0

		initialize(var/initparams) //Called when a program starts running.
			if(src.initialized || !master)
				return 1

			src.initialized = 1
			return 0

		//Note: If you want your application to end intentionally, send the OS an "exit" signal.
		//Use the mainframe_prog_exit macro.  The program will not exit otherwise, even if nothing bothers to send it more input
		handle_quit()
			src.master?.unload_program(src)
			return

		process()
			if (!istype(master))
				return 1

			if (src.needs_holder)
				if (!istype(holder))
					return 1

				if(!(holder in src.master.contents))
					master.processing.Remove(src)
					return 1

				if(!src.holder.root)
					src.holder.root = new /datum/computer/folder
					src.holder.root.holder = src
					src.holder.root.name = "root"

			return 0

		parse_string(string, var/list/replaceList = null)
			var/list/sorted = list()
			sorted = command2list(string, " ", replaceList)
			if (!sorted.len) sorted.len++
			return sorted

		//Find a folder with a given name
		get_folder_name(string, var/datum/computer/folder/check_folder, var/datum/mainframe2_user_data/user)
			if(!string || !istype(check_folder))
				return null

			var/datum/computer/taken = null
			for(var/datum/computer/folder/F in check_folder.contents)
				if(ckey(string) == ckey(F.name) && (!user || check_read_permission(F, user)))
					taken = F
					break

			return taken

		//Find a file with a given name
		get_file_name(string, var/datum/computer/folder/check_folder, var/datum/mainframe2_user_data/user)
			if(!string || !istype(check_folder))
				return null

			var/datum/computer/taken = null
			for(var/datum/computer/file/F in check_folder.contents)
				if(ckey(string) == ckey(F.name) && (!user || check_read_permission(F, user)))
					taken = F
					break

			return taken

		//Just find any computer datum with this name, gosh
		get_computer_datum(string, var/datum/computer/folder/check_folder, var/datum/mainframe2_user_data/user)
			if(!string || !istype(check_folder))
				return null

			var/datum/computer/taken = null
			for(var/datum/computer/C in check_folder.contents)
				if(ckey(string) == ckey(C.name) && (!user || check_read_permission(C, user)))
					taken = C
					break

			return taken

		is_name_invalid(string) //Check if a filename is invalid somehow
			if(!string)
				return 1
			//ckeyEx because it allows for - and _ and we love those!!
			if(lowertext(ckeyEx(string)) != replacetext(lowertext(string), " ", null))
				return 1

			if(findtext(string, "/"))
				return 1


			return 0

		//Pass an output string to the user terminal, with optional render value.
		//Notes: The string is not immediately set to the user! It is instead passed by signal to the parent task of the program.
		//This allows for piping operations, etc.  It is the duty of the OS to actually tranmit the information to the terminal.
		message_user(var/msg, var/render, var/file)
			if (!useracc)
				return ESIG_NOTARGET

			if (parent_task)
				if (render)
					return signal_program(parent_task.progid, list("command"=DWAINE_COMMAND_MSG_TERM, "data" = msg, "term" = useracc.user_id, "render" = render), file )
				else
					return signal_program(parent_task.progid, list("command"=DWAINE_COMMAND_MSG_TERM, "data" = msg, "term" = useracc.user_id), file )

			return ESIG_GENERIC

		read_user_field(var/field)
			if (!useracc || (!istype(useracc.user_file) && !useracc.reload_user_file()))
				return null

			return useracc.user_file.fields[field]

		write_user_field(var/field, var/data)
			if (!useracc || !field || (!istype(useracc.user_file) && !useracc.reload_user_file()) || !useracc.user_file.fields)
				return 0

			useracc.user_file.fields[field] = data
			return 1

		signal_program(var/progid, var/list/data, var/datum/computer/file/file)
			if(!data || !master)
				return 1

			if(useracc?.user_file && ("id" in useracc.user_file.fields))
				data["user"] = useracc.user_file.fields["id"]

			return master.relay_progsignal(src, progid, data, file)

		receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
			return (!src.master || !(src in master.processing))


		unloaded()
			return

		check_read_permission(var/datum/computer/cdatum, var/datum/mainframe2_user_data/usdat)
			if (!usdat)
				return 0

			if (istype(cdatum, /datum/computer/folder/link) && cdatum:target)
				cdatum = cdatum:target

			if (!istype(cdatum) || !cdatum.metadata)
				return 0

			var/permissions = COMP_ALLACC
			if (isnum(cdatum.metadata["permission"]))
				permissions = cdatum.metadata["permission"]

			if (istype(usdat.user_file) || usdat.reload_user_file())
				if (!usdat.user_file.fields)
					usdat.user_file.fields = list()

				if (usdat.user_file.fields["group"] == 0) //Sysop usergroup
					return 1

				if (cdatum.metadata["owner"] && (usdat.user_file.fields["name"] == cdatum.metadata["owner"]) && (permissions & COMP_ROWNER))
					return 1

				if (cdatum.metadata["group"] && (usdat.user_file.fields["group"] == cdatum.metadata["group"]) && (permissions & COMP_RGROUP))
					return 1

			return (permissions & COMP_ROTHER)

		check_write_permission(var/datum/computer/cdatum, var/datum/mainframe2_user_data/usdat)
			if (!cdatum || !usdat)
				return 0

			var/permissions = COMP_ALLACC

			if (istype(cdatum, /datum/computer/folder/link) && cdatum:target)
				cdatum = cdatum:target

			if (!istype(cdatum) || !cdatum.metadata)
				return 0

			if (istype(cdatum.metadata, /list) && isnum(cdatum.metadata["permission"]))
				permissions = cdatum.metadata["permission"]

			if (istype(usdat.user_file) || usdat.reload_user_file())

				if (usdat.user_file.fields["group"] == 0) //Sysop usergroup can ~do anything~
					return 1

				if (cdatum.metadata["owner"] && (usdat.user_file.fields["name"] == cdatum.metadata["owner"]) && (permissions & COMP_WOWNER))
					return 1

				if (cdatum.metadata["group"] && (usdat.user_file.fields["group"] == cdatum.metadata["group"]) && (permissions & COMP_WGROUP))
					return 1

				return (permissions & COMP_WOTHER)

			return 0

		check_mode_permission(var/datum/computer/cdatum, var/datum/mainframe2_user_data/usdat)
			if (!cdatum || !usdat)
				return 0

			if (istype(cdatum, /datum/computer/folder/link) && cdatum:target)
				cdatum = cdatum:target

			if (!istype(cdatum) || !cdatum.metadata)
				return 0

			var/permissions = COMP_ALLACC
			if (istype(cdatum.metadata, /list) && isnum(cdatum.metadata["permission"]))
				permissions = cdatum.metadata["permission"]

			if (istype(usdat.user_file) || usdat.reload_user_file())

				if (usdat.user_file.fields["group"] == 0) //Sysop usergroup can ~do anything~
					return 1

				if (cdatum.metadata["owner"] && (usdat.user_file.fields["name"] == cdatum.metadata["owner"]) && (permissions & COMP_DOWNER && permissions & COMP_WOWNER) )
					return 1

				if (cdatum.metadata["group"] && (usdat.user_file.fields["group"] == cdatum.metadata["group"]) && (permissions & COMP_DGROUP && permissions & COMP_WGROUP) )
					return 1

				return ((permissions & COMP_DOTHER) && (permissions & COMP_WOTHER))

			return 0

//Command2list is a modified version of dd_text2list() designed to eat empty list entries generated by superfluous whitespace.
//It also can insert shell alias/variables if provided with a replacement value list.
#define QUOTE_SYMBOL "\""
#define QUOTE_SYMBOL_LENGTH 1
/proc/command2list(text, separator, list/replaceList, list/substitution_feedback_thing)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	var/list/textList = new()
	var/searchPosition = 1
	var/findPosition = 1
	var/buggyText


	//substitution_feedback_thing = list()	//debug
	while(1)
		text = html_decode(text) // makes it so this works again
		findPosition = findtext(text, separator, searchPosition, 0)
		var/quotePoint = findtext(text, QUOTE_SYMBOL, searchPosition, findPosition)
		if (quotePoint)
			text = copytext(text, 1, quotePoint) + copytext(text, quotePoint + QUOTE_SYMBOL_LENGTH, 0)
			var/quotePointEnd = findtext(text, QUOTE_SYMBOL, quotePoint, 0)
			buggyText = copytext(text, searchPosition, quotePointEnd)
			findPosition = quotePointEnd+QUOTE_SYMBOL_LENGTH
		else
			var/subStartPoint = findtext(text, "$(", searchPosition, findPosition)
			if (substitution_feedback_thing && subStartPoint)
				var/subEndPoint = findtext(text, ")", subStartPoint)
				substitution_feedback_thing[++substitution_feedback_thing.len] = copytext(text, subStartPoint+2, subEndPoint)

				text = copytext(text, 1, subStartPoint) + "_sub[substitution_feedback_thing.len]" + copytext(text, subEndPoint ? subEndPoint + 1 : 0)
				//boutput(world, "text changed to \"[text]\"")

				//boutput(world, "added: \[[substitution_feedback_thing[substitution_feedback_thing.len]]]")

				continue

			else
				buggyText = trim(copytext(text, searchPosition, findPosition))

		if(buggyText)

			if (replaceList && dd_hasprefix(buggyText, "$") && (copytext(buggyText,2) in replaceList))
				textList += "[replaceList[copytext(buggyText, 2)]]"
			else
				textList += "[buggyText]"
		if(!findPosition)
			//boutput(world, english_list(textList))
			return textList
		searchPosition = findPosition + separatorlength
		if(searchPosition > textlength)
			//boutput(world, english_list(textList))
			return textList
	return

#undef QUOTE_SYMBOL
#undef QUOTE_SYMBOL_LENGTH

