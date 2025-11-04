/datum/computer/file/mainframe_program/utility/cat
	name = "cat"

/datum/computer/file/mainframe_program/utility/cat/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	var/list/initlist = splittext(initparams, " ")
	if (!length(initlist))
		src.message_user("Error: No filepath(s) specified.")
		mainframe_prog_exit
		return

	var/message = ""
	var/current = src.read_user_field("curpath")
	for (var/path as anything in initlist)
		var/datum/computer/file/target = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = ABSOLUTE_PATH(path, current)))
		if (!istype(target))
			break

		var/to_add = target.asText()
		if (to_add)
			message += to_add

	if (message)
		src.message_user(copytext(message, 1, MAX_MESSAGE_LEN), "multiline")

	mainframe_prog_exit
