/* Usage:
	Expression:				Value:
	`X e`			-->		`istype(X, /datum/computer)`
	`/bin/ls e`		-->		`1`
	`/conf/motd e`	-->		`1`
	`/mnt e`		-->		`1`
*/
/datum/dwaine_shell_script_operator/exists
	name = "e"

/datum/dwaine_shell_script_operator/exists/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return DWAINE::ERR::SHELL::SCRIPT::STACK_UNDERFLOW

	var/operand_1 = src.shell.stack[stack_length]
	if (!istext(operand_1))
		return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED

	var/datum/computer/C = src.shell.signal_program(1, list("command" = DWAINE::SYSCALL::FGET, "path" = operand_1))
	src.shell.stack.Splice(-1, 0, istype(C))
	return DWAINE::ERR::SHELL::SCRIPT::SUCCESS
