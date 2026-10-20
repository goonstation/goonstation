/datum/dwaine_syscall/tlist
	id = DWAINE::SYSCALL::TLIST

/datum/dwaine_syscall/tlist/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return DWAINE::ERR::SIG::GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog)
		return DWAINE::ERR::SIG::GENERIC

	var/list/datum/computer/file/mainframe_program/progs = list()
	progs.len = length(src.kernel.master.processing)

	for (var/i in 1 to length(src.kernel.master.processing))
		var/datum/computer/file/mainframe_program/MP = src.kernel.master.processing[i]
		if (MP && (MP.parent_task == caller_prog))
			progs[i] = MP

	return progs
