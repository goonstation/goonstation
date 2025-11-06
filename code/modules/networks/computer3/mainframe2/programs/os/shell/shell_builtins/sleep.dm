/datum/dwaine_shell_builtin/_sleep
	name = "sleep"

/datum/dwaine_shell_builtin/_sleep/execute(list/command_list, list/piped_list)
	if (!length(command_list))
		return BUILTIN_SUCCESS

	var/delay = text2num_safe(command_list[1])
	if (!isnum(delay) || (delay < 0))
		return BUILTIN_SUCCESS

	sleep(clamp(delay, 0, 30) SECONDS)
	return BUILTIN_SUCCESS
