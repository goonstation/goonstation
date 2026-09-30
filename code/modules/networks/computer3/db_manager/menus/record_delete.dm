/datum/db_manager_menu/record_delete
	VAR_PRIVATE/datum/db_record/record = null
	VAR_PRIVATE/list/database_ids = null

/datum/db_manager_menu/record_delete/load(datum/db_record/record)
	src.record = record
	src.database_ids = list()

	var/list/datum/db_record/linked_records = src.parent.current_record_group.get_linked_records(src.record)
	var/leading_zero_count = length("[length(linked_records)]")
	var/record_id = record["id"]
	var/text = "Please select a section of \[[record_id]\] to delete:"

	var/i = 1
	for (var/db_id as anything in linked_records)
		var/datum/db_record/db_record = linked_records[db_id]
		if (!istype(db_record))
			continue

		src.database_ids += db_id
		text += "<br><b>\[[global.add_zero(i++, leading_zero_count)]\]</b> " + db_id

	text += "<br><br>Enter a section number to delete, or 0 to return."
	src.parent.print_text(text)

/datum/db_manager_menu/record_delete/unload()
	src.record = null
	src.database_ids = null

/datum/db_manager_menu/record_delete/input_text(text)
	var/command = global.text2num_safe(src.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))
	if (index_number == 0)
		src.parent.switch_menu_to("record_view", src.record)
		return

	if (index_number > length(src.database_ids))
		src.parent.print_text("<b>Error:</b> Invalid choice.")
		return

	var/list/datum/db_record/linked_records = src.parent.current_record_group.get_linked_records(src.record)
	var/database_id = src.database_ids[index_number]
	var/datum/db_record/del_record = linked_records[database_id]

	if (src.record == del_record)
		src.record = null

	logTheThing(LOG_STATION, usr, "deleted [database_id] record [del_record.to_display_string()].")
	qdel(del_record)

	if (src.record)
		src.parent.switch_menu_to("record_delete", src.record)

	else
		for (var/db_id as anything in linked_records)
			qdel(linked_records[db_id])

		src.parent.switch_menu_to("record_list")
