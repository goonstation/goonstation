
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
	/// gforce applied to all non-space tiles on this zlevel
	var/gforce = 1
	/// name displayed when someone ingame wants to know which z-level they are
	var/display_name = "Unknown"

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

	#ifndef UNDERWATER_MAP
	global.set_zlevel_gforce(Z_LEVEL_STATION, GFORCE_GRAVITY_MINIMUM, FALSE)
	if (length(global.zlevels) >= Z_LEVEL_DEBRIS)
		global.set_zlevel_gforce(Z_LEVEL_DEBRIS, GFORCE_GRAVITY_MINIMUM, FALSE)
	if (length(global.zlevels) >= Z_LEVEL_MINING)
		global.set_zlevel_gforce(Z_LEVEL_MINING, GFORCE_GRAVITY_MINIMUM, FALSE)
	#else
	global.set_zlevel_gforce(Z_LEVEL_STATION, GFORCE_EARTH_GRAVITY, FALSE)
	if (length(global.zlevels) >= Z_LEVEL_DEBRIS)
		global.set_zlevel_gforce(Z_LEVEL_DEBRIS, GFORCE_EARTH_GRAVITY, FALSE)
	if (length(global.zlevels) >= Z_LEVEL_MINING)
		global.set_zlevel_gforce(Z_LEVEL_MINING, GFORCE_EARTH_GRAVITY, FALSE)
	#endif

	// display_name-setting... god, i feel like i commit crimes here
	for(var/datum/zlevel/manipulated_zlevel in global.zlevels)
		var/name_to_set = "Unknown"
		switch(manipulated_zlevel.z)
			if (Z_LEVEL_STATION)
				name_to_set = "[capitalize(station_or_ship())]"
			if (Z_LEVEL_ADVENTURE)
				name_to_set = "Restricted"
			if (Z_LEVEL_DEBRIS)
				#ifdef UNDERWATER_MAP
				name_to_set = "Deep Trench"
				#else
				name_to_set = "Debris Field"
				#endif
			if (Z_LEVEL_MINING)
				#ifdef UNDERWATER_MAP
				name_to_set =  "Trench"
				#else
				name_to_set =  "Asteroid Field"
				#endif
			else
				continue
		manipulated_zlevel.display_name = name_to_set
