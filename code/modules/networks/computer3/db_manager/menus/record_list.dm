/datum/db_manager_menu/record_list

/datum/db_manager_menu/record_list/load()
	var/list/datum/db_record/records = src.parent.current_record_group.get_records()
	var/text = ""

	var/record_count = length(records)
	if (record_count)
		var/leading_zero_count = length("[record_count]")
		text = replacetext(src.parent.current_record_group.record_list_prompt, "%DUMMY_INDEX", @"[" + global.pad_leading(null, leading_zero_count, "_") + @"]")

		for (var/i in 1 to record_count)
			text += "<br><b>\[[global.add_zero(i, leading_zero_count)]\]</b>"

			var/datum/db_record/R = records[i]
			if (istype(R))
				text += R.to_list_display_string()
			else
				text += "<font color=red>ERR: CORRUPTED</font>"

	else
		text += "<b>Error:</b> No records found in database."

	if (src.parent.current_record_group.can_add_and_remove_records)
		text += @"<br><b>[new]</b> Create New Record."

	text += "<br><br>Enter record number, or 0 to return."
	src.parent.print_text(text)

/datum/db_manager_menu/record_list/input_text(text)
	var/command = lowertext(src.parent.parse_string(text)[1])

	if (command == "new")
		if (src.parent.current_record_group.can_add_and_remove_records)
			var/datum/record_database/database = src.parent.current_record_group.get_main_database()
			var/datum/db_record/record = new database.record_type()
			database.add_record(record)
			src.parent.switch_menu_to("record_view", record)

		return

	var/index_number = round(max(global.text2num_safe(command), 0))
	if (index_number == 0)
		src.parent.switch_menu_to(src.parent.current_record_group.main_menu)
		return

	var/list/datum/db_record/records = src.parent.current_record_group.get_records()
	if (index_number > length(records))
		src.parent.print_text("<b>Error:</b> Invalid record.")
		return

	var/datum/db_record/record = records[index_number]
	if (!istype(record))
		src.parent.print_text("<b>Error:</b> Record data invalid.")
		return

	src.parent.switch_menu_to("record_view", record)
