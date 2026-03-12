/datum/dwaine_syscall/ugroup
	id = DWAINE_COMMAND_UGROUP

/datum/dwaine_syscall/ugroup/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog || !isnum(data["group"]))
		return ESIG_GENERIC

	if (!caller_prog.useracc || !caller_prog.useracc.user_file)
		return ESIG_NOUSR

	caller_prog.useracc.user_file.fields["group"] = clamp(0, data["group"], 255)
	return ESIG_SUCCESS
