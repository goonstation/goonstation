/datum/db_manager_menu/record_new
	VAR_PRIVATE/current_id = null
	VAR_PRIVATE/list/database_ids = null

/datum/db_manager_menu/record_new/load(record_id)
	src.current_id = record_id
	src.database_ids = list()

	var/alist/databases = src.parent.current_record_group.get_all_databases()
	var/leading_zero_count = length("[length(databases)]")
	var/text = "Please select a section of \[[record_id]\] to create:"

	var/i = 1
	for (var/db_id as anything in databases)
		var/datum/record_database/db = databases[db_id]
		if (istype(db.find_record("id", record_id), /datum/db_record))
			continue

		src.database_ids += db_id
		text += "<br><b>\[[global.add_zero(i++, leading_zero_count)]\]</b> " + db.name

	text += "<br><br>Enter a section number to create, or 0 to return."
	src.parent.print_text(text)

/datum/db_manager_menu/record_new/input_text(text)
	var/command = global.text2num_safe(src.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))
	if (index_number == 0)
		src.parent.switch_menu_to("record_view", src.current_id)
		return

	if (index_number > length(src.database_ids))
		src.parent.print_text("<b>Error:</b> Invalid choice.")
		return

	var/database_id = src.database_ids[index_number]
	var/alist/databases = src.parent.current_record_group.get_all_databases()
	var/datum/record_database/database = databases[database_id]
	var/datum/db_record/main_record = src.parent.current_record_group.get_main_database().find_record("id", src.current_id)

	var/datum/db_record/record = new database.record_type(main_record)
	record["id"] = src.current_id
	database.add_record(record)

	var/count = 0
	for (var/db_id as anything in databases)
		var/datum/record_database/db = databases[db_id]
		if (!istype(db.find_record("id", src.current_id), /datum/db_record))
			count++

	if (count)
		src.parent.switch_menu_to("record_new", src.current_id)
	else
		src.parent.switch_menu_to("record_view", src.current_id)
