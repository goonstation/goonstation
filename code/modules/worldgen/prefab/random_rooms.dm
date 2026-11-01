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
	for_by_tcl(landmark, /obj/landmark/engine_room)
		landmark.apply()


/obj/landmark/random_room
	var/size = null
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "random_room"
	deleted_on_start = FALSE
	add_to_landmarks = FALSE
	opacity = 1
	invisibility = 0 // To see landmarks if NO_RANDOM_ROOM is defined
	plane = PLANE_FLOOR
	var/list/additional_tags = null //! All of these tags must be present on the random room prefab for it to be chosen

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

	proc/apply()
		var/tags = list(size)
		if(!isnull(additional_tags))
			tags += additional_tags
		var/datum/mapPrefab/random_room/room_prefab = pick_map_prefab(/datum/mapPrefab/random_room, wanted_tags_all=tags)
		if(isnull(room_prefab))
			CRASH("No random room prefab found for [src.type] (size: [size], additional tags: [json_encode(additional_tags)]")
		room_prefab.applyTo(src.loc)
		logTheThing(LOG_DEBUG, null, "Applied random room prefab: [room_prefab] to [log_loc(src)]")
		qdel(src)

	// TODO these should likely also be organized into an additional tag for actual rooms, I just don't feel like causing myriad merge conflicts in maps rn
	size3x3
		size = "3x3"
		icon = 'icons/effects/mapeditor/3x3tiles.dmi'

	size3x5
		size = "3x5"
		icon = 'icons/effects/mapeditor/3x5tiles.dmi'

	size5x3
		size = "5x3"
		icon = 'icons/effects/mapeditor/5x3tiles.dmi'

	nadir_rocks_7x5
		size = "7x5"
		icon = 'icons/effects/mapeditor/7x5tiles.dmi'
		additional_tags = list("nadir_rocks")

	d2_artlab_5x15
		size = "5x15"
		additional_tags = list("d2_artlab")

//Probstation
/obj/landmark/random_room/probstation
	size = "9x9"
	icon = 'icons/effects/mapeditor/9x9tiles.dmi'
	additional_tags = list("probstation")

/obj/landmark/random_room/probstation_15x15
	size = "15x15"
	icon = 'icons/effects/mapeditor/15x15tiles.dmi'
	additional_tags = list("probstation")

/obj/landmark/random_room/probstation_shuttles
	size = "32x32"
	icon = 'icons/effects/mapeditor/32x32tiles.dmi'
	icon_state = "probstation_shuttles"
	additional_tags = list("probstation")
	var/static/locations_to_apply = list("shuttle", "traders")

	apply()
		var/picked_tag = pick(locations_to_apply)
		src.additional_tags += picked_tag
		src.locations_to_apply -= picked_tag
		src.additional_tags += dir_to_dirname(src.dir)
		. = ..()

/obj/landmark/random_room/probstation_spacejunk_32x32
	size = "32x32"
	icon = 'icons/effects/mapeditor/32x32tiles.dmi'
	icon_state = "probstation_shuttles"
	additional_tags = list("probstation", "spacejunk")
