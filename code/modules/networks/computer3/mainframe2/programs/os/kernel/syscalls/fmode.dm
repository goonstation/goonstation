/datum/dwaine_syscall/fmode
	id = DWAINE_COMMAND_FMODE

/datum/dwaine_syscall/fmode/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return ESIG_GENERIC

	if (!isnum(data["permission"]))
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!data["path"] || !caller_prog)
		return ESIG_NOTARGET

	var/datum/computer/target_file = src.kernel.parse_datum_directory(data["path"], src.kernel.holder.root, FALSE, caller_prog.useracc)
	if (!istype(target_file))
		return ESIG_NOFILE

	if (caller_prog.useracc && !src.kernel.check_mode_permission(target_file, caller_prog.useracc))
		return ESIG_GENERIC

	src.kernel.change_metadata(target_file, "permission", data["permission"])
	return ESIG_SUCCESS
