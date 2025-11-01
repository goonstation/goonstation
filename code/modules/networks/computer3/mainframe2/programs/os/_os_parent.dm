/**
 *	Operating system mainframe programs are the very first programs to be loaded by the network mainframe. They instruct the
 *	mainframe on how to handle connections, disconnections, pings, and messages. Operating systems also handle filesystem
 *	navigation for mainframe programs.
 */
/datum/computer/file/mainframe_program/os
	name = "Base OS"
	size = 16
	extension = "SYS"
	executable = FALSE
	var/tmp/setup_string = null

/// Called by the mainframe when a new terminal connection is made so as to alert the OS.
/datum/computer/file/mainframe_program/os/proc/new_connection(datum/terminal_connection/conn)
	return

/// Called by the mainframe upon termination of a connection, conn is deleted afterwards.
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
