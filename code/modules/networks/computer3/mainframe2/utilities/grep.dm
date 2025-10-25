/datum/computer/file/mainframe_program/utility/grep
	name = "grep"
	var/max_recursion = 100

/datum/computer/file/mainframe_program/utility/grep/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	var/list/initlist = splittext(initparams, " ")
	if (length(initlist) < 2)
		src.message_user("No pattern or target file. Try 'help grep'")
		mainframe_prog_exit
		return

	var/case_sensitive = TRUE
	var/print_only_match = FALSE
	var/recursive = FALSE
	var/no_messages = FALSE
	var/plain = FALSE

	if (dd_hasprefix(initlist[1], "-"))
		var/options = copytext(initlist[1], 2)

		if (findtext(options, "i"))
			case_sensitive = FALSE
		if (findtext(options, "o"))
			print_only_match = TRUE
		if (findtext(options, "r"))
			recursive = TRUE
		if (findtext(options, "s"))
			no_messages = TRUE
		if (findtext(options, "h"))
			plain = TRUE

		initlist -= initlist[1]
		if (length(initlist) < 2)
			src.message_user("No pattern or target file. Try 'help grep'")
			mainframe_prog_exit
			return

	var/regex/regex = new(copytext(initlist[1], 1, 20), (case_sensitive ? "i" : null))
	if (!istype(regex))
		src.message_user("No regular expression found.")
		mainframe_prog_exit
		return

	var/recursion_levels = 0

	var/list/grep_results = list()
	var/current = src.read_user_field("curpath")
	for (var/i = 2, i <= length(initlist), i++)
		initlist[i] = ABSOLUTE_PATH(initlist[i], current)

		var/datum/computer/target = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = initlist[i]))
		if (!istype(target))
			continue

		if (!src.check_read_permission(target, src.useracc))
			continue

		if (recursive && istype(target, /datum/computer/folder))
			recursion_levels += 1
			if (recursion_levels > src.max_recursion)
				src.message_user("Maximum recursion depth reached, aborting.")
				mainframe_prog_exit
				return

			var/datum/computer/folder/folder = target
			for (var/datum/computer/C as anything in folder.contents)
				initlist += ABSOLUTE_PATH(C.name, initlist[i])

		else if (istype(target, /datum/computer/file/record))
			var/datum/computer/file/record/record = target
			for (var/j in 1 to length(record.fields))
				var/field_name = record.fields[j]
				var/field_data = record.fields[field_name]
				var/field = (!isnull(field_data)) ? "[field_name]=[field_data]" : field_name

				if (regex.Find("[field]"))
					if (print_only_match)
						grep_results += "[regex.match]"
					else if (plain)
						grep_results += "[field]"
					else
						grep_results += "[record.name]:[j]:[field]"

		else if (!no_messages)
			grep_results += "[target] could not be read."

	if (length(grep_results))
		src.message_user("[jointext(grep_results, "|n")]", "multiline")

	mainframe_prog_exit
