/datum/dwaine_syscall/dget
	id = DWAINE::SYSCALL::DGET

/datum/dwaine_syscall/dget/execute(sendid, list/data, datum/computer/file/file)
	var/target_tag = lowertext(data["dtag"] || data["dnetid"])
	if (!target_tag)
		return DWAINE::ERR::SIG::NOTARGET

	for (var/i in 1 to length(src.kernel.processing_drivers))
		var/datum/computer/file/mainframe_program/driver/driver = src.kernel.processing_drivers[i]
		if (!istype(driver))
			continue

		if (driver.disposed)
			src.kernel.processing_drivers[i] = null
			continue

		if ((driver.termtag == target_tag) || (driver.name == target_tag))
			return (i | DWAINE::ERR::SIG::DATABIT)

	return DWAINE::ERR::SIG::NOTARGET
