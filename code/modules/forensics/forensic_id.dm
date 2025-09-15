
// Store forensic_ids into a dictionary to prevent duplicates
var/global/list/datum/forensic_id/registered_id_list = new()

/// Check if the ID already exists and return it. Else create a new ID.
/proc/register_id(var/id_text, var/list/reg_list = registered_id_list)
	RETURN_TYPE(/datum/forensic_id)
	if(!id_text)
		return null
	if(reg_list[id_text])
		return reg_list[id_text]
	var/datum/forensic_id/new_id = new()
	new_id.id = id_text
	reg_list[id_text] = new_id
	return new_id

// -----| Forensic ID |-----
// A piece of forensic evidence to be passed around and referenced
/datum/forensic_id
	var/id = null // Read only!

	New(var/id_text = "")
		if(id_text)
			src.id = id_text
			registered_id_list[id_text] = src
		..()

// -----| Forensic Display |-----

// Store how the forensic text should be displayed... by reference! Might be unnecessary.
datum/forensic_display
	var/text = null

	New(var/text = null)
		..()
		src.text = text
