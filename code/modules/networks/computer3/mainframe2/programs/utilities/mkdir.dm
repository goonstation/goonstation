/datum/computer/file/mainframe_program/utility/mkdir
	name = "mkdir"

/datum/computer/file/mainframe_program/utility/mkdir/initialize(initparams)
	if (..() || !src.useracc)
		mainframe_prog_exit
		return

	var/list/initlist = splittext(initparams, " ")
	if (!length(initlist))
		src.message_user("Error: No filepath(s) specified.")
		mainframe_prog_exit
		return

	var/create_full = FALSE
	if (initlist[1] == "-p")
		initlist -= initlist[1]
		create_full = TRUE

	initlist.len = min(initlist.len, 4)

	var/current = src.read_user_field("curpath")
	for (var/path as anything in initlist)
		path = ABSOLUTE_PATH(path, current)

		var/list/dir_path = splittext(path, "/")
		var/path_length = length(dir_path)
		var/dir_name = copytext(dir_path[path_length], 1, 16)
		dir_path.Cut(path_length)

		path = jointext(dir_path, "/") || "/"

		var/datum/computer/folder/new_folder = new /datum/computer/folder()
		new_folder.name = dir_name
		new_folder.metadata["owner"] = src.read_user_field("name")
		new_folder.metadata["permission"] = COMP_ALLACC & ~(COMP_WOTHER | COMP_DOTHER)
		if (src.signal_program(1, list("command" = DWAINE_COMMAND_FWRITE, "path" = path, "mkdir" = create_full), new_folder) != ESIG_SUCCESS)
			new_folder.dispose()

	mainframe_prog_exit
