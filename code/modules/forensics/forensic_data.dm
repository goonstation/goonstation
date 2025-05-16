
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
	var/value = 0 //! A value the evidence can use if needed
	var/datum/forensic_display/display = null //! How the data should appear when turned to text

	New(var/datum/forensic_id/id, var/datum/forensic_display/disp = disp_empty, var/flags = 0, var/value = 0)
		..()
		src.evidence = id
		src.display = disp
		src.flags = flags
		src.value = value

	get_copy()
		var/datum/forensic_data/basic/data_copy = new(src.evidence, src.display, src.flags, src.value)
		data_copy.time_start = src.time_start
		data_copy.time_end = src.time_end
		return data_copy
