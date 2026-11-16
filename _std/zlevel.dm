
/// Instead of `#include "foo.dmm"` use the following macro which will also store information about the loaded z-level
#define INCLUDE_MAP(MAP_PATH, DATUM_PATH) \
	/datum/_zlevel_helper/inner/get_zlevels() \
		{ . = ..() + list(list("path"=MAP_PATH,"datum"=DATUM_PATH));}\
	INCLUDE MAP_PATH

// Saved as list of associated lists
// (["path": "../path.dmm", "datum": /datum/zlevel/subpath], ["path": "../path.dmm", "datum": /datum/zlevel/subpath])

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
	var/gforce = GFORCE_GRAVITY_MINIMUM
	/// name displayed when someone ingame wants to know which z-level they are
	var/display_name = "Unknown"
	/// teleportation inside the z-level is (mostly) prohibited
	var/teleport_restricted = TRUE
	/// ghosts cannot float around on the z-level
	var/ghost_restricted = TRUE

	New(path, z)
		..()
		src.path = path
		src.z = z
		src.generate_name()
		src.set_gforce(src.gforce, FALSE)

	proc/generate_name()
		var/list/path_parts = splittext(path, "/")
		var/filename = path_parts[length(path_parts)]
		var/filename_parts = splittext(filename, ".")
		src.name = filename_parts[1]

	proc/set_gforce(new_gforce, update_tethers=FALSE)
		src.gforce = new_gforce
		if (update_tethers)
			if (new_gforce == 0)
				SEND_GLOBAL_SIGNAL(COMSIG_GRAVITY_EVENT, GRAVITY_EVENT_CHANGE, src.z, GFORCE_EARTH_GRAVITY) // were going to space vegas, babey
			else if (new_gforce >= GFORCE_EARTH_GRAVITY)
				SEND_GLOBAL_SIGNAL(COMSIG_GRAVITY_EVENT, GRAVITY_EVENT_CHANGE, src.z, 0) // shut off on terrestiral gravity

		for (var/turf/T as anything in block(locate(1, 1, src.z), locate(world.maxx, world.maxy, src.z)))
			T.gforce_area_rev = 0

	// eventual plan is to add more properties to this (tele blockability, observability etc.) and create some subtypes which are chosen based on path
	// instead of base /datum/zlevel being used

/datum/zlevel/main
	teleport_restricted = FALSE
	ghost_restricted = FALSE

/datum/zlevel/main/dev
	display_name = "Dev Zone"
	gforce = GFORCE_EARTH_GRAVITY

/datum/zlevel/main/station
	display_name = "Station"

/datum/zlevel/main/station/terrestrial
	gforce = GFORCE_EARTH_GRAVITY

/datum/zlevel/main/ship
	display_name = "Ship"

/datum/zlevel/main/crash
	display_name = "Crash Site"

/datum/zlevel/main/podwars
	display_name = "Spess"

/datum/zlevel/adventure
	display_name = "Restricted"

/datum/zlevel/debris
	teleport_restricted = FALSE
	ghost_restricted = FALSE

/datum/zlevel/debris/space
	display_name = "Debris Field"

/datum/zlevel/debris/underwater
	display_name = "Deep Trench"
	ghost_restricted = TRUE // *only* ghosst restricted
	gforce = GFORCE_EARTH_GRAVITY

/datum/zlevel/mining
	teleport_restricted = FALSE
	ghost_restricted = FALSE

/datum/zlevel/mining/space
	display_name = "Asteroid Field"

/datum/zlevel/mining/underwater
	display_name = "Trench"
	gforce = GFORCE_EARTH_GRAVITY

// internals

/datum/_zlevel_helper
	proc/get_zlevels()
		. = list()

/datum/_zlevel_helper/inner

proc/init_zlevel_datums()
	var/datum/_zlevel_helper/inner/helper = new
	global.zlevels = list()
	for (var/z_level in helper.get_zlevels())
		var/datum_path = z_level["datum"] // extract the path so we can call it below without syntax errors
		global.zlevels += new datum_path(z_level["path"], length(global.zlevels) + 1)
