#ifndef UNDERWATER_MAP
/datum/random_event/start/parking
	name = "Parking Incident"
	customization_available = 0
	required_elapsed_round_time = 0
	wont_occur_past_this_time = 1 MINUTE


	event_effect(var/source)
		..()

		var/list/area/all_areas = get_accessible_station_areas()
		var/list/area/real_maint_areas = list()
		for(var/area_name in all_areas)
			if(istype(all_areas[area_name],/area/station/maintenance))
				real_maint_areas += all_areas[area_name]

		if (!length(real_maint_areas))
			message_admins("Parking Incident event couldn't find any maintenance areas!")
			logTheThing(LOG_DEBUG, null, "Failed to find any maintenance areas for a Parking Incident event.")
			return

		var/attempts = 0
		var/list/turf/eligible_parking_spaces = list()
		while(attempts < 3)
			attempts++
			var/area/trouble_zone = pick(real_maint_areas)
			real_maint_areas -= trouble_zone

			for(var/turf/T in get_area_turfs(trouble_zone, TRUE))
				if(!istype(T,/turf/simulated/floor/plating))
					continue

				var/turf_ineligible = FALSE

				for (var/obj/O in T.contents)
					if (O.density || istype(O,/obj/machinery))
						turf_ineligible = TRUE
						break

				if(!turf_ineligible)
					eligible_parking_spaces += T

			if (length(eligible_parking_spaces) > 0) break

		if (!length(eligible_parking_spaces))
			message_admins("Parking Incident event couldn't find any open tiles in visited areas.")
			logTheThing(LOG_DEBUG, null, "Failed to find any open tiles for a Parking Incident event.")
			return

		var/turf/parking_turf = pick(eligible_parking_spaces)
		new /obj/machinery/vehicle/miniputt/unfueled(parking_turf)

		logTheThing(LOG_STATION, null, "Parking Incident event created an unfueled miniputt at [log_loc(parking_turf)].")
#endif
