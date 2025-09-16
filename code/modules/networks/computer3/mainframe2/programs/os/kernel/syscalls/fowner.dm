/datum/dwaine_syscall/fowner
	id = DWAINE_COMMAND_FOWNER

/datum/dwaine_syscall/fowner/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return ESIG_GENERIC

	if (!isnum(data["group"]) && !data["owner"])
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!data["path"] || !caller_prog)
		return ESIG_NOTARGET

	var/datum/computer/target_file = src.kernel.parse_datum_directory(data["path"], src.kernel.holder.root, FALSE, caller_prog.useracc)
	if (!istype(target_file))
		return ESIG_NOFILE

	if (caller_prog.useracc && !src.kernel.check_mode_permission(target_file, caller_prog.useracc))
		return ESIG_GENERIC

	if (data["owner"])
		src.kernel.change_metadata(target_file, "owner", copytext(data["owner"], 1, 16))

	if (isnum(data["group"]))
		src.kernel.change_metadata(target_file, "group", clamp(data["group"], 0, 255))

	return ESIG_SUCCESS
