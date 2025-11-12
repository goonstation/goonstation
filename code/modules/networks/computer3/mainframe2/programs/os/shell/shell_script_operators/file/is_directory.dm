/* Usage:
	Expression:				Value:
	`X d`			-->		`istype(X, /datum/computer/folder)`
	`/bin/ls d`		-->		`0`
	`/conf/motd d`	-->		`0`
	`/mnt d`		-->		`1`
*/
/datum/dwaine_shell_script_operator/is_directory
	name = "d"

/datum/dwaine_shell_script_operator/is_directory/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return SCRIPT_STACK_UNDERFLOW

	var/operand_1 = src.shell.stack[stack_length]
	if (!istext(operand_1))
		return SCRIPT_UNDEFINED

	var/datum/computer/folder/folder = src.shell.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = operand_1))
	src.shell.stack.Splice(-1, 0, istype(folder))
	return SCRIPT_SUCCESS
