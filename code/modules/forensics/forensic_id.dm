
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

/proc/build_id(var/list/char_list, var/id_length)
	var/new_id = ""
	for(var/i in 1 to id_length)
		new_id += pick(char_list)
	return new_id

/proc/build_id_norepeat(var/list/char_list, var/id_length)
	if(id_length > char_list.len)
		id_length = char_list.len
	char_list = char_list.Copy() // Don't edit the list directly
	var/char_length = char_list.len
	var/new_id = ""
	for(var/i in 1 to id_length)
		var/index = rand(1, char_length)
		new_id += char_list[index]
		char_list[index] = char_list[char_length]
		char_length--
	return new_id

/proc/build_id_separate(var/text, var/bunch_size, var/separation_text = "-")
	var/final_text = copytext(text, 1, bunch_size + 1)
	var/bunch_count = floor(length(text) / bunch_size)
	for(var/i=1; i<= bunch_count - 1; i++)
		var/pos = (i * bunch_size) + 1
		final_text += separation_text + copytext(text, pos, pos + bunch_size)
	return final_text

/proc/build_id_fingerprint(var/list/char_list)
	return build_id_separate(build_id_norepeat(char_list, 16), 4)

// -----| Forensic Display |-----

// Store how the forensic text should be displayed... by reference! Might be unnecessary.
datum/forensic_display
	var/text = null

	New(var/text = null)
		..()
		src.text = text
