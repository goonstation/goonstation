/mob/living/carbon/human/dummy
	real_name = "Target Dummy"
//	nodamage = 1
	New()
		. = ..()
		src.maptext_y = 32

	verb/heal_dummy() //this cannot possibly go wrong
		set src in oview(1)
		set category = "Local"
		logTheThing("combat", usr, src, "[usr] did a target dummy fullheal on %target% at [log_loc(usr)]") //maybe worth being logged?
		src.full_heal()
