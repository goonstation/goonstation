/* Usage:
	Expression:			Value:
	`X Y or`	-->		`X | Y` or `X || Y`
	`3 6 or`	-->		`7`
	`0 A or`	-->		`1`
	`A B or`	-->		`1`
*/
/datum/dwaine_shell_script_operator/or
	name = "or"

/datum/dwaine_shell_script_operator/or/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 2)
		return SCRIPT_STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length - 1])
	var/operand_2 = global.text2num_if_num(src.shell.stack[stack_length])

	if (isnum(operand_1) && isnum(operand_2))
		src.shell.stack.Splice(-2, 0, SCRIPT_CLAMPVALUE(operand_1 | operand_2))
	else
		src.shell.stack.Splice(-2, 0, !!(operand_1 || operand_2))

	return SCRIPT_SUCCESS
