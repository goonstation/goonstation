/datum/dwaine_syscall/confget
	id = DWAINE::SYSCALL::CONFGET

/datum/dwaine_syscall/confget/execute(sendid, list/data, datum/computer/file/file)
	if (!data["fname"])
		return DWAINE::ERR::SIG::NOTARGET

	var/datum/computer/folder/config_folder = src.kernel.parse_directory(DWAINE::DIRECTORY::CONFIG, src.kernel.holder.root, FALSE)
	if (!config_folder)
		return DWAINE::ERR::SIG::NOTARGET

	var/datum/computer/file/target_file = src.kernel.get_file_name(data["fname"], config_folder)
	if (!target_file)
		return DWAINE::ERR::SIG::NOFILE

	return target_file
