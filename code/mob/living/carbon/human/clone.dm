/mob/living/carbon/human/clone
	real_name = "cloned human"

	cust_one_state = "None"
	cust_two_state = "None"
	cust_three_state = "none"

	New()
		. = ..()

		// Randomize gender and blood type
		// For whatever reason this appeared to be randomizing other appearance details,
		// so... no more of that
		// SPAWN_DBG(0)
		// 	randomize_look(src, 1, 1, 0, 0, 0, 0)
