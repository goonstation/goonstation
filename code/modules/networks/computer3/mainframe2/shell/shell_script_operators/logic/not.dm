/* Usage:
	Expression:			Value:
	`X not`		-->		`~X` or `!X`
	`5 not`		-->		`2`
	`A not`		-->		`0`
*/
/datum/dwaine_shell_script_operator/not
	name = list("not", "!")

/datum/dwaine_shell_script_operator/not/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return SCRIPT_STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length])

	if (isnum(operand_1))
		src.shell.stack.Splice(-1, 0, ~operand_1)
	else
		src.shell.stack.Splice(-1, 0, !operand_1)

	return SCRIPT_SUCCESS
