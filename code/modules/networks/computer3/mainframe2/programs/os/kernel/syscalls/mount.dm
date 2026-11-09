/datum/dwaine_syscall/mount
	id = DWAINE::SYSCALL::MOUNT

/datum/dwaine_syscall/mount/execute(sendid, list/data, datum/computer/file/file)
	if (!data["id"])
		return DWAINE::ERR::SIG::NOTARGET

	var/datum/computer/file/mainframe_program/driver/mountable/mountable = src.kernel.parse_file_directory("[DWAINE::DIRECTORY::DEVICES]/_[data["id"]]", src.kernel.holder.root, FALSE)
	if (!istype(mountable))
		return DWAINE::ERR::SIG::NOTARGET

	var/datum/computer/folder/mount_folder = src.kernel.parse_directory(DWAINE::DIRECTORY::MOUNTED, src.kernel.holder.root, TRUE)
	if (!istype(mount_folder))
		return DWAINE::ERR::SIG::NOTARGET

	var/datum/computer/folder/mountpoint/mountpoint = src.kernel.get_computer_datum("_[data["id"]]", mount_folder)
	if (istype(mountpoint))
		mountpoint.dispose()

	else if (istype(mountpoint, /datum/computer))
		return DWAINE::ERR::SIG::GENERIC

	mountpoint = new /datum/computer/folder/mountpoint(mountable)
	mountpoint.name = "_[data["id"]]"
	if (!mount_folder.add_file(mountpoint))
		mountpoint.dispose()
		return DWAINE::ERR::SIG::GENERIC

	if (data["link"])
		var/datum/computer/folder/link/symlink = src.kernel.get_computer_datum(data["link"], mount_folder)
		if (!symlink || istype(symlink))
			if (symlink)
				symlink.dispose()

			symlink = new /datum/computer/folder/link(mountpoint)
			symlink.name = data["link"]
			if (!mount_folder.add_file(symlink))
				symlink.dispose()

	mountpoint.metadata["permission"] = mountable.default_permission
	mountpoint.metadata["group"] = 1
	mountpoint.metadata["owner"] = "Nobody"
	return DWAINE::ERR::SIG::SUCCESS
