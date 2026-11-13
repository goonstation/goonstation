//please pardon the inconvenience, shedding some extra gravitons
/datum/random_event/menhir/gravity
	name = "A Shift in the Sands"
	description = "The Crown sheds excess gravitons, causing variable gravitational disruption stationwide and creating minor local anomalies."
	message_delay = 1 MINUTE
	announcement_style = EVENT::MENHIR::NOTIFY::GLOBAL

	event_effect()
		var/list/candidate_landmarks = list()
		for (var/turf/T in landmarks[LANDMARK_HALLOWEEN_SPAWN])
			candidate_landmarks += T
		for (var/turf/T in landmarks[LANDMARK_MENHIR_OUTREACH])
			if(istype(get_area(T),/area/station/maintenance) && prob(50)) continue
			candidate_landmarks += T

		var/anomaly_count = rand(10,14)
		if(length(candidate_landmarks) < anomaly_count)
			logTheThing(LOG_DEBUG, null, "Menhir event [src.name] couldn't find enough anomaly sites! This shouldn't happen.")
			message_admins("Menhir event [src.name] couldn't find enough anomaly sites! This shouldn't happen. Aborting event")
			return

		playsound_global(Z_LEVEL_STATION, 'sound/musical_instruments/artifact/Artifact_Precursor_3.ogg', 65, 0, pitch = 0.3)
		SPAWN(2) //approximately syncs sound
			for (var/mob/M in mobs)
				SPAWN(0)
					if (M.z == Z_LEVEL_STATION && !inafterlife(M) && !isVRghost(M))
						shake_camera(M, 6, 6)

		logTheThing(LOG_STATION, null, "Menhir event [src.name] triggered for [anomaly_count] locations. Baseline gravity amplified.")
		message_admins("Menhir event [src.name] triggered for [anomaly_count] locations. Baseline gravity amplified.")

		var/list/station_areas = get_accessible_station_areas()

		SPAWN(0.5 SECONDS)
			for (var/area_name in station_areas)
				LAGCHECK(LAG_LOW)
				var/area/A = station_areas[area_name]
				A.set_gforce_minimum(rand(150,250))

		SPAWN(1 SECOND)
			var/turf/rolling_target
			for(var/i = 1 to anomaly_count)
				rolling_target = pick(candidate_landmarks)
				candidate_landmarks.Remove(rolling_target)
				new /obj/anomaly/gravitational/minor(rolling_target, rand(10 SECONDS, 20 SECONDS))
				sleep(rand(4 SECONDS - anomaly_count, 4 SECONDS))

			for (var/area_name in station_areas)
				LAGCHECK(LAG_LOW)
				var/area/A = station_areas[area_name]
				A.set_gforce_minimum(GFORCE_GRAVITY_MINIMUM)
			logTheThing(LOG_STATION, null, "[src.name] has finished spawning anomalies. Baseline gravity reset.")
			message_admins("[src.name] has finished spawning anomalies. Baseline gravity reset.")

		message_delay = rand(12 SECONDS, 18 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_curious.ogg', EVENT::MENHIR::ALERT_VOLUME)
