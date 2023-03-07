/datum/antagonist/intangible/wraith
	id = ROLE_WRAITH
	display_name = "wraith"
	intangible_mob_path = /mob/living/intangible/wraith

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
