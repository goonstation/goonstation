/datum/map_correctness_check/area_contents/cloner
	check_name = "Cloner Contents Check"
	target_areas = list(
		/area/station/medical/medbay/cloner,
	)
	expected_contents = list(
		// Equipment
		CONTENTS_EQ(/obj/machinery/computer/cloning, 1),
		CONTENTS_EQ(/obj/machinery/clonegrinder, 1),
		CONTENTS_EQ(/obj/machinery/clone_scanner, 1),
		CONTENTS_EQ(/obj/machinery/clonepod, 1),
		CONTENTS_EQ(/obj/spawner/clone_rack, 1),
		// Supplies
		CONTENTS_GT(/obj/storage/secure/closet/medical/cloning, 0),
		CONTENTS_GT(/obj/item/storage/box/diskbox, 0),
		CONTENTS_GT(/obj/item/hand_labeler, 0),
	)
