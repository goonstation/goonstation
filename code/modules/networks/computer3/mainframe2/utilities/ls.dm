/datum/computer/file/mainframe_program/utility/ls
	name = "ls"

/datum/computer/file/mainframe_program/utility/ls/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	var/descriptive = FALSE

	if (initparams)
		var/list/initlist = splittext(initparams, " ")
		if (length(initlist) && (initlist[1] == "-l"))
			initparams = jointext(initlist - initlist[1], "")
			descriptive = TRUE

	var/current = src.read_user_field("curpath")
	if (initparams)
		initparams = ABSOLUTE_PATH(initparams, current)
	else
		initparams = (current || "/")

	var/datum/computer/target = src.signal_program(1, list("command" = DWAINE_COMMAND_FGET, "path" = initparams))

	if (istype(target, /datum/computer/folder))
		var/datum/computer/folder/F = target
		var/message = null
		for (var/datum/computer/C as anything in F.contents)
			if (!src.check_read_permission(C, src.useracc))
				continue

			if (descriptive)
				message += src.print_file_description(C)
			else if (!dd_hasprefix(C.name, "_"))
				message += "[C.name]|n"

		message ||= " No files.|n"
		src.message_user("Contents of [initparams]|n" + message, "multiline")

	else if (istype(target, /datum/computer/file) && descriptive)
		src.message_user(src.print_file_description(target), "multiline")

	else
		src.message_user("Error: Invalid resource or directory.")

	mainframe_prog_exit

/datum/computer/file/mainframe_program/utility/ls/proc/print_file_description(datum/computer/C)
	C.metadata ||= list()

	var/size = null
	var/extension = null
	if (istype(C, /datum/computer/folder))
		size = @"[--]"
		extension = "DIR"
	else
		size = "\[[add_zero(C.size, 2)]\]"
		extension = copytext(C:extension, 1, 4)

	var/group = null
	if (isnum(text2num_safe(C.metadata["group"])))
		group = add_zero(C.metadata["group"], 3)
	else
		group = "ANY"

	var/permissions = null
	var/permissions_bitflag = C.metadata["permission"]
	if (isnum(permissions_bitflag))
		permissions = {"\
			[(permissions_bitflag & COMP_DOWNER) ? "s" : "-"]\
			[(permissions_bitflag & COMP_ROWNER) ? "r" : "-"]\
			[(permissions_bitflag & COMP_WOWNER) ? "w" : "-"]\
			[(permissions_bitflag & COMP_DGROUP) ? "s" : "-"]\
			[(permissions_bitflag & COMP_RGROUP) ? "r" : "-"]\
			[(permissions_bitflag & COMP_WGROUP) ? "w" : "-"]\
			[(permissions_bitflag & COMP_DOTHER) ? "s" : "-"]\
			[(permissions_bitflag & COMP_ROTHER) ? "r" : "-"]\
			[(permissions_bitflag & COMP_WOTHER) ? "w" : "-"]\
		"}
	else
		permissions = "srwsrwsrw"

	var/owner = pad_leading((C.metadata["owner"] || "Nobody"), 16)
	var/name = C.name

	return "[size] [group][permissions] [extension][owner] [name]|n"
