/datum/dwaine_syscall/ugroup
	id = DWAINE::SYSCALL::UGROUP

/datum/dwaine_syscall/ugroup/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return DWAINE::ERR::SIG::GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog || !isnum(data["group"]))
		return DWAINE::ERR::SIG::GENERIC

	if (!caller_prog.useracc || !caller_prog.useracc.user_file)
		return DWAINE::ERR::SIG::NOUSR

	caller_prog.useracc.user_file.fields["group"] = clamp(0, data["group"], 255)
	return DWAINE::ERR::SIG::SUCCESS
