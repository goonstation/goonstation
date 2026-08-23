/datum/dwaine_shell_builtin/_while
	name = "while"

/datum/dwaine_shell_builtin/_while/execute(list/command_list, list/piped_list)
	if (!length(command_list) || (src.shell.scriptstat & DWAINE::SHELL::SCRIPT::IN_LOOP))
		return DWAINE::ERR::SHELL::BUILTIN::BREAK

	switch (src.shell.script_evaluate(command_list, TRUE))
		if (TRUE)
			src.shell.scriptstat |= DWAINE::SHELL::SCRIPT::IN_LOOP
			return DWAINE::ERR::SHELL::BUILTIN::SUCCESS

		if (FALSE)
			src.shell.scriptstat &= ~DWAINE::SHELL::SCRIPT::IN_LOOP
			return DWAINE::ERR::SHELL::BUILTIN::CONTINUE

		else
			return DWAINE::ERR::SHELL::BUILTIN::BREAK
