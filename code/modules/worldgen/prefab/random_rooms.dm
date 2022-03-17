/**
 * Want to add a room that's chosen from a selection of random rooms to your map? This is the place to look for that.
 * Put create a dmm file like assets/maps/random_rooms/WIDTHxHEIGHT/NAME_WEIGHT.dmm (or the appropriate secret folder).
 * WIDTH, HEIGHT are the dimensions of the room.
 * NAME is just what you choose to name it.
 * WEIGHT is the probability weight of the room, 100 is the default if you choose to omit this.
 *
 * Then placing an appropriate landmark on a map will choose a random room from the right folder.
 */


TYPEINFO(/datum/mapPrefab/random_room)
	folder = "random_rooms"

/datum/mapPrefab/random_room
	maxNum = 1 // Might be useful to add a way to override if someone ever wants that

	post_init()
		var/regex/size_regex = regex(@"^(\d+)x(\d+)$")
		for(var/tag in src.tags)
			if(size_regex.Find(tag))
				src.prefabSizeX = text2num(size_regex.group[1])
				src.prefabSizeY = text2num(size_regex.group[2])

		var/filename = filename_from_path(src.prefabPath)
		var/regex/probability_regex = regex(@"^.*_(\d+)\.dmm$")
		if(probability_regex.Find(filename))
			src.probability = text2num(probability_regex.group[1])


proc/buildRandomRooms()
	shuffle_list(by_type[/obj/landmark/random_room])
	for_by_tcl(landmark, /obj/landmark/random_room)
		landmark.apply()


/obj/landmark/random_room
	var/size = null
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/apply()
		var/datum/mapPrefab/random_room/room_prefab = pick_map_prefab(/datum/mapPrefab/random_room, list(size))
		if(isnull(room_prefab))
			CRASH("No random room prefab found for size: " + size)
		room_prefab.applyTo(src.loc)
		logTheThing("debug", null, null, "Applied random room prefab: [room_prefab] to [log_loc(src)]")
		qdel(src)

	size3x3
		size = "3x3"

	size3x5
		size = "3x5"

	size5x3
		size = "5x3"
