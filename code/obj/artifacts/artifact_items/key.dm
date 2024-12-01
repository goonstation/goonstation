#define NORTH_ENTRANCE 1
#define EAST_ENTRANCE 2
#define SOUTH_ENTRANCE 3
#define WEST_ENTRANCE 4

/obj/item/artifact/key
	name = "artifact key"
	icon = 'icons/obj/artifacts/artifactsitemS.dmi'
	associated_datum = /datum/artifact/key
	var/datum/allocated_region/backroom_region

	// var names here are in reference to inside the fissure - south means south entrance of the room
	var/list/south_dummies = list()
	var/list/north_dummies = list()
	var/list/east_dummies = list()
	var/list/west_dummies = list()

	var/south_entr_placed = FALSE
	var/north_entr_placed = FALSE
	var/east_entr_placed = FALSE
	var/west_entr_placed = FALSE

	afterattack(atom/target, mob/user, reach)
		..()
		if (!src.artifact.activated)
			return
		if (!reach)
			return
		if (BOUNDS_DIST(user, target) > 0 || !iswall(target) || istype(get_area(target), /area/artifact_backroom) || user.z == Z_LEVEL_SECRET || user.z == Z_LEVEL_ADVENTURE)
			boutput(user, SPAN_ALERT("Nothing happens, except for a light stinging sensation in your hand. [src] probably doesn't work here"))
			return

		if (user.dir == NORTH)
			if (!src.south_entr_placed)
				src.create_entrance(SOUTH_ENTRANCE, target, user)
			else
				boutput(user, SPAN_ALERT("Nothing happens, except for a light stinging sensation in your hand."))
		else if (user.dir == SOUTH)
			if (!src.north_entr_placed)
				src.create_entrance(NORTH_ENTRANCE, target, user)
			else
				boutput(user, SPAN_ALERT("Nothing happens, except for a light stinging sensation in your hand."))
		else if (user.dir == EAST)
			if (!src.west_entr_placed)
				src.create_entrance(WEST_ENTRANCE, target, user)
			else
				boutput(user, SPAN_ALERT("Nothing happens, except for a light stinging sensation in your hand."))
		else if (user.dir == WEST)
			if (!src.east_entr_placed)
				src.create_entrance(EAST_ENTRANCE, target, user)
			else
				boutput(user, SPAN_ALERT("Nothing happens, except for a light stinging sensation in your hand."))

	proc/create_entrance(entrance_dir, turf/entrance, mob/user)
		switch (entrance_dir)
			if (SOUTH_ENTRANCE)
				var/obj/cross_dummy/north/n = new (entrance, src.backroom_region.turf_at(15, 14))
				var/obj/cross_dummy/south/s = new (src.backroom_region.turf_at(15, 13), get_step(entrance, SOUTH))
				src.south_dummies += n
				src.south_dummies += s
			if (NORTH_ENTRANCE)
				var/obj/cross_dummy/south/s = new (entrance, src.backroom_region.turf_at(15, 24))
				var/obj/cross_dummy/north/n = new (src.backroom_region.turf_at(15, 25), get_step(entrance, NORTH))
				src.north_dummies += s
				src.north_dummies += n
			if (EAST_ENTRANCE)
				var/obj/cross_dummy/west/w = new (entrance, src.backroom_region.turf_at(17, 19))
				var/obj/cross_dummy/east/e = new (src.backroom_region.turf_at(18, 29), get_step(entrance, EAST))
				src.east_dummies += w
				src.east_dummies += e
			if (WEST_ENTRANCE)
				var/obj/cross_dummy/east/e = new (entrance, src.backroom_region.turf_at(13, 19))
				var/obj/cross_dummy/west/w = new (src.backroom_region.turf_at(12, 19), get_step(entrance, WEST))
				src.west_dummies += e
				src.west_dummies += w

		entrance.density = FALSE
		var/obj/artifact_door/wooden_door = new(entrance)
		wooden_door.set_dir(get_dir(wooden_door, user))
		src.update_visual_mirrors(entrance)
		entrance.icon = 'icons/turf/floors.dmi'
		entrance.icon_state = "darkvoid"
		entrance.opacity = TRUE
		entrance.name = "Thick void mist"
		entrance.desc = "Void mist thick enough that you can't see through it.. How did this get here?"
		RL_UPDATE_LIGHT(entrance)

	proc/update_visual_mirrors(turf/station_reference, entrance)
		var/col_start
		var/col_end
		var/row_start
		var/row_end
		var/x_start_offset
		var/y_start_offset

		switch(entrance)
			if (NORTH_ENTRANCE)
				col_start = 1
				col_end = 29
				row_start = 25
				row_end = 35
				x_start_offset = -15
				y_start_offset = -24
			if (SOUTH_ENTRANCE)
				col_start = 1
				col_end = 29
				row_start = 1
				row_end = 13
				x_start_offset = -15
				y_start_offset = -14
			if (EAST_ENTRANCE)
				col_start = 18
				col_end = 29
				row_start = 1
				row_end = 35
				x_start_offset = -17
				y_start_offset = -19
			if (WEST_ENTRANCE)
				col_start = 1
				col_end = 12
				row_start = 1
				row_end = 35
				x_start_offset = -13
				y_start_offset = -19

		var/turf/T
		var/turf/station_turf
		for (var/i = col_start to col_end)
			for (var/j = row_start to row_end)
				T = src.backroom_region.turf_at(i, j)
				station_turf = locate(station_reference.x + x_start_offset + i, station_reference.y + y_start_offset + j, station_reference.z)

				if (station_turf)
					station_turf.appearance_flags |= KEEP_TOGETHER
					T.vis_contents = null // clear previously assigned vis_contents
					//RL_UPDATE_LIGHT(T)
					//T.RL_AddOverlay()
					//RL_APPLY_LIGHT(T, null, null, station_turf.RL_GetBrightness(), 0, 255, 255, 255)
					T.vis_contents += station_turf
					T.density = station_turf.density
					T.opacity = station_turf.opacity
					T.name = station_turf.name
					T.desc = station_turf.desc
					T.icon = station_turf.icon
					T.icon_state = station_turf.icon_state
					//T.fullbright = TRUE
					T.RL_Init()

/datum/artifact/key
	associated_object = /obj/item/artifact/key
	type_name = "Dimensional key"
	type_size = ARTIFACT_SIZE_TINY
	rarity_weight = 200
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	react_xray = list(73, 90, 38, 4, "SEGMENTED")
	examine_hint = "It kinda looks like it's supposed to be inserted into something."




/****** Supporting items/atoms/etc. *******/

ABSTRACT_TYPE(/obj/cross_dummy)
/obj/cross_dummy
	name = ""
	desc = ""
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED_ALWAYS
	var/turf/exit_turf
	var/required_dir

	New(newLoc, turf/exit)
		..()
		src.exit_turf = exit

	Crossed(atom/movable/AM)
		if (AM.dir == src.required_dir)
			AM.set_loc(src.exit_turf)
			var/obj/artifact_door/wooden_door = locate() in src.exit_turf
			wooden_door.open()
		else
			return ..()

	north
		required_dir = NORTH

	east
		required_dir = EAST

	south
		required_dir = SOUTH

	west
		required_dir = WEST

/obj/artifact_door
	name = "Mysterious Wooden Door"
	desc = "A wooden door, but it emanates some aura. Something's not right about it."
	icon = 'icons/obj/doors/door_wood.dmi'
	icon_state = "door1"
	opacity = TRUE
	density = TRUE
	var/open = FALSE

	attack_hand(mob/user)
		..()
		if (src.open)
			src.close()
		else if (!src.open && istype(get_area(user), /area/artifact_backroom))
			src.open()
		else
			boutput(user, SPAN_NOTICE("[src] is locked. Perhaps a key will open it?"))

	attackby(obj/item/I, mob/user)
		if (!istype(I, /obj/item/artifact/key) || !I.artifact.activated)
			return ..()
		if (src.open)
			src.close()
		else
			src.open()

	proc/open()
		playsound(src, 'sound/machines/door_open.ogg', 50, TRUE)
		src.icon = "door0"
		flick("doorc0", src)
		src.opacity = FALSE
		src.density = FALSE
		src.open = TRUE

	proc/close()
		playsound(src, 'sound/machines/door_close.ogg', 50, TRUE)
		src.icon = "door1"
		flick("doorc1", src)
		src.opacity = TRUE
		src.density = TRUE
		src.open = FALSE

	proc/deny_open()
		flick("door_deny", src)
		if (ON_COOLDOWN(src, "deny_sound", 1 SECOND))
			return
		playsound(src, 'sound/machines/airlock_deny.ogg', 25, FALSE)

	unopenable
		attackby(obj/item/I, mob/user)
			if (istype(I, /obj/item/artifact/key) && I.artifact.activated)
				boutput(user, SPAN_NOTICE("Looks this isn't the right key. Bummer."))
				return
			return ..()

/area/artifact_backroom
	name = "Dimensional Fissure"
	skip_sims = TRUE

/area/artifact_backroom/visual_mirror
	name = "Artifact backroom visual mirror zone"
	//ambient_light = "#ffffff"
	force_fullbright = TRUE

/*
for (var/i = 1 to 8)
					var/turf/Z = locate(T.x, T.y + i, T.z)
					var/image/I = image('icons/turf/floors.dmi', Z, i % 2 == 0 ? "marble_black" : "marble_white", T.layer + 0.0001)
					I.alpha = 200
					Z.overlays += I

					if (i % 2 == 0)
						I = image('icons/obj/lighting.dmi', Z, "floor1", T.layer + 0.0001)
						I.alpha = 200
						Z.overlays += I

					Z = locate(T.x - 1, T.y + i, T.z)
					I = image('icons/turf/floors.dmi', Z, "marble_white", T.layer + 0.0001)
					I.alpha = 200
					Z.overlays += I

					Z = locate(T.x + 1, T.y + i, T.z)
					I = image('icons/turf/floors.dmi', Z, "marble_white", T.layer + 0.0001)
					I.alpha = 200
					Z.overlays += I

					Z = locate(T.x - 2, T.y + i, T.z)
					if (i % 2 == 0)
						I = image('icons/obj/doors/door_wood.dmi', Z, "door1", T.layer + 0.0001)
					else
						I = image('icons/turf/walls.dmi', Z, "ancient", T.layer + 0.0001)
					I.alpha = 200
					Z.overlays += I

					Z = locate(T.x + 2, T.y + i, T.z)
					if (i % 2 == 0)
						I = image('icons/obj/doors/door_wood.dmi', Z, "door1", T.layer + 0.0001)
					else
						I = image('icons/turf/walls.dmi', Z, "ancient", T.layer + 0.0001)
					I.alpha = 200
					Z.overlays += I
					*/

#undef NORTH_ENTRANCE
#undef EAST_ENTRANCE
#undef SOUTH_ENTRANCE
#undef WEST_ENTRANCE

