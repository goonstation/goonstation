/datum/computer/file/archive
	name = "archive"
	extension = "FAR"
	size = 8

	// Size of files stored within.
	var/uncompressed_size = 0
	// Generally assumed that all contained files will be expendable copies.
	var/tmp/list/contained_files = null
	var/max_contained_size = 48

/datum/computer/file/archive/New()
	. = ..()
	src.contained_files = list()

/datum/computer/file/archive/disposing()
	for (var/datum/computer/C as anything in src.contained_files)
		C.dispose()

	src.contained_files = null
	. = ..()

/datum/computer/file/archive/copy_file()
	var/datum/computer/file/archive/copy = ..() // handle our metadata

	copy.contained_files ||= list()
	for (var/datum/computer/C as anything in src.contained_files)
		copy.contained_files += C.copy_file()

	return copy

/datum/computer/file/archive/proc/add_file(datum/computer/C)
	if (!C || ((src.uncompressed_size + C.size) > src.max_contained_size))
		return FALSE

	if (istype(C, /datum/computer/file/archive))
		return FALSE

	src.contained_files += C
	src.uncompressed_size += C.size
	return TRUE
