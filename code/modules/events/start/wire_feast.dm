/datum/random_event/start/wire_feast
	name = "Wire Feast"
	customization_available = 0
	required_elapsed_round_time = 0

	admin_call(var/source)
		if (..())
			return

	event_effect(var/source)
		..()

		for (var/area/station/maintenance/place in global.get_accessible_station_areas())
			message_admins(SPAN_INTERNAL("[src.name] event occured at [place](Source: [source])."))
			for (var/obj/cable/to_eat in place)
				message_admins(SPAN_INTERNAL("[src.name] event occured at [to_eat](Source: [source])."))
				var/eat_chance = rand(1,90)
				if(eat_chance == 1)
					to_eat.cut(null,to_eat.loc)
					var/mob/living/critter/small_animal/mouse/M = new /mob/living/critter/small_animal/mouse(to_eat.loc)
					M.health = 0
					M.death()
