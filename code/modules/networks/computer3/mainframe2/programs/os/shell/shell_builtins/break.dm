/datum/dwaine_shell_builtin/_break
	name = "break"

/datum/dwaine_shell_builtin/_break/execute(list/command_list, list/piped_list)
	return DWAINE::ERR::SHELL::BUILTIN::BREAK
