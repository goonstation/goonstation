/datum/dwaine_syscall/ulogin
	id = DWAINE_COMMAND_ULOGIN

/datum/dwaine_syscall/ulogin/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog || !data["name"])
		return ESIG_GENERIC

	if (data["data"] && (data["name"] == "TEMP"))
		return (src.kernel.login_temp_user(data["data"], null, caller_prog)) ? ESIG_GENERIC : ESIG_SUCCESS

	if (!caller_prog.useracc)
		return ESIG_NOUSR

	if (src.kernel.login_user(caller_prog.useracc, data["name"], data["sysop"], (data["service"] != 1)))
		return ESIG_GENERIC

	return ESIG_SUCCESS
