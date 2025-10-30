/datum/computer/file/mainframe_program/utility/ln
	name = "ln"

/datum/computer/file/mainframe_program/utility/ln/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	var/list/initlist = splittext(initparams, " ")
	if (length(initlist) < 2)
		src.message_user("Error: Must specify target and link paths.")
		mainframe_prog_exit
		return

	var/current = src.read_user_field("curpath")
	initlist[1] = ABSOLUTE_PATH(initlist[1], current)
	initlist[2] = ABSOLUTE_PATH(initlist[2], current)

	var/datum/computer/folder/target_folder = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = initlist[1]))
	if (!istype(target_folder))
		src.message_user("Error: Invalid target path.")
		mainframe_prog_exit
		return

	var/link_check = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = initlist[2]))
	if (link_check != ESIG_NOFILE)
		src.message_user("Error: Invalid link path (Path already taken?).")
		mainframe_prog_exit
		return

	var/list/link_path = splittext(initlist[2], "/")
	var/path_length = length(link_path)
	var/link_name = copytext(link_path[path_length], 1, 16)
	link_path.Cut(path_length)

	initlist[2] = jointext(link_path, "/") || "/"

	var/datum/computer/folder/link/symlink = new /datum/computer/folder/link(target_folder)
	symlink.name = link_name
	symlink.metadata["owner"] = src.read_user_field("name")
	symlink.metadata["permission"] = COMP_ALLACC & ~(COMP_WOTHER | COMP_DOTHER)
	if (src.signal_program(1, list("command" = DWAINE_COMMAND_FWRITE, "path" = initlist[2]), symlink) != ESIG_SUCCESS)
		symlink.dispose()
		src.message_user("Error: Could not create link.")

	mainframe_prog_exit
