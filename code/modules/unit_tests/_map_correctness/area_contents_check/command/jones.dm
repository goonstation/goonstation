/// Jones require special handling because they can be on the bridge or cap's quaters, but cap's quaters are not always considered bridge.
/datum/map_correctness_check/area_contents/jones
	check_name = "Jones existance Content Check"
	target_areas = list(
		/area/station/crew_quarters/captain,
		/area/station/bridge,
		/area/station/captain,
	)

	expected_contents = list(
		CONTENTS_EQ(/mob/living/critter/small_animal/cat/jones, 1),
	)
