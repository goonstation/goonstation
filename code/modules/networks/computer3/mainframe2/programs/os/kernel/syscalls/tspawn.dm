/datum/dwaine_syscall/tspawn
	id = DWAINE::SYSCALL::TSPAWN

/datum/dwaine_syscall/tspawn/execute(sendid, list/data, datum/computer/file/file)
	if (!data["path"])
		return DWAINE::ERR::SIG::NOTARGET

	if (!sendid)
		return DWAINE::ERR::SIG::GENERIC

	var/pass_user = (data["passusr"] == 1)

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog)
		return DWAINE::ERR::SIG::GENERIC

	var/datum/computer/file/mainframe_program/task_model = src.kernel.parse_file_directory(data["path"], src.kernel.holder.root, FALSE)
	if (!task_model?.executable)
		return DWAINE::ERR::SIG::NOTARGET

	task_model = src.kernel.master.run_program(task_model, (pass_user ? caller_prog.useracc : null), caller_prog, data["args"])
	if (!task_model)
		return DWAINE::ERR::SIG::GENERIC

	return task_model
