/* Usage:
	Expression:			Value:
	`X Y %`		-->		`X % Y`
	`9 4 %`		-->		`1`
*/
/datum/dwaine_shell_script_operator/modulo
	name = "%"

/datum/dwaine_shell_script_operator/modulo/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 2)
		return DWAINE::ERR::SHELL::SCRIPT::STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length - 1])
	var/operand_2 = global.text2num_if_num(src.shell.stack[stack_length])

	if (isnum(operand_1) && isnum(operand_2))
		if (operand_2 == 0)
			return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED

		src.shell.stack.Splice(-2, 0, SCRIPT_CLAMPVALUE(operand_1 % operand_2))
		return DWAINE::ERR::SHELL::SCRIPT::SUCCESS

	return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED
