/* Usage:
	Expression:			Value:
	`A B .`		-->		`A`, and topmost stack item, B, is printed.

	Statement:						Output:
	`eval 3 2 . 4 | echo`	-->		`2`: this is useful for debugging scripts and piping values.
*/
/datum/dwaine_shell_script_operator/stack_pop
	name = "."

/datum/dwaine_shell_script_operator/stack_pop/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return SCRIPT_STACK_UNDERFLOW

	src.shell.message_user("[src.shell.stack[stack_length]]")
	src.shell.stack.Cut(stack_length)
	return SCRIPT_SUCCESS
