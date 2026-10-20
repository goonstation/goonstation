/datum/dwaine_shell_builtin/_sleep
	name = "sleep"

/datum/dwaine_shell_builtin/_sleep/execute(list/command_list, list/piped_list)
	if (!length(command_list))
		return DWAINE::ERR::SHELL::BUILTIN::SUCCESS

	var/delay = text2num_safe(command_list[1])
	if (!isnum(delay) || (delay < 0))
		return DWAINE::ERR::SHELL::BUILTIN::SUCCESS

	sleep(clamp(delay, 0, 30) SECONDS)
	return DWAINE::ERR::SHELL::BUILTIN::SUCCESS
