/datum/antagonist/wraith
	id = ROLE_WRAITH
	display_name = "wraith"

	give_equipment()
		var/mob/current_mob = src.owner.current
		var/mob/living/intangible/wraith/wraith = new /mob/living/intangible/wraith(current_mob)

		wraith.set_loc(get_turf(current_mob))

		src.owner.transfer_to(wraith)
		qdel(current_mob)

	remove_equipment()
		var/mob/current_mob = src.owner.current
		src.owner.current.ghostize()
		qdel(current_mob)

	relocate()
		var/turf/T = get_turf(src.owner.current)
		if (!(T && isturf(T)) || (T.z != 1))
			var/spawn_loc = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (spawn_loc)
				src.owner.current.set_loc(spawn_loc)
			else
				src.owner.current.z = 1
		else
			src.owner.current.set_loc(T)

	assign_objectives()
		switch (rand(1, 3))
			if (1)
				for(var/i in 1 to 3)
					new /datum/objective/specialist/wraith/murder(null, src.owner, src)
			if (2)
				new /datum/objective/specialist/wraith/absorb(null, src.owner, src)
				new /datum/objective/specialist/wraith/prevent(null, src.owner, src)
			if (3)
				new /datum/objective/specialist/wraith/absorb(null, src.owner, src)
				new /datum/objective/specialist/wraith/murder/absorb(null, src.owner, src)
		switch (rand(1, 3))
			if(1)
				new /datum/objective/specialist/wraith/travel(null, src.owner, src)
			if(2)
				new /datum/objective/specialist/wraith/survive(null, src.owner, src)
			if(3)
				new /datum/objective/specialist/wraith/flawless(null, src.owner, src)

	announce()
		. = ..()
		boutput(owner.current, "<span class='alert'><b>Your astral powers enable you to survive one banishment. Beware of salt.</b></span>")
		boutput(owner.current, "<span class='alert'><b>Use the question mark button in the lower right corner to get help on your abilities.</b></span>")
