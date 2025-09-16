/datum/computer/file/mainframe_program/utility/mv
	name = "mv"

/datum/computer/file/mainframe_program/utility/mv/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	var/list/initlist = splittext(initparams, " ")
	if (length(initlist) < 2)
		src.message_user("Error: Filepaths of target and destination must be specified.")
		mainframe_prog_exit
		return

	var/current = src.read_user_field("curpath")
	initlist[1] = ABSOLUTE_PATH(initlist[1], current)
	initlist[2] = ABSOLUTE_PATH(initlist[2], current)

	var/datum/computer/file/target = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = initlist[1]))
	if (!istype(target))
		src.message_user("Error: Invalid target path.")
		mainframe_prog_exit
		return

	var/copy_name = null
	var/dest_check = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = initlist[2]))
	if (dest_check != ESIG_NOFILE)
		if (istype(dest_check, /datum/computer/folder) && !src.get_computer_datum(target.name, dest_check))
			copy_name = target.name

		else
			src.message_user("Error: Invalid destination path (Path already taken?).")
			mainframe_prog_exit
			return

	var/list/destination_path = splittext(initlist[2], "/")
	if (!copy_name)
		var/path_length = length(destination_path)
		copy_name = copytext(destination_path[path_length], 1, 16)
		destination_path.Cut(path_length)

	initlist[2] = jointext(destination_path, "/") || "/"

	var/datum/computer/file/copy = target.copy_file()
	copy.name = copy_name
	copy.metadata["owner"] = src.read_user_field("name")
	copy.metadata["permission"] = COMP_ALLACC
	if (src.signal_program(1, list("command" = DWAINE_COMMAND_FWRITE, "path" = initlist[2]), copy) != ESIG_SUCCESS)
		copy.dispose()
		src.message_user("Error: Could not move file.")
	else
		src.signal_program(1, list("command" = DWAINE_COMMAND_FKILL, "path" = initlist[1]))

	mainframe_prog_exit
