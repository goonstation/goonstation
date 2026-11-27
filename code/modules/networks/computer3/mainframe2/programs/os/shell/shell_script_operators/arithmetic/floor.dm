/* Usage:
	Expression:			Value:
	`X floor`		-->		`floor(X)`
	`50.82 floor`	-->		`50`
	`-5.2 floor`	-->		`-6`
*/
/datum/dwaine_shell_script_operator/floor
	name = "floor"

/datum/dwaine_shell_script_operator/floor/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return DWAINE::ERR::SHELL::SCRIPT::STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length])
	if (!isnum(operand_1))
		return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED

	src.shell.stack.Splice(-1, 0, SCRIPT_CLAMPVALUE(floor(operand_1)))
	return DWAINE::ERR::SHELL::SCRIPT::SUCCESS
