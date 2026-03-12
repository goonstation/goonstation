/datum/computer/file/mainframe_program/utility/tar
	name = "tar"
	size = 3
	/// The response from `getopt`.
	VAR_PRIVATE/tmp/opt_data = null
	/// Whether `tar` should create a new archive. Mutually exclusive with `opt_list` and `opt_extract`.
	VAR_PRIVATE/tmp/opt_create = null
	/// The filepath of the archive to be created, read, or extracted. Mutually exclusive with `opt_temporary`.
	VAR_PRIVATE/tmp/opt_file = null
	/// When extracting from an archive, whether `tar` should skip over already existing filepaths or overwrite them with archive contents.
	VAR_PRIVATE/tmp/opt_skip = null
	/// Whether `tar` should list the contents of an archive. Mutually exclusive with `opt_create` and `opt_extract`.
	VAR_PRIVATE/tmp/opt_list = null
	/// Whether `tar` should suppress error and warning messages. Mutually exclusive with `opt_verbose`.
	VAR_PRIVATE/tmp/opt_quiet = null
	/// When creating a new archive, whether `tar` should create a temporary file in the `/tmp` directory. Mutually exclusive with `opt_file`.
	VAR_PRIVATE/tmp/opt_temporary = null
	/// Whether `tar` should list every filepath as it is archived or extracted. Mutually exclusive with `opt_quiet`.
	VAR_PRIVATE/tmp/opt_verbose = null
	/// Whether `tar` should extract the contents of an existing archive. Mutually exclusive with `opt_create` and `opt_list`.
	VAR_PRIVATE/tmp/opt_extract = null

/datum/computer/file/mainframe_program/utility/tar/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	if (!initparams)
		src.message_user("tar: Expected arguments.")
		mainframe_prog_exit
		return

	src.opt_data = null
	if (src.signal_program(1, list("command" = DWAINE_COMMAND_TSPAWN, "passusr" = TRUE, "path" = "/bin/getopt", "args" = "cf:klqtvx [initparams]")) == ESIG_NOTARGET)
		src.message_user("getopt: command not found.")
		mainframe_prog_exit
		return

	if (!src.opt_data)
		src.message_user("tar: No response from getopt.")
		mainframe_prog_exit
		return

	if (copytext(src.opt_data, 1, 7) == "getopt")
		src.message_user(src.opt_data)
		mainframe_prog_exit
		return

	var/list/arguments = global.optparse(src.opt_data)
	if (!arguments)
		src.message_user("tar: Error parsing options: [src.opt_data]")
		mainframe_prog_exit
		return

	var/list/options = arguments[1]
	var/list/unaffected = arguments[2]

	src.opt_create = options["c"]
	src.opt_file = options["f"]
	src.opt_skip = options["k"]
	src.opt_list = options["l"]
	src.opt_quiet = options["q"]
	src.opt_temporary = options["t"]
	src.opt_verbose = options["v"]
	src.opt_extract = options["x"]

	if (!src.opt_file && (!src.opt_create || !src.opt_temporary))
		src.usage()
		mainframe_prog_exit
		return

	if (src.opt_temporary && src.opt_file)
		src.message_user("tar: Cannot create both temporary and targeted file.")
		mainframe_prog_exit
		return

	if (src.opt_quiet && src.opt_verbose)
		src.message_user("tar: Cannot run in quiet verbose mode.")
		mainframe_prog_exit
		return

	if ((!!src.opt_create + !!src.opt_extract + !!src.opt_list) != 1)
		src.usage()
		mainframe_prog_exit
		return

	var/current = src.read_user_field("curpath")
	var/archive_path = null
	if (src.opt_file)
		archive_path = ABSOLUTE_PATH(src.opt_file, current)
	else
		archive_path = "/tmp/[src.temp_file_name()]"

	// List the contents of an archive file.
	if (src.opt_list)
		var/datum/computer/file/archive/archive = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = archive_path))
		if (!istype(archive))
			src.message_user("tar: Cannot locate archive [src.opt_file]")
			mainframe_prog_exit
			return

		for (var/datum/computer/C as anything in archive.contained_files)
			src.recursive_list(C, "")

	// Extract the contents of an archive file.
	else if (src.opt_extract)
		var/datum/computer/file/archive/archive = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = archive_path))
		if (!istype(archive))
			src.message_user("tar: Cannot locate archive [src.opt_file]")
			mainframe_prog_exit
			return

		var/target_path = null
		if (length(unaffected))
			target_path = ABSOLUTE_PATH(unaffected[1], current)
		else
			target_path = current

		if (!istype(src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = target_path)), /datum/computer/folder))
			src.message_user("tar: cannot read target directory [target_path]")
			mainframe_prog_exit
			return

		if (!dd_hassuffix(target_path, "/"))
			target_path += "/"

		for (var/datum/computer/C as anything in archive.contained_files)
			src.recursive_extract(C, target_path, "")

	// Create an archive file.
	else if (src.opt_create)
		if (!length(unaffected))
			src.message_user("tar: No files to add to archive.")
			mainframe_prog_exit
			return

		var/datum/computer/file/archive/archive = new()
		for (var/path as anything in unaffected)
			var/datum/computer/C = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = ABSOLUTE_PATH(path, current)))
			if (!istype(C))
				src.message_user("tar: File [path] does not exist.")
				mainframe_prog_exit
				return

			var/datum/computer/copy = src.deep_copy(C)
			if (!istype(copy))
				src.message_user("tar: Failed to replicate [path].")
				mainframe_prog_exit
				return

			archive.add_file(copy)

		var/list/separated_filepath = splittext(archive_path, "/")
		var/path_length = length(separated_filepath)
		archive.name = separated_filepath[path_length]
		separated_filepath.Cut(path_length)

		var/new_path = jointext(separated_filepath, "/") || "/"

		switch (src.signal_program(1, list("command" = DWAINE_COMMAND_FWRITE, "path" = new_path, "mkdir" = TRUE, "replace" = TRUE), archive))
			if (ESIG_NOWRITE)
				src.message_user("tar: Cannot write destination [src.opt_file]")
			if (ESIG_NOTARGET)
				src.message_user("tar: Error creating path to archive.")
			if (ESIG_GENERIC)
				src.message_user("tar: Error while creating archive.")

		if (src.opt_temporary)
			src.message_reply_and_user(archive_path)

	mainframe_prog_exit

/datum/computer/file/mainframe_program/utility/tar/receive_progsignal(sendid, list/data, datum/computer/file/file)
	if (..())
		return ESIG_GENERIC

	switch (data["command"])
		if (DWAINE_COMMAND_REPLY)
			if (data["sender_tag"] == "getopt")
				src.opt_data = data["data"]
				return ESIG_USR4
			else
				return ESIG_GENERIC

		if (DWAINE_COMMAND_MSG_TERM)
			src.message_user(data["data"])

		else
			return ESIG_GENERIC

	return ESIG_SUCCESS

/datum/computer/file/mainframe_program/utility/tar/message_user(msg, render, file)
	if (src.opt_quiet)
		return

	. = ..()

/datum/computer/file/mainframe_program/utility/tar/proc/usage()
	src.message_user("Usage:")
	src.message_user("[name] -x \[-kqv\] -f ARCHIVE \[PATH\]")
	src.message_user("[name] -c \[-v\] (-t|-f ARCHIVE) FILE ...")
	src.message_user("[name] -l -f ARCHIVE")

/datum/computer/file/mainframe_program/utility/tar/proc/message_reply_and_user(message)
	var/list/data = list("command" = DWAINE_COMMAND_REPLY, "data" = message, "sender_tag" = "tar")
	if (src.useracc)
		data["term"] = src.useracc.user_id

	if (src.signal_program(src.parent_task.progid, data) != ESIG_USR4)
		src.message_user(message)

/datum/computer/file/mainframe_program/utility/tar/proc/temp_file_name()
	. = "tmp"
	for (var/i in 1 to 12)
		. += "[num2hex(rand(0, 15), 1)]"

/datum/computer/file/mainframe_program/utility/tar/proc/recursive_list(datum/computer/target, current_path = "", depth = 0)
	if (depth >= 8)
		src.message_user("tar: Stack overflow.")
		return

	src.message_reply_and_user("[current_path][target.name]")

	if (!istype(target, /datum/computer/folder))
		return

	var/datum/computer/folder/folder = target
	var/folder_path = "[current_path][folder.name]/"
	for (var/datum/computer/C as anything in folder.contents)
		src.recursive_list(C, folder_path, depth + 1)

/datum/computer/file/mainframe_program/utility/tar/proc/recursive_extract(datum/computer/to_extract, target_path, current_path = "", depth = 0)
	if (depth >= 8)
		src.message_user("tar: Stack overflow.")
		return

	var/datum/computer/T = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = "[target_path][to_extract.name]"))
	if (src.opt_verbose)
		src.message_reply_and_user("[current_path][to_extract.name]")

	if (istype(to_extract, /datum/computer/folder))
		if (!istype(T))
			if (src.signal_program(1, list("command" = DWAINE_COMMAND_TSPAWN, "passusr" = TRUE, "path" = "/bin/mkdir", "args" = "[target_path][to_extract.name]")) == ESIG_NOTARGET)
				src.message_user("mkdir: command not found.")

			if (!istype(src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = "[target_path][to_extract.name]")), /datum/computer/folder))
				src.message_user("tar: Failed to create directory [to_extract.name]")

			var/datum/computer/folder/folder = to_extract
			for (var/datum/computer/C as anything in folder.contents)
				src.recursive_extract(C, "[target_path][to_extract.name]/", "[current_path][to_extract.name]/", depth + 1)

		else if (src.opt_skip)
			src.message_user("tar: [target_path][to_extract.name] already exists, skipping.")
		else
			src.message_user("tar: [target_path][to_extract.name] already exists, cannot overwrite folder - skipping.")

	else if (istype(to_extract, /datum/computer/file))
		if (!istype(T) || !src.opt_skip)
			var/outcome = src.signal_program(1, list("command" = DWAINE_COMMAND_FWRITE, "path" = "[target_path]", "mkdir" = TRUE, "replace" = TRUE), to_extract)
			switch (outcome)
				if (ESIG_NOWRITE)
					src.message_user("tar: [target_path][to_extract.name]: permission denied.")
				if (ESIG_GENERIC)
					src.message_user("tar: Error extracting [target_path][to_extract.name]")
				if (ESIG_NOTARGET)
					src.message_user("tar: Bad path: [target_path] for file [to_extract.name]")

		else
			src.message_user("[target_path][to_extract.name] already exists, skipping")

	else
		src.message_user("tar: Unknown data type: [to_extract.name]")

/datum/computer/file/mainframe_program/utility/tar/proc/deep_copy(datum/computer/to_copy, current_path = "", depth = 0)
	if (depth >= 8)
		src.message_user("tar: Stack overflow.")
		return

	if (istype(to_copy, /datum/computer/file/archive))
		src.message_user("tar: Cannot handle file [current_path][to_copy]")
		return

	if (istype(to_copy, /datum/computer/folder))
		var/datum/computer/folder/folder_to_copy = to_copy
		var/datum/computer/folder/folder_copy = new()

		folder_copy.name = folder_to_copy.name
		for (var/datum/computer/C as anything in folder_to_copy.contents)
			var/datum/computer/copy = src.deep_copy(C, "[current_path][to_copy.name]/", depth + 1)
			if (istype(copy))
				folder_copy.contents += copy

		return folder_copy

	else if (istype(to_copy, /datum/computer/file))
		var/datum/computer/file/file_to_copy = to_copy
		if (src.opt_verbose)
			src.message_reply_and_user("[current_path][to_copy.name]")

		return file_to_copy.copy_file()

	else
		src.message_user("tar: Unknown data type: [to_copy.name]")
