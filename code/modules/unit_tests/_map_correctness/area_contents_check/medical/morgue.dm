/datum/map_correctness_check/area_contents/morgue
	check_name = "Morgue Contents Check"
	target_areas = list(
		/area/station/medical/morgue,
	)
	expected_contents = list(
		// General
		CONTENTS_GT(/obj/machinery/traymachine/morgue, 2),
		CONTENTS_EQ(/mob/living/critter/small_animal/opossum/morty, 1),
		// Surgical Equipment
		CONTENTS_GT(/obj/machinery/optable, 0),
		CONTENTS_GT(/obj/machinery/drainage, 0),
		CONTENTS_GT(/obj/item/scalpel, 0),
		CONTENTS_GT(/obj/item/circular_saw, 0),
		CONTENTS_GT(/obj/item/scissors/surgical_scissors, 0),
		CONTENTS_GT(/obj/item/surgical_spoon, 0),
		CONTENTS_OR(
			list(CONTENTS_GT(/obj/item/suture, 0)),
			list(CONTENTS_GT(/obj/item/staple_gun, 0)),
		),
		// Supplies
		CONTENTS_GT(/obj/item/device/detective_scanner, 0),
		CONTENTS_GT(/obj/item/reagent_containers/glass/bottle/formaldehyde, 0),
		CONTENTS_GT(/obj/item/reagent_containers/syringe, 0),
		CONTENTS_GT(/obj/item/spraybottle/cleaner, 0),
		CONTENTS_GT(/obj/item/hand_labeler, 0),
		CONTENTS_GT(/obj/item/storage/box/biohazard_bags, 0),
		CONTENTS_OR(
			list(CONTENTS_GT(/obj/item/storage/box/body_bag, 0)),
			list(CONTENTS_GT(/obj/item/body_bag, 2)),
		),
		// Morgue-Crematorium Linkage
		CONTENTS_OR(
			list(CONTENTS_EQ(/obj/disposaloutlet, 1)),
			list(CONTENTS_EQ(/obj/machinery/disposal/morgue, 1)),
		),
	)
