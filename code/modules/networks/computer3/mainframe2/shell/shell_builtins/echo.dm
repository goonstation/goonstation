/datum/dwaine_shell_builtin/echo
	name = "echo"

/datum/dwaine_shell_builtin/echo/execute(list/command_list, list/piped_list)
	var/echo_text = src.shell.pipetemp
	var/add_newline = TRUE

	if (length(command_list) > 0)
		if (command_list[1] == "-n")
			add_newline = FALSE
			command_list.Cut(1, 2)

		echo_text += jointext(command_list, " ")

	if (src.shell.piping && length(piped_list) && (ckey(piped_list[1]) != "break"))
		src.shell.pipetemp = echo_text

	else
		if (echo_text && add_newline && !dd_hassuffix(echo_text, "|n"))
			echo_text += "|n"

		src.shell.message_user(echo_text, "multiline")

	return BUILTIN_SUCCESS
