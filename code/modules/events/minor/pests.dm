/datum/random_event/minor/pests
	name = "Pests"

	event_effect()
		..()
		var/pestlandmark = pick_landmark(LANDMARK_PESTSTART)
		if(!pestlandmark)
			logTheThing(LOG_DEBUG, null, "Minor pest event couldn't find a LANDMARK_PESTSTART!")
			return
		var/masterspawnamount = rand(4,12)
		var/spawnamount = masterspawnamount
		var/type
		switch (rand(1,5))
			if (1)
				while (spawnamount > 0)
					type = /mob/living/critter/small_animal/cockroach
					new type(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
			if (2)
				while (spawnamount > 0)
					type = /mob/living/critter/small_animal/mouse
					new type(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
			if (3)
				while (spawnamount > 0)
					type = /obj/critter/wasp
					new type(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
			if (4)
				while (spawnamount > 0)
					type = /mob/living/critter/small_animal/scorpion
					new type(pestlandmark)
					spawnamount -= 3
					LAGCHECK(LAG_LOW)
			if (5)
				while (spawnamount > 0)
					type = /mob/living/critter/small_animal/rattlesnake
					new type(pestlandmark)
					spawnamount -= 4
					LAGCHECK(LAG_LOW)
		logTheThing(LOG_STATION, null, "minor pest event spawned [type] at [log_loc(pestlandmark)]")

#ifdef MOVING_SUB_MAP //Defined in the map-specific .dm configuration file.
/datum/random_event/minor/electricmalfunction
	name = "Electrical Malfunction"

	event_effect()
		..()
		var/obj/machinery/junctionbox/J = pick(by_type[/obj/machinery/junctionbox])
		if (J.broken)
			return
		J.Breakdown()
#endif
