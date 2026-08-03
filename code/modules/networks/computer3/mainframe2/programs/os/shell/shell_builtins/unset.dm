/datum/dwaine_shell_builtin/unset
	name = "unset"

/datum/dwaine_shell_builtin/unset/execute(list/command_list, list/piped_list)
	if (!length(command_list))
		src.shell.scriptvars = list()
		return DWAINE::ERR::SHELL::BUILTIN::SUCCESS

	for (var/variable as anything in command_list)
		src.shell.scriptvars -= lowertext(ckeyEx(variable))

	return DWAINE::ERR::SHELL::BUILTIN::SUCCESS
