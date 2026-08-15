/datum/map_correctness_check/area_contents/head_of_security
	check_name = "Head of Security's Office Content Check"
	target_areas = list(/area/station/security/hos)

	expected_contents = list(
		// Generic head stuff
		CONTENTS_EQ(/obj/storage/secure/closet/command/head_of_security, 1),
		CONTENTS_EQ(/obj/item/stamp/hos, 1),
		CONTENTS_EQ(/obj/machinery/computer/card/department/security, 1),
		CONTENTS_EQ(/obj/decal/poster/wallsign/framed_award/hos_medal, 1),

		// hos stuff
		CONTENTS_EQ(/obj/machinery/recharger, 1),
		CONTENTS_EQ(/obj/item/reagent_containers/food/snacks/spaghetti/spicy/security, 1),
		CONTENTS_EQ(/obj/item/kitchen/utensil/fork, 1), // What is a pasta, without a fork?
		CONTENTS_EQ(/obj/item/reagent_containers/food/drinks/mug/HoS, 1)
	)
