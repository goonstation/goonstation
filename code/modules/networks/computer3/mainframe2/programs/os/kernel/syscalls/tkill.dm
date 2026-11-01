/datum/dwaine_syscall/tkill
	id = DWAINE::SYSCALL::TKILL

/datum/dwaine_syscall/tkill/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return DWAINE::ERR::SIG::NOTARGET

	var/target_id = data["target"]
	if (!isnum(target_id) || (target_id < 0) || (target_id > length(src.kernel.master.processing)))
		return DWAINE::ERR::SIG::NOTARGET

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog)
		return DWAINE::ERR::SIG::GENERIC

	var/datum/computer/file/mainframe_program/target_task = src.kernel.master.processing[target_id]
	if (!target_task)
		return DWAINE::ERR::SIG::SUCCESS

	if (target_task.parent_task != caller_prog)
		return DWAINE::ERR::SIG::GENERIC

	var/datum/mainframe2_user_data/target_user = target_task.useracc
	if (target_user && (!caller_prog.useracc || (target_user.current_prog == target_task)))
		target_user.current_prog = caller_prog
		caller_prog.useracc = target_user

	target_task.handle_quit()

	return DWAINE::ERR::SIG::SUCCESS
