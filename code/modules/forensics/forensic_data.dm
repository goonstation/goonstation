
// Note: multiple forensic_holders should not share any forensic_data, each should have their own instance of the evidence
// Unless if the evidence is supposed to be synced for some reason, I guess

/datum/forensic_data
	var/category = FORENSIC_GROUP_NONE
	var/time_start = 0 // What time the evidence was first applied, or 0 if not relavent
	var/time_end = 0 // When the evidence was most recently applied
	var/perc_offset = 0 // Error offset multiplier for time estimations
	var/accuracy_mult = 1 // Individual accuracy multiplier for this piece of evidence
	var/flags = 0
	// var/user = null // The player responsible for this evidence (for admins)
	New()
		..()
		src.time_start = TIME
		src.time_end = time_start
		src.perc_offset = (rand() - 0.5) * 2
		src.accuracy_mult *= ((rand() - 0.5) * 0.15) + 1
	proc/get_text() // The text to display when scanned
		return ""
	proc/should_remove(var/remove_flags) // Should this evidence be removed?
		var/remove = HAS_ANY_FLAGS(src.flags & (REMOVE_ALL_EVIDENCE & !REMOVE_HEAL), remove_flags)
		remove |= HAS_ALL_FLAGS(src.flags & REMOVE_HEAL, remove_flags & REMOVE_HEAL) // Need full healing to remove
		return remove
	proc/mark_as_junk()
		flags = flags | IS_FAKE
	proc/get_copy()
		RETURN_TYPE(/datum/forensic_data)
		return null

	proc/get_time_estimate(var/accuracy) // Return a text estimate for when this evidence might have occured
		if(src.time_start == 0 || accuracy < 0)
			return "" // Negative accuracy -> do not report a time
		var/t_end = (TIME - src.time_end) / (1 MINUTE)
		if(t_end <= 0)
			return SPAN_SUBTLE(" <i>(Current)</i>")
		else if(accuracy == 0) // perfect accuracy is zero
			return SPAN_SUBTLE(" <i>([round(t_end)] mins ago)</i>")
		else
			accuracy = t_end * FORENSIC_BASE_ACCURACY * accuracy * accuracy_mult // Base accuracy: +-25% (20 mins -> 15-25 mins)
			var/offset = accuracy * src.perc_offset
			var/low_est = round(t_end - accuracy + offset)
			var/high_est = round(t_end + accuracy + offset)
			if(low_est == high_est)
				return SPAN_SUBTLE(" <i>([low_est] mins ago)</i>")
			else
				return SPAN_SUBTLE(" <i>([low_est] to [high_est] mins ago)</i>")


/datum/forensic_data/basic // Evidence stored as a single ID + an optional value. Flags not included.
	var/static/datum/forensic_display/disp_empty = new("@F")
	var/static/datum/forensic_display/disp_value = new("@F: @V")
	var/datum/forensic_id/evidence = null
	var/value = 0 // A value the evidence can use if needed
	var/datum/forensic_display/display = null

	New(var/datum/forensic_id/id, var/datum/forensic_display/disp = disp_empty, var/flags = 0, var/value = 0)
		..()
		src.evidence = id
		src.display = disp
		src.flags = flags
		src.value = value

	get_text()
		var/scan_text = replacetext(display.display_text, "@F", evidence.id)
		scan_text = replacetext(scan_text, "@V", "[value]")
		return scan_text

	get_copy()
		var/datum/forensic_data/basic/c_data = new(src.evidence, src.display, src.flags, src.value)
		c_data.category = src.category
		c_data.accuracy_mult = src.accuracy_mult
		c_data.time_start = src.time_start
		c_data.time_end = src.time_end
		c_data.perc_offset = src.perc_offset
		return c_data

/datum/forensic_data/multi // Two or three pieces of evidence linked together. Flags not included.
	var/static/datum/forensic_display/disp_double = new("@A [SPAN_NOTICE("|")] @B")
	var/static/datum/forensic_display/disp_pair = new("@A @B")
	var/static/datum/forensic_display/disp_pair_double = new("@C [SPAN_NOTICE("|")] @A @B") // Easier to get pair A&B first
	var/static/datum/forensic_id/organ_empty = new("_____")
	var/datum/forensic_display/display = null // @A, @B, @C
	var/datum/forensic_id/evidence_A = null
	var/datum/forensic_id/evidence_B = null
	var/datum/forensic_id/evidence_C = null

	New(var/datum/forensic_id/idA, var/datum/forensic_id/idB, var/datum/forensic_id/idC = null, var/datum/forensic_display/disp = disp_double)
		..()
		src.evidence_A = idA
		src.evidence_B = idB
		src.evidence_C = idC
		src.display = disp

	get_text()
		var/scan_text = display.display_text
		if(!evidence_A)
			scan_text = replacetextEx(scan_text, "@A", "")
		else
			scan_text = replacetextEx(scan_text, "@A", evidence_A.id)
		if(!evidence_B)
			scan_text = replacetextEx(scan_text, "@B", "")
		else
			scan_text = replacetextEx(scan_text, "@B", evidence_B.id)
		if(!evidence_C)
			scan_text = replacetextEx(scan_text, "@C", "")
		else
			scan_text = replacetextEx(scan_text, "@C", evidence_C.id)
		return scan_text

	get_copy()
		var/datum/forensic_data/multi/c_data = new(src.evidence_A, src.evidence_B, src.evidence_C, src.display)
		c_data.category = src.category
		c_data.flags = src.flags
		c_data.time_start = src.time_start
		c_data.time_end = src.time_end
		c_data.accuracy_mult = src.accuracy_mult
		c_data.perc_offset = src.perc_offset
		return c_data

	proc/is_same(datum/forensic_data/multi/other)
		return src.evidence_A == other.evidence_A && src.evidence_B == other.evidence_B && src.evidence_C == other.evidence_C

/proc/estimate_counter(var/text, var/actual, var/accuracy, var/offset) // Scan estimate for whole numbers
	if(actual <= 0)
		return "[text]: [actual]"

	var/note = null
	if(accuracy < 0)
		accuracy = FORENSIC_BASE_ACCURACY
	var/high_est = round(actual + (actual * accuracy * offset))
	var/low_est = max(1, round(actual - (actual * accuracy * (1 - offset))))
	if(high_est == low_est)
		note = "[text]: [actual]"
	else
		note = "[text]: [low_est] to [high_est]"
	return note
