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

	proc/forensic_search(var/search_input)
		var/list/datum/db_record/record_matches = forensic_search_subjects(search_input)
		var/result = ""
		if(length(record_matches) > 0)
			result = SPAN_SUCCESS("<li>Records matching \"[search_input]\"</li>")
			var/match_num = ""
			if(length(record_matches) > 1)
				match_num = " (1/[length(record_matches)])"
			var/match_count = 1
			for(var/datum/db_record/R in record_matches)
				result += "<li>[SPAN_NOTICE("Match[match_num]:<b> [R["name"]]</b>")]" + " ([R["rank"]])</li>"
				var/fprint_right = R["fingerprint_right"]
				var/fprint_left = R["fingerprint_left"]
				if(fprint_right == fprint_left)
					result += "<li style='margin-left:15px;list-style-type:none'><i>Fingerprints:</i> [fprint_right]</li>"
				else
					result += "<li style='margin-left:15px;list-style-type:none'><i>Fingerprint (R):</i> [fprint_right]</li>\
								<li style='margin-left:15px;list-style-type:none'><i>Fingerprint (L):</i> [fprint_left]</li>"
				result += "<li style='margin-left:15px;list-style-type:none'><i>Blood DNA:</i> [R["dna"]]</li>"
				match_count++
				match_num = " ([match_count]/[length(record_matches)])"
			return result

		// Search for partial fingerprints
		record_matches = forensic_search_fingerprint_partial(search_input)
		if(length(record_matches) > 0)
			result = SPAN_SUCCESS("<li>Potential matches for \"[search_input]\"</li>")
			for(var/datum/db_record/R in record_matches)
				var/fprint_right = R["fingerprint_right"]
				var/fprint_left = R["fingerprint_left"]
				var/match_result = SPAN_NOTICE("<li style='margin-left:15px;list-style-type:none'>["<b>[R["name"]]</b>"]")
				if(fprint_right == fprint_left)
					match_result += ": [fprint_right]</li>"
				else
					match_result += ": [fprint_right]  |  [fprint_left]</li>"
				result += match_result
			return result
		return SPAN_ALERT("No match found in security records for \"[search_input]\".")

	/// Search for records based on name, dna, or fingerprints
	proc/forensic_search_subjects(var/search_input)
		var/search_low = lowertext(search_input)
		var/list/datum/db_record/subject_records = list()
		for(var/datum/db_record/R as anything in data_core.general.records)
			var/is_subj = (search_low == lowertext(R["dna"]))
			is_subj = is_subj || (search_low == lowertext(R["name"]))
			is_subj = is_subj || (search_low == lowertext(R["fingerprint_right"]))
			is_subj = is_subj || (search_low == lowertext(R["fingerprint_left"]))
			if(is_subj)
				subject_records += R
		return subject_records

	proc/forensic_search_fingerprint_partial(var/search_input)
		RETURN_TYPE(/list/datum/db_record)
		if(!search_input)
			return null
		var/list/record_prints = list()
		var/list/datum/db_record/record_refs = list()

		// Collect the fingerprint data and their associated records that we need to go through
		for(var/list/datum/db_record/record in data_core.general.records)
			var/fprint_right = record["fingerprint_right"]
			var/fprint_left = record["fingerprint_left"]
			if(fprint_right == fprint_left)
				if(!fprint_right)
					continue
				record_prints.Add(fprint_right)
				record_refs.Add(record)
			else
				if(fprint_right)
					record_prints.Add(fprint_right)
					record_refs.Add(record)
				if(fprint_left)
					record_prints.Add(fprint_left)
					record_refs.Add(record)
		if(!record_prints || !record_refs)
			return null

		// Get the input into a more usable format
		// Print: (..3..-4567-...?...-CDEF) => Bunches: list("_3_","4567","_?_","CDEF")
		search_input = limit_chars(search_input, list("?",".","-"), TRUE, TRUE)
		var/list/input_bunches = splittext(search_input, "-")
		for(var/i in length(input_bunches) to 1 step -1)
			if(input_bunches[i] == "")
				input_bunches.Cut(i, i+1)
		if(length(input_bunches) == 0)
			return null
		var/list/input_empty = list()
		for(var/i in 1 to length(input_bunches))
			input_bunches[i] = text_replace_repeat(input_bunches[i], ".", "_")
			var/is_empty = !contains_chars(input_bunches[i], null, TRUE, TRUE)
			input_empty += is_empty

		var/trim_start = 0
		var/trim_end = 0
		for(var/i in 1 to length(input_empty))
			if(!input_empty[i])
				break
			trim_start++
		for(var/i in length(input_empty) to 1 step -1)
			if(!input_empty[i])
				break
			trim_end++
		trim_list(input_bunches, trim_start, trim_end)
		if(length(input_bunches) == 0)
			return null

		// Find and collect all records containing a matching print
		var/list/datum/db_record/match_records = list() // All records with a matching print
		for(var/i in 1 to length(record_prints))
			var/list/rec_bunches = splittext(record_prints[i], "-")
			trim_list(rec_bunches, trim_start, trim_end)
			if(length(rec_bunches) == 0)
				continue
			var/input_index = 1
			for(var/k in 1 to length(rec_bunches))
				var/bunch_match = FALSE
				if(findtext(input_bunches[input_index], "_")) // (-...A...-) or (...A...B...)
					// Not efficient to split the input bunch every time, but should be fine
					var/list/input_bunch_split = splittext(input_bunches[input_index], "_")
					input_bunch_split.RemoveAll("")
					if(length(input_empty) == 1)
						// Check the whole fingerprint rather than individual bunches
						if(findtextEx_ordered(record_prints[i], input_bunch_split))
							bunch_match = TRUE
					else if(findtextEx_ordered(rec_bunches[k], input_bunch_split))
						bunch_match = TRUE
				else if(findtextEx(input_bunches[input_index], "?"))
					if(text_replace_repeat(input_bunches[input_index], "?", "?") == "?") // Bunch only contains question marks
						input_index++
					else if(text_equals_partial(rec_bunches[k], input_bunches[input_index], "?")) // (-??A?-)
						bunch_match = TRUE
				if(bunch_match)
					input_index++
				else
					input_index = 1
				if(input_index == length(input_bunches) + 1) // Found a match!
					match_records += record_refs[i]
					break
		return match_records

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
