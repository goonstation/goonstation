/datum/random_event/minor/pests
	name = "Pests"

	event_effect()
		..()
		var/pestlandmark = pick_landmark(LANDMARK_PESTSTART)
		if(!pestlandmark)
			return
		var/masterspawnamount = rand(4,12)
		var/spawnamount = masterspawnamount
		var/type = rand(1,5)
		switch (type)
			if (1)
				while (spawnamount > 0)
					new /mob/living/critter/small_animal/cockroach(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
			if (2)
				while (spawnamount > 0)
					new /mob/living/critter/small_animal/mouse(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
			if (3)
				while (spawnamount > 0)
					new /obj/critter/wasp(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
			if (4)
				while (spawnamount > 0)
					new /obj/critter/spacescorpion(pestlandmark)
					spawnamount -= 3
					LAGCHECK(LAG_LOW)
			if (5)
				while (spawnamount > 0)
					new /obj/critter/spacerattlesnake(pestlandmark)
					spawnamount -= 11
					LAGCHECK(LAG_LOW)
		//pestlandmark.visible_message("A group of [type] emerges from their hidey-hole")

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
