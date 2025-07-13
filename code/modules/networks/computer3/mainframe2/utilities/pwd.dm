/datum/computer/file/mainframe_program/utility/pwd
	name = "pwd"

/datum/computer/file/mainframe_program/utility/pwd/initialize(initparams)
	src.message_user(src.read_user_field("curpath"))
	mainframe_prog_exit
