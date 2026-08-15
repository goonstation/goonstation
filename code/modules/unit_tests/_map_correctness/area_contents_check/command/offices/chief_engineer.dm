/datum/map_correctness_check/area_contents/chief_engineer
	check_name = "Chief Engineer's Office Content Check"
	target_areas = list(
		/area/station/crew_quarters/ce,
		/area/station/engine/engineering/ce,
	)

	expected_contents = list(
		// Generic head stuff
		CONTENTS_EQ(/obj/storage/secure/closet/command/chief_engineer, 1),
		CONTENTS_EQ(/obj/item/stamp/ce, 1),
		CONTENTS_EQ(/obj/machinery/computer/card/department/engineering, 1)
		CONTENTS_EQ(/obj/item/rocko, 1),

		// CE stuff
		CONTENTS_EQ(/obj/storage/crate/rcd/CE, 1),
		CONTENTS_EQ(/obj/item/deconstructor, 1)
	)

/datum/map_correctness_check/area_contents/chief_engineer/teg_maps
	check_name = "Chief Engineer's Office Content Check (TEG)"

	only_check_on = list(
		/datum/map_settings/cogmap,
		/datum/map_settings/cogmap2
		/datum/map_settings/kondaru,
	)

	expected_contents = list(
		CONTENTS_EQ(/obj/item/pinpointer/teg_semi, 1),
	)
