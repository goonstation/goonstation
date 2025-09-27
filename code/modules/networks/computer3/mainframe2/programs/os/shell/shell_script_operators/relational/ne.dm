/* Usage:
	Expression:			Value:
	`X Y ne`	-->		`X != Y`
	`8 3 ne`	-->		`1`
	`W W ne`	-->		`0`
*/
/datum/dwaine_shell_script_operator/ne
	name = "ne"

/datum/dwaine_shell_script_operator/ne/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 2)
		return SCRIPT_STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length - 1])
	var/operand_2 = global.text2num_if_num(src.shell.stack[stack_length])

	src.shell.stack.Splice(-2, 0, (operand_1 != operand_2))
	return SCRIPT_SUCCESS
