ABSTRACT_TYPE(/datum/db_record_group)
/datum/db_record_group
	/// The prompt to give a user when requesting a string to search for within the record group.
	var/search_input_prompt = null
	/// The record keys to search by value when performing a search on this record group.
	var/list/list/keys_to_search_by_db = null

	/// Whether new records can be created or existing ones deleted when managing records within this group.
	var/can_add_and_remove_records = TRUE
	/// The field data that this record group should display, indexed by the database ID string. Each field entry contains the field key, write permissions, and search permissions.
	var/alist/field_data = null
	/// This record group's writable fields. Generated from `field_data` during instantiation.
	var/list/alist/writable_fields = null

	/// The padding for field names within this record group, indexed by the database ID string.
	VAR_PRIVATE/alist/padding_by_database = null
	/// The leading zero count to use for field indices within this record group. Generated during instantiation.
	VAR_PRIVATE/leading_zero_count = null
	/// The index to use for read-only fields. Generated during instantiation.
	VAR_PRIVATE/read_only_index = null

/datum/db_record_group/New()
	. = ..()

	src.writable_fields = list()
	src.keys_to_search_by_db = list()
	for (var/db as anything in src.field_data)
		src.keys_to_search_by_db[db] = list()

		for (var/alist/data as anything in src.field_data[db])
			if (data["write"])
				src.writable_fields += list(alist("db" = db, "key" = data["key"]))
			if (data["search"])
				src.keys_to_search_by_db[db] += data["key"]

	src.padding_by_database = alist()
	src.leading_zero_count = length("[length(src.writable_fields)]")
	src.read_only_index = @"[" + global.pad_leading(null, src.leading_zero_count, "_") + @"]"

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
	var/i = 1
	for (var/db_id as anything in databases)
		var/datum/record_database/db = databases[db_id]
		var/datum/db_record/record = db.find_record("id", record_id)
		if (!istype(record))
			var/text = "<br><b>[db.name] Record Lost!</b><br>"
			if (src.can_add_and_remove_records && !for_print)
				text += "\[new\] Create New [db.name] Record.<br>"

			fields += text
			continue

		var/padding = (src.padding_by_database[db_id] ||= src.get_padding(db_id, record))
		if (for_print)
			padding += 3

		fields += "<br><center><b>[db.name] Record Data</b></center><br>"
		for (var/alist/data as anything in src.field_data[db_id])
			var/key = data["key"]
			var/datum/record_field/field = record.get_field_datum(key)

			var/text = "<div style='display: flex; word-break: break-all;'><div style='flex-shrink: 0;'>"
			// Index:
			if (!for_print)
				text += data["write"] ? "\[[global.add_zero(i++, src.leading_zero_count)]\]" : src.read_only_index
			// Field name:
			text += global.pad_trailing("<b>" + field.name + "</b>", padding, ".")
			// Field value:
			text += "</div>[field.get_display_value()]</div>"

			fields += text

	if (for_print)
		fields.Insert(1, "<font face='Consolas'>")
		fields += "</font>"
	else if (src.can_add_and_remove_records)
		fields += "<br>Enter field number to edit a field:<br>(R) Redraw (D) Delete (P) Print (0) Return to index."
	else
		fields += "<br>Enter field number to edit a field:<br>(R) Redraw (P) Print (0) Return to index."

	return fields

/// Determine the padding for field names for a specific database. Requires a sample record.
/datum/db_record_group/proc/get_padding(db_id, datum/db_record/record)
	PRIVATE_PROC(TRUE)
	var/padding = 0
	for (var/alist/data as anything in src.field_data[db_id])
		var/name = record.get_field_datum(data["key"]).name
		padding = max(padding, length(name))

	return padding + 9
