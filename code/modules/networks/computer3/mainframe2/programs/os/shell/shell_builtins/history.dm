/datum/dwaine_shell_builtin/history
	name = "history"

/datum/dwaine_shell_builtin/history/execute(list/command_list, list/piped_list)
	// getting user and their file:

	var/datum/mainframe2_user_data/user = src.shell.useracc

	if (isnull(user) || !istype(user))
		src.shell.message_user("Error: Executing user not found.")
		return BUILTIN_BREAK

	var/user_history_path = src.shell.histfile_full_path(user.user_filename)
	var/datum/computer/file/record/history_file =  src.shell.signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path" = user_history_path))

	if (isnull(history_file) || history_file == ESIG_NOFILE)
		src.shell.message_user("Error: User's history fille not found ([user_history_path]).")
		return BUILTIN_BREAK

	if (!istype(history_file))
		src.shell.message_user("Error: User's history file is of the wrong type (expected record, got [history_file.extension])..")
		return BUILTIN_BREAK

	// actual command functionality:
	if (length(command_list) > 0 && command_list[1] == "-c")
		src.shell.message_user("History file cleared.")
		history_file.fields.Cut()

		return BUILTIN_SUCCESS

	var/arg_as_num = length(command_list) > 0 ? text2num(command_list[1]) : length(history_file.fields)

	if(isnan(arg_as_num) || isnull(arg_as_num) || arg_as_num < 0)
		src.shell.message_user("Error: Invalid argument [command_list[1]]")
		return BUILTIN_BREAK

	var/history_output = src.history_file_to_text(history_file.fields, arg_as_num)

	if (src.shell.piping && length(piped_list) && (ckey(piped_list[1]) != "break"))
		src.shell.pipetemp = history_output
	else
		src.shell.message_user(copytext(history_output, 1, MAX_MESSAGE_LEN), "multiline")

	return BUILTIN_SUCCESS

/datum/dwaine_shell_builtin/history/proc/history_file_to_text(list/history, last_n_entries)
	var/start_idx = max(1, length(history) - last_n_entries + 1)

	for (var/idx in start_idx to length(history))
		. += "[idx] [history[history[idx]]]|n"
