/datum/dwaine_syscall/confget
	id = DWAINE_COMMAND_CONFGET

/datum/dwaine_syscall/confget/execute(sendid, list/data, datum/computer/file/file)
	if (!data["fname"])
		return ESIG_NOTARGET

	var/datum/computer/folder/config_folder = src.kernel.parse_directory(setup_filepath_config, src.kernel.holder.root, FALSE)
	if (!config_folder)
		return ESIG_NOTARGET

	var/datum/computer/file/target_file = src.kernel.get_file_name(data["fname"], config_folder)
	if (!target_file)
		return ESIG_NOFILE

	return target_file
