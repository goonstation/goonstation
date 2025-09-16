/datum/dwaine_shell_builtin/unset
	name = "unset"

/datum/dwaine_shell_builtin/unset/execute(list/command_list, list/piped_list)
	if (!length(command_list))
		src.shell.scriptvars = list()
		return BUILTIN_SUCCESS

	for (var/variable as anything in command_list)
		src.shell.scriptvars -= lowertext(ckeyEx(variable))

	return BUILTIN_SUCCESS
