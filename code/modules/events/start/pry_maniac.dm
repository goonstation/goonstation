/datum/random_event/start/prying
	name = "Pry Maniac"
	customization_available = 0
	required_elapsed_round_time = 0

	admin_call(var/source)
		if (..())
			return

	event_effect(var/source)
		..()

		var/list/area/stationAreas = get_accessible_station_areas()
		var/area/SA = stationAreas[pick(stationAreas)]
		for(var/turf/T in get_area_turfs(SA, TRUE))
			if (istype(T, /turf/simulated/floor))
				var/turf/simulated/floor/F = T
				var/floor_chance = prob(16.67)
				if(floor_chance)
					if (locate(/obj/item/reagent_containers/food/snacks/ingredient/egg/century) in F.hidden_contents)
						return
					else
						F.pry_tile()
		message_admins(SPAN_INTERNAL("[src.name] event occured at [SA](Source: [source])."))
