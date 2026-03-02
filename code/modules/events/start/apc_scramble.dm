/datum/random_event/start/viscera
	name = "Viscera Cleanup"
	customization_available = 0
	required_elapsed_round_time = 0

	admin_call(var/source)
		if (..())
			return

	event_effect(var/source)
		..()

		var/i
		var/list/area/stationAreas = get_accessible_station_areas()
		var/obj/machinery/power/apc/A
		for(i in 1 to rand(0,15))
			var/area/SA = stationAreas[pick(stationAreas)]
			A = locate(/obj/machinery/power/apc/) in SA?.machines
			if(istype(A))
				var/apc_diceroll = rand(1,4)
				switch(apc_diceroll)
					if (1)
						A.lighting = 0
					if (2)
						A.equipment = 0
					if (3)
						A.environ = 0
					if (4)
						A.environ = 0
						A.equipment = 0
						A.lighting = 0
				logTheThing(LOG_STATION, null, "APC Scramble interfered with [A.name] at [log_loc(apc)].")
				A.update()
				A.UpdateIcon()


