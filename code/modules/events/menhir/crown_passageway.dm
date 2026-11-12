//sometimes, the door just unlocks itself
/datum/random_event/menhir/road
	name = "For Parted Are The Gates"
	description = "Opens doors at the east, west and south sides of the Crown, allowing free passage through its main hallways."
	message_delay = 30 SECONDS
	weight = 10
	announcement_style = EVENT::MENHIR::NOTIFY::GLOBAL

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_PASSAGE] || length(landmarks[LANDMARK_MENHIR_PASSAGE]) < 1)
				. = FALSE //the road is already open

	event_effect()
		if (!landmarks[LANDMARK_MENHIR_PASSAGE] || length(landmarks[LANDMARK_MENHIR_PASSAGE]) < 1) return //manual call safeguard
		for (var/turf/T in landmarks[LANDMARK_MENHIR_PASSAGE])
			if (istype(T,/turf/unsimulated/wall))
				var/save_dir = T.icon_state
				var/obj/newdoor = new /obj/machinery/door/unpowered/blue(T)
				if (save_dir == "interior-3") //vertical wall detection
					newdoor.dir = 4
			else
				showswirl(T)
				Artifact_Spawn(T,"precursor")

		playsound_global(Z_LEVEL_STATION, 'sound/musical_instruments/artifact/Artifact_Precursor_5.ogg', 45, 0, 0.45)
		landmarks[LANDMARK_MENHIR_PASSAGE] = null

		message_delay = rand(5 SECONDS, 8 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_curious.ogg', EVENT::MENHIR::ALERT_VOLUME)

		logTheThing(LOG_STATION, null, "Menhir event [src.name] triggered.")
		message_admins("Menhir event [src.name] triggered.")
