
// Note: multiple forensic_holders should not share any forensic_data, each should have their own instance of the evidence
// Unless if the evidence is supposed to be synced for some reason I guess

/datum/forensic_data
	var/time_start = 0 // What time the evidence was first applied, or 0 if not relavent
	var/time_end = 0 // When the evidence was most recently applied. Can include future time.
	var/perc_offset = 0 // Offset for time estimations
	var/accuracy_mult = 1 // Individual accuracy multiplier for this piece of evidence
	var/flags = 0

	New()
		..()
		src.time_start = TIME
		src.time_end = time_start
		src.perc_offset = (rand() - 0.5) * 2
		src.accuracy_mult *= ((rand() - 0.5) * 0.15) + 1

	// The text to display when scanned
	proc/get_text()
		return ""

	proc/get_copy()
		RETURN_TYPE(/datum/forensic_data)
		return null

// Generic evidence that can be stored as an ID + optional value. Don't forget to set the flags.
/datum/forensic_data/basic
	var/static/datum/forensic_display/disp_empty = new("@F")
	var/static/datum/forensic_display/disp_value = new("@F: @V")
	var/datum/forensic_id/evidence = null
	var/value = 0 // A value the evidence can use if needed
	var/datum/forensic_display/display = null // How the data should appear when turned to text

	New(var/datum/forensic_id/id, var/datum/forensic_display/disp = disp_empty, var/flags = 0, var/value = 0)
		..()
		src.evidence = id
		src.display = disp
		src.flags = flags
		src.value = value

	get_copy()
		var/datum/forensic_data/basic/c_data = new(src.evidence, src.display, src.flags, src.value)
		c_data.accuracy_mult = src.accuracy_mult
		c_data.time_start = src.time_start
		c_data.time_end = src.time_end
		c_data.perc_offset = src.perc_offset
		return c_data
