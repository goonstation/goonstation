/datum/computer/file/mainframe_program/utility/rm
	name = "rm"
	/// Stored target filepath, for use with interactive mode.
	VAR_PRIVATE/tmp/target_path = null
	/// Whether `rm` should run in interactive mode and issue confirmation prompts.
	VAR_PRIVATE/tmp/opt_interactive = FALSE
	/// Whether `rm` should remove directories and their contents.
	VAR_PRIVATE/tmp/opt_recursive = FALSE
	/// Whether `rm` should report errors.
	VAR_PRIVATE/tmp/opt_silent = FALSE

/datum/computer/file/mainframe_program/utility/rm/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	src.opt_interactive = FALSE
	src.opt_recursive = FALSE
	src.opt_silent = FALSE

	if (!initparams)
		src.message_user("Error: No name or path specified.")
		mainframe_prog_exit
		return

	var/list/initlist = splittext(initparams, " ")
	if (length(initlist) && dd_hasprefix(initlist[1], "-"))
		var/options = copytext(initlist[1], 2)

		if (findtext(options, "f"))
			src.opt_silent = TRUE
		else if (findtext(options, "i"))
			src.opt_interactive = TRUE
		if (findtext(options, "r"))
			src.opt_recursive = TRUE

		initparams = jointext(initlist - initlist[1], "")

	var/current = src.read_user_field("curpath")
	initparams = ABSOLUTE_PATH(initparams, current)

	var/datum/computer/target = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = initparams))

	if (!istype(target))
		src.message_user("Error: Invalid path.")

	else if (istype(target, /datum/computer/folder) && !src.opt_recursive)
		src.message_user("Error: Cannot remove target (Is a directory).")

	else
		if (src.opt_interactive)
			src.target_path = initparams
			src.message_user("Remove target '[target.name]'?")
			return

		if (src.signal_program(1, list("command" = DWAINE_COMMAND_FKILL, "path" = initparams)) != ESIG_SUCCESS)
			src.message_user("Error: Cannot remove target.")

	mainframe_prog_exit

/datum/computer/file/mainframe_program/utility/rm/input_text(text)
	if(..() || !src.useracc || !src.target_path)
		mainframe_prog_exit
		return

	var/list/command_list = src.parse_string(text)
	var/command = lowertext(command_list[1])

	if ((command == "yes") || (command == "y"))
		var/datum/computer/target = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = src.target_path))
		if (!istype(target))
			src.message_user("Error: Unable to locate target.")

		else if (istype(target, /datum/computer/folder) && !src.opt_recursive)
			src.message_user("Error: Cannot remove target (Is a directory).")

		else if (src.signal_program(1, list("command" = DWAINE_COMMAND_FKILL, "path" = src.target_path)) != ESIG_SUCCESS)
			src.message_user("Error: Cannot remove target.")

	mainframe_prog_exit

/datum/computer/file/mainframe_program/utility/rm/message_user(msg, render, file)
	if (src.opt_silent)
		return

	. = ..()
