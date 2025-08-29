/* Usage:
	Expression:			Value:
	`5 to num`	-->		None; `echo $num` --> `5`
*/
/datum/dwaine_shell_script_operator/assignment
	name = list("to", "value")

/datum/dwaine_shell_script_operator/assignment/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return SCRIPT_STACK_UNDERFLOW

	if (!length(token_stream))
		return SCRIPT_UNDEFINED

	var/variable = lowertext(ckeyEx(token_stream[1]))
	if (!variable)
		return SCRIPT_UNDEFINED

	var/operand_1 = src.shell.stack[stack_length]

	src.shell.scriptvars[variable] = operand_1
	src.shell.stack.Cut(stack_length)
	return SCRIPT_SUCCESS
