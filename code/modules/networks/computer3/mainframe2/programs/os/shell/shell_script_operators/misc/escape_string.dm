/* Usage:
	Expression:				Value:
	`' A B C '`		-->		`A B C`

	Statement:						Output:
	`eval 1 2 +`			-->		`3`
	`eval ' eval 1 2 + '	-->		`eval 1 2 +`
*/
/datum/dwaine_shell_script_operator/escape_string
	name = "'"

/datum/dwaine_shell_script_operator/escape_string/execute(list/token_stream)
	var/end = token_stream.Find("'")
	var/result = jointext(token_stream, " ", 1, end)
	token_stream.Cut(1, end + 1)

	if (result)
		src.shell.stack.Add(result)

	return SCRIPT_SUCCESS
