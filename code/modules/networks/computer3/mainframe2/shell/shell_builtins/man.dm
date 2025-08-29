/datum/dwaine_shell_builtin/man
	name = list("man", "help")

/datum/dwaine_shell_builtin/man/execute(list/command_list, list/piped_list)
	var/datum/computer/file/record/help_record = src.shell.signal_program(1, list("command" = DWAINE_COMMAND_CONFGET, "fname" = "help"))

	if (!istype(help_record))
		src.shell.message_user("Error: Help library missing or invalid.")
		return BUILTIN_SUCCESS

	var/target_entry = "index"
	if (length(command_list) && ckey(command_list[1]))
		target_entry = lowertext(command_list[1])

	if (help_record.fields[target_entry])
		src.shell.message_user("[capitalize(target_entry)]: [help_record.fields[target_entry]]", "multiline")
	else
		src.shell.message_user("Error: Unknown topic.")

	return BUILTIN_SUCCESS
