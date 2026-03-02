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
		for(var/turf/T in get_area_turfs(SA.type, TRUE))
			var/floor_chance = rand(0,5)
			message_admins(SPAN_INTERNAL("[src.name] event occured at [SA](Source: [source])."))
			for(var/turf/simulated/floor/F in T)
				if(!floor_chance)
					if (!locate(/obj/item/reagent_containers/food/snacks/ingredient/egg/century) in F.hidden_contents)
						return
					else
						F.pry_tile()
