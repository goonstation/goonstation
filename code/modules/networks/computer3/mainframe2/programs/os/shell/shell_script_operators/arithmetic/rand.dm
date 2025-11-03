/* Usage:
	Expression:			Value:
	`X rand`	-->		`rand(1, X)`
	`4 rand`	-->		`3`
	`4 rand`	-->		`1`
*/
/datum/dwaine_shell_script_operator/rand
	name = "rand"

/datum/dwaine_shell_script_operator/rand/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return SCRIPT_STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length])

	src.shell.stack.Splice(-1, 0, SCRIPT_CLAMPVALUE(rand(1, operand_1)))
	return SCRIPT_SUCCESS
