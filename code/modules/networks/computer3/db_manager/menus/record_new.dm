/datum/db_manager_menu/record_new
	VAR_PRIVATE/datum/db_record/record = null
	VAR_PRIVATE/list/database_ids = null

/datum/db_manager_menu/record_new/load(datum/db_record/record)
	src.record = record
	src.database_ids = list()

	var/alist/databases = src.parent.current_record_group.get_all_databases()
	var/leading_zero_count = length("[length(databases)]")
	var/record_id = record["id"]
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

/datum/db_manager_menu/record_new/unload()
	src.record = null

/datum/db_manager_menu/record_new/input_text(text)
	var/command = global.text2num_safe(src.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))
	if (index_number == 0)
		src.parent.switch_menu_to("record_view", src.record)
		return

	if (index_number > length(src.database_ids))
		src.parent.print_text("<b>Error:</b> Invalid choice.")
		return

	var/record_id = src.record["id"]
	var/database_id = src.database_ids[index_number]
	var/alist/databases = src.parent.current_record_group.get_all_databases()
	var/datum/record_database/database = databases[database_id]
	var/datum/db_record/main_record = src.parent.current_record_group.get_main_database().find_record("id", record_id)

	var/datum/db_record/new_record = new database.record_type(main_record)
	new_record["id"] = record_id
	database.add_record(new_record)

	var/count = 0
	for (var/db_id as anything in databases)
		var/datum/record_database/db = databases[db_id]
		if (!istype(db.find_record("id", record_id), /datum/db_record))
			count++

	if (count)
		src.parent.switch_menu_to("record_new", src.record)
	else
		src.parent.switch_menu_to("record_view", src.record)
