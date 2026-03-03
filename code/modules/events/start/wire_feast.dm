/datum/random_event/start/wire_feast
	name = "Wire Feast"
	customization_available = 0
	required_elapsed_round_time = 0

	admin_call(var/source)
		if (..())
			return

	event_effect(var/source)
		..()
		for (var/area/station/maintenance/place in world)
			for (var/obj/cable/to_eat in place)
				var/eat_chance = rand(1,90)
				if(eat_chance == 1)
					to_eat.cut(null,to_eat.loc)
					var/mouse_chance = rand(1, 10)
					if(mouse_chance > 7)
						message_admins("A mouse was supposed to spawn at [get_turf(to_eat)]!")
						var/mob/living/critter/small_animal/mouse/dead = new /mob/living/critter/small_animal/mouse(to_eat.loc)
