/* Usage:
	Expression:			Value:
	`X Y *`		-->		`X * Y`
	`4 3 *`		-->		`12`
	`Ha 3 *`	-->		`HaHaHa`
*/
/datum/dwaine_shell_script_operator/multiply
	name = "*"

/datum/dwaine_shell_script_operator/multiply/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 2)
		return SCRIPT_STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length - 1])
	var/operand_2 = global.text2num_if_num(src.shell.stack[stack_length])

	if (isnum(operand_1) && isnum(operand_2))
		src.shell.stack.Splice(-2, 0, SCRIPT_CLAMPVALUE(operand_1 * operand_2))
		return SCRIPT_SUCCESS

	if (istext(operand_1) && isnum(operand_2))
		var/result = ""
		for (var/i in 1 to operand_2)
			result += operand_1

		src.shell.stack.Splice(-2, 0, copytext(result, 1, MAX_MESSAGE_LEN))
		return SCRIPT_SUCCESS

	return SCRIPT_UNDEFINED
