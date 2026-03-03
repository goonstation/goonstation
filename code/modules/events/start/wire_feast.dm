/datum/random_event/start/wire_feast
	name = "Wire Feast"
	customization_available = 0
	required_elapsed_round_time = 0

	admin_call(var/source)
		if (..())
			return

	event_effect(var/source)
		..()
		for (var/area/station/maintenance/MA in world)
			for (var/obj/cable/C in MA)
				var/eat_chance = rand(1,90)
				if(eat_chance == 1)
					var/mouse_chance = rand(1, 10)
					if(mouse_chance >= 7 && mouse_chance < 10)
						new /mob/living/critter/small_animal/mouse/dead(C.loc)
					else if (mouse_chance == 10)
						var/mob/living/critter/wraith/plaguerat/young/PR = new /mob/living/critter/wraith/plaguerat/young(C.loc)
						PR.death()
					C.cut(null,C.loc)
