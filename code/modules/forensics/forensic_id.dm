
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

/// Rebuilds IDs until a unique version is found in the specified register list
///
/// char_list (list) [Required] - The list of characters to build the ID from.
///
/// id_length (num) [Required] - The length of characters to include in the ID. Does not include separators.
///
/// reg_list (list) [Default: global.registered_id_list] - The list of IDs to check against for duplicates.
///
/// no_repeat (bool) [Default: FALSE] - If TRUE, the ID should not have repeated characters from `char_list`.
///
/// bunch_size (num) [Default: null] - Number of ID characters grouped into bunches. Must be set alongside `separator`.
///
/// separator (char) [Default: null] - Character used to separate bunches. Must be set alongside `bunch_size`.
/proc/build_id_unique(list/char_list, id_length, list/reg_list = global.registered_id_list, no_repeat = FALSE, bunch_size=null, separator=null)
	if (!reg_list || !id_length)
		return null
	if (bunch_size && !separator || separator && !bunch_size)
		return null // bunch size or separator set but not both
	var/do_bunch = FALSE
	if (bunch_size && separator)
		do_bunch = TRUE
	var/new_id = ""
	while (TRUE)
		if (no_repeat)
			new_id = build_id_norepeat(char_list, id_length)
		else
			new_id = build_id(char_list, id_length)
		if (do_bunch)
			new_id = build_id_separate(new_id, bunch_size, separator)
		if (reg_list[new_id])
			continue
		break
	return new_id

/proc/build_id_fingerprint(var/list/char_list)
	return build_id_unique(char_list, 16, no_repeat=TRUE, bunch_size=4, separator="-")

// -----| Forensic Display |-----

// Store how the forensic text should be displayed... by reference! Might be unnecessary.
datum/forensic_display
	var/text = null

	New(var/text = null)
		..()
		src.text = text
