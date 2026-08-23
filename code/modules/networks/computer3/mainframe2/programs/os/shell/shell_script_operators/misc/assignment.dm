/* Usage:
	Expression:			Value:
	`5 to num`	-->		None; `echo $num` --> `5`
*/
/datum/dwaine_shell_script_operator/assignment
	name = list("to", "value")

/datum/dwaine_shell_script_operator/assignment/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return DWAINE::ERR::SHELL::SCRIPT::STACK_UNDERFLOW

	if (!length(token_stream))
		return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED

	var/variable = lowertext(ckeyEx(token_stream[1]))
	if (!variable)
		return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED

	var/operand_1 = src.shell.stack[stack_length]

	src.shell.scriptvars[variable] = operand_1
	src.shell.stack.Cut(stack_length)
	return DWAINE::ERR::SHELL::SCRIPT::SUCCESS
