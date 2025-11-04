/datum/computer/file/mainframe_program/utility/chown
	name = "chown"

/datum/computer/file/mainframe_program/utility/chown/initialize(initparams)
	if (..() || !src.useracc)
		mainframe_prog_exit
		return

	. = src.read_user_field("group")
	if ((. > src.metadata["group"]) && (. != 0))
		src.message_user("Error: Access denied.")
		mainframe_prog_exit
		return

	var/list/initlist = splittext(initparams, " ")
	if (length(initlist) < 2)
		src.message_user("Error: Must specify owner/group value(s) and target path.")
		mainframe_prog_exit
		return

	var/list/new_list = splittext(initlist[1], ":")
	if (!length(new_list) || (length(new_list) > 2))
		src.message_user(@"Error: Input values should be of form [owner]:[group]")
		mainframe_prog_exit
		return

	var/new_owner = copytext(ckeyEx(new_list[1]), 1, 16)
	var/new_group = null
	if (length(new_list) == 2)
		new_group = text2num_safe(new_list[2])
		if (isnull(new_group))
			src.message_user("Error: Invalid group ID.")
			mainframe_prog_exit
			return

	var/current = src.read_user_field("curpath")
	switch (src.signal_program(1, list("command" = DWAINE_COMMAND_FOWNER, "path" = ABSOLUTE_PATH(initlist[2], current), "owner" = new_owner, "group" = new_group)))
		if (ESIG_NOFILE, ESIG_NOTARGET)
			src.message_user("Error: Invalid target path.")

		if (ESIG_GENERIC)
			src.message_user("Error: Access denied.")

	mainframe_prog_exit
