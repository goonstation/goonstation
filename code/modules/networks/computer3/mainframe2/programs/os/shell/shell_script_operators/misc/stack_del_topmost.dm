/* Usage:
	Expression:			Value:
	`A B del`	-->		`A`

	Statement:						Output:
	`eval 4 1 del 4 +`		-->		`8`
*/
/datum/dwaine_shell_script_operator/stack_del_topmost
	name = "del"

/datum/dwaine_shell_script_operator/stack_del_topmost/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return DWAINE::ERR::SHELL::SCRIPT::STACK_UNDERFLOW

	src.shell.stack.Cut(stack_length)
	return DWAINE::ERR::SHELL::SCRIPT::SUCCESS
