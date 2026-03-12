/* Usage:
	Expression:			Value:
	`.s`		-->		None, and stack is printed.

	Statement:							Output:
	`eval A 2 iii .s 4 | echo`	-->		`<3>`, `A`, `2`, `iii`: this is useful for debugging scripts and piping values.
*/
/datum/dwaine_shell_script_operator/stack_print
	name = ".s"

/datum/dwaine_shell_script_operator/stack_print/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	src.shell.message_user("<[stack_length]>")

	if (stack_length < 1)
		return SCRIPT_SUCCESS

	src.shell.message_user(jointext(src.shell.stack, "|n") + "|n", "multiline")
	return SCRIPT_SUCCESS
