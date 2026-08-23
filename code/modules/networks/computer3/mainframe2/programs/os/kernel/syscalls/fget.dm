/datum/dwaine_syscall/fget
	id = DWAINE::SYSCALL::FGET

/datum/dwaine_syscall/fget/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return DWAINE::ERR::SIG::GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!data["path"] || !caller_prog)
		return DWAINE::ERR::SIG::NOTARGET

	var/datum/computer/target_file = src.kernel.parse_datum_directory(data["path"], src.kernel.holder.root, FALSE, caller_prog.useracc)
	if (!target_file)
		return DWAINE::ERR::SIG::NOFILE

	return target_file
