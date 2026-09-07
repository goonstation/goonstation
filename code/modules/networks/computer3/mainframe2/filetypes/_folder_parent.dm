/datum/computer/folder
	name = "Folder"
	size = 0
	/// The generation of this computer folder; that is, the number of nested parent folders above this folder.
	var/gen = 0
	/// The contents of this computer folder.
	var/list/datum/computer/contents = null
	/// The symlinks that link to this computer folder.
	var/tmp/list/datum/computer/folder/link/linkers = null

/datum/computer/folder/New()
	. = ..()
	src.contents = list()
	src.linkers = list()

/datum/computer/folder/disposing()
	for (var/datum/computer/folder/link/L as anything in src.linkers)
		L.contents.Cut()
		L.target = null

	for (var/datum/computer/C as anything in src.contents)
		C.dispose()

	src.contents = null
	src.linkers = null
	. = ..()

/datum/computer/folder/copy_file(depth = 0)
	if (depth >= 8)
		return

	var/datum/computer/folder/copy = new src.type()
	copy.name = src.name
	copy.holder = src.holder

	copy.metadata ||= list()
	if (src.metadata)
		copy.metadata["owner"] = src.metadata["owner"]
		copy.metadata["permission"] = src.metadata["permission"]
		copy.metadata["group"] = src.metadata["group"]

	depth += 1
	for (var/datum/computer/C as anything in src.contents)
		copy.add_file(C.copy_file(depth))

	return copy

/// Add a file to this computer folder.
/datum/computer/folder/proc/add_file(datum/computer/C)
	if (!src.can_add_file(C))
		return FALSE

	src.contents += C
	C.holder = src.holder
	C.holding_folder = src

	if (src.gen)
		C.metadata ||= list()
		if (isnull(C.metadata["owner"]))
			C.metadata["owner"] = src.metadata["owner"]
		if (isnull(C.metadata["group"]))
			C.metadata["group"] = src.metadata["group"]
		if (isnull(C.metadata["permission"]) || (C.metadata["permission"] == DWAINE::PERM::DEFAULT::ALLACCESS))
			C.metadata["permission"] = src.metadata["permission"]

	src.size += C.size
	src.holder.file_used += C.size
	astype(C, /datum/computer/folder)?.gen = src.gen + 1
	return TRUE

/// Remove a file from this computer folder.
/datum/computer/folder/proc/remove_file(datum/computer/C)
	if (!src.holder || src.holder.read_only || !C)
		return FALSE

	src.contents -= C
	src.size -= C.size
	src.holder.file_used = max(src.holder.file_used - C.size, 0)
	return TRUE

/// Whether the specified computer datum can be added to this folder.
/datum/computer/folder/proc/can_add_file(datum/computer/C)
	if (!src.holder || src.holder.read_only || !C)
		return FALSE

	if (istype(C, /datum/computer/folder) && (src.gen >= 10))
		return FALSE

	if ((src.holder.file_used + C.size) > src.holder.file_amount)
		return FALSE

	return TRUE
