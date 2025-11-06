/**
 *	The shell is the main computer program that is used to interface with the DWAINE OS, and allows user to execute other
 *	computer programs, run shell builtins, and run shell scripts. The shell is automatically loaded when a user logs in.
 */
/datum/computer/file/mainframe_program/shell
	name = "Msh"
	size = 8
	executable = FALSE

	/// A list of cached DWAINE shell builtin datums, indexed by their name.
	var/list/datum/dwaine_shell_builtin/shell_builtins = null
	/// A list of cached DWAINE shell script operator datums, indexed by their name.
	var/list/datum/dwaine_shell_script_operator/shell_script_operators = null

	/// Whether the shell is currently piping the output of one program into another.
	var/tmp/piping = 0
	/// A standin for a standard streams system; `pipetemp` is used to pass the output of one program into another.
	var/tmp/pipetemp = null
	/// The aggregate result of `pipetemp` across several programs. Used for command substitution.
	var/tmp/previous_pipeout = null
	/// If enabled, prevents messages from being sent to the user.
	var/tmp/suppress_out = FALSE

	/// The program ID of any child program that this shell is running.
	var/tmp/scriptprocess = 0
	/// When executing a shell script, the shell forks itself; this is the fork depth of this shell.
	var/tmp/script_iteration = 0
	/// The current line in the shell script being processed.
	var/tmp/scriptline = 0
	/// A list of the remaining lines to process in the shell script being processed.
	var/tmp/list/shscript = null
	/// The status of the current shell script; whether it is in an `if` statement or `while` loop.
	var/tmp/scriptstat = 0
	/// The varibles defined at the current scope.
	var/tmp/list/scriptvars = null
	/// Shell scripts are stack-oriented; this is the stack used by the shell script being processed.
	var/tmp/list/stack = null

/datum/computer/file/mainframe_program/shell/disposing()
	for (var/name as anything in src.shell_builtins)
		var/datum/dwaine_shell_builtin/shell_builtin = src.shell_builtins[name]
		if (QDELETED(shell_builtin))
			continue

		qdel(shell_builtin)

	src.shell_builtins = null

	for (var/name as anything in src.shell_script_operators)
		var/datum/dwaine_shell_script_operator/shell_script_operator = src.shell_script_operators[name]
		if (QDELETED(shell_script_operator))
			continue

		qdel(shell_script_operator)

	src.shell_script_operators = null

	. = ..()

/datum/computer/file/mainframe_program/shell/initialize(list/supplied_config)
	if (..() || !src.useracc)
		return

	src.shell_builtins = list()
	for (var/shell_builtin_type as anything in concrete_typesof(/datum/dwaine_shell_builtin))
		var/datum/dwaine_shell_builtin/shell_builtin = new shell_builtin_type(src)

		if (islist(shell_builtin.name))
			for (var/name as anything in shell_builtin.name)
				src.shell_builtins[name] = shell_builtin
		else
			src.shell_builtins[shell_builtin.name] = shell_builtin

	src.shell_script_operators = list()
	for (var/shell_script_operator_type as anything in concrete_typesof(/datum/dwaine_shell_script_operator))
		var/datum/dwaine_shell_script_operator/shell_script_operator = new shell_script_operator_type(src)

		if (islist(shell_script_operator.name))
			for (var/name as anything in shell_script_operator.name)
				src.shell_script_operators[name] = shell_script_operator
		else
			src.shell_script_operators[shell_script_operator.name] = shell_script_operator

	src.previous_pipeout = null

	src.piping = 0
	src.suppress_out = FALSE
	src.pipetemp = ""
	src.scriptline = 0

	if (length(supplied_config) >= 3)
		src.script_iteration = supplied_config[1]
		src.scriptvars = supplied_config[2]
		src.shscript = supplied_config[3]
	else
		src.script_iteration = 0

	src.scriptstat = 0
	src.scriptvars ||= list()
	src.shscript ||= list()

	if (src.useracc.user_file && !src.script_iteration)
		if (!src.read_user_field("name"))
			src.write_user_field("name", src.useracc.user_name)

		src.useracc.user_file.fields["curpath"] = "/home/usr[src.read_user_field("name")]"
		src.useracc.base_shell_instance = src

	if (!src.script_iteration)
		src.message_user("[src.read_user_field("name")]@DWAINE - [time2text(world.realtime, "hh:mm MM/DD/53")]|nType \"help\" for command listing.", "multiline")

	src.process()

/datum/computer/file/mainframe_program/shell/process()
	if (..() || !src.useracc)
		return

	if (src.script_iteration)
		src.script_process()

/datum/computer/file/mainframe_program/shell/input_text(text)
	if (..() || !src.useracc)
		return TRUE

	var/list/subcommands = list()
	var/list/piped_list = global.command2list(text, "^", src.scriptvars, subcommands)
	piped_list.len = min(length(piped_list), MAX_PIPED_COMMANDS)
	src.piping = length(piped_list)
	src.pipetemp = ""

	var/script_counter = 0
	while (length(piped_list) && (script_counter < MAX_SCRIPT_COMPLEXITY))
		script_counter++

		text = piped_list[1]
		piped_list.Cut(1, 2)
		src.piping--

		/* Handle command substition:
			Commands wrapped in $(...) will be processed prior to the main statement, with their ouputs being be pasted back
			as arguments to another command.

			`command2list` replaces `$(...)` with `_sub#`, with # corresponding to an index in a substitution list with this
			index containing the original statement.
		*/
		var/string_index = findtext(text, "_sub")
		if (string_index)
			src.suppress_out = TRUE

			while (string_index)
				var/list_index = text2num_safe(copytext(text, string_index + 4, string_index + 5))
				if (!isnum(list_index) || (list_index < 1) || (list_index > length(subcommands)))
					return TRUE

				src.previous_pipeout = ""
				if (src.input_text(subcommands[list_index], 0))
					return TRUE

				if (dd_hassuffix(src.previous_pipeout, "|n"))
					src.previous_pipeout = copytext(src.previous_pipeout, 1, -2)

				text = splicetext(text, string_index, string_index + 5, src.previous_pipeout)

				string_index = findtext(text, "_sub")

			src.suppress_out = FALSE

		var/list/command_list = src.parse_string(text, src.scriptvars)
		var/command = null
		while (!command && length(command_list))
			command = lowertext(command_list[1])
			command_list.Cut(1, 2)

		// Attempt to locate the command in the `/bin` directory.
		if (src.execpath("/bin/[command]", command_list, src.script_iteration))
			continue

		// Attempt to locate the command in the current working directory.
		var/current = src.read_user_field("curpath")
		switch (src.execpath("[current]/[dd_hasprefix(command, "/") ? copytext(command, 1) : command]", command_list, src.script_iteration))
			if (EXEC_SUCCESS)
				continue
			if (EXEC_SCRIPT_ERROR)
				src.message_user("Error: Unable to execute script.")
				return TRUE
			if (EXEC_STACK_OVERFLOW)
				src.message_user("Error: Stack overflow.")
				return TRUE

		// Attempt to run the command as a shell builtin.
		var/datum/dwaine_shell_builtin/shell_builtin = src.shell_builtins[command]
		if (istype(shell_builtin))
			var/outcome = shell_builtin.execute(command_list, piped_list)
			switch (outcome)
				if (BUILTIN_SUCCESS)
					continue
				if (BUILTIN_BREAK)
					return TRUE
				if (BUILTIN_CONTINUE)
					return FALSE
				else
					CRASH("Unexpected return value ([outcome]) from DWAINE shell builtin ([shell_builtin.type]).")

		// Pipe to a file.
		if (src.pipetemp)
			command = ABSOLUTE_PATH(command, current)

			var/list/separated_filepath = splittext(command, "/")
			var/path_length = length(separated_filepath)
			if (!path_length)
				src.message_user("Syntax error.")
				break

			var/record_name = copytext(separated_filepath[path_length], 1, 16)
			if (record_name)
				while (dd_hasprefix(record_name, " "))
					record_name = copytext(record_name, 2)
			else
				record_name = "out"

			separated_filepath.Cut(path_length)
			command = jointext(separated_filepath, "/") || "/"

			var/datum/computer/file/record/record = new /datum/computer/file/record()
			record.fields = splittext(src.pipetemp, "|n")
			record.name = record_name
			record.metadata["owner"] = read_user_field("name")
			record.metadata["permission"] = COMP_ALLACC

			if (src.signal_program(1, list("command" = DWAINE_COMMAND_FWRITE, "path" = command, "append" = TRUE), record) != ESIG_SUCCESS)
				src.message_user("Unable to pipe stream to file.")
				record.dispose()
				break

			continue

		src.message_user("Syntax error.")
		return TRUE

	src.previous_pipeout += src.pipetemp
	return FALSE

/datum/computer/file/mainframe_program/shell/receive_progsignal(sendid, list/data, datum/computer/file/file)
	if (..() || !data["command"])
		return ESIG_GENERIC

	switch (data["command"])
		if (DWAINE_COMMAND_MSG_TERM)
			if (src.piping)
				src.pipetemp += data["data"]
			else
				return src.message_user(data["data"], data["render"])

		if (DWAINE_COMMAND_BREAK)
			if (length(src.shscript))
				src.message_user("Break at line [src.scriptline + 1]")
				src.shscript.Cut()
				src.scriptline = 0
				return

		if (DWAINE_COMMAND_TEXIT)
			src.scriptprocess = 0
			return

		if (DWAINE_COMMAND_RECVFILE)
			var/current_path = src.read_user_field("curpath")
			if (!current_path)
				return ESIG_GENERIC

			if (!istype(file))
				return ESIG_NOFILE

			return src.signal_program(1, list("command" = DWAINE_COMMAND_FWRITE, "path" = current_path, "replace" = TRUE, "mkdir" = FALSE), file)

/datum/computer/file/mainframe_program/shell/message_user(msg, render, file)
	if (!src.useracc)
		return ESIG_NOTARGET

	if (src.suppress_out)
		if (dd_hassuffix(msg, "|n"))
			msg = copytext(msg, 1, -2)

		src.previous_pipeout += replacetext(msg, "|n", " ")
		return ESIG_SUCCESS

	src.previous_pipeout += msg
	if (render)
		return src.signal_program(src.parent_task.progid, list("command" = DWAINE_COMMAND_MSG_TERM, "data" = msg, "term" = src.useracc.user_id, "render" = render))
	else
		return src.signal_program(src.parent_task.progid, list("command" = DWAINE_COMMAND_MSG_TERM, "data" = msg, "term" = src.useracc.user_id))

/// Attempt to locate and execute a mainframe program or shell script at the provided filepath.
/datum/computer/file/mainframe_program/shell/proc/execpath(file_path, list/command_list, scripting = 0)
	var/datum/computer/file/record/exec = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = file_path))

	// If the executable is a mainframe program.
	if (istype(exec, /datum/computer/file/mainframe_program))
		if (src.pipetemp)
			command_list ||= list()
			command_list += src.pipetemp

		src.pipetemp = ""

		var/list/siglist = list("command" = DWAINE_COMMAND_TSPAWN, "passusr" = TRUE, "path" = file_path)
		if (length(command_list))
			siglist["args"] = strip_html(jointext(command_list, " "))

		var/datum/computer/file/mainframe_program/to_run = src.signal_program(1, siglist)
		if (istype(to_run) && !QDELETED(to_run))
			src.scriptprocess = to_run.progid

		return EXEC_SUCCESS

	// If the executable is a shell script.
	if ((!src.pipetemp || scripting) && istype(exec) && (length(exec.fields) > 1) && dd_hasprefix(exec.fields[1], "#!"))
		if (src.script_iteration + 1 >= MAX_SCRIPT_ITERATIONS)
			return EXEC_STACK_OVERFLOW

		var/list/scriptvars_to_pass = list(
			"$" = src.progid,
			"su" = (src.read_user_field("group") == 0),
			"*" = jointext(command_list, " "),
			"argc" = length(command_list),
		)

		for (var/i in 1 to length(command_list))
			scriptvars_to_pass["arg[i - 1]"] = command_list[i]

		var/list/child_script = src.script_format(exec.fields.Copy())

		src.scriptprocess = src.signal_program(1, list("command" = DWAINE_COMMAND_TFORK, "args" = list(src.script_iteration + 1, scriptvars_to_pass, child_script)))
		if (src.scriptprocess & ESIG_DATABIT)
			src.scriptprocess &= ~ESIG_DATABIT
			return EXEC_SUCCESS

		src.scriptprocess = 0
		return EXEC_SCRIPT_ERROR

	return EXEC_FAILURE

/// Process the currently running shell script.
/datum/computer/file/mainframe_program/shell/proc/script_process()
	// Only process a maximum of five shell script lines per processing cycle.
	for (var/i in 1 to min(5, length(src.shscript)))
		// Process the script line.
		if (src.input_text(src.shscript[1], src.script_iteration))
			src.message_user("Break at line [src.scriptline + 1]")

			if (src.scriptprocess)
				src.signal_program(1, list("command" = DWAINE_COMMAND_TKILL, "target" = src.scriptprocess))
				src.scriptprocess = 0

			if (src.parent_id && src.pipetemp)
				src.message_user(src.pipetemp)

			mainframe_prog_exit
			return TRUE

		// Disable the `SCRIPT_IN_LOOP` flag after the line is finished processing.
		if (src.scriptstat & SCRIPT_IN_LOOP)
			src.scriptstat &= ~SCRIPT_IN_LOOP
			continue

		// Remove the processed line.
		if (length(src.shscript))
			src.shscript.Cut(1, 2)

		src.scriptline++

	var/shscript_length = length(src.shscript)
	src.scriptline = shscript_length ? src.scriptline : 0

	if (!shscript_length && !src.scriptprocess)
		if (src.parent_id && src.pipetemp)
			src.message_user(src.pipetemp)

		mainframe_prog_exit

/// Format a shell script, trimming the shebang and commented lines.
/datum/computer/file/mainframe_program/shell/proc/script_format(list/script_list)
	RETURN_TYPE(/list)
	. = list()

	if (length(script_list) < 2)
		return

	// The first line of a shell script will always be `#!`, so remove it.
	script_list.Cut(1, 2)

	for (var/line as anything in script_list)
		// Filter out commented lines.
		if (dd_hasprefix(trim_left(line), "#"))
			continue

		. += replacetext(line, "|", "^")

/// Evaluate an expression involving script operators.
/datum/computer/file/mainframe_program/shell/proc/script_evaluate(list/token_stream, return_bool = FALSE)
	src.stack = list()

	// The following allows apostrophes to sit next to text and still be treated as a separate token.
	// This will eventually be replaced by a proper tokeniser.
	for (var/i = 1; i <= length(token_stream); i++)
		var/token = token_stream[i]

		if (findtext(token, "'", 1, 2))
			token = copytext(token, 2, 0)
			token_stream[i] = token
			token_stream.Insert(i, "'")
			i++

		if (findtext(token, "'", -1, 0))
			token = copytext(token, 1, -1)
			token_stream[i] = token
			token_stream.Insert(i + 1, "'")
			i++

	while (length(token_stream))
		var/current_token = text2num_if_num(token_stream[1])
		token_stream.Cut(1, 2)

		// If the current token is a number, add it to the stack.
		if (isnum(current_token))
			if (length(src.stack) > MAX_STACK_DEPTH)
				return SCRIPT_STACK_OVERFLOW

			src.stack.Add(SCRIPT_CLAMPVALUE(current_token))
			continue

		// Check if the current token is an operator token.
		var/datum/dwaine_shell_script_operator/shell_script_operator = src.shell_script_operators[lowertext(current_token)]
		if (istype(shell_script_operator))
			var/outcome = shell_script_operator.execute(token_stream)
			switch (outcome)
				if (SCRIPT_SUCCESS)
					continue
				if (SCRIPT_STACK_OVERFLOW, SCRIPT_STACK_UNDERFLOW, SCRIPT_UNDEFINED)
					return outcome
				else
					CRASH("Unexpected return value ([outcome]) from DWAINE shell script operator ([shell_script_operator.type]).")

		// If the current token is a script variable, add the value of that variable to the stack.
		else if (src.scriptvars[lowertext(ckeyEx(current_token))])
			src.stack.Add(src.scriptvars[lowertext(ckeyEx(current_token))])

		// Otherwise if the current token is a string, add it to the stack.
		else if (istext(current_token))
			src.stack.Add(current_token)

	if (return_bool)
		var/stack_length = length(src.stack)
		if (stack_length && src.stack[stack_length])
			return TRUE
		else
			return FALSE

	return SCRIPT_SUCCESS
