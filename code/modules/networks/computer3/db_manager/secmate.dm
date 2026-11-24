/datum/computer/file/terminal_program/db_manager/secmate
	name = "SecMate"
	size = 12
	req_access = list(access_security)

/datum/computer/file/terminal_program/db_manager/secmate/get_menus()
	var/datum/db_record_group/security/security_group = new()
	var/datum/db_record_group/citation/citation_group = new()

	. = ..() + alist(
		"main"				= new /datum/db_manager_menu/main/secmate(src),
		"security_list"		= new /datum/db_manager_menu/relay(src, security_group, "record_list"),
		"security_search"	= new /datum/db_manager_menu/relay(src, security_group, "search_input"),
		"manage_citations"	= new /datum/db_manager_menu/manage_citations(src, citation_group),
		"issue_ticket"		= new /datum/db_manager_menu/issue_citation/ticket(src, citation_group),
		"issue_fine"		= new /datum/db_manager_menu/issue_citation/fine(src, citation_group),
		"issue_arrest"		= new /datum/db_manager_menu/issue_citation/arrest(src, citation_group),
		"close_arrest"		= new /datum/db_manager_menu/issue_citation/close_arrest(src, citation_group),
	)
