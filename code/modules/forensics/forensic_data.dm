
// Note: multiple forensic_holders should not share any forensic_data, each should have their own instance of the evidence
// Unless if the evidence is supposed to be synced for some reason I guess
/datum/forensic_data
	var/time_start = 0 //! What time the evidence was first applied, or 0 if not relavent
	var/time_end = 0 //! When the evidence was most recently applied. Can include future time to mark evidence as current until that point.
	var/flags = 0

	New()
		..()
		src.time_start = TIME
		src.time_end = time_start

	/// The text to display when scanned
	proc/get_text(var/datum/forensic_scan/scan)
		return ""

	/// Return a copy of the data. Forensic scan is optional for copying incomplete data.
	proc/get_copy(var/datum/forensic_scan/scan)
		RETURN_TYPE(/datum/forensic_data)
		return null

	proc/get_minutes_since(var/time, var/since_start = FALSE)
		var/data_time = since_start ? time_end : time_start
		return TO_MINUTES(time) - TO_MINUTES(data_time)

// Generic evidence that can be stored as an ID + optional value. Don't forget to set the flags.
/datum/forensic_data/basic
	var/static/datum/forensic_display/disp_empty = new("@F")
	var/static/datum/forensic_display/disp_value = new("@F: @V")
	var/datum/forensic_id/evidence = null
	var/value = 0 //! A value the evidence can use if needed
	var/datum/forensic_display/display = null //! How the data should appear when turned to text

	New(var/datum/forensic_id/id, var/datum/forensic_display/disp = disp_empty, var/flags = 0, var/value = 0)
		..()
		src.evidence = id
		src.display = disp
		src.flags = flags
		src.value = value

	get_text(var/datum/forensic_scan/scan)
		return replacetextEx(src.display.text, "@F", src.evidence.id)

	get_copy()
		var/datum/forensic_data/basic/data_copy = new(src.evidence, src.display, src.flags, src.value)
		data_copy.time_start = src.time_start
		data_copy.time_end = src.time_end
		REMOVE_FLAG(data_copy.flags, FORENSIC_USED)
		return data_copy

/// Simple text displayed as forensic evidence.
/datum/forensic_data/text
	var/text = ""
	var/header = "" //! The header that the text is placed under.

	New(var/text, var/header = "Notes", var/flags = 0)
		..()
		src.text = text
		src.header = header
		src.flags = flags

	get_text(var/datum/forensic_scan/scan)
		return src.text

	get_copy()
		var/datum/forensic_data/text/data_copy = new(src.text, src.header, src.flags)
		data_copy.time_start = src.time_start
		data_copy.time_end = src.time_end
		REMOVE_FLAG(data_copy.flags, FORENSIC_USED)
		return data_copy

/datum/forensic_data/adminprint
	var/datum/forensic_id/clientKey = null

	New(var/datum/forensic_id/clientKey)
		..()
		src.clientKey = clientKey

	get_text()
		var/mins_start = src.get_minutes_since(TIME, TRUE)
		var/mins_end = src.get_minutes_since(TIME)
		if(mins_start == mins_end)
			return src.clientKey.id + SPAN_SUBTLE(" ([mins_end] mins ago)")
		return src.clientKey.id + SPAN_SUBTLE(" ([mins_end] to [mins_start] mins ago)")

	get_copy()
		var/datum/forensic_data/adminprint/data_copy = new(src.clientKey)
		data_copy.time_start = src.time_start
		data_copy.time_end = src.time_end
		REMOVE_FLAG(data_copy.flags, FORENSIC_USED)
		return data_copy

/datum/forensic_data/fingerprint
	var/datum/forensic_id/print = null
	var/datum/forensic_id/fibers = null
	var/datum/forensic_id/print_mask = null

	New(var/datum/forensic_id/print, var/datum/forensic_id/fibers, var/datum/forensic_id/print_mask, var/flags = 0)
		..()
		src.print = print
		src.fibers = fibers
		src.print_mask = print_mask
		src.flags = flags

	get_text(var/datum/forensic_scan/scan)
		var/fibers_text = SPAN_SUBTLE(src.fibers?.id)
		if(scan.has_effect("effect_silver_nitrate"))
			// Silver nitrate was applied. Show partial fingerprints.
			var/fprint_text = get_masked_print()
			if(fprint_text && fibers_text && src.print_mask)
				return "([fprint_text]) [fibers_text]"
			return fprint_text + fibers_text
		else if(src.print_mask?.id == FORENSIC_GLOVE_MASK_FINGERLESS)
			return src.print?.id
		else if(src.fibers && startswith(src.fibers.id, "latex rubber"))
			return "([get_masked_print()])"

			// Not including the fibers for now because they were taking up too much room in the forensic report.
			//var/fprint_text = get_masked_print()
			// if(fprint_text && fibers_text)
				// return "[fprint_text] ([fibers_text])"
			// return fprint_text + fibers_text
		else if(src.fibers)
			return fibers_text
		else
			return src.print?.id

	get_copy(var/datum/forensic_scan/scan)
		var/datum/forensic_data/fingerprint/data_copy = new(src.print, src.fibers, src.print_mask, src.flags)
		data_copy.time_start = src.time_start
		data_copy.time_end = src.time_end
		REMOVE_FLAG(data_copy.flags, FORENSIC_USED)
		if(!scan)
			return data_copy
		if(scan.has_effect("effect_silver_nitrate"))
			return data_copy
		if(src.fibers && startswith(src.fibers.id, "latex rubber"))
			return data_copy
		if(!src.print_mask || src.print_mask.id == FORENSIC_GLOVE_MASK_FINGERLESS)
			// Ignore the fibers of fingerless gloves for now. Taking up too much room in the forensic report.
			data_copy.fibers = null
			data_copy.print_mask = null
			return data_copy
		if(src.fibers)
			// Fingerprints are not visible. Don't copy the prints themselves (avoid listing duplicate gloves).
			data_copy.print = null
		return data_copy

	proc/get_masked_print()
		if(!src.print)
			return ""
		if(!src.print_mask)
			return src.print.id
		var/masked_print = ""
		for(var/i in 1 to length(src.print_mask.id))
			var/char = copytext(src.print_mask.id, i, i+1)
			if(is_hex(char))
				var/index = hex2num(char)
				index += floor(index / 4) + 1
				masked_print += copytext(src.print.id, index, index + 1)
			else
				masked_print += char
		return masked_print
