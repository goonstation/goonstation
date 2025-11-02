/datum/computer/file/mainframe_program/utility/cd
	name = "cd"

/datum/computer/file/mainframe_program/utility/cd/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	if (initparams)
		var/current = src.read_user_field("curpath")
		initparams = ABSOLUTE_PATH(initparams, current)
	else
		initparams = "/home/usr[src.read_user_field("name")]"

	var/datum/computer/folder/F = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = initparams))
	if (!istype(F))
		src.message_user("Error: Invalid path.")

	else
		src.write_user_field("curpath", src.trim_path(initparams))

	mainframe_prog_exit

/datum/computer/file/mainframe_program/utility/cd/proc/trim_path(filepath)
	var/list/separated_filepath = splittext(filepath, "/")
	var/list/file_list = list()

	for (var/file as anything in separated_filepath)
		switch (file)
			if ("..")
				var/path_length = length(file_list)
				if (!path_length)
					continue

				file_list.Cut(path_length)

			if (".")
				continue

			else
				file_list += file

	if (!length(file_list))
		return "/"

	var/path_length = length(file_list)
	if ((path_length > 2) && (file_list[path_length] == ""))
		file_list.Cut(path_length)

	return jointext(file_list, "/")
