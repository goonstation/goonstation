/datum/dwaine_shell_builtin/talk
	name = "talk"

/datum/dwaine_shell_builtin/talk/execute(list/command_list, list/piped_list)
	if (src.shell.pipetemp && istype(command_list))
		command_list += splittext(src.shell.pipetemp, " ")

	if (length(command_list) < 2)
		src.shell.message_user("Error: Insufficient arguments for Talk (Requires Target ID and Message).")
		return BUILTIN_BREAK

	var/target_user = lowertext(command_list[1])
	command_list.Cut(1, 2)
	switch (src.shell.signal_program(1, list("command" = DWAINE_COMMAND_UMSG, "term" = target_user, data = jointext(command_list, " "))))
		if (ESIG_SUCCESS)
			return BUILTIN_SUCCESS

		if (ESIG_NOTARGET)
			src.shell.message_user("Error: Invalid Target ID.")
			return BUILTIN_BREAK

		if (ESIG_IOERR)
			if (src.shell.piping)
				src.shell.pipetemp = "Error: Message refused by Target."
			else
				src.shell.message_user("Error: Message refused by Target.")

			return BUILTIN_SUCCESS

		else
			src.shell.message_user("Error: Unexpected response from kernel.")
			return BUILTIN_BREAK
