#ifdef CI_RUNTIME_CHECKING

/**
 * Similar to the prefab runtime checker. The following text is mostly plagiarised from PrefabRuntimeChecker.dm
 *
 * The proc places all random rooms on the map in a grid.
 * Probstation rooms get their own pass.
 * It overwrites existing objects, mobs, and turfs when doing so.
 * This proc will only work correctly if RUNTIME_CHECKING is defined,
 * as some turfs cannot be replaced using `turf/proc/ReplaceWith()`
 * and RUNTIME_CHECKING fixes this.
 *
 * Do not use this proc on a live server.
 *
 * If you run it locally do not move your mob into the location turfs are
 * being placed (your client will be `qdel`'d).
 *
 * This proc was designed to be used with totally blank maps, where
 * every tile is either space or trench.
 *
 * Prefabs are found by looking for concrete types of
 * `/datum/mapPrefab/random_room`. To add a new prefab to be checked, simply
 * create a type for it.
 */
/proc/placeAllRandomRooms()
	var/startTime = world.timeofday
	CI.announce("Generating random rooms...")
	var/list/room_types = get_map_prefabs(/datum/mapPrefab/random_room)
	CI.announce("Found [length(room_types)] random rooms...")
	var/list/datum/mapPrefab/rooms = list()
	var/list/datum/mapPrefab/probstation_rooms = list()
	for (var/name in room_types)
		var/datum/mapPrefab/room = room_types[name]
		if ("probstation" in room.tags)
			probstation_rooms += room
		else
			rooms += room
	place_prefabs_for_checking(rooms, correctness_label = "random rooms")
	place_prefabs_for_checking(probstation_rooms, correctness_label = "probstation rooms")
	CI.announce("Placed random rooms in [((world.timeofday - startTime)/10)] seconds!")

#endif
