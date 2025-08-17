/datum/dwaine_syscall/fget
	id = DWAINE_COMMAND_FGET

/datum/dwaine_syscall/fget/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!data["path"] || !caller_prog)
		return ESIG_NOTARGET

	var/datum/computer/target_file = src.kernel.parse_datum_directory(data["path"], src.kernel.holder.root, FALSE, caller_prog.useracc)
	if (!target_file)
		return ESIG_NOFILE

	return target_file
