/**
 *	Mainframe programs represent computer programs, and are responsible for carrying out an instruction or set of instructions
 *	specified by commands passed to them. Unlike real computer programs, mainframe programs are not in possession of any ingame
 *	representation of "source code" and are hardcoded. Most of DWAINE's functionality is provided by computer programs, which
 *	include the kernel, the shell, the drivers, and system utilities (ls, cd, etc...), among other programs.
 */
/datum/computer/file/mainframe_program
	name = "mainframe program"
	extension = "MPG"

	/// The mainframe computer that this program is bring run by.
	var/obj/machinery/networked/mainframe/master = null
	/// Whether this program can be executed by the kernel.
	var/executable = TRUE
	/// Whether this program requires a holder data disc.
	var/needs_holder = TRUE

	/// The parent task of this program. This corresponds to the program that initialised this program.
	var/tmp/datum/computer/file/mainframe_program/parent_task = null
	/// The program ID of this program. This corresponds to the position of this program in the mainframe's processing list.
	var/tmp/progid = 0
	/// The program ID of this program's parent task.
	var/tmp/parent_id = 0
	/// Whether this program has been initialised and is running.
	var/tmp/initialized = FALSE
	/// This program's current user.
	var/tmp/datum/mainframe2_user_data/useracc = null

/datum/computer/file/mainframe_program/New(obj/holding)
	. = ..()

	if (holding)
		src.holder = holding

		if (istype(src.holder.loc, /obj/machinery/networked/mainframe))
			src.master = src.holder.loc

/datum/computer/file/mainframe_program/disposing()
	if (src.master && (src in src.master.processing))
		src.master.processing[src] = null
		src.master = null

	. = ..()

/datum/computer/file/mainframe_program/asText()
	if (src.initialized)
		return "[src.progid]"

	. = ..()

/// Ensure that the program is configured correctly. Returns `TRUE` on success, `FALSE` on failure.
/datum/computer/file/mainframe_program/proc/ensure_program()
	if (!istype(src.master))
		return FALSE

	if (src.master.status & (NOPOWER | BROKEN | MAINT))
		return FALSE

	if (src.needs_holder)
		if (!(src.holder in src.master.contents))
			return FALSE

		if (!src.holder.root)
			src.holder.root = new /datum/computer/folder
			src.holder.root.holder = src
			src.holder.root.name = "root"

	return TRUE

/// Pass text to this program; this text is typically interpreted as a command.
/datum/computer/file/mainframe_program/proc/input_text(text)
	if (!src.useracc || !text || !src.ensure_program())
		return TRUE

	return FALSE

/// Initialise this program. Called when this program starts running.
/datum/computer/file/mainframe_program/proc/initialize(initparams)
	if (src.initialized || !src.master)
		return FALSE

	src.initialized = TRUE
	return FALSE

/// Handle program exiting. If a program should end intentionally, an exit system call should be sent to the OS through `mainframe_prog_exit`. The program will not exit otherwise, even if nothing bothers to send it more input.
/datum/computer/file/mainframe_program/proc/handle_quit()
	src.master?.unload_program(src)

/// Called by the mainframe processing loop, in sync with the machinery processing loop.
/datum/computer/file/mainframe_program/proc/process()
	if (!src.ensure_program())
		return TRUE

	return FALSE

/// Format a string into a command and substitute variable names with their values.
/datum/computer/file/mainframe_program/proc/parse_string(string, list/replace_list)
	var/list/sorted = global.command2list(string, " ", replace_list)
	sorted.len ||= 1

	return sorted

/// Find a folder with a given name.
/datum/computer/file/mainframe_program/proc/get_folder_name(string, datum/computer/folder/check_folder, datum/mainframe2_user_data/user)
	if (!string || !istype(check_folder))
		return

	string = ckey(string)
	for (var/datum/computer/folder/F in check_folder.contents)
		if (string != ckey(F.name))
			continue

		if (user && !src.check_read_permission(F, user))
			continue

		return F

/// Find a file with a given name.
/datum/computer/file/mainframe_program/proc/get_file_name(string, datum/computer/folder/check_folder, datum/mainframe2_user_data/user)
	if (!string || !istype(check_folder))
		return

	string = ckey(string)
	for (var/datum/computer/file/F in check_folder.contents)
		if (string != ckey(F.name))
			continue

		if (user && !src.check_read_permission(F, user))
			continue

		return F

/// Find any computer datum with a given name.
/datum/computer/file/mainframe_program/proc/get_computer_datum(string, datum/computer/folder/check_folder, datum/mainframe2_user_data/user)
	if (!string || !istype(check_folder))
		return null

	string = ckey(string)
	for (var/datum/computer/C as anything in check_folder.contents)
		if (string != ckey(C.name))
			continue

		if (user && !src.check_read_permission(C, user))
			continue

		return C

/// Check if a filename is invalid somehow.
/datum/computer/file/mainframe_program/proc/is_name_invalid(string)
	if (!string)
		return TRUE

	// `ckeyEx` allows for - and _ characters.
	if (lowertext(ckeyEx(string)) != replacetext(lowertext(string), " ", ""))
		return TRUE

	if (findtext(string, "/"))
		return TRUE

	return FALSE

/// Instruct the parent task to pass an output string to the user terminal, with optional render options. This allows for piping operations.
/datum/computer/file/mainframe_program/proc/message_user(msg, render, file)
	if (!src.useracc)
		return ESIG_NOTARGET

	if (src.parent_task)
		if (render)
			return src.signal_program(src.parent_task.progid, list("command" = DWAINE_COMMAND_MSG_TERM, "data" = msg, "term" = src.useracc.user_id, "render" = render), file)
		else
			return src.signal_program(src.parent_task.progid, list("command" = DWAINE_COMMAND_MSG_TERM, "data" = msg, "term" = src.useracc.user_id), file)

	return ESIG_GENERIC

/// Read a field from the current user's user file.
/datum/computer/file/mainframe_program/proc/read_user_field(field)
	if (!src.useracc)
		return

	if (!istype(src.useracc.user_file) && !src.useracc.reload_user_file())
		return

	return src.useracc.user_file.fields[field]

/// Read a value to a field from the current user's user file.
/datum/computer/file/mainframe_program/proc/write_user_field(field, data)
	if (!src.useracc || !field || !src.useracc.user_file.fields)
		return FALSE

	if (!istype(src.useracc.user_file) && !src.useracc.reload_user_file())
		return FALSE

	src.useracc.user_file.fields[field] = data
	return TRUE

/// Send a signal from this program to its mainframe computer.
/datum/computer/file/mainframe_program/proc/signal_program(progid, list/data, datum/computer/file/file)
	if (!src.master || !data)
		return TRUE

	if (src.useracc?.user_file && src.useracc.user_file.fields["id"])
		data["user"] = src.useracc.user_file.fields["id"]

	return src.master.relay_progsignal(src, progid, data, file)

/// Called when this program receives a signal.
/datum/computer/file/mainframe_program/proc/receive_progsignal(sendid, list/data, datum/computer/file/file)
	return (!src.master || !(src in src.master.processing))

/// Called when this program is unloaded.
/datum/computer/file/mainframe_program/proc/unloaded()
	return

/// Check that the specified user has the required permissions to read the content of the target file or folder.
/datum/computer/file/mainframe_program/proc/check_read_permission(datum/computer/target, datum/mainframe2_user_data/user)
	if (!user)
		return FALSE

	if (istype(target, /datum/computer/folder/link))
		var/datum/computer/folder/link/symlink = target
		if (symlink.target)
			target = symlink.target

	if (!istype(target) || !islist(target.metadata))
		return FALSE

	var/permissions = COMP_ALLACC
	if (isnum(target.metadata["permission"]))
		permissions = target.metadata["permission"]

	if (istype(user.user_file) || user.reload_user_file())
		user.user_file.fields ||= list()

		if (user.user_file.fields["group"] == 0)
			return TRUE

		if (target.metadata["owner"] && (user.user_file.fields["name"] == target.metadata["owner"]) && (permissions & COMP_ROWNER))
			return TRUE

		if (target.metadata["group"] && (user.user_file.fields["group"] == target.metadata["group"]) && (permissions & COMP_RGROUP))
			return TRUE

	return (permissions & COMP_ROTHER)

/// Check that the specified user has the required permissions to write to the target file or folder.
/datum/computer/file/mainframe_program/proc/check_write_permission(datum/computer/target, datum/mainframe2_user_data/user)
	if (!user)
		return FALSE

	if (istype(target, /datum/computer/folder/link))
		var/datum/computer/folder/link/symlink = target
		if (symlink.target)
			target = symlink.target

	if (!istype(target) || !islist(target.metadata))
		return FALSE

	var/permissions = COMP_ALLACC
	if (isnum(target.metadata["permission"]))
		permissions = target.metadata["permission"]

	if (istype(user.user_file) || user.reload_user_file())
		user.user_file.fields ||= list()

		if (user.user_file.fields["group"] == 0)
			return TRUE

		if (target.metadata["owner"] && (user.user_file.fields["name"] == target.metadata["owner"]) && (permissions & COMP_WOWNER))
			return TRUE

		if (target.metadata["group"] && (user.user_file.fields["group"] == target.metadata["group"]) && (permissions & COMP_WGROUP))
			return TRUE

		return (permissions & COMP_WOTHER)

	return FALSE

/// Check that the specified user has the required permissions to alter the metadata and permission level of the target file or folder.
/datum/computer/file/mainframe_program/proc/check_mode_permission(datum/computer/target, datum/mainframe2_user_data/user)
	if (!user)
		return FALSE

	if (istype(target, /datum/computer/folder/link))
		var/datum/computer/folder/link/symlink = target
		if (symlink.target)
			target = symlink.target

	if (!istype(target) || !islist(target.metadata))
		return FALSE

	var/permissions = COMP_ALLACC
	if (isnum(target.metadata["permission"]))
		permissions = target.metadata["permission"]

	if (istype(user.user_file) || user.reload_user_file())
		user.user_file.fields ||= list()

		if (user.user_file.fields["group"] == 0)
			return TRUE

		if (target.metadata["owner"] && (user.user_file.fields["name"] == target.metadata["owner"]) && (permissions & COMP_DOWNER) && (permissions & COMP_WOWNER))
			return TRUE

		if (target.metadata["group"] && (user.user_file.fields["group"] == target.metadata["group"]) && (permissions & COMP_DGROUP) && (permissions & COMP_WGROUP))
			return TRUE

		return ((permissions & COMP_DOTHER) && (permissions & COMP_WOTHER))

	return FALSE









/datum/computer/file/mainframe_program/os
	name = "Base OS"
	size = 16
	extension = "SYS"
	executable = FALSE
	var/tmp/setup_string = null

/// Called by the mainframe when a new terminal connection is made so as to alert the OS
/datum/computer/file/mainframe_program/os/proc/new_connection(datum/terminal_connection/conn)
	return

/// Called by the mainframe upon termination of a connection, conn is deleted afterwards
/datum/computer/file/mainframe_program/os/proc/closed_connection(datum/terminal_connection/conn)
	return

/// Data sent to the program by a connected terminal. If a file is passed, note that the file will be treated as temporary and deleted after the function returns.
/datum/computer/file/mainframe_program/os/proc/term_input(data, termid, datum/computer/file/file)
	if (!data || !termid || !src.ensure_program())
		return TRUE

	return FALSE

/// Called when a reply ping is received by the mainframe.
/datum/computer/file/mainframe_program/os/proc/ping_reply(senderid, sendertype)
	return (!src.master || !senderid || !sendertype)

/// Pass a message to the connected terminal.
/datum/computer/file/mainframe_program/os/proc/message_term(message, termid, render)
	if (!message || !termid || !src.ensure_program())
		return TRUE

	SPAWN(1 DECI SECOND)
		src.master.post_status(termid, "command", "term_message", "data", message, "render", render)

	return FALSE

/// Pass a file to the connected terminal.
/datum/computer/file/mainframe_program/os/proc/file_term(datum/computer/file/file, termid, exdata)
	if (!istype(file) || !termid || !src.ensure_program())
		return TRUE

	SPAWN(1 DECI SECOND)
		src.master.post_file(termid, "data", exdata, file)

	return FALSE

/**
 *	Parse the provided filesystem for a folder located at a specified filepath.
 *	- `string`: The filepath to parse.
 *		Special prefixes:
 *		- `/`: Start the search at the origin point.
 *		- `.`: Start the search at the current folder.
 *		- `..`: Start the search at the parent folder.
 *	- `origin`: The root folder.
 *	- `create_if_missing`: Whether intermediary folders in the path should be created if not present.
 *	- `user`: If a user is specified, all files and folders are filtered by the access permissions of the user.
 */
/datum/computer/file/mainframe_program/os/proc/parse_directory(string, datum/computer/folder/origin, create_if_missing, datum/mainframe2_user_data/user)
	if (!string)
		return

	var/datum/computer/folder/current_folder = origin
	origin ||= src.holder.root

	if (dd_hasprefix(string , "/"))
		if (string == "/")
			return origin

		current_folder = origin
		string = copytext(string, 2)

	var/list/separated_filepath = splittext(string, "/")
	var/path_length = length(separated_filepath)
	if (path_length && !separated_filepath[path_length])
		separated_filepath.len--

	while (current_folder)
		// Return the current folder if the end of the filepath has been reached.
		if (!length(separated_filepath))
			return current_folder

		switch (separated_filepath[1])
			// Navigate to the parent directory.
			if ("..")
				if (current_folder == origin)
					return

				current_folder = current_folder.holding_folder
				separated_filepath.Cut(1, 2)
				continue

			// Remain at the current directory.
			if (".")
				separated_filepath.Cut(1, 2)
				continue

			// Return the current folder if the end of the filepath has been reached.
			else
				if (!separated_filepath[1] && !create_if_missing)
					return current_folder

		var/folder_found = FALSE
		var/folder_name = ckey(separated_filepath[1])
		for (var/datum/computer/folder/F in current_folder.contents)
			if (folder_name != ckey(F.name))
				continue

			if (user && !src.check_read_permission(F, user))
				continue

			separated_filepath.Cut(1, 2)
			current_folder = F
			folder_found = TRUE
			break

		if (!folder_found)
			if (!create_if_missing)
				return

			var/datum/computer/folder/F = new /datum/computer/folder()
			F.name = separated_filepath[1]

			if (src.is_name_invalid(F.name))
				F.dispose()
				return

			var/datum/computer/folder/new_folder = current_folder.add_file(F)
			if (!new_folder)
				if (F)
					F.dispose()
					return

			else if (istype(new_folder))
				F = new_folder

			separated_filepath.Cut(1, 2)
			current_folder = F

/**
 *	Parse the provided filesystem for a file located at a specified filepath.
 *	- `string`: The filepath to parse.
 *		Special prefixes:
 *		- `/`: Start the search at the origin point.
 *		- `.`: Start the search at the current folder.
 *		- `..`: Start the search at the parent folder.
 *	- `origin`: The root folder.
 *	- `create_if_missing`: Whether intermediary folders in the path should be created if not present.
 *	- `user`: If a user is specified, all files and folders are filtered by the access permissions of the user.
 */
/datum/computer/file/mainframe_program/os/proc/parse_file_directory(string, datum/computer/folder/origin, create_if_missing, datum/mainframe2_user_data/user)
	if (!string)
		return

	var/datum/computer/folder/current_folder = origin
	origin ||= src.holder.root

	if (dd_hasprefix(string , "/"))
		current_folder = origin
		string = copytext(string, 2)

	var/list/separated_filepath = splittext(string, "/")
	var/path_length = length(separated_filepath)
	var/file_name = separated_filepath[path_length]
	if (!file_name)
		return

	separated_filepath.Cut(path_length)

	while (current_folder)
		if (!length(separated_filepath))
			var/datum/computer/file/check = src.get_file_name(file_name, current_folder, user)
			if (istype(check))
				return check
			else
				return

		switch (separated_filepath[1])
			// Navigate to the parent directory.
			if ("..")
				if (current_folder == origin)
					return

				current_folder = current_folder.holding_folder
				separated_filepath.Cut(1, 2)
				continue

			// Remain at the current directory.
			if (".")
				separated_filepath.Cut(1, 2)
				continue

		var/folder_found = FALSE
		var/folder_name = ckey(separated_filepath[1])
		for (var/datum/computer/folder/F in current_folder.contents)
			if (folder_name != ckey(F.name))
				continue

			if (user && !src.check_read_permission(F, user))
				continue

			separated_filepath.Cut(1, 2)
			current_folder = F
			folder_found = TRUE
			break

		if (!folder_found)
			if (!create_if_missing)
				return null

			var/datum/computer/folder/F = new /datum/computer/folder()
			F.name = separated_filepath[1]

			if (src.is_name_invalid(F.name) || !current_folder.add_file(F))
				F.dispose()
				return

			separated_filepath.Cut(1, 2)
			current_folder = F

/**
 *	Parse the provided filesystem for a folder or file located at a specified filepath.
 *	- `string`: The filepath to parse.
 *		Special prefixes:
 *		- `/`: Start the search at the origin point.
 *		- `.`: Start the search at the current folder.
 *		- `..`: Start the search at the parent folder.
 *	- `origin`: The root folder.
 *	- `create_if_missing`: Whether intermediary folders in the path should be created if not present.
 *	- `user`: If a user is specified, all files and folders are filtered by the access permissions of the user.
 */
/datum/computer/file/mainframe_program/os/proc/parse_datum_directory(string, datum/computer/folder/origin, create_if_missing, datum/mainframe2_user_data/user)
	if (!string)
		return

	var/datum/computer/folder/current_folder = origin
	origin ||= src.holder.root

	if (dd_hasprefix(string , "/"))
		if (string == "/")
			return origin

		current_folder = origin
		string = copytext(string, 2)

	var/list/separated_filepath = splittext(string, "/")
	var/path_length = length(separated_filepath)

	var/datum_name = separated_filepath[path_length]
	while (!datum_name && --path_length)
		datum_name = separated_filepath[path_length]

	separated_filepath.Cut(path_length)

	while (current_folder)
		if (!length(separated_filepath))
			switch (datum_name)
				if ("..")
					if (current_folder == origin)
						return

					return current_folder.holding_folder

				if (".")
					return current_folder

			var/datum/computer/check = src.get_computer_datum(datum_name, current_folder, user)
			if (istype(check))
				return check
			else
				return

		switch (separated_filepath[1])
			// Navigate to the parent directory.
			if ("..")
				current_folder = current_folder.holding_folder
				separated_filepath.Cut(1, 2)
				continue

			// Remain at the current directory.
			if (".")
				separated_filepath.Cut(1, 2)
				continue

		var/folder_found = FALSE
		var/folder_name = ckey(separated_filepath[1])
		for (var/datum/computer/folder/F in current_folder.contents)
			if (folder_name != ckey(F.name))
				continue

			if (user && !src.check_read_permission(F, user))
				continue

			separated_filepath.Cut(1, 2)
			current_folder = F
			folder_found = TRUE
			break

		if (!folder_found)
			if (!create_if_missing)
				return

			var/datum/computer/folder/F = new /datum/computer/folder()
			F.name = separated_filepath[1]

			if (src.is_name_invalid(F.name) || !current_folder.add_file(F))
				F.dispose()
				return

			separated_filepath.Cut(1, 2)
			current_folder = F





#define QUOTE_SYMBOL "\""
#define QUOTE_SYMBOL_LENGTH 1
/// Command2list is a modified version of dd_text2list() designed to eat empty list entries generated by superfluous whitespace.
/// It also can insert shell alias/variables if provided with a replacement value list.
/proc/command2list(text, separator, list/replaceList, list/substitution_feedback_thing)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	var/list/textList = new()
	var/searchPosition = 1
	var/findPosition = 1
	var/buggyText

	while (1)
		text = strip_html_tags(html_decode(text))	// Strip HTML.
		findPosition = findtext(text, separator, searchPosition, 0)	// Seach for the next instance of a separator.

		var/quotePoint = findtext(text, QUOTE_SYMBOL, searchPosition, findPosition)	// Search for the next instance of a quote mark before the separator.
		if (quotePoint)
			text = copytext(text, 1, quotePoint) + copytext(text, quotePoint + QUOTE_SYMBOL_LENGTH, 0)	// Remove the quote mark.
			var/quotePointEnd = findtext(text, QUOTE_SYMBOL, quotePoint, 0)	// Find the closing quote mark position.
			buggyText = copytext(text, searchPosition, quotePointEnd)	// Copy the text from the pos to the last quote mark to the buggy text.
			findPosition = quotePointEnd + QUOTE_SYMBOL_LENGTH	// Update findpos to the end of the quote.

		else
			var/subStartPoint = findtext(text, "$(", searchPosition, findPosition)	// Search for the first instance of $( before the separator.
			if (substitution_feedback_thing && subStartPoint)
				var/subEndPoint = findtext(text, ")", subStartPoint)	// Find the closing ) position.
				substitution_feedback_thing += copytext(text, subStartPoint+2, subEndPoint)	// Copy the contents of $(...) to the substitution list.

				text = copytext(text, 1, subStartPoint) + "_sub[substitution_feedback_thing.len]" + copytext(text, subEndPoint ? subEndPoint + 1 : 0)	// Replace the $(...) with _sub1, _sub2, etc.
				continue

			else
				buggyText = trimtext(copytext(text, searchPosition, findPosition))	// Copy the text from the pos to the separator to the buggy text.

		if (buggyText)
			if (replaceList && dd_hasprefix(buggyText, "$") && (copytext(buggyText,2) in replaceList))
				textList += "[replaceList[copytext(buggyText, 2)]]"	// If the text starts with $ and is in the replacelist, replace it.
			else
				textList += "[buggyText]"	// Otherwise, just add the word to the list.

		if (!findPosition)
			return textList

		searchPosition = findPosition + separatorlength	// Move to the next character after the separator in the list.

		if (searchPosition > textlength)
			return textList

#undef QUOTE_SYMBOL
#undef QUOTE_SYMBOL_LENGTH

