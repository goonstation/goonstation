/datum/dwaine_shell_builtin/logout
	name = list("logout", "logoff")

/datum/dwaine_shell_builtin/logout/execute(list/command_list, list/piped_list)
	src.shell.message_user("Thank you for using DWAINE!", "clear")

	if (src.shell.scriptprocess)
		src.shell.signal_program(1, list("command" = DWAINE_COMMAND_TKILL, "target" = src.shell.scriptprocess))
		src.shell.scriptprocess = 0

	src.shell.signal_program(1, global.generic_exit_list)
	return BUILTIN_BREAK
