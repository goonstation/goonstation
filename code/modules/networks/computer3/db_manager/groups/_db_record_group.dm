ABSTRACT_TYPE(/datum/db_record_group)
/datum/db_record_group
	/// The main menu that this record group should use.
	var/main_menu = "main"
	/// The prompt to give a user when displaying a list of records.
	var/record_list_prompt = "Please select a record:"
	/// The prompt to give a user when requesting a string to search for within the record group.
	var/search_input_prompt = null
	/// The record keys to search by value when performing a search on this record group, indexed by the database ID string.
	var/alist/keys_to_search_by_db = null

	/// Whether new records can be created or existing ones deleted when managing records within this group.
	var/can_add_and_remove_records = TRUE
	/// The field data that this record group should display, indexed by the database ID string. Each field entry contains the field key, write permissions, and search permissions.
	var/alist/field_data = null
	/// This record group's writable fields. Generated from `field_data` during instantiation.
	var/list/alist/writable_fields = null

	/// The number of writable fields within each database.
	VAR_PRIVATE/alist/writable_field_count_by_db = null
	/// The leading zero count to use for field indices within this record group. Generated during instantiation.
	VAR_PRIVATE/leading_zero_count = null
	/// The index to use for read-only fields. Generated during instantiation.
	VAR_PRIVATE/read_only_index = null

/datum/db_record_group/New()
	. = ..()

	src.writable_fields = list()
	src.writable_field_count_by_db = alist()
	src.keys_to_search_by_db = alist()

	for (var/db as anything in src.field_data)
		src.writable_field_count_by_db[db] = 0
		src.keys_to_search_by_db[db] = list()

		for (var/alist/data as anything in src.field_data[db])
			if (data["write"])
				src.writable_fields += list(alist("db" = db, "key" = data["key"]))
				src.writable_field_count_by_db[db] += 1
			if (data["search"])
				src.keys_to_search_by_db[db] += data["key"]

	src.leading_zero_count = length("[length(src.writable_fields)]")
	src.read_only_index = @"[" + global.pad_leading(null, src.leading_zero_count, "_") + @"]"

/// Return all the records associated with this record group.
/datum/db_record_group/proc/get_records()
	RETURN_TYPE(/list/datum/db_record)
	return src.get_main_database()?.records

/// Return this record group's main database. This is the database used to iterate over records, with records in other databases within the group linked through their ID field.
/datum/db_record_group/proc/get_main_database()
	RETURN_TYPE(/datum/record_database)
	return

/// Return all databases within this record group, indexed by the database ID string.
/datum/db_record_group/proc/get_all_databases()
	RETURN_TYPE(/alist)
	return

/// Render a record for output. Returned as a list of lines.
/datum/db_record_group/proc/get_record(record_id, for_print = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)
	RETURN_TYPE(/list)
	var/alist/databases = src.get_all_databases()

	var/list/fields = list()
	var/i = 0
	for (var/db_id as anything in databases)
		var/datum/record_database/db = databases[db_id]
		var/datum/db_record/record = db.find_record("id", record_id)
		if (!istype(record))
			var/text = "<br><b>[db.name] Record Lost!</b><br>"
			if (src.can_add_and_remove_records && !for_print)
				text += "\[new\] Create New [db.name] Record.<br>"

			fields += text
			i += src.writable_field_count_by_db[db_id]
			continue

		var/padding = src.get_padding(db_id, record)
		if (for_print)
			padding += 3

		fields += "<br><center><b>[db.name] Record Data</b></center><br>"
		for (var/alist/data as anything in src.field_data[db_id])
			if (data["write"])
				i++

			var/key = data["key"]
			var/datum/record_field/field = record.get_field_datum(key)
			if (!field)
				continue

			var/text = "<div style='display: flex; word-break: break-all;'><div style='flex-shrink: 0;'>"
			// Index:
			if (!for_print)
				text += data["write"] ? "\[[global.add_zero(i, src.leading_zero_count)]\]" : src.read_only_index
			// Field name:
			text += global.pad_trailing("<b>" + field.name + "</b>", padding, ".")
			// Field value:
			text += "</div>[field.get_display_value()]</div>"

			fields += text

	if (for_print)
		fields.Insert(1, "<font face='Consolas'>")
		fields += "</font>"
	else
		fields += "<br>Enter field number to edit a field." + src.get_commands(record_id)

	return fields

/// Determine the padding for field names for a specific database. Requires a sample record.
/datum/db_record_group/proc/get_padding(db_id, datum/db_record/record)
	PRIVATE_PROC(TRUE)
	var/padding = 0
	for (var/alist/data as anything in src.field_data[db_id])
		var/datum/record_field/field = record.get_field_datum(data["key"])
		if (!field)
			continue

		padding = max(padding, length(field.name))

	return padding + 9

/datum/db_record_group/proc/get_commands(record_id)
	if (src.can_add_and_remove_records)
		return "<br>(R) Redraw <br>(D) Delete <br>(P) Print <br>(0) Return to index."
	else
		return "<br>(R) Redraw <br>(P) Print <br>(0) Return to index."

/datum/db_record_group/proc/input_command(datum/db_manager_menu/record_view/menu, record_id, command)
	switch (command)
		if ("r")
			menu.parent.switch_menu_to("record_view", record_id)

		if ("d")
			if (src.can_add_and_remove_records)
				menu.parent.switch_menu_to("record_delete", record_id)

		if ("p")
			var/datum/computer/file/record/print_record = new()
			print_record.fields += "title=Record [record_id]"
			print_record.fields += src.get_record(record_id, TRUE)

			if (menu.parent.print_file(print_record))
				menu.parent.print_text("Print instruction sent.")
			else
				menu.parent.print_text("<b>Error:</b> No printer detected.")

		if ("new")
			if (src.can_add_and_remove_records)
				menu.parent.switch_menu_to("record_new", record_id)

		else
			return FALSE

	return TRUE
