/datum/dwaine_syscall/fwrite
	id = DWAINE_COMMAND_FWRITE

/datum/dwaine_syscall/fwrite/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!file || !data["path"] || !caller_prog)
		return ESIG_NOTARGET

	if (src.kernel.is_name_invalid(file.name))
		return ESIG_GENERIC

	var/datum/mainframe2_user_data/user = caller_prog.useracc
	var/datum/computer/folder/destination = src.kernel.parse_directory(data["path"], src.kernel.holder.root, (data["mkdir"] == 1), user)
	if (!destination || (destination == src.kernel.master.runfolder))
		return ESIG_NOTARGET

	var/datum/computer/file/record/destfile = src.kernel.get_computer_datum(file.name, destination)
	if (istype(destfile, /datum/computer/folder))
		destination = destfile

	if (user && !src.kernel.check_write_permission(destination, user))
		return ESIG_NOWRITE

	var/delete_dest = FALSE
	if (destfile)
		if ((data["append"] == 1) && (!user || src.kernel.check_write_permission(destfile, user)) && (istype(destfile) && istype(file, /datum/computer/file/record)))
			file:fields = destfile.fields + file:fields
			delete_dest = TRUE

		else if ((data["replace"] == 1) && (!user || src.kernel.check_mode_permission(destfile, user)))
			delete_dest = TRUE

		else if (istype(destfile, /datum/computer/file))
			return ESIG_GENERIC

	if (!destination.can_add_file(file, user))
		return ESIG_GENERIC

	if (delete_dest && destfile)
		destfile.dispose()

	destination.add_file(file, user)
	return ESIG_SUCCESS
