/datum/db_manager_menu/record_view
	VAR_PRIVATE/datum/db_record/record = null

/datum/db_manager_menu/record_view/load(datum/db_record/record)
	src.record = record
	src.parent.print_text(src.parent.current_record_group.get_record(src.record).Join())

/datum/db_manager_menu/record_view/unload()
	src.record = null

/datum/db_manager_menu/record_view/input_text(text)
	var/command = lowertext(src.parent.parse_string(text)[1])

	if (src.parent.current_record_group.input_command(src, src.record, command))
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

	var/datum/db_record/db_record = database.find_record("id", src.record["id"])
	if (!istype(db_record))
		src.parent.print_text("<b>Error:</b> Invalid record.")
		return

	var/datum/record_field/field = db_record.get_field_datum(field_data["key"])
	if (!istype(field))
		src.parent.print_text("<b>Error:</b> Invalid field.")
		return

	src.parent.switch_menu_to("field_input", db_record, field_data["key"])
