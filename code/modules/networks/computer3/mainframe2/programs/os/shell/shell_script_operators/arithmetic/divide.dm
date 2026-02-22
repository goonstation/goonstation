/* Usage:
	Expression:			Value:
	`X Y /`		-->		`X / Y`
	`9 3 /`		-->		`3`
	`A,B,C , /`	-->		`A B C`
*/
/datum/dwaine_shell_script_operator/divide
	name = "/"

/datum/dwaine_shell_script_operator/divide/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 2)
		return SCRIPT_STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length - 1])
	var/operand_2 = global.text2num_if_num(src.shell.stack[stack_length])

	if (isnum(operand_1) && isnum(operand_2))
		if (operand_2 == 0)
			return SCRIPT_UNDEFINED

		src.shell.stack.Splice(-2, 0, SCRIPT_CLAMPVALUE(operand_1 / operand_2))
		return SCRIPT_SUCCESS

	if (istext(operand_1) && istext(operand_2))
		var/list/result = splittext(operand_1, operand_2)
		if ((length(src.shell.stack) + length(result) - 2) > MAX_STACK_DEPTH)
			return SCRIPT_STACK_OVERFLOW

		src.shell.stack.Splice(-2, 0, result)
		return SCRIPT_SUCCESS

	return SCRIPT_UNDEFINED
