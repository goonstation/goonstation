/datum/dwaine_syscall/tkill
	id = DWAINE_COMMAND_TKILL

/datum/dwaine_syscall/tkill/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return ESIG_NOTARGET

	var/target_id = data["target"]
	if (!isnum(target_id) || (target_id < 0) || (target_id > length(src.kernel.master.processing)))
		return ESIG_NOTARGET

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog)
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/target_task = src.kernel.master.processing[target_id]
	if (!target_task)
		return ESIG_SUCCESS

	if (target_task.parent_task != caller_prog)
		return ESIG_GENERIC

	var/datum/mainframe2_user_data/target_user = target_task.useracc
	if (target_user && (!caller_prog.useracc || (target_user.current_prog == target_task)))
		target_user.current_prog = caller_prog
		caller_prog.useracc = target_user

	target_task.handle_quit()

	return ESIG_SUCCESS
