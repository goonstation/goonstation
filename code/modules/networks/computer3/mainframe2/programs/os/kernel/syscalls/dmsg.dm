/datum/dwaine_syscall/dmsg
	id = DWAINE_COMMAND_DMSG

/datum/dwaine_syscall/dmsg/execute(sendid, list/data, datum/computer/file/file)
	var/driver_id = data["target"]
	var/datum/computer/file/mainframe_program/driver/driver

	if (data["mode"] == 1)
		for (var/datum/computer/file/mainframe_program/driver/D as anything in src.kernel.processing_drivers)
			if (!cmptext("[driver_id]", D.name))
				continue

			driver = D
			break

	else if (isnum(driver_id) && (driver_id >= 1) && (driver_id <= length(src.kernel.processing_drivers)))
		driver = src.kernel.processing_drivers[driver_id]

	if (!istype(driver))
		return ESIG_NOTARGET

	data["command"] = data["dcommand"]
	data["target"] = data["dtarget"]
	return driver.receive_progsignal(sendid, data, file)
