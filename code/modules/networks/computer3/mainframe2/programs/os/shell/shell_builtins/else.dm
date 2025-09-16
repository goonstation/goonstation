/datum/dwaine_shell_builtin/_else
	name = "else"

/datum/dwaine_shell_builtin/_else/execute(list/command_list, list/piped_list)
	if (src.shell.scriptstat & SCRIPT_IF_TRUE)
		return BUILTIN_CONTINUE

	return BUILTIN_SUCCESS
