/datum/db_manager_menu/issue_citation
	VAR_PRIVATE/datum/db_record_group/citation/record_group = null

/datum/db_manager_menu/issue_citation/New(datum/computer/file/terminal_program/db_manager/parent, datum/db_record_group/citation/record_group)
	. = ..()
	src.record_group = record_group
