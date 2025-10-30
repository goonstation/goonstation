/datum/dwaine_shell_builtin/who
	name = "who"

/datum/dwaine_shell_builtin/who/execute(list/command_list, list/piped_list)
	var/whotext = null
	var/list/user_list = src.shell.signal_program(1, list("command" = DWAINE_COMMAND_ULIST))

	if (istype(user_list))
		for (var/uid as anything in user_list)
			whotext += "[uid]-[user_list[uid]]|n"
	else
		whotext = "Error: Unable to determine current users."

	if (src.shell.piping)
		src.shell.pipetemp = whotext

	else
		whotext ||= "Error: Unable to determine current users."
		src.shell.message_user(whotext, "multiline")

	return BUILTIN_SUCCESS
