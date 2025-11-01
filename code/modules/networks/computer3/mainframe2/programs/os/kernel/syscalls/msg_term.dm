/datum/dwaine_syscall/msg_term
	id = DWAINE_COMMAND_MSG_TERM

/datum/dwaine_syscall/msg_term/execute(sendid, list/data, datum/computer/file/file)
	if (!data["term"])
		return ESIG_NOTARGET

	if (file)
		return src.kernel.file_term(file, data["term"], data["data"])
	else
		return src.kernel.message_term(data["data"], data["term"], data["render"])
