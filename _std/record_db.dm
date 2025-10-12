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
		return null

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

	/// Use a partial fingerprint to search for potential suspects. Here there be monsters.
	proc/forensic_search_fingerprint_partial(var/search_input)
		RETURN_TYPE(/list/datum/db_record)
		var/list/record_prints = list()
		var/list/datum/db_record/record_refs = list()
		// List the fingerprint data that we need to go through
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
		if(!record_prints || !record_refs || length(record_prints) != length(record_refs))
			return null

		// Get the input into a more usable format
		// Print: (0123-4567-89AB-CDEF) => Bunches: list("0123","4567","89AB","CDEF")
		var/list/bunches = list() // Split search into bunches separated by "-"
		var/list/bunch_is_empty = list() // Does this bunch include a number or letter?
		var/includes_num_or_letter = FALSE
		var/search_allowed = FALSE
		var/was_last_period = FALSE // Used to get rid of period series
		var/search = ""
		for(var/i in 1 to length(search_input))
			var/input_char = copytext(search_input, i, i+1)
			var/is_allowed = isnum_safe(text2num(input_char))
			// is_uppercase_letter and is_lowercase_letter are both undefined for this file, so I'm just doing this
			is_allowed = is_allowed || (text2ascii(input_char, 1) >= 65 && text2ascii(input_char, 1) <= 90)
			is_allowed = is_allowed || (text2ascii(input_char, 1) >= 97 && text2ascii(input_char, 1) <= 122)
			if(is_allowed)
				includes_num_or_letter = TRUE
				search_allowed = TRUE
			is_allowed = is_allowed || (input_char == "?")
			if(is_allowed)
				was_last_period = FALSE
				search += input_char
			else if(input_char == ".")
				if(was_last_period == TRUE)
					continue
				search += "_" // Replace series of dots with a single underscore for easier analysis
				was_last_period = TRUE
			else if(input_char == "-")
				if(search)
					bunches.Add(search)
					bunch_is_empty.Add(!includes_num_or_letter)
				search = ""
				includes_num_or_letter = FALSE
		bunches.Add(search)
		bunch_is_empty.Add(!includes_num_or_letter)
		if(!search_allowed)
			return null

		var/list/datum/db_record/match_records = list() // All records with a matching print

		if(length(bunches) > 1)
			// trim empty edge bunches
			var/list/bunch_is_empty_trim = bunch_is_empty.Copy()
			for(var/i in length(bunch_is_empty) to 1 step -1)
				if(!bunch_is_empty[i])
					break
				bunches.Cut(length(bunch_is_empty))
				bunch_is_empty_trim.Cut(length(bunch_is_empty))
			for(var/i in 1 to length(bunch_is_empty))
				if(!bunch_is_empty[i])
					break
				bunches.Cut(1, 2)
				bunch_is_empty_trim.Cut(1, 2)
			// Get rid of empty edge bunches in record prints
			for(var/i in 1 to length(record_prints))
				if(length(match_records) > 0)
					if(record_refs[i] == match_records[length(match_records)])
						continue // Already found a matching fingerprint for this record
				var/list/rec_bunches = splittext(record_prints[i], "-")
				if(length(rec_bunches) < length(bunch_is_empty))
					record_prints[i] = null // Can't be it. Not enough bunches in the recorded fingerprint.
					continue
				// Remove empty edge bunches at end of print
				for(var/k in length(bunch_is_empty) to 1 step -1)
					var/bunch_length = length(rec_bunches)
					if(!bunch_is_empty[k] || bunch_length == 0)
						break
					rec_bunches.Cut(bunch_length)
				// Remove empty edge bunches at start of print
				for(var/k in 1 to length(bunch_is_empty))
					if(!bunch_is_empty[k] || length(rec_bunches) == 0)
						break
					rec_bunches.Cut(1, 2)
				// Cleaning done. Now we finally compare the search to the records to see if there's a match
				var/is_match = FALSE
				var/search_bunch_index = 1
				for(var/k in 1 to length(rec_bunches))
					if(search_bunch_index == 1 && length(rec_bunches) < length(bunches))
						break // Not enough bunches left for a match
					var/rec_bunch = rec_bunches[k]
					var/search_bunch = bunches[search_bunch_index]
					var/is_bunch_match = bunch_is_empty_trim[search_bunch_index]
					if(!is_bunch_match)
						if(!findtextEx(search_bunch, "_")) // -??x?-
							if(length(search_bunch) == length(rec_bunch))
								for(var/j in 1 to length(search_bunch))
									var/search_char = copytext(search_bunch, j, j+1)
									var/rec_char = copytext(rec_bunch, j, j+1)
									if(search_char != "?" && search_char != rec_char)
										break
									else if(j == length(search_bunch))
										is_match = TRUE
						else if(!findtextEx(search_bunch, "?")) // -_x_-
							var/search_chars = replacetextEx(search_bunch, "_", "")
							is_bunch_match = findtextEx(rec_bunch, search_chars)
						else
							// Underscores, question marks, and print characters all exist in one bunch. Abandon all hope.
							is_bunch_match = FALSE
					if(is_match)
						break
					if(is_bunch_match)
						if(search_bunch_index == length(bunches))
							is_match = TRUE
							break
						search_bunch_index++
					else
						search_bunch_index = 1
				if(is_match)
					match_records.Add(record_refs[i])
		else
			// Format was "...a...b...", which is now reformatted to "_a_b_"
			var/list/search_chars = splittext(bunches[1], "_")
			search_chars.RemoveAll("")
			if(length(search_chars) > 1)
				for(var/i in 1 to length(record_prints))
					if(length(match_records) > 0)
						if(record_refs[i] == match_records[length(match_records)])
							continue // Already found a matching fingerprint for this record
					var/is_match = TRUE
					var/rec_prints = record_prints[i]
					var/list/chars_index = list()
					for(var/k in 1 to length(search_chars))
						chars_index += findtextEx(rec_prints, search_chars[k])
					for(var/k in 1 to length(chars_index) - 1)
						if(chars_index[k] == 0)
							is_match = FALSE
							break
						if(chars_index[k] > chars_index[k+1])
							is_match = FALSE
							break
					if(is_match)
						match_records.Add(record_refs[i])

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
