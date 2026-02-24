/datum/dwaine_syscall/fkill
	id = DWAINE_COMMAND_FKILL

/datum/dwaine_syscall/fkill/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!data["path"] || !caller_prog)
		return ESIG_NOTARGET

	var/datum/mainframe2_user_data/user = caller_prog.useracc
	var/datum/computer/target_file = src.kernel.parse_datum_directory(data["path"], src.kernel.holder.root, FALSE, user)

	if (!target_file || (target_file.holding_folder == src.kernel.master.runfolder) || (target_file == src.kernel.master.runfolder) || (target_file == src.kernel.holder.root))
		return ESIG_NOFILE

	if (user && !src.kernel.check_mode_permission(target_file, user))
		return ESIG_NOFILE

	if (istype(target_file.holding_folder, /datum/computer/file/mainframe_program/driver/mountable))
		target_file.holding_folder.remove_file(target_file)
		return ESIG_SUCCESS

	target_file.dispose()
	return ESIG_SUCCESS
