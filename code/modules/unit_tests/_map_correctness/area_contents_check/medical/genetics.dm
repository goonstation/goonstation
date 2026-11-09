/datum/map_correctness_check/area_contents/genetics
	check_name = "Genetics Contents Check"
	target_areas = list(
		/area/station/medical/research,
		/area/station/medical/dome,
	)
	expected_contents = list(
		// Genetics Equipment
		CONTENTS_GT(/obj/machinery/genetics_scanner, 1),
		CONTENTS_GT(/obj/machinery/computer/genetics, 1),
		CONTENTS_EQ(/obj/item/cloneModule/genepowermodule, 1),
		CONTENTS_GT(/obj/item/storage/pill_bottle/mutadone, 0),
		// Monkey Equipment
		CONTENTS_EQ(/obj/monkeyplant, 1),
		CONTENTS_EQ(/obj/machinery/vending/monkey/genetics, 1),
		CONTENTS_GT(/obj/storage/secure/closet/animal, 0),
	)
