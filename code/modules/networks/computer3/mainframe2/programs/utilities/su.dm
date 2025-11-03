/datum/computer/file/mainframe_program/utility/su
	name = "su"

/datum/computer/file/mainframe_program/utility/su/initialize(initparams)
	if (..() || (src.read_user_field("group") == 0))
		mainframe_prog_exit
		return

	src.message_user("Please enter *authorized* card and \"term_login\"")

/datum/computer/file/mainframe_program/utility/su/receive_progsignal(sendid, list/data, datum/computer/file/file)
	if (..() || (data["command"] != DWAINE_COMMAND_RECVFILE) || !istype(file, /datum/computer/file/record))
		return ESIG_GENERIC

	if (!src.useracc)
		return ESIG_NOUSR

	var/datum/computer/file/record/user_data = file
	if (!user_data.fields["registered"] || !user_data.fields["assignment"])
		return ESIG_GENERIC

	if ("[access_dwaine_superuser]" in splittext(user_data.fields["access"], ";"))
		if (src.signal_program(1, list("command" = DWAINE_COMMAND_UGROUP, "group" = 0)) == ESIG_SUCCESS)
			src.message_user("You are now authorized.")
			usr.unlock_medal("I'm in", TRUE)
		else
			src.message_user("Error: Unable to authorize.")
	else
		src.message_user("Error: Insufficient credentials.")

	mainframe_prog_exit

/datum/computer/file/mainframe_program/utility/su/input_text(text)
	mainframe_prog_exit
