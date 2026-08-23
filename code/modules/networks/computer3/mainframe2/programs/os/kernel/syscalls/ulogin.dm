/datum/dwaine_syscall/ulogin
	id = DWAINE::SYSCALL::ULOGIN

/datum/dwaine_syscall/ulogin/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return DWAINE::ERR::SIG::GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog || !data["name"])
		return DWAINE::ERR::SIG::GENERIC

	if (data["data"] && (data["name"] == "TEMP"))
		return (src.kernel.login_temp_user(data["data"], null, caller_prog)) ? DWAINE::ERR::SIG::GENERIC : DWAINE::ERR::SIG::SUCCESS

	if (!caller_prog.useracc)
		return DWAINE::ERR::SIG::NOUSR

	if (src.kernel.login_user(caller_prog.useracc, data["name"], data["sysop"], (data["service"] != 1)))
		return DWAINE::ERR::SIG::GENERIC

	return DWAINE::ERR::SIG::SUCCESS
