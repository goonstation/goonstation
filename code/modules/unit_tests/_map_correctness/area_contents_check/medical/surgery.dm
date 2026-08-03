/datum/map_correctness_check/area_contents/surgery
	check_name = "Operating Theatre Contents Check"
	only_check_on = null
	skip_check_on = list(
		// Donut3's operating theatre is rolled into the treatment centre.
		/datum/map_settings/donut3,
	)
	target_areas = list(
		/area/station/medical/medbay/surgery,
	)
	expected_contents = list(
		// Surgical Equipment
		CONTENTS_GT(/obj/machinery/optable, 0),
		CONTENTS_GT(/obj/machinery/computer/operating, 0),
		CONTENTS_GT(/obj/machinery/drainage, 0),
		CONTENTS_GT(/obj/machinery/sink, 0),
		CONTENTS_GT(/obj/item/scalpel, 0),
		CONTENTS_GT(/obj/item/circular_saw, 0),
		CONTENTS_GT(/obj/item/scissors/surgical_scissors, 0),
		CONTENTS_GT(/obj/item/surgical_spoon, 0),
		CONTENTS_GT(/obj/item/hemostat, 0),
		CONTENTS_GT(/obj/item/suture, 0),
		CONTENTS_GT(/obj/item/staple_gun, 0),
		CONTENTS_GT(/obj/machinery/defib_mount, 0),
		// Supplies
		CONTENTS_EQ(/obj/storage/secure/closet/fridge/blood, 1),
		CONTENTS_EQ(/obj/storage/secure/closet/medical/anesthetic, 1),
		// IV
		CONTENTS_EQ(/obj/machinery/dialysis, 1),
		CONTENTS_GT(/obj/iv_stand, 0),
		CONTENTS_GT(/obj/item/reagent_containers/iv_drip, 0),
	)

/datum/map_correctness_check/area_contents/surgery/donut3
	only_check_on = list(
		/datum/map_settings/donut3,
	)
	skip_check_on = null
	target_areas = list(
		/area/station/medical/medbay/treatment,
	)
