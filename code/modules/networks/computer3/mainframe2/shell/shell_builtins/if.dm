/datum/dwaine_shell_builtin/_if
	name = "if"

/datum/dwaine_shell_builtin/_if/execute(list/command_list, list/piped_list)
	if (!length(command_list))
		return BUILTIN_BREAK

	switch (src.shell.script_evaluate(command_list, TRUE))
		if (TRUE)
			src.shell.scriptstat |= SCRIPT_IF_TRUE
			src.shell.pipetemp = null

			var/else_position = piped_list.Find("else")
			if (else_position)
				piped_list.Cut(else_position)
				src.shell.piping = length(piped_list)

			return BUILTIN_SUCCESS

		if (FALSE)
			src.shell.scriptstat &= ~SCRIPT_IF_TRUE

			var/else_position = piped_list.Find("else")
			if (else_position)
				piped_list.Cut(1, else_position + 1)
				src.shell.piping = length(piped_list)
				src.shell.pipetemp = null

				return BUILTIN_SUCCESS

			return BUILTIN_CONTINUE

		else
			return BUILTIN_BREAK
