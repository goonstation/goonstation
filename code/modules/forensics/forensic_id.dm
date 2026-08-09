
// Store forensic_ids into a dictionary to prevent duplicates
var/global/list/datum/forensic_id/registered_id_list = new()

/// Check if the ID already exists and return it. Else create a new ID.
/proc/register_id(id_text, list/reg_list = registered_id_list)
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

	New(id_text = "")
		if(id_text)
			src.id = id_text
			registered_id_list[id_text] = src
		..()

/proc/build_id(list/char_list, id_length)
	var/new_id = ""
	for(var/i in 1 to id_length)
		new_id += pick(char_list)
	return new_id

/proc/build_id_norepeat(list/char_list, id_length)
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

/proc/build_id_separate(text, bunch_size, separation_text = "-")
	var/final_text = copytext(text, 1, bunch_size + 1)
	var/bunch_count = floor(length(text) / bunch_size)
	for(var/i=1; i<= bunch_count - 1; i++)
		var/pos = (i * bunch_size) + 1
		final_text += separation_text + copytext(text, pos, pos + bunch_size)
	return final_text

/// Builds a forensic ID with the given proc and charcter list, ensures it is unique in the given registry list, and returns the corresponding forensic string.
///
/// You must register the returned datum/forensic_id with register_id() to ensure it is stored in the global list of IDs.
///
/// Best usage: Write a wrapper build_id proc chaining the above procs together for your forensic item, then pass that wrapper proc to this proc.
///
/// * forensic_proc (proc) [Required] - The proc to call to build the ID. Must return a string.
/// * char_list (list) [Required] - The list of characters to build the ID from.
/// * reg_list (list) [Default: global.registered_id_list] - The list of IDs to check against for duplicates. Defaults to the global registered ID list.
/proc/build_id_unique(forensic_proc, list/char_list, list/reg_list=global.registered_id_list)
	if (!forensic_proc || !char_list || !reg_list)
		CRASH("One or more required arguments not passed to build_id_unique")

	var/new_id = ""

	while (TRUE)
		new_id = call(forensic_proc)(char_list)
		if (reg_list[new_id])
			continue
		break

	return new_id

/proc/build_id_fingerprint(list/char_list)
	return build_id_separate(build_id_norepeat(char_list, 16), 4, "-")

// -----| Forensic Display |-----

// Store how the forensic text should be displayed... by reference! Might be unnecessary.
datum/forensic_display
	var/text = null

	New(text = null)
		..()
		src.text = text
