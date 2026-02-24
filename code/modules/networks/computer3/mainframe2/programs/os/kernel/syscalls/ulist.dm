/datum/dwaine_syscall/ulist
	id = DWAINE_COMMAND_ULIST

/datum/dwaine_syscall/ulist/execute(sendid, list/data, datum/computer/file/file)
	var/list/user_list = list()

	for (var/uid in src.kernel.users)
		var/datum/mainframe2_user_data/user = src.kernel.users[uid]
		if (!istype(user) || !istype(user.user_file))
			continue

		var/groupnum = user.user_file.fields["group"]
		if (!isnum(groupnum))
			groupnum = "N"

		var/logtime = user.user_file.fields["logtime"]
		if (isnum(logtime))
			logtime = time2text(logtime, "hh:mm")
		else
			logtime = "??:??"

		user_list[uid] = "[logtime] [groupnum] [user.user_file.fields["name"]]"

	if (!length(user_list))
		return ESIG_GENERIC

	return user_list
