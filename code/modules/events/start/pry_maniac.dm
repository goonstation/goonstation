/datum/random_event/start/prying
	name = "Pry Maniac"
	customization_available = 0
	required_elapsed_round_time = 0

	admin_call(var/source)
		if (..())
			return

	event_effect(var/source)
		..()

		var/list/turfs
		var/area/A

		A = pick(var/area in childrentypesof(area/station))
		turfs = get_area_turfs(A)
			var/floor_chance = rand(0,5)
			for(var/turf/simulated/floor/F in turfs)
				if(!/obj/item/reagent_containers/food/snacks/ingredient/egg/century) in floor.hidden_contents
					F.pry_tile()
