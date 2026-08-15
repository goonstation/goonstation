/datum/map_correctness_check/area_contents/head_of_security
	check_name = "Head of Security's Office Content Check"
	target_areas = list(
		/area/station/security/hos,
		/area/station/crew_quarters/hos,
	)

	expected_contents = list(
		// Generic head stuff
		CONTENTS_EQ(/obj/storage/secure/closet/command/hos, 1),
		CONTENTS_EQ(/obj/item/stamp/hos, 1),
		CONTENTS_EQ(/obj/machinery/computer/card/department/security, 1),
		CONTENTS_EQ(/mob/living/critter/small_animal/turtle/sylvester/HoS, 1)
		CONTENTS_EQ(/obj/decal/poster/wallsign/framed_award/hos_medal, 1),

		// HOS stuff
		CONTENTS_EQ(/obj/machinery/recharger, 1),
		CONTENTS_EQ(/obj/item/reagent_containers/food/snacks/spaghetti/spicy/security, 1),
		CONTENTS_EQ(/obj/item/kitchen/utensil/fork, 1), // What is a super spicey pasta, without a fork? but a trap went untriggered?
		CONTENTS_EQ(/obj/item/reagent_containers/food/drinks/mug/HoS, 1),
	)
