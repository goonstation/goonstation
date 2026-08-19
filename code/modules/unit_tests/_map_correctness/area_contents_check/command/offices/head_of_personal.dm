/datum/map_correctness_check/area_contents/head_of_personal
	check_name = "Head of Personal's Office Content Check"
	target_areas = list(
		/area/station/crew_quarters/hop,
		/area/station/bridge/customs
	)

	expected_contents = list(
		// Generic head stuff
		CONTENTS_EQ(/obj/storage/secure/closet/command/hop, 1),
		CONTENTS_EQ(/obj/item/stamp/hop, 1),
		CONTENTS_EQ(/obj/decal/poster/wallsign/framed_award/firstbill, 1),
		CONTENTS_OR(
			list(CONTENTS_EQ(/mob/living/critter/small_animal/dog/blair, 1)),
			list(CONTENTS_EQ(/mob/living/critter/small_animal/dog/george/orwell, 1)),
		),

		// HOP stuff
		CONTENTS_EQ(/obj/item/reagent_containers/food/drinks/rum_spaced, 1),
		CONTENTS_EQ(/obj/item/pen/crayon/golden, 1),
	)
