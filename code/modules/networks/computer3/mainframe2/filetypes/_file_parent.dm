/datum/computer/file
	name = "File"
	/// The extension associated with this computer file.
	var/extension = "FILE"

/datum/computer/file/asText()
	var/text = pick(
		"Error: Unknown filetype for '[name]'",
		"Imagine four balls on the edge of a cliff.  Time works the same way.",
		"Packet five loss packet six echo loss packet nine loss packet ten loss gain signal.",
	)

	return global.corruptText(text, 60)

/datum/computer/file/copy_file()
	var/datum/computer/file/copy = new src.type()

	for (var/variable_name as anything in src.vars)
		if (issaved(src.vars[variable_name]))
			copy.vars[variable_name] = src.vars[variable_name]

	copy.metadata ||= list()
	if (src.metadata)
		copy.metadata["owner"] = src.metadata["owner"]
		copy.metadata["permission"] = src.metadata["permission"]
		copy.metadata["group"] = src.metadata["group"]

	return copy

/// Makes a copy of this computer file in the specified folder.
/datum/computer/file/proc/copy_file_to_folder(datum/computer/folder/F, new_name)
	if (!astype(F)?.can_add_file(src))
		return FALSE

	var/datum/computer/file/copy = src.copy_file()
	if (new_name)
		copy.name = new_name

	if (!F.add_file(copy))
		qdel(copy)

	return TRUE

/// Whether this computer file can be wrote to.
/datum/computer/file/proc/writable()
	return src.holder?.read_only
