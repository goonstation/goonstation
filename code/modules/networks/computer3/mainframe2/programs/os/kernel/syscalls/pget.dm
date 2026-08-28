/datum/dwaine_syscall/pget
	id = DWAINE::SYSCALL::PGET

/datum/dwaine_syscall/pget/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return DWAINE::ERR::SIG::GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!data["path"] || !caller_prog)
		return DWAINE::ERR::SIG::NOTARGET

	var/datum/computer/folder/target_directory = src.kernel.parse_directory(data["path"], src.kernel.holder.root, FALSE, caller_prog.useracc)
	if (!target_directory) // no part of the given filepath exists at all
		return DWAINE::ERR::SIG::NOFILE

	return target_directory
