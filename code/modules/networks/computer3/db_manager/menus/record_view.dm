/datum/db_manager_menu/record_view
	VAR_PRIVATE/current_id = null

/datum/db_manager_menu/record_view/load(record_id)
	src.current_id = record_id
	src.parent.print_text(src.parent.current_record_group.get_record(src.current_id).Join())

/datum/db_manager_menu/record_view/input_text(text)
	var/command = lowertext(src.parent.parse_string(text)[1])

	switch (command)
		if ("r")
			src.parent.switch_menu_to("record_view", src.current_id)
			return

		if ("d")
			if (src.parent.current_record_group.can_add_and_remove_records)
				src.parent.switch_menu_to("record_delete", src.current_id)

			return

		if ("p")
			if (src.parent.connected && src.parent.selected_printer && (!src.parent.network_print(src.current_id) || !src.parent.local_print(src.current_id)))
				src.parent.print_text("Print instruction sent.")
			else
				src.parent.print_text("<b>Error:</b> No printer detected.")

			return

		if ("new")
			if (src.parent.current_record_group.can_add_and_remove_records)
				src.parent.switch_menu_to("record_new", src.current_id)

			return

	var/index_number = round(max(global.text2num_safe(command), 0))
	if (index_number == 0)
		src.parent.switch_menu_to("record_list")
		return

	if (index_number > length(src.parent.current_record_group.writable_fields))
		src.parent.print_text("<b>Error:</b> Invalid field.")
		return

	var/alist/field_data = src.parent.current_record_group.writable_fields[index_number]
	var/datum/record_database/database = src.parent.current_record_group.get_all_databases()[field_data["db"]]
	if (!istype(database))
		src.parent.print_text("<b>Error:</b> Invalid database.")
		return

	var/datum/db_record/record = database.find_record("id", src.current_id)
	if (!istype(record))
		src.parent.print_text("<b>Error:</b> Invalid record.")
		return

	src.parent.switch_menu_to("field_input", record, field_data["key"])
