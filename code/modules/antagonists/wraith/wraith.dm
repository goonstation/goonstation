/datum/antagonist/mob/intangible/wraith
	id = ROLE_WRAITH
	display_name = "wraith"
	antagonist_icon = "wraith"
	faction = list(FACTION_WRAITH)
	mob_path = /mob/living/intangible/wraith
	uses_pref_name = FALSE
	has_info_popup = FALSE

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
		boutput(owner.current, SPAN_ALERT("<b>Your astral powers enable you to survive one banishment. Beware of salt.</b>"))
		boutput(owner.current, SPAN_ALERT("<b>Use the question mark button in the lower right corner to get help on your abilities.</b>"))
