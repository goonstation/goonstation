/* Usage:
	Expression:			Value:
	`#`			-->		`5`

	Statement:					Output:
	`eval A B C #`		-->		`3`
*/
/datum/dwaine_shell_script_operator/stack_depth
	name = "#"

/datum/dwaine_shell_script_operator/stack_depth/execute(list/token_stream)
	src.shell.stack.Add(length(src.shell.stack))
	return SCRIPT_SUCCESS
