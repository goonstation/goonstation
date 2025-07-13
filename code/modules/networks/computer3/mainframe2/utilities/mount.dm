/datum/computer/file/mainframe_program/utility/mount
	name = "mount"

/datum/computer/file/mainframe_program/utility/mount/initialize(initparams)
	if (..())
		mainframe_prog_exit
		return

	. = src.read_user_field("group")
	if ((. > src.metadata["group"]) && (. != 0))
		src.message_user("Error: Access denied.")
		mainframe_prog_exit
		return

	var/list/initlist = splittext(initparams, " ")
	if (length(initlist) < 2)
		src.message_user("Error: Must specify device file and mount point names.")
		mainframe_prog_exit
		return

	var/driver_id = initlist[1]
	if (!driver_id)
		src.message_user("Error: Invalid device file id.")
		mainframe_prog_exit
		return

	var/mount_name = copytext(initlist[2], 1, 16)
	if (src.is_name_invalid(mount_name))
		src.message_user("Error: Invalid mountpoint name.")
		mainframe_prog_exit
		return

	if (src.signal_program(1, list("command" = DWAINE_COMMAND_MOUNT, "id" = driver_id, "link" = mount_name)) != ESIG_SUCCESS)
		src.message_user("Error: Could not mount filesystem.")

	mainframe_prog_exit
