/datum/db_manager_menu/relay
	VAR_PRIVATE/datum/db_record_group/record_group = null
	VAR_PRIVATE/menu_id = null

/datum/db_manager_menu/relay/New(datum/computer/file/terminal_program/db_manager/parent, datum/db_record_group/record_group, menu_id)
	. = ..()
	src.record_group = record_group
	src.menu_id = menu_id

/datum/db_manager_menu/relay/disposing()
	src.record_group = null
	. = ..()

/datum/db_manager_menu/relay/load()
	src.parent.current_record_group = src.record_group
	src.parent.switch_menu_to(src.menu_id)
