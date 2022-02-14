/mob/living/carbon/human/tdummy
	real_name = "Target Dummy"
	var/shutup = FALSE
//	nodamage = 1
	New()
		. = ..()
		src.maptext_y = 32

	say(message, ignore_stamina_winded)
		if(!shutup)
			. = ..()