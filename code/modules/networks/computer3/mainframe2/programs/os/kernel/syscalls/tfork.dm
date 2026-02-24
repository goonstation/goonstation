/datum/dwaine_syscall/tfork
	id = DWAINE_COMMAND_TFORK

/datum/dwaine_syscall/tfork/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog)
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/fork = src.kernel.master.run_program(caller_prog, null, caller_prog, data["args"], TRUE)
	if (!fork)
		return ESIG_GENERIC

	return fork.progid | ESIG_DATABIT
