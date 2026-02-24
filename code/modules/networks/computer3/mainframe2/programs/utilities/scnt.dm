/datum/computer/file/mainframe_program/utility/scnt
	name = "scnt"

/datum/computer/file/mainframe_program/utility/scnt/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	if (initparams)
		var/list/initlist = splittext(initparams, " ")
		for (var/id as anything in initlist)
			id = ckey(id)
			if ((length(id) != 8) || !is_hex(id))
				src.message_user("Error: Invalid net ID format.")
				mainframe_prog_exit
				return

			src.master.reconnect_device(id)

		src.message_user("Now scanning for device(s).")
		mainframe_prog_exit
		return

	. = src.read_user_field("group")
	if ((. > src.metadata["group"]) && (. != 0))
		src.message_user("Error: Access denied.")
		mainframe_prog_exit
		return

	if (src.signal_program(1, list("command" = DWAINE_COMMAND_DSCAN)) == ESIG_SUCCESS)
		src.message_user("Now scanning for devices -- This may take a few seconds.")
	else
		src.message_user("Scan already in progress -- Please be patient.")

	mainframe_prog_exit
