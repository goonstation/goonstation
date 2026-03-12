/datum/dwaine_syscall/umsg
	id = DWAINE_COMMAND_UMSG

/datum/dwaine_syscall/umsg/execute(sendid, list/data, datum/computer/file/file)
	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog || !caller_prog.useracc)
		return ESIG_NOUSR

	var/sender_name = caller_prog.useracc.user_name
	if (!sender_name)
		return ESIG_NOUSR

	var/message = data["data"]
	if (!ckeyEx(message))
		return ESIG_GENERIC

	var/target_uid = data["term"]
	if (!target_uid)
		return ESIG_NOTARGET

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
			return ESIG_NOTARGET

	else if (!istype(target.user_file))
		return ESIG_NOTARGET

	if (caller_prog.useracc == target)
		return ESIG_NOTARGET

	if (!(target.user_file.fields["accept_msg"] == "1"))
		return ESIG_IOERR

	src.kernel.message_term("MSG from \[[sender_name]]: [message]", target_uid, "multiline")
	return ESIG_SUCCESS
