/datum/random_event/start/apc_scramble
	name = "APC Scramble"
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
		for(i in 1 to rand(1,15))
			var/area/SA = stationAreas[pick(stationAreas)]
			A = locate(/obj/machinery/power/apc/) in SA?.machines
			if(istype(A))
				var/apc_diceroll = rand(1,4)
				var/modify_type = null
				switch(apc_diceroll)
					if (1)
						A.lighting = 0
						modify_type = "lighting"
					if (2)
						A.equipment = 0
						modify_type = "equipment"
					if (3)
						A.environ = 0
						modify_type = "enviromental"
					if (4)
						A.environ = 0
						A.equipment = 0
						A.lighting = 0
						modify_type = "all"
				logTheThing(LOG_STATION, null, "APC Scramble event interfered with [A.name] at [log_loc(A)] by changing [modify_type] settings.")
				A.update()
				A.UpdateIcon()


