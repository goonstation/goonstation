/datum/computer/file/user_data
	name = "user account"
	extension = "USR"
	size = 1

	// Store the data an ID card would.
	var/registered = null
	var/assignment = null
	var/list/access = null

	var/net_id = null
	var/tmp/authlevel = 0
	var/tmp/datum/computer/file/mainframe_program/active_program = null
	var/tmp/datum/computer/folder/current_folder = null

/datum/computer/file/user_data/New()
	. = ..()
	src.access = list()

/datum/computer/file/user_data/disposing()
	src.active_program = null
	src.current_folder = null
	src.access = null
	. = ..()


/datum/mainframe2_user_data
	var/datum/computer/file/record/user_file = null
	var/datum/computer/folder/user_file_folder = null
	var/user_filename = null
	var/user_name = "GENERIC"
	var/user_id = null
	var/full_user = 0
	var/datum/computer/file/mainframe_program/current_prog = null
	var/tmp/datum/computer/file/mainframe_program/shell/base_shell_instance = null

/datum/mainframe2_user_data/disposing()
	src.current_prog = null
	src.user_file = null
	src.user_file_folder = null
	src.base_shell_instance = null
	. = ..()

/datum/mainframe2_user_data/proc/reload_user_file()
	if (!src.user_file_folder || !src.user_filename)
		return FALSE

	for (var/datum/computer/file/record/R in src.user_file_folder.contents)
		if (R.name == src.user_filename)
			src.user_file = R
			return TRUE

	return FALSE
