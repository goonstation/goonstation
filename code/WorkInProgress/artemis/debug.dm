// stuff for debugging Artemis, definitely don't use in real code lol

/world/load_mode()
	. = ..()
	master_mode = "freeroam"

/mob/living/carbon/human/New()
	. = ..()
	SPAWN(4 SECONDS)
		if(src.client)
			src.set_loc(locate(26, 34, 1))
