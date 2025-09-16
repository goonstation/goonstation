/datum/dwaine_shell_builtin/goonsay
	name = "goonsay"

/datum/dwaine_shell_builtin/goonsay/execute(list/command_list, list/piped_list)
	var/anger_text = src.shell.pipetemp

	if (length(command_list) > 0)
		anger_text += jointext(command_list, " ")

	if (src.shell.piping && length(piped_list) && (ckey(piped_list[1]) != "break"))
		src.shell.pipetemp = anger_text

	else
		if (!anger_text)
			anger_text = "A clown? On a space station? what|n"
		else if (!dd_hassuffix(anger_text, "|n"))
			anger_text += "|n"

		anger_text += @" __________|n(--[ .]-[ .] /|n(_______0__)"
		src.shell.message_user(anger_text, "multiline")

	return BUILTIN_SUCCESS
