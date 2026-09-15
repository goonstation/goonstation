/datum/computer/file/terminal_program/db_manager/bankboss
	name = "BankBoss"
	size = 12
	req_access = list(access_money)

/datum/computer/file/terminal_program/db_manager/bankboss/get_menus()
	var/datum/db_record_group/bank/record_group = new()

	. = ..() + alist(
		"main"				= new /datum/db_manager_menu/main/bankboss(src),
		"record_list"		= new /datum/db_manager_menu/record_list(src, record_group),
		"search_input"		= new /datum/db_manager_menu/search_input(src, record_group),
		"station_budget"	= new /datum/db_manager_menu/station_budget(src),
		"transfer_funds"	= new /datum/db_manager_menu/transfer_funds(src),
		"issue_bonus"		= new /datum/db_manager_menu/issue_bonus(src),
	)
