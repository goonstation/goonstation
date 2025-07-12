/datum/dwaine_syscall/dlist
	id = DWAINE_COMMAND_DLIST

/datum/dwaine_syscall/dlist/execute(sendid, list/data, datum/computer/file/file)
	var/list/driver_list = list()
	var/target_tag = lowertext(data["dtag"])
	var/omit_wrong_tags = (data["mode"] == 1)

	if (!omit_wrong_tags)
		driver_list.len = length(src.kernel.processing_drivers)

	for (var/i in 1 to length(src.kernel.processing_drivers))
		var/datum/computer/file/mainframe_program/driver/D = src.kernel.processing_drivers[i]
		if (!istype(D))
			continue

		if (D.disposed)
			src.kernel.processing_drivers[i] = null
			continue

		if (D.termtag != target_tag)
			continue

		if (!omit_wrong_tags)
			driver_list[i] = "[D.name]"

		driver_list["[D.name]"] = D.status

	if (!length(driver_list))
		return ESIG_GENERIC

	return driver_list
