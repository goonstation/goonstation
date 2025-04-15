
// Store forensic_ids into a dictionary to prevent duplicates
var/global/list/datum/forensic_id/registered_id_list = new()

// Check if the ID already exists and return it. Else create a new ID.
/proc/register_id(var/id_text, var/list/reg_list = registered_id_list)
	if(!id_text)
		return null
	if(reg_list[id_text])
		return reg_list[id_text]
	var/datum/forensic_id/new_id = new()
	new_id.id = id_text
	reg_list[id_text] = new_id
	return new_id

// -----| Forensic ID |-----
/datum/forensic_id // A piece of forensic evidence to be passed around and referenced
	var/id = null // Read only!

	New(var/id_text = "")
		if(id_text)
			src.id = id_text
			registered_id_list[id_text] = src
		..()

// -----| ID Building Procs |-----

// Create a random string using the given characters
/proc/build_id(var/length, var/list/char_list = CHAR_LIST_NUM, var/prefix = "", var/suffix = "")
	var/list/new_id_list = new()
	for(var/i=1, i<= length, i++)
		new_id_list += pick(char_list)
	return prefix + list2text(new_id_list) + suffix

// -----| Forensic Display |-----

datum/forensic_display // Store how the forensic text should be displayed... by reference! Might be unnecessary.
	var/display_text = null

	New(var/id_text = null)
		..()
		display_text = id_text
