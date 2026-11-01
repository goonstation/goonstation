/datum/dwaine_syscall/tfork
	id = DWAINE::SYSCALL::TFORK

/datum/dwaine_syscall/tfork/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return DWAINE::ERR::SIG::GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog)
		return DWAINE::ERR::SIG::GENERIC

	var/datum/computer/file/mainframe_program/fork = src.kernel.master.run_program(caller_prog, null, caller_prog, data["args"], TRUE)
	if (!fork)
		return DWAINE::ERR::SIG::GENERIC

	return fork.progid | DWAINE::ERR::SIG::DATABIT
