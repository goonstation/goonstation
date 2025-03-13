#define NORTH_ENTRANCE 1
#define EAST_ENTRANCE 2
#define SOUTH_ENTRANCE 3
#define WEST_ENTRANCE 4

/obj/item/artifact/dimensional_key
	name = "artifact key"
	icon = 'icons/obj/artifacts/artifactsitemS.dmi'
	associated_datum = /datum/artifact/dimensional_key
	var/datum/allocated_region/fissure_region

	// var names here are in reference to inside the fissure - south means south entrance of the room
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
		if (!iswall(target))
			return
		if (BOUNDS_DIST(user, target) > 0 || isrestrictedz(get_z(target)))
			boutput(user, SPAN_ALERT("Nothing happens, except for a light stinging sensation in your hand. [src] probably doesn't work here"))
			return

		if (user.dir == NORTH)
			if (!src.south_entr_placed)
				src.create_entrance(SOUTH_ENTRANCE, target, user)
				src.south_entr_placed = TRUE
			else
				boutput(user, SPAN_ALERT("Nothing happens, except for a light stinging sensation in your hand."))
		else if (user.dir == SOUTH)
			if (!src.north_entr_placed)
				src.create_entrance(NORTH_ENTRANCE, target, user)
				src.north_entr_placed = TRUE
			else
				boutput(user, SPAN_ALERT("Nothing happens, except for a light stinging sensation in your hand."))
		else if (user.dir == EAST)
			if (!src.west_entr_placed)
				src.create_entrance(WEST_ENTRANCE, target, user)
				src.west_entr_placed = TRUE
			else
				boutput(user, SPAN_ALERT("Nothing happens, except for a light stinging sensation in your hand."))
		else if (user.dir == WEST)
			if (!src.east_entr_placed)
				src.create_entrance(EAST_ENTRANCE, target, user)
				src.east_entr_placed = TRUE
			else
				boutput(user, SPAN_ALERT("Nothing happens, except for a light stinging sensation in your hand."))

	proc/create_entrance(entrance_dir, turf/entrance, mob/user)
		var/obj/art_fissure_objs/door/inner_door
		var/turf/fissure_entr
		var/list/adj_entr_turfs
		switch (entrance_dir)
			if (SOUTH_ENTRANCE)
				fissure_entr = src.fissure_region.turf_at(15, 14)
				new /obj/art_fissure_objs/cross_dummy/north(entrance, fissure_entr)
				new /obj/art_fissure_objs/cross_dummy/south(src.fissure_region.turf_at(15, 13), get_step(entrance, SOUTH))
				inner_door = locate() in src.fissure_region.turf_at(15, 14)
				inner_door.outer_entrance_spawned = TRUE
				adj_entr_turfs = block(entrance.x - 1, entrance.y - 1, entrance.z, entrance.x + 1, entrance.y - 1, entrance.z)
			if (NORTH_ENTRANCE)
				fissure_entr = src.fissure_region.turf_at(15, 24)
				new /obj/art_fissure_objs/cross_dummy/south(entrance, fissure_entr)
				new /obj/art_fissure_objs/cross_dummy/north(src.fissure_region.turf_at(15, 25), get_step(entrance, NORTH))
				inner_door = locate() in src.fissure_region.turf_at(15, 24)
				inner_door.outer_entrance_spawned = TRUE
				adj_entr_turfs = block(entrance.x - 1, entrance.y + 1, entrance.z, entrance.x + 1, entrance.y + 1, entrance.z)
			if (EAST_ENTRANCE)
				fissure_entr = src.fissure_region.turf_at(17, 19)
				new /obj/art_fissure_objs/cross_dummy/west(entrance, fissure_entr)
				new /obj/art_fissure_objs/cross_dummy/east(src.fissure_region.turf_at(18, 19), get_step(entrance, EAST))
				inner_door = locate() in src.fissure_region.turf_at(17, 19)
				inner_door.outer_entrance_spawned = TRUE
				adj_entr_turfs = block(entrance.x + 1, entrance.y - 1, entrance.z, entrance.x + 1, entrance.y + 1, entrance.z)
			if (WEST_ENTRANCE)
				fissure_entr = src.fissure_region.turf_at(13, 19)
				new /obj/art_fissure_objs/cross_dummy/east(entrance, fissure_entr)
				new /obj/art_fissure_objs/cross_dummy/west(src.fissure_region.turf_at(12, 19), get_step(entrance, WEST))
				inner_door = locate() in src.fissure_region.turf_at(13, 19)
				inner_door.outer_entrance_spawned = TRUE
				adj_entr_turfs = block(entrance.x - 1, entrance.y - 1, entrance.z, entrance.x - 1, entrance.y + 1, entrance.z)

		entrance.density = FALSE
		entrance.flags |= (FLUID_DENSE | FLUID_DENSE_ALWAYS)
		var/obj/art_fissure_objs/door/outer_door = new(entrance)
		outer_door.set_dir(get_dir(outer_door, user))
		outer_door.linked_door = inner_door
		inner_door.set_dir(get_dir(outer_door, user))
		inner_door.linked_door = outer_door
		fissure_entr.reachable_turfs += adj_entr_turfs
		for (var/turf/T as anything in fissure_entr.reachable_turfs)
			if (!T.reachable_turfs)
				T.reachable_turfs = list()
			T.reachable_turfs += fissure_entr
		var/area/artifact_fissure/A = get_area(inner_door)
		A.update_visual_mirrors(entrance, entrance_dir)
		new /obj/art_fissure_objs/mirror_update_dummy(fissure_entr, entrance, entrance_dir)
		entrance.icon = 'icons/turf/floors.dmi'
		entrance.icon_state = "darkvoid"
		entrance.opacity = TRUE
		entrance.name = "Thick void mist"
		entrance.desc = "Void mist thick enough that you can't see through it.. How did this get here?"
		RL_UPDATE_LIGHT(entrance)

		logTheThing(LOG_STATION, src, "Dimensional key artifact door created at [log_loc(outer_door)] by [key_name(user)].")

/datum/artifact/dimensional_key
	associated_object = /obj/item/artifact/dimensional_key
	type_name = "Dimensional key"
	type_size = ARTIFACT_SIZE_TINY
	rarity_weight = 200
	validtypes = list("eldritch", "precursor")
	react_xray = list(73, 90, 38, 4, "ANOMALOUS")
	examine_hint = "It kinda looks like it's supposed to be inserted into something."

	effect_activate(obj/O)
		. = ..()
		if (.)
			return TRUE
		var/obj/item/artifact/dimensional_key/artkey = O
		var/datum/mapPrefab/allocated/allocated = get_singleton(/datum/mapPrefab/allocated/artifact_fissure)
		artkey.fissure_region = allocated.load()
		var/turf/T = artkey.fissure_region.get_center()
		var/area/artifact_fissure/fissure_area = get_area(T)
		fissure_area.fissure_region = artkey.fissure_region

/****** Supporting items/atoms/etc. *******/

ABSTRACT_TYPE(/obj/art_fissure_objs)
/obj/art_fissure_objs
	name = ""
	desc = ""
	anchored = ANCHORED_ALWAYS

	ex_act()
		return

ABSTRACT_TYPE(/obj/art_fissure_objs/cross_dummy)
/obj/art_fissure_objs/cross_dummy
	invisibility = INVIS_ALWAYS
	var/turf/exit_turf
	var/required_dir

	New(newLoc, turf/exit)
		..()
		src.exit_turf = exit

	disposing()
		src.exit_turf = null
		..()

	Crossed(atom/movable/AM)
		if (istype(AM, /obj/projectile))
			var/obj/projectile/P = AM
			var/obj/projectile/new_proj = initialize_projectile(src.exit_turf, P.proj_data, P.xo, P.yo, P.shooter)
			new_proj.travelled = P.travelled
			new_proj.launch()
			P.die()
		else if (AM.dir == src.required_dir && !istype(AM, /obj/art_fissure_objs/door) && !istype(AM, /obj/art_fissure_objs/cross_dummy))
			// makes it look like an animation glide
			AM.set_loc(get_step(src.exit_turf, turn(AM.dir, 180)))
			SPAWN(0.001) // just a really low value
				AM.set_loc(src.exit_turf)

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

/obj/art_fissure_objs/mirror_update_dummy
	invisibility = INVIS_ALWAYS
	var/turf/station_ref
	var/entrance_loc

	New(newLoc, turf/station_ref, entrance_loc)
		..()
		src.station_ref = station_ref
		src.entrance_loc = entrance_loc

	disposing()
		src.station_ref = null
		..()

	Crossed(atom/movable/AM)
		if (isliving(AM) && !isintangible(AM))
			var/area/artifact_fissure/fissure_area = get_area(src)
			fissure_area.update_visual_mirrors(src.station_ref, src.entrance_loc)
			return ..()
		return ..()

/obj/art_fissure_objs/door
	name = "mysterious wooden door"
	desc = "A wooden door, but it emanates some aura. Something's not right about it."
	icon = 'icons/obj/doors/door_wood.dmi'
	icon_state = "door1"
	opacity = TRUE
	density = TRUE
	/// open or closed
	var/open = FALSE
	/// whether this is a "fake" door or not
	var/can_be_opened = TRUE
	/// if a door as a part of the fissure, whether the corresponding outer entrance has been created or not
	var/outer_entrance_spawned = FALSE
	/// associated door in/outside the fissure
	var/obj/art_fissure_objs/door/linked_door = null

	disposing()
		src.linked_door = null
		..()

	attack_hand(mob/user)
		..()
		if (!src.can_be_opened)
			src.deny_open()
			boutput(user, SPAN_NOTICE("[src] is locked. Perhaps a key will open it?"))
			return
		if (src.open)
			src.close()
		else if (!src.open && istype(get_area(user), /area/artifact_fissure))
			if (!src.outer_entrance_spawned)
				src.deny_open()
				boutput(user, SPAN_NOTICE("[src] doesn't seemed to be locked, but won't open either... strange."))
			else
				src.open()
		else
			src.deny_open()
			boutput(user, SPAN_NOTICE("[src] is locked. Perhaps a key will open it?"))

	attackby(obj/item/I, mob/user)
		if (!istype(I, /obj/item/artifact/dimensional_key) || !I.artifact.activated)
			return ..()
		if (!src.can_be_opened)
			src.deny_open()
			boutput(user, SPAN_NOTICE("Looks like [I] doesn't fit. Bummer."))
			return
		if (src.open)
			src.close()
		else
			if (!src.outer_entrance_spawned && istype(get_area(src), /area/artifact_fissure))
				src.deny_open()
				boutput(user, SPAN_NOTICE("[src] doesn't seemed to be locked, but won't open either... strange."))
			else
				var/obj/item/artifact/dimensional_key/key = I
				key.ArtifactFaultUsed(user, key)
				src.open()

	Bumped(atom/movable/AM)
		..()
		var/mob/living/L = AM
		if (!istype(L))
			return
		var/obj/item/equipped_item = L.equipped()
		if (istype(equipped_item, /obj/item/artifact/dimensional_key) && equipped_item.artifact.activated)
			src.Attackby(equipped_item, L)
		else
			src.Attackhand(L)

	proc/open(recursion_check = TRUE)
		src.icon_state = "door0"
		playsound(src, 'sound/machines/door_open.ogg', 50, TRUE)
		flick("doorc0", src)
		src.set_opacity(FALSE)
		src.density = FALSE
		src.open = TRUE
		if (recursion_check)
			src.linked_door.open(FALSE)

	proc/close(recursion_check = TRUE)
		src.icon_state = "door1"
		playsound(src, 'sound/machines/door_close.ogg', 50, TRUE)
		flick("doorc1", src)
		src.set_opacity(TRUE)
		src.density = TRUE
		src.open = FALSE
		if (recursion_check)
			src.linked_door.close(FALSE)

	proc/deny_open()
		flick("door_deny", src)
		if (ON_COOLDOWN(src, "deny_sound", 1 SECOND))
			return
		playsound(src, 'sound/machines/door_locked.ogg', 40, FALSE)

	unopenable
		can_be_opened = FALSE

TYPEINFO(/turf/unsimulated/wall/auto/adventure/ancient/artifact_fissure)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/adventure/ancient/artifact_fissure)
	. = ..()
	src.connects_to[/obj/art_fissure_objs/door] = TRUE
	src.connects_to[/obj/art_fissure_objs/door/unopenable] = TRUE
	src.connects_with_overlay[/obj/art_fissure_objs/door] = TRUE
	src.connects_with_overlay[/obj/art_fissure_objs/door/unopenable] = TRUE

/area/artifact_fissure
	name = "dimensional fissure"
	skip_sims = TRUE
	var/datum/allocated_region/fissure_region

	Entered(atom/movable/AM, atom/oldloc)
		..()
		AM.setStatus("art_fissure_corrosion", INFINITE_STATUS)

	Exited(atom/movable/AM)
		AM.delStatus("art_fissure_corrosion")
		..()

	proc/update_visual_mirrors(turf/station_ref, entrance_loc)
		var/col_start
		var/col_end
		var/row_start
		var/row_end
		var/x_start_offset
		var/y_start_offset

		switch(entrance_loc)
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
				T = src.fissure_region.turf_at(i, j)
				station_turf = locate(station_ref.x + x_start_offset + i, station_ref.y + y_start_offset + j, station_ref.z)

				T.vis_contents = null// clear previously assigned vis_contents
				if (station_turf)
					station_turf.appearance_flags |= KEEP_TOGETHER
					if (!station_turf.listening_turfs)
						station_turf.listening_turfs = list()
					station_turf.listening_turfs += T

					T.vis_contents += station_turf
					T.density = station_turf.density
					T.opacity = station_turf.opacity
					for (var/atom/A as anything in station_turf)
						if (A.opacity)
							T.opacity = TRUE
							break
					T.name = station_turf.name
					T.desc = station_turf.desc
					T.icon = station_turf.icon
					T.icon_state = station_turf.icon_state
				else // past edge of map
					T.icon = null
					T.icon_state = null
					T.density = TRUE
					T.opacity = TRUE
					T.name = ""
					T.desc = ""
				T.RL_Init()

/area/artifact_fissure/visual_mirror
	name = "artifact fissure visual mirror zone"
	force_fullbright = TRUE

#undef NORTH_ENTRANCE
#undef EAST_ENTRANCE
#undef SOUTH_ENTRANCE
#undef WEST_ENTRANCE

