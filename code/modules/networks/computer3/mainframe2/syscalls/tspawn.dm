/datum/dwaine_syscall/tspawn
	id = DWAINE_COMMAND_TSPAWN

/datum/dwaine_syscall/tspawn/execute(sendid, list/data, datum/computer/file/file)
	if (!data["path"])
		return ESIG_NOTARGET

	if (!sendid)
		return ESIG_GENERIC

	var/pass_user = (data["passusr"] == 1)

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog)
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/task_model = src.kernel.parse_file_directory(data["path"], src.kernel.holder.root, FALSE)
	if (!task_model?.executable)
		return ESIG_NOTARGET

	task_model = src.kernel.master.run_program(task_model, (pass_user ? caller_prog.useracc : null), caller_prog, data["args"])
	if (!task_model)
		return ESIG_GENERIC

	return task_model
