

//Filetype used to store information on current user
/datum/computer/file/user_data
	name = "user account"
	extension = "USR"
	size = 1

	//Store the data an ID card would.
	var/registered = null
	var/assignment = null
	var/list/access = list()
	//And some more
	var/net_id = null
	var/tmp/authlevel = 0
	var/tmp/datum/computer/file/mainframe_program/active_program = null
	var/tmp/datum/computer/folder/current_folder = null

	disposing()
		active_program = null
		current_folder = null
		access = null

		..()

/*
 *	User Account Datum
 */

/datum/mainframe2_user_data
	var/datum/computer/file/record/user_file = null
	var/datum/computer/folder/user_file_folder = null
	var/user_filename = null
	var/user_name = "GENERIC"
	var/user_id = null
	var/full_user = 0
	var/datum/computer/file/mainframe_program/current_prog = null
	var/tmp/datum/computer/file/mainframe_program/shell/base_shell_instance = null

	disposing()
		current_prog = null
		user_file = null
		user_file_folder = null
		base_shell_instance = null
		..()

	proc/reload_user_file()
		if (!user_file_folder || !user_filename)
			return 0

		for (var/datum/computer/file/record/potential in user_file_folder.contents)
			if (potential.name == user_filename)
				user_file = potential
				return 1

		return 0

/datum/computer/file/document
	name = "Document"
	extension = "DOC"
	var/list/textlist = list() //Actual document text
	var/list/metalist = list() //Instructions on how to process each line.

	disposing()
		textlist = null
		metalist = null

		..()
