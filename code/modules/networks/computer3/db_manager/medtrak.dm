/datum/computer/file/terminal_program/db_manager/medtrak
	name = "MedTrak"
	size = 12
	req_access = list(access_medical)

/datum/computer/file/terminal_program/db_manager/medtrak/get_menus()
	var/datum/db_record_group/medical/record_group = new()

	. = ..() + alist(
		"main"			= new /datum/db_manager_menu/main/medtrak(src),
		"record_list"	= new /datum/db_manager_menu/record_list(src, record_group),
		"search_input"	= new /datum/db_manager_menu/search_input(src, record_group),
		"disease_list"	= new /datum/db_manager_menu/record_list(src, new /datum/db_record_group/disease),
	)
