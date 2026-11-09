ABSTRACT_TYPE(/datum/computer)
/**
 *	Computer datums provide a representation for the various kinds of files and folders that can exist inside the DWAINE
 *	filesystem.
 */
/datum/computer
	/// The name of this computer datum.
	var/name = null
	/// The amount of disc space that this computer datum occupies.
	var/size = 4
	/// Prevents virtual PDA filehosting and TermOS copies.
	var/dont_copy = FALSE
	/// The physical disc that contains this computer datum.
	var/tmp/obj/item/disk/data/holder = null
	/// The parent folder that contains this computer datum.
	var/tmp/datum/computer/folder/holding_folder = null
	/// The metadata associated with this computer datum.
	var/tmp/list/metadata = null

/datum/computer/New()
	. = ..()
	src.metadata = list(
		"date" = world.realtime,
		"owner" = null,
		"group" = null,
		"permission" = DWAINE::PERM::DEFAULT::ALLACCESS,
	)

/datum/computer/disposing()
	if (src.holding_folder)
		src.holding_folder.remove_file(src)
		src.holding_folder = null

	src.holder = null
	src.metadata = null
	. = ..()

/// Converts the contents of the computer datum to text, if possible.
/datum/computer/proc/asText()
	return

/// Copy this computer datum.
/datum/computer/proc/copy_file(depth = 0)
	RETURN_TYPE(/datum/computer)
	return

/datum/computer/proc/get_archive_size()
	return src.size
