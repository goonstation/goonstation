#define RAND_3_BY_3 1
#define RAND_3_BY_5 2
#define RAND_5_BY_3 3

//you like rooms, right?
/datum/random_event/menhir/extrusion
	name = "A Place of Paths Not Taken"
	description = "A regular random room of any type appears at one of a few preselected locations along the edge of the station."
	message_delay = 3 MINUTES

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_EXTRUSION] || length(landmarks[LANDMARK_MENHIR_EXTRUSION]) < 1) //if no eligible nodes remain, do not trigger event
				. = FALSE

	event_effect()
		var/turf/extlandmark = pick(landmarks[LANDMARK_MENHIR_EXTRUSION])
		var/alignment = landmarks[LANDMARK_MENHIR_EXTRUSION][extlandmark]
		var/are_we_west = FALSE
		if (alignment == "WEST") are_we_west = TRUE
		var/roomtype = rand(1,3)

		var/list/frametiles = src.get_walls(extlandmark, are_we_west, roomtype)
		var/list/to_area_swap = src.get_whole_coverage(extlandmark, are_we_west, roomtype)
		var/turf/rroom_site = src.get_room_spot(extlandmark, are_we_west, roomtype)

		var/area/hostarea = get_area(extlandmark)

		for (var/turf/T in to_area_swap)
			if(isarea(T.loc))
				var/area/A = T.loc
				A.contents -= T
			hostarea.contents += T

		var/do_rwalls = FALSE
		if (istype(extlandmark,/turf/simulated/wall/auto/reinforced)) do_rwalls = TRUE

		for (var/turf/T in frametiles)
			if((T.density && !do_rwalls) || locate(/obj/window) in T || locate(/obj/machinery/door) in T) continue
			if(do_rwalls)
				T.ReplaceWithRWall()
			else
				T.ReplaceWithWall()
			leaveresidual(T)

		var/already_have_door = FALSE
		for (var/obj/O in extlandmark)
			if(istype(O,/obj/mesh) || istype(O,/obj/window))
				qdel(O)
			if(istype(O,/obj/machinery/door))
				already_have_door = TRUE
		if (extlandmark.density)
			extlandmark.ReplaceWith(/turf/simulated/floor/plating)
		if (!already_have_door)
			var/obj/newdoor = new /obj/machinery/door/airlock/pyro/maintenance(extlandmark)
			newdoor.dir = EAST

		var/obj/landmark/random_room/mark_plier
		switch(roomtype)
			if(RAND_3_BY_3) mark_plier = new /obj/landmark/random_room/size3x3(rroom_site)
			if(RAND_3_BY_5) mark_plier = new /obj/landmark/random_room/size3x5(rroom_site)
			if(RAND_5_BY_3) mark_plier = new /obj/landmark/random_room/size5x3(rroom_site)
		mark_plier.apply()

		if(prob(60))
			playsound(extlandmark, 'sound/effects/ring_happi.ogg', 65, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(extlandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 65, 0, extrarange = 24)

		src.localize_reading(extlandmark)

		message_delay = rand(90 SECONDS, 140 SECONDS)
		..()

		landmarks[LANDMARK_MENHIR_EXTRUSION].Remove(extlandmark)

		logTheThing(LOG_STATION, null, "Menhir event [src.name] at [log_loc(extlandmark)]")
		message_admins("Menhir event [src.name] triggered at [log_loc(extlandmark)]")

	///Retrieves the turfs to frame out the new room.
	proc/get_walls(var/turf/T, var/offset_to_west, var/roomtype)
		. = list()
		var/offset_H = 4
		if(roomtype == RAND_5_BY_3) offset_H = 6
		var/offset_V = 2 //applies in each direction, so total vertical span is double this plus 1
		if(roomtype == RAND_3_BY_5) offset_V = 3

		. += block(T.x, T.y - offset_V, T.z, T.x, T.y + offset_V, T.z) //vertical along landmark column (consistent across directions)
		if(offset_to_west)
			. += block(T.x - offset_H, T.y - offset_V, T.z, T.x - offset_H, T.y + offset_V, T.z) //vertical at far end
			offset_H -= 1
			. += block(T.x - offset_H, T.y - offset_V, T.z, T.x - 1, T.y - offset_V, T.z) //below, from far to close
			. += block(T.x - offset_H, T.y + offset_V, T.z, T.x - 1, T.y + offset_V, T.z) //above, from far to close
		else
			. += block(T.x + offset_H, T.y - offset_V, T.z, T.x + offset_H, T.y + offset_V, T.z) //vertical at far end
			offset_H -= 1
			. += block(T.x + 1, T.y - offset_V, T.z, T.x + offset_H, T.y - offset_V, T.z) //below, from close to far
			. += block(T.x + 1, T.y + offset_V, T.z, T.x + offset_H, T.y + offset_V, T.z) //above, from close to far
		return

	///Retrieves all turfs associated with the new room (for addition to associated area).
	proc/get_whole_coverage(var/turf/T, var/offset_to_west, var/roomtype)
		. = list()
		var/offset_H = 4
		if(roomtype == RAND_5_BY_3) offset_H = 6
		var/offset_V = 2 //applies in each direction, so total vertical span is double this plus 1
		if(roomtype == RAND_3_BY_5) offset_V = 3

		if(offset_to_west)
			. = block(T.x - offset_H, T.y - offset_V, T.z, T.x, T.y + offset_V, T.z)
		else
			. = block(T.x, T.y - offset_V, T.z, T.x + offset_H, T.y + offset_V, T.z)
		return

	///Retrieves the turf the event should place a random room spawner onto.
	proc/get_room_spot(var/turf/T, var/offset_to_west, var/roomtype)
		var/horz_bump = 1
		if(offset_to_west)
			if(roomtype == RAND_5_BY_3)
				horz_bump = -5
			else
				horz_bump = -3

		if(roomtype == RAND_3_BY_5)
			. = locate(T.x + horz_bump, T.y - 2, T.z)
		else
			. = locate(T.x + horz_bump, T.y - 1, T.z)
		return

#undef RAND_3_BY_3
#undef RAND_3_BY_5
#undef RAND_5_BY_3
