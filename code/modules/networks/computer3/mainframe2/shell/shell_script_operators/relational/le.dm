/* Usage:
	Expression:			Value:
	`X Y le`	-->		`X <= Y`
	`7 6 le`	-->		`0`
	`Ha 1 le`	-->		`0`
	`0 A le`	-->		`1`
	`Ha Ha le`	-->		`1`
*/
/datum/dwaine_shell_script_operator/le
	name = "le"

/datum/dwaine_shell_script_operator/le/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 2)
		return SCRIPT_STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length - 1])
	var/operand_2 = global.text2num_if_num(src.shell.stack[stack_length])

	if (isnum(operand_1) && isnum(operand_2))
		src.shell.stack.Splice(-2, 0, (operand_1 <= operand_2))

	else if (istext(operand_1) && isnum(operand_2))
		src.shell.stack.Splice(-2, 0, (length(operand_1) <= operand_2))

	else if (isnum(operand_1) && istext(operand_2))
		src.shell.stack.Splice(-2, 0, (operand_1 <= length(operand_2)))

	else
		src.shell.stack.Splice(-2, 0, (length(operand_1) <= length(operand_2)))

	return SCRIPT_SUCCESS
