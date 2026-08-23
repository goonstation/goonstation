/* Usage:
	Expression:				Value:
	`X x`			-->		`istype(X, /datum/computer/file/mainframe_program)`
	`/bin/ls x`		-->		`1`
	`/conf/motd x`	-->		`0`
	`/mnt x`		-->		`0`
*/
/datum/dwaine_shell_script_operator/is_executable
	name = "x"

/datum/dwaine_shell_script_operator/is_executable/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return DWAINE::ERR::SHELL::SCRIPT::STACK_UNDERFLOW

	var/operand_1 = src.shell.stack[stack_length]
	if (!istext(operand_1))
		return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED

	var/datum/computer/file/mainframe_program/program = src.shell.signal_program(1, list("command" = DWAINE::SYSCALL::FGET, "path" = operand_1))
	src.shell.stack.Splice(-1, 0, istype(program))
	return DWAINE::ERR::SHELL::SCRIPT::SUCCESS
