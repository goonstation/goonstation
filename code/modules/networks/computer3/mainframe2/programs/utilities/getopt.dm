/datum/computer/file/mainframe_program/utility/getopt
	name = "getopt"
	var/error = null

/datum/computer/file/mainframe_program/utility/getopt/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	if (!initparams)
		src.message_user("Expected arguments.")
		mainframe_prog_exit
		return

	var/list/params = global.bash_explode(initparams)
	if (!params)
		src.message_user("Invalid input: [initparams]")
		mainframe_prog_exit
		return

	var/list/all = src.invoke(params)
	if (!istype(all))
		src.message_user(src.error)
		mainframe_prog_exit
		return

	var/list/options = all[1]
	var/list/unaffected = all[2]
	var/printed = ""
	for (var/option as anything in options)
		printed += "-[option] "

		if (istext(options[option]))
			printed += "[options[option]] "

	printed += "--"
	for (var/parameter as anything in unaffected)
		printed += " [parameter]"

	src.message_reply_and_user(printed)

	mainframe_prog_exit

/datum/computer/file/mainframe_program/utility/getopt/proc/invoke(list/string_list)
	src.error = null

	if (!length(string_list))
		src.error = "getopt: requires at least one parameter."
		return src.error

	var/list/options = list()
	var/list/unaffected = list()

	// Parse `getopt` options definition: /([a-zA-Z]:?)+/i
	var/options_string = string_list[1]
	var/previous_option = null
	for (var/i in 1 to length(options_string))
		var/option = options_string[i]
		var/ascii = text2ascii(option)
		if (option == ":")
			if (!previous_option)
				src.error = "getopt: unexpected : in definition following no option."
				return src.error

			options[previous_option] = ""
			previous_option = null

		else if (((65 <= ascii) && (ascii <= 90)) || ((97 <= ascii) && (ascii <= 122)))
			options[option] = 0
			previous_option = option

		else
			src.error = "getopt: unexpected [option] in definition."
			return src.error

	// Parse `$@`; the list of parameters provided to the original command.
	previous_option = null
	string_list -= options_string
	for (var/string as anything in string_list)
		// `--` resets parameters; e.g. for `command -p -- something`, `something` is not a parameter of `-p`.
		if (string == "--")
			previous_option = null
			continue

		// The current string is an option.
		if (dd_hasprefix(string, "-"))
			// If the previous string is an option, then the current string must be an parameter.
			if (previous_option && istext(options[previous_option]))
				src.error = "getopt: -[previous_option] expecting parameter, found [string]"
				return src.error

			var/string_length = length(string)
			for (var/j in 2 to string_length)
				previous_option = string[j]

				// Unexpected option.
				if (isnull(options[previous_option]))
					src.error = "getopt: unexpected option -[previous_option]"
					return src.error

				// Expecting a parameter.
				if ((options[previous_option] == "") && (j != string_length))
					src.error = "getopt: -[previous_option] expecting parameter in [string]"
					return src.error

				if (isnum(options[previous_option]))
					options[previous_option] = 1

		// The current string is an unaffected parameter.
		else if (!previous_option)
			unaffected += string
			continue

		// The current string is an unexpected parameter.
		else if (isnum(options[previous_option]))
			src.error = "getopt: unexpected parameter for -[previous_option]"
			return src.error

		// The current string is a parameter associated with an option.
		else
			options[previous_option] = string
			previous_option = null

	// An option defined as having a parameter couldn't find one.
	if (previous_option && (options[previous_option] == ""))
		src.error = "getopt: -[previous_option] expecting parameter, found EOL."
		return src.error

	for (var/option as anything in options)
		if (options[option])
			continue

		options -= option

	return list(options, unaffected)

/datum/computer/file/mainframe_program/utility/getopt/proc/message_reply_and_user(message)
	var/list/data = list("command" = DWAINE_COMMAND_REPLY, "data" = message, "sender_tag" = "getopt")
	if (src.useracc)
		data["term"] = src.useracc.user_id

	if (src.signal_program(src.parent_task.progid, data) != ESIG_USR4)
		src.message_user(message)
