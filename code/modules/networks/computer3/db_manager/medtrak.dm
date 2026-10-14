/datum/computer/file/terminal_program/db_manager/medtrak
	name = "MedTrak"
	size = 12
	req_access = list(access_medical)

/datum/computer/file/terminal_program/db_manager/medtrak/get_menus()
	var/datum/db_record_group/medical/record_group = new()

	. = ..() + alist(
		"main"				= new /datum/db_manager_menu/main/medtrak(src),
		"medical_list"		= new /datum/db_manager_menu/relay(src, record_group, "record_list"),
		"medical_search"	= new /datum/db_manager_menu/relay(src, record_group, "search_input"),
		"disease_list"		= new /datum/db_manager_menu/relay(src, new /datum/db_record_group/disease, "record_list"),
	)
