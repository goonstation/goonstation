/datum/dwaine_shell_builtin/eval
	name = "eval"

/datum/dwaine_shell_builtin/eval/execute(list/command_list, list/piped_list)
	var/result = null
	var/pipe_result = (length(command_list) == 1)

	if (!length(command_list))
		return BUILTIN_SUCCESS

	switch (src.shell.script_evaluate(command_list, FALSE))
		if (SCRIPT_SUCCESS)
			var/stack_depth = length(src.shell.stack)
			if (stack_depth)
				result = src.shell.stack[stack_depth]
			else
				result = 0

		if (SCRIPT_STACK_OVERFLOW)
			src.shell.message_user("Error: Stack overflow.")
			return BUILTIN_BREAK

		if (SCRIPT_STACK_UNDERFLOW)
			src.shell.message_user("Error: Stack underflow.")
			return BUILTIN_BREAK

		if (SCRIPT_UNDEFINED)
			src.shell.message_user("Error: Undefined result.")
			return BUILTIN_BREAK

	if (src.shell.piping && pipe_result)
		src.shell.pipetemp = "[result]"

	else if (!src.shell.script_iteration && !isnull(result))
		src.shell.message_user("[result]")

	return BUILTIN_SUCCESS
