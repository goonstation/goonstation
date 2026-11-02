/datum/db_manager_menu/manage_citations
	VAR_PRIVATE/datum/db_record_group/citation/record_group = null

/datum/db_manager_menu/manage_citations/New(datum/computer/file/terminal_program/db_manager/parent, datum/db_record_group/citation/record_group)
	. = ..()
	src.record_group = record_group

/datum/db_manager_menu/manage_citations/load()
	var/text = ""

	text += "<b>Issue Citation:</b>"
	text += "<br>(1) Issue ticket."
	text += "<br>(2) Issue fine."
	text += "<br>(3) Issue arrest warrant."

	text += "<br><br><b>View Citations:</b>"
	text += "<br>(4) View all citations."
	text += "<br>(5) Search all citations."
	text += "<br>(6) View tickets."
	text += "<br>(7) View fines."
	text += "<br>(8) View arrest warrants."
	text += "<br><br>(0) Go back."

	src.parent.print_text(text)

/datum/db_manager_menu/manage_citations/input_text(text)
	var/command = global.text2num_safe(src.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))

	switch (index_number)
		if (0)
			src.parent.switch_menu_to("main")

		if (1)
			src.parent.switch_menu_to("issue_ticket")

		if (2)
			src.parent.switch_menu_to("issue_fine")

		if (3)
			src.parent.switch_menu_to("issue_arrest")

		if (4)
			src.record_group.mode = "ALL"
			src.parent.current_record_group = src.record_group
			src.parent.switch_menu_to("record_list")

		if (5)
			src.record_group.mode = "ALL"
			src.parent.current_record_group = src.record_group
			src.parent.switch_menu_to("search_input")

		if (6)
			src.record_group.mode = "TICKETS"
			src.parent.current_record_group = src.record_group
			src.parent.switch_menu_to("record_list")

		if (7)
			src.record_group.mode = "FINES"
			src.parent.current_record_group = src.record_group
			src.parent.switch_menu_to("record_list")

		if (8)
			src.record_group.mode = "ARRESTS"
			src.parent.current_record_group = src.record_group
			src.parent.switch_menu_to("record_list")
