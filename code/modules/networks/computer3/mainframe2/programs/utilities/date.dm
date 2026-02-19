/datum/computer/file/mainframe_program/utility/date
	name = "date"
	var/opt_data = null

/datum/computer/file/mainframe_program/utility/date/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	src.opt_data = null
	if (src.signal_program(1, list("command" = DWAINE_COMMAND_TSPAWN, "passusr" = TRUE, "path" = "/bin/getopt", "args" = "ht: [initparams]")) == ESIG_NOTARGET)
		src.message_user("getopt: command not found.")
		mainframe_prog_exit
		return

	if (!src.opt_data)
		src.message_user("date: No response from getopt.")
		mainframe_prog_exit
		return

	if (copytext(src.opt_data, 1, 7) == "getopt")
		src.message_user(src.opt_data)
		mainframe_prog_exit
		return

	var/list/arguments = global.optparse(src.opt_data)
	if (!arguments)
		src.message_user("date: Error parsing options: [src.opt_data]")
		src.usage()
		mainframe_prog_exit
		return

	var/list/options = arguments[1]
	if (options["h"])
		src.usage()

	else if (!options["t"])
		src.message_reply_and_user("[ticker.round_elapsed_ticks]")

	else
		var/format = options["t"]

		var/t = ticker.round_elapsed_ticks % 10
		format = replacetext(format, "%t", "[t]")
		var/s = round(ticker.round_elapsed_ticks / 10) % 60
		format = replacetext(format, "%s", "[s]")
		var/m = round(ticker.round_elapsed_ticks / 600) % 60
		format = replacetext(format, "%m", "[m]")
		var/h = round(ticker.round_elapsed_ticks / 36000)
		format = replacetext(format, "%h", "[h]")

		src.message_reply_and_user(format)

	mainframe_prog_exit

/datum/computer/file/mainframe_program/utility/date/receive_progsignal(sendid, list/data, datum/computer/file/file)
	if (..())
		return ESIG_GENERIC

	switch (data["command"])
		if (DWAINE_COMMAND_REPLY)
			if (data["sender_tag"] == "getopt")
				src.opt_data = data["data"]
				return ESIG_USR4
			else
				return ESIG_GENERIC

		if (DWAINE_COMMAND_MSG_TERM)
			src.message_user(data["data"])

		else
			return ESIG_GENERIC

	return ESIG_SUCCESS

/datum/computer/file/mainframe_program/utility/date/proc/usage()
	src.message_user("Date and time utility. Without parameters, outputs current Spacetime Stamp.")
	src.message_user("Format specifiers: %h hour, %m minute, %s second, %t one-tenth of a second.")
	src.message_user("Usage:")
	src.message_user("[src.name] \[-t FORMAT\]")

/datum/computer/file/mainframe_program/utility/date/proc/message_reply_and_user(message)
	var/list/data = list("command" = DWAINE_COMMAND_REPLY, "data" = message, "sender_tag" = "date")
	if (src.useracc)
		data["term"] = src.useracc.user_id

	if (src.signal_program(src.parent_task.progid, data) != ESIG_USR4)
		src.message_user(message)
