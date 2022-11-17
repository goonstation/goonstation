
/// Instead of `#include "foo.dmm"` use the following macro which will also store information about the loaded z-level
#define INCLUDE_MAP(PATH) \
	/datum/_zlevel_helper/inner/get_zlevels() \
		{ . = ..() + list(PATH);}\
	INCLUDE PATH

/// List containing all z-level datums indexed by their z coordinate
var/global/list/datum/zlevel/zlevels = null

/// Datum representing a single z-level
/datum/zlevel
	/// Some name of the map loaded into this z-level, currently filename without extension
	var/name
	/// Filesystem path to the map loaded into this z-level
	var/path
	/// Z coordinate of this z-level
	var/z

	New(path, z)
		..()
		src.path = path
		src.z = z
		src.generate_name()

	proc/generate_name()
		var/list/path_parts = splittext(path, "/")
		var/filename = path_parts[length(path_parts)]
		var/filename_parts = splittext(filename, ".")
		src.name = filename_parts[1]

	// eventual plan is to add more properties to this (tele blockability, observability etc.) and create some subtypes which are chosen based on path
	// instead of base /datum/zlevel being used


// internals

/datum/_zlevel_helper
	proc/get_zlevels()
		. = list()

/datum/_zlevel_helper/inner

proc/init_zlevel_datums()
	var/datum/_zlevel_helper/inner/helper = new
	global.zlevels = list()
	for(var/path in helper.get_zlevels())
		global.zlevels += new /datum/zlevel(path, length(global.zlevels) + 1)
