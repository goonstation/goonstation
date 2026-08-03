/datum/dwaine_shell_builtin/_else
	name = "else"

/datum/dwaine_shell_builtin/_else/execute(list/command_list, list/piped_list)
	if (src.shell.scriptstat & DWAINE::SHELL::SCRIPT::IF_TRUE)
		return DWAINE::ERR::SHELL::BUILTIN::CONTINUE

	return DWAINE::ERR::SHELL::BUILTIN::SUCCESS
