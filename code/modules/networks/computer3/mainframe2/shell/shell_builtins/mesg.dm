/datum/dwaine_shell_builtin/mesg
	name = "mesg"

/datum/dwaine_shell_builtin/mesg/execute(list/command_list, list/piped_list)
	var/input = src.shell.pipetemp

	if (!input && length(command_list))
		input = command_list[1]

	var/output = null
	switch (lowertext(input))
		if ("y")
			if (src.shell.write_user_field("accept_msg", "1"))
				output = "Now allowing messages."
			else
				output = "Error: Unable to write user configuration."

		if ("n")
			if (src.shell.write_user_field("accept_msg", "0"))
				output = "Now disallowing messages."
			else
				output = "Error: Unable to write user configuration."

		if ("", null)
			output = "is [(src.shell.read_user_field("accept_msg") == "1") ? "y" : "n"]"

		else
			output = "Error: Invalid argument for mesg (Must be \"y\" or \"n\")"

	if (src.shell.piping)
		src.shell.pipetemp = output
	else
		src.shell.message_user(output)

	return BUILTIN_SUCCESS
