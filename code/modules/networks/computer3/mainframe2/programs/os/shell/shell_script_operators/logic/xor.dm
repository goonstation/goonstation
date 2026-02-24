/* Usage:
	Expression:			Value:
	`X Y xor`	-->		`X ^ Y` or `(X && !Y) || (!X && Y)`
	`6 3 xor`	-->		`5`
	`0 A xor`	-->		`1`
	`A B xor`	-->		`0`
*/
/datum/dwaine_shell_script_operator/xor
	name = list("xor", "eor")

/datum/dwaine_shell_script_operator/xor/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 2)
		return SCRIPT_STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length - 1])
	var/operand_2 = global.text2num_if_num(src.shell.stack[stack_length])

	if (isnum(operand_1) && isnum(operand_2))
		src.shell.stack.Splice(-2, 0, SCRIPT_CLAMPVALUE(operand_1 ^ operand_2))
	else
		src.shell.stack.Splice(-2, 0, !!((operand_1 && !operand_2) || (!operand_1 && operand_2)))

	return SCRIPT_SUCCESS
