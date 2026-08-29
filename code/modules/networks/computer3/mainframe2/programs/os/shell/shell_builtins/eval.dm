/datum/dwaine_shell_builtin/eval
	name = "eval"

/datum/dwaine_shell_builtin/eval/execute(list/command_list, list/piped_list)
	var/result = null
	var/pipe_result = (length(command_list) == 1)

	if (!length(command_list))
		return DWAINE::ERR::SHELL::BUILTIN::SUCCESS

	switch (src.shell.script_evaluate(command_list, FALSE))
		if (DWAINE::ERR::SHELL::SCRIPT::SUCCESS)
			var/stack_depth = length(src.shell.stack)
			if (stack_depth)
				result = src.shell.stack[stack_depth]
			else
				result = 0

		if (DWAINE::ERR::SHELL::SCRIPT::STACK_OVERFLOW)
			src.shell.message_user("Error: Stack overflow.")
			return DWAINE::ERR::SHELL::BUILTIN::BREAK

		if (DWAINE::ERR::SHELL::SCRIPT::STACK_UNDERFLOW)
			src.shell.message_user("Error: Stack underflow.")
			return DWAINE::ERR::SHELL::BUILTIN::BREAK

		if (DWAINE::ERR::SHELL::SCRIPT::UNDEFINED)
			src.shell.message_user("Error: Undefined result.")
			return DWAINE::ERR::SHELL::BUILTIN::BREAK

	if (src.shell.piping && pipe_result)
		src.shell.pipetemp = "[result]"

	else if (!src.shell.script_iteration && !isnull(result))
		src.shell.message_user("[result]")

	return DWAINE::ERR::SHELL::BUILTIN::SUCCESS
