/datum/random_event/start/wire_feast
	name = "Wire Feast"
	customization_available = 0
	required_elapsed_round_time = 0

	admin_call(var/source)
		if (..())
			return

	event_effect(var/source)
		..()

		var/i
		for(i in 1 to rand(0,450))
			var/area/SA = /area/station/hallway/primary // Just need to grab a powernet
			var/obj/machinery/power/apc/PC = SA.area_apc
			var/datum/powernet/PN = PC.powernet
			for(var/obj/cable/C in PN.cables)
				if(C.loc == !/area/station/maintenance)
					return
				if (istype(C, /obj/cable))
					message_admins(SPAN_INTERNAL("[src.name] event occured at [C] in [SA](Source: [source])."))
					var/floor_chance = rand(0,5)
					if(floor_chance < 5)
						C.cut(null,C.loc)
