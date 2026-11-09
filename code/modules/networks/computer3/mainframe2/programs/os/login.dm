/**
 *	The user login manager is responsible for passing user login credentials from the user to the kernel to be authenticated,
 *	displaying the daily welcome message to the user, and for notifying the user in the event of a login failure.
 */
/datum/computer/file/mainframe_program/login
	name = "Login"
	size = 2
	executable = 0

	var/motd = "Welcome to DWAINE System VI!|nCopyright 2050 Thinktronic Systems, LTD."
	var/setup_filename_motd = "motd"

/datum/computer/file/mainframe_program/login/initialize()
	if (..())
		return

	var/datum/computer/file/record/record = src.signal_program(1, list("command" = DWAINE::SYSCALL::CONFGET, "fname" = src.setup_filename_motd))
	if (istype(record))
		src.motd = jointext(record.fields, "|n")
		src.motd = copytext(src.motd, 1, 255)
	else
		src.motd = initial(src.motd)

	src.message_user("[src.motd]|nPlease enter card and \"term_login\"", "multiline")

/datum/computer/file/mainframe_program/login/receive_progsignal(sendid, list/data, datum/computer/file/record/file)
	if (..() || (data["command"] != DWAINE::SYSCALL::RECVFILE) || !istype(file))
		return DWAINE::ERR::SIG::GENERIC

	if (!src.useracc)
		return DWAINE::ERR::SIG::NOUSR

	if (!file.fields["registered"] || !file.fields["assignment"])
		return DWAINE::ERR::SIG::GENERIC

	if (file.fields["code"] != netpass_login)
		return DWAINE::ERR::SIG::GENERIC

	if (src.signal_program(1, list("command" = DWAINE::SYSCALL::ULOGIN, "name" = file.fields["registered"])) != DWAINE::ERR::SIG::SUCCESS)
		src.message_user("Error: Login failure. Please try again.")
		return DWAINE::ERR::SIG::GENERIC

	mainframe_prog_exit
