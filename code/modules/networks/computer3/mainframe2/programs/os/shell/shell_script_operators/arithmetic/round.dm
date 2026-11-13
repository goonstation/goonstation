/* Usage:
	Expression:			Value:
	`X round`		-->		`round(X, 1)`
	`50.32 round`	-->		`50`
	`50.82 round`	-->		`51`
*/
/datum/dwaine_shell_script_operator/round
	name = "round"

/datum/dwaine_shell_script_operator/round/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return DWAINE::ERR::SHELL::SCRIPT::STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length])
	if (!isnum(operand_1))
		return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED

	src.shell.stack.Splice(-1, 0, SCRIPT_CLAMPVALUE(round(operand_1, 1)))
	return DWAINE::ERR::SHELL::SCRIPT::SUCCESS

/* Usage:
	Expression:				Value:
	`X Y roundto`			-->		`round(X, Y)`
	`50.32 0.5 roundto`		-->		`50.5`
	`50.32 0.25 roundto`	-->		`50.25`
*/
/datum/dwaine_shell_script_operator/roundto
	name = "roundto"

/datum/dwaine_shell_script_operator/roundto/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 2)
		return DWAINE::ERR::SHELL::SCRIPT::STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length - 1])
	var/operand_2 = global.text2num_if_num(src.shell.stack[stack_length])
	if (!isnum(operand_1) || !isnum(operand_2))
		return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED

	if (operand_2 == 0)
		return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED

	src.shell.stack.Splice(-2, 0, SCRIPT_CLAMPVALUE(round(operand_1, operand_2)))
	return DWAINE::ERR::SHELL::SCRIPT::SUCCESS
