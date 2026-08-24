/datum/computer/folder/link
	name = "symlink"
	gen = 10
	/// The folder that this symlink should point to.
	var/datum/computer/folder/target = null

/datum/computer/folder/link/New(datum/computer/folder/F)
	. = ..()
	src.gen = 10

	var/datum/computer/folder/link/symlink = astype(F)
	if (symlink)
		F = symlink.target

	if (!istype(F))
		return

	src.target = F
	src.contents = F.contents
	F.linkers += src

/datum/computer/folder/link/disposing()
	if (src.target)
		src.target.linkers -= src
		src.target = null

	src.contents = null
	. = ..()

/datum/computer/folder/link/copy_file(depth = 0)
	if (!src.target || (src.target.holder != src.holder))
		return FALSE

	return src.target.copy_file(depth)

/// Add a file to the linked folder and optional driver data
/datum/computer/folder/link/add_file(datum/computer/C, misc)
	if (!src.target || (src.target.holder != src.holder))
		return FALSE

	return src.target.add_file(C, misc)

/datum/computer/folder/link/remove_file(datum/computer/C)
	if (!src.target || (src.target.holder != src.holder))
		return FALSE

	return src.target.remove_file(C)

/datum/computer/folder/link/can_add_file(datum/computer/C)
	if (!src.target || (src.target.holder != src.holder))
		return FALSE

	return src.target.can_add_file(C)
