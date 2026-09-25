/datum/db_record
	/// This database record's parent database, if it has one.
	VAR_PRIVATE/datum/record_database/db = null
	/// This database record's fields.
	VAR_PROTECTED/alist/fields = alist(
		"id" = new /datum/record_field/string("000000", @"[a-f0-9]{6}"),
	)

/datum/db_record/New()
	. = ..()
	src.fields ||= alist()
	src["id"] = copytext(ref(src), -7, -1)

/datum/db_record/disposing()
	src.delete()
	src.fields = null
	. = ..()

/// Returns this record's parent database, if it has one.
/datum/db_record/proc/get_db()
	RETURN_TYPE(/datum/record_database)
	return src.db

/// Set the parent database of this record. Don't call this unless you know what you're doing.
/datum/db_record/proc/set_db(new_db)
	src.db = new_db

/// Delete this record, removing it from it's parent database.
/datum/db_record/proc/delete()
	src.db?.delete_record(src)
	src.db = null

/// Returns TRUE if this record has the specified field.
/datum/db_record/proc/has_field(key)
	return istype(src.fields[key], /datum/record_field)

/// Returns the datum representing the specified field on this record.
/datum/db_record/proc/get_field_datum(key)
	RETURN_TYPE(/datum/record_field)
	return src.fields[key]

/// Creates a copy of this record.
/datum/db_record/proc/copy()
	RETURN_TYPE(/datum/db_record)

	var/datum/db_record/copy = new src.type()
	for (var/key as anything in src.fields)
		copy[key] = src[key]

	return copy

/// Returns the value of the specified field on this record.
/datum/db_record/proc/operator[](key)
	return astype(src.fields[key], /datum/record_field)?.get_value()

/// Sets the value of the specified field on this record.
/datum/db_record/proc/operator[]=(key, value)
	src.db?.notify_field_change(src, key, src[key], value)
	var/datum/record_field/field = (src.fields[key] ||= new /datum/record_field)
	return field.set_value(value)

/// Returns how this record should be displayed on record lists.
/datum/db_record/proc/to_display_string()
	return "ERR"
