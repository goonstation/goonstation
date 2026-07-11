/datum/computer/file/mainframe_program/utility/chmod
	name = "chmod"

/datum/computer/file/mainframe_program/utility/chmod/initialize(initparams)
	if (..() || !src.useracc)
		mainframe_prog_exit
		return

	var/list/initlist = splittext(initparams, " ")
	if (length(initlist) < 2)
		src.message_user("Error: Must specify permission value and target path.")
		mainframe_prog_exit
		return

	var/new_permissions = text2num_safe(initlist[1])
	if (!isnum(new_permissions))
		src.message_user("Error: Invalid permission value.")
		mainframe_prog_exit
		return

	new_permissions = src.process_permissions(new_permissions)
	if (new_permissions < 0)
		src.message_user("Error: Invalid permission value.")
		mainframe_prog_exit
		return

	var/current = src.read_user_field("curpath")
	switch (src.signal_program(1, list("command" = DWAINE::SYSCALL::FMODE, "path" = ABSOLUTE_PATH(initlist[2], current), "permission" = new_permissions)))
		if (DWAINE::ERR::SIG::NOFILE, DWAINE::ERR::SIG::NOTARGET)
			src.message_user("Error: Invalid target path.")

		if (DWAINE::ERR::SIG::GENERIC)
			src.message_user("Error: Access denied.")

	mainframe_prog_exit

/datum/computer/file/mainframe_program/utility/chmod/proc/process_permissions(permissions)
	if ((permissions < 0) || (permissions > 888))
		return -1

	var/otherperm = permissions % 10
	permissions /= 10
	var/groupperm = permissions % 10
	permissions /= 10
	var/ownerperm = permissions % 10

	. = 0
	if (otherperm & 4)
		. |= DWAINE::PERM::BIT::OTHER_READ
	if (otherperm & 2)
		. |= DWAINE::PERM::BIT::OTHER_WRITE
	if (otherperm & 1)
		. |= DWAINE::PERM::BIT::OTHER_EXECUTE

	if (groupperm & 4)
		. |= DWAINE::PERM::BIT::GROUP_READ
	if (groupperm & 2)
		. |= DWAINE::PERM::BIT::GROUP_WRITE
	if (groupperm & 1)
		. |= DWAINE::PERM::BIT::GROUP_EXECUTE

	if (ownerperm & 4)
		. |= DWAINE::PERM::BIT::OWNER_READ
	if (ownerperm & 2)
		. |= DWAINE::PERM::BIT::OWNER_WRITE
	if (ownerperm & 1)
		. |= DWAINE::PERM::BIT::OWNER_EXECUTE
