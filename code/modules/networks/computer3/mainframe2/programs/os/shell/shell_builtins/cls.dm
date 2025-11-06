/datum/dwaine_shell_builtin/cls
	name = list("cls", "clear")

/datum/dwaine_shell_builtin/cls/execute(list/command_list, list/piped_list)
	src.shell.message_user("Screen cleared.", "clear")
	return BUILTIN_SUCCESS
