/datum/db_record
	/// This database record's parent database, if it has one.
	VAR_PRIVATE/datum/record_database/db = null
	/// This database record's fields.
	VAR_PROTECTED/list/fields = null

/datum/db_record/New()
	. = ..()
	src.fields ||= list()

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
	return (key in src.fields)

/// Returns the value of the specified field on this record.
/datum/db_record/proc/get_field(key)
	return src.fields[key]

/// Sets the value of the specified field on this record.
/datum/db_record/proc/set_field(key, value)
	src.db?.notify_field_change(src, key, src.get_field(key), value)
	src.fields[key] = value

/// Creates a copy of this record.
/datum/db_record/proc/copy()
	RETURN_TYPE(/datum/db_record)
	var/datum/db_record/copy = new()
	copy.fields = src.fields.Copy()
	return copy

/datum/db_record/proc/operator[](key)
	return src.get_field(key)

/datum/db_record/proc/operator[]=(key, value)
	return src.set_field(key, value)
