/* Usage:
	Expression:			Value:
	`X dup`		-->		`X X`
	`6 dup`		-->		`6 6`
	`A dup`		-->		`A A`

	Statement:					Output:
	`eval 3 dup +`		-->		`6`
*/
/datum/dwaine_shell_script_operator/stack_dup_topmost
	name = "dup"

/datum/dwaine_shell_script_operator/stack_dup_topmost/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return SCRIPT_STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length])

	src.shell.stack.Add(operand_1)
	return SCRIPT_SUCCESS
