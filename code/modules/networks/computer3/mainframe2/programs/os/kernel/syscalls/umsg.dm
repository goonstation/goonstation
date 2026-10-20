/datum/dwaine_syscall/umsg
	id = DWAINE::SYSCALL::UMSG

/datum/dwaine_syscall/umsg/execute(sendid, list/data, datum/computer/file/file)
	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog || !caller_prog.useracc)
		return DWAINE::ERR::SIG::NOUSR

	var/sender_name = caller_prog.useracc.user_name
	if (!sender_name)
		return DWAINE::ERR::SIG::NOUSR

	var/message = data["data"]
	if (!ckeyEx(message))
		return DWAINE::ERR::SIG::GENERIC

	var/target_uid = data["term"]
	if (!target_uid)
		return DWAINE::ERR::SIG::NOTARGET

	var/datum/mainframe2_user_data/target = src.kernel.users[target_uid]
	if (!istype(target))
		for (var/uid in src.kernel.users)
			var/datum/mainframe2_user_data/user = src.kernel.users[uid]
			if (!user?.user_file)
				continue

			if (!(lowertext(user.user_file.fields["name"]) == target_uid))
				continue

			target = user
			target_uid = uid
			break

		if (!istype(target))
			return DWAINE::ERR::SIG::NOTARGET

	else if (!istype(target.user_file))
		return DWAINE::ERR::SIG::NOTARGET

	if (caller_prog.useracc == target)
		return DWAINE::ERR::SIG::NOTARGET

	if (!(target.user_file.fields["accept_msg"] == "1"))
		return DWAINE::ERR::SIG::IOERR

	src.kernel.message_term("MSG from \[[sender_name]]: [message]", target_uid, "multiline")
	return DWAINE::ERR::SIG::SUCCESS
