/* Usage:
	Expression:				Value:
	`X f`			-->		`istype(X, /datum/computer/file)`
	`/bin/ls f`		-->		`1`
	`/conf/motd f`	-->		`1`
	`/mnt f`		-->		`0`
*/
/datum/dwaine_shell_script_operator/is_file
	name = "f"

/datum/dwaine_shell_script_operator/is_file/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return DWAINE::ERR::SHELL::SCRIPT::STACK_UNDERFLOW

	var/operand_1 = src.shell.stack[stack_length]
	if (!istext(operand_1))
		return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED

	var/datum/computer/file/file = src.shell.signal_program(1, list("command" = DWAINE::SYSCALL::FGET, "path" = operand_1))
	src.shell.stack.Splice(-1, 0, istype(file))
	return DWAINE::ERR::SHELL::SCRIPT::SUCCESS
