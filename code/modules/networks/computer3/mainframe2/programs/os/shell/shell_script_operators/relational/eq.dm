/* Usage:
	Expression:			Value:
	`X Y eq`	-->		`X == Y`
	`7 1 eq`	-->		`0`
	`A A eq`	-->		`1`
*/
/datum/dwaine_shell_script_operator/eq
	name = "eq"

/datum/dwaine_shell_script_operator/eq/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 2)
		return SCRIPT_STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length - 1])
	var/operand_2 = global.text2num_if_num(src.shell.stack[stack_length])

	src.shell.stack.Splice(-2, 0, (operand_1 == operand_2))
	return SCRIPT_SUCCESS
