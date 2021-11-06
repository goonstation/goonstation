/datum/record_database
	var/list/datum/db_record/records = list()
	var/list/indices = null

	New(list/index_keys)
		..()
		if(length(index_keys) > 0)
			indices = list()
			for(var/key in index_keys)
				indices[key] = list()

	proc/has_record(datum/db_record/record)
		return record?.get_db() == src

	proc/find_records(key, value)
		RETURN_TYPE(/list/datum/db_record)
		if(key in indices)
			if(isnum(value))
				value = "[value]"
			if(!(value in indices[key]))
				return list()
			return indices[key][value]
		. = list()
		for(var/datum/db_record/record as anything in records)
			if(record[key] == value)
				. += record

	proc/find_record(key, value)
		RETURN_TYPE(/datum/db_record)
		if(key in indices)
			if(isnum(value))
				value = "[value]"
			if(!(value in indices[key]) || length(indices[key][value]) == 0)
				return null
			return indices[key][value][1]
		for(var/datum/db_record/record as anything in records)
			if(record[key] == value)
				return record
		return null

	proc/delete_record(datum/db_record/record)
		for(var/index_key in indices)
			if(record.has_field(index_key))
				var/index_value = record[index_key]
				if(isnum(index_value))
					index_value = "[index_value]"
				indices[index_key][index_value] -= record
		records -= record

	proc/add_record(datum/db_record/record)
		if(!isnull(record.get_db()))
			CRASH("Attempt to insert a record already belonging to a database.")
		record.set_db(src)
		records[record] = 1 // associative so deletion is faster
		for(var/index_key in indices)
			if(record.has_field(index_key))
				var/index_value = record.get_field(index_key)
				if(isnum(index_value))
					index_value = "[index_value]"
				if(index_value in indices[index_key])
					indices[index_key][index_value][record] = 1
				else
					indices[index_key][index_value]=list((record) = 1)

	proc/create_record(list/fields)
		RETURN_TYPE(/datum/db_record)
		var/datum/db_record/record = new(null, fields)
		src.add_record(record)
		return record

	proc/notify_field_change(datum/db_record/record, key, old_value, new_value)
		if(!(key in indices))
			return
		if(isnum(old_value))
			old_value = "[old_value]"
		if(isnum(new_value))
			new_value = "[new_value]"
		if(record in indices[key][old_value])
			indices[key][old_value] -= record
		if(new_value in indices[key])
			indices[key][new_value][record] = 1
		else
			indices[key][new_value]=list((record) = 1)

	disposing()
		for(var/datum/db_record/record as anything in records)
			record.delete()
		records = null
		indices = null
		..()

/datum/db_record
	VAR_PRIVATE/datum/record_database/db
	VAR_PRIVATE/list/fields

	New(datum/record_database/db=null, list/fields=null)
		..()
		if(db)
			src.db = db
		if(fields)
			src.fields = fields
		else
			src.fields = list()

	proc/get_db()
		RETURN_TYPE(/datum/record_database)
		return src.db

	/// Don't call this unless you know what you're doing
	proc/set_db(new_db)
		src.db = new_db

	proc/delete()
		db?.delete_record(src)
		src.db = null

	disposing()
		src.delete()
		src.fields = null
		..()

	proc/has_field(key)
		return key in fields

	proc/get_field(key, default=null)
		return (key in fields) ? fields[key] : default

	proc/operator[](key)
		return src.get_field(key)

	proc/set_field(key, value)
		db?.notify_field_change(src, key, src[key], value)
		fields[key] = value

	proc/operator[]=(key, value)
		return src.set_field(key, value)

	proc/copy()
		RETURN_TYPE(/datum/db_record)
		return new/datum/db_record(null, fields.Copy())

	proc/get_fields_copy()
		return fields.Copy()
