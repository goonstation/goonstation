/datum/dwaine_syscall/fmode
	id = DWAINE::SYSCALL::FMODE

/datum/dwaine_syscall/fmode/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return DWAINE::ERR::SIG::GENERIC

	if (!isnum(data["permission"]))
		return DWAINE::ERR::SIG::GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!data["path"] || !caller_prog)
		return DWAINE::ERR::SIG::NOTARGET

	var/datum/computer/target_file = src.kernel.parse_datum_directory(data["path"], src.kernel.holder.root, FALSE, caller_prog.useracc)
	if (!istype(target_file))
		return DWAINE::ERR::SIG::NOFILE

	if (caller_prog.useracc && !src.kernel.check_mode_permission(target_file, caller_prog.useracc))
		return DWAINE::ERR::SIG::GENERIC

	src.kernel.change_metadata(target_file, "permission", data["permission"])
	return DWAINE::ERR::SIG::SUCCESS
