/datum/dwaine_shell_builtin/_while
	name = "while"

/datum/dwaine_shell_builtin/_while/execute(list/command_list, list/piped_list)
	if (!length(command_list) || (src.shell.scriptstat & SCRIPT_IN_LOOP))
		return BUILTIN_BREAK

	switch (src.shell.script_evaluate(command_list, TRUE))
		if (TRUE)
			src.shell.scriptstat |= SCRIPT_IN_LOOP
			return BUILTIN_SUCCESS

		if (FALSE)
			src.shell.scriptstat &= ~SCRIPT_IN_LOOP
			return BUILTIN_CONTINUE

		else
			return BUILTIN_BREAK
