/datum/record_database
	/**
	 *	A list of records index by their keys and values. Used for quick lookups. \
	 *	Type structure: `/alist<key, /alist<value, /list/datum/db_record>>`
	 */
	var/alist/indices = null

	/// A list of all records contained within this database.
	var/list/datum/db_record/records = null

/datum/record_database/New(list/index_keys)
	. = ..()
	src.records = list()

	if (!length(index_keys))
		return

	src.indices = alist()
	for (var/key as anything in index_keys)
		src.indices[key] = alist()

/datum/record_database/disposing()
	for (var/datum/db_record/record as anything in src.records)
		record.delete()

	src.records = null
	src.indices = null
	. = ..()

/// Whether this database contains the specified record.
/datum/record_database/proc/has_record(datum/db_record/record)
	return (record?.get_db() == src)

/// Find all records within this database that match the specified key-value pair.
/datum/record_database/proc/find_records(key, value)
	RETURN_TYPE(/list/datum/db_record)

	if (src.indices[key])
		return src.indices[key][value]

	. = list()
	for (var/datum/db_record/record as anything in src.records)
		if (record[key] == value)
			. += record

/// A regex-supported, multi-key variant of `find_records`.
/datum/record_database/proc/adv_find_records(list/keys, regex/value_regex)
	RETURN_TYPE(/list/datum/db_record)
	. = list()

	for (var/datum/db_record/record as anything in src.records)
		for (var/key as anything in keys)
			var/value = record.get_field(key)
			if (matchtext(value, value_regex))
				. += record
				break

/// Find the first record within this database that matches the specified key-value pair.
/datum/record_database/proc/find_record(key, value)
	RETURN_TYPE(/datum/db_record)

	if (src.indices[key])
		return src.indices[key][value]?[1]

	for (var/datum/db_record/record as anything in src.records)
		if (record[key] == value)
			return record

/// Delete the specified record from this database.
/datum/record_database/proc/delete_record(datum/db_record/record)
	for (var/key as anything in src.indices)
		if (!record.has_field(key))
			continue

		var/value = record.get_field(key)
		var/list/datum/db_record/indexed_records = src.indices[key][value]
		indexed_records -= record
		if (!length(indexed_records))
			src.indices[key] -= value

	src.records -= record

/// Add the specified record to this database.
/datum/record_database/proc/add_record(datum/db_record/record)
	if (!isnull(record.get_db()))
		CRASH("Attempt to insert a record already belonging to a database.")

	record.set_db(src)
	src.records += record

	for (var/key in src.indices)
		if (!record.has_field(key))
			continue

		var/value = record.get_field(key)
		var/list/datum/db_record/indexed_records = (src.indices[key][value] ||= list())
		indexed_records += record

/// Create a new record and add it to this database.
/datum/record_database/proc/create_record(list/fields)
	RETURN_TYPE(/datum/db_record)

	var/datum/db_record/record = new()
	for (var/key as anything in fields)
		record.set_field(key, fields[key])

	src.add_record(record)
	return record

/// Notify this database that one of its records has had a value updated.
/datum/record_database/proc/notify_field_change(datum/db_record/record, key, old_value, new_value)
	var/alist/records_by_value = src.indices[key]
	if (!records_by_value)
		return

	// Remove the record from the index for the old value.
	var/list/datum/db_record/old_records = records_by_value[old_value]
	if (old_records)
		old_records -= record
		if (!length(old_records))
			records_by_value -= old_value

	// Add the record to the index for the new value.
	var/list/datum/db_record/new_records = (records_by_value[new_value] ||= list())
	new_records += record
