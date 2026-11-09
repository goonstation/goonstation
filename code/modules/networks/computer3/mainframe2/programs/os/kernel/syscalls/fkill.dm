/datum/dwaine_syscall/fkill
	id = DWAINE::SYSCALL::FKILL

/datum/dwaine_syscall/fkill/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return DWAINE::ERR::SIG::GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!data["path"] || !caller_prog)
		return DWAINE::ERR::SIG::NOTARGET

	var/datum/mainframe2_user_data/user = caller_prog.useracc
	var/datum/computer/target_file = src.kernel.parse_datum_directory(data["path"], src.kernel.holder.root, FALSE, user)

	if (!target_file || (target_file.holding_folder == src.kernel.master.runfolder) || (target_file == src.kernel.master.runfolder) || (target_file == src.kernel.holder.root))
		return DWAINE::ERR::SIG::NOFILE

	if (user && !src.kernel.check_mode_permission(target_file, user))
		return DWAINE::ERR::SIG::NOFILE

	if (istype(target_file.holding_folder, /datum/computer/file/mainframe_program/driver/mountable))
		target_file.holding_folder.remove_file(target_file)
		return DWAINE::ERR::SIG::SUCCESS

	target_file.dispose()
	return DWAINE::ERR::SIG::SUCCESS
