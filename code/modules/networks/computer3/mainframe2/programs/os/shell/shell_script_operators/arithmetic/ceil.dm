/* Usage:
	Expression:			Value:
	`X ceil`		-->		`ceil(X)`
	`50.12 ceil`	-->		`51`
	`-5.8 ceil`		-->		`-5`
*/
/datum/dwaine_shell_script_operator/ceil
	name = "ceil"

/datum/dwaine_shell_script_operator/ceil/execute(list/token_stream)
	var/stack_length = length(src.shell.stack)
	if (stack_length < 1)
		return DWAINE::ERR::SHELL::SCRIPT::STACK_UNDERFLOW

	var/operand_1 = global.text2num_if_num(src.shell.stack[stack_length])
	if (!isnum(operand_1))
		return DWAINE::ERR::SHELL::SCRIPT::UNDEFINED

	src.shell.stack.Splice(-1, 0, SCRIPT_CLAMPVALUE(ceil(operand_1)))
	return DWAINE::ERR::SHELL::SCRIPT::SUCCESS
