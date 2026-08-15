/datum/map_correctness_check/area_contents/research_director
	check_name = "Research Director's Office Content Check"
	target_areas = list(
		/area/station/science/research_director,
		/area/station/crew_quarters/hor,
	)

	expected_contents = list(
		// Generic head stuff
		CONTENTS_EQ(/obj/storage/secure/closet/command/research_director, 1),
		CONTENTS_EQ(/obj/item/stamp/rd, 1),
		CONTENTS_EQ(/obj/machinery/computer/card/department/research, 1),
		CONTENTS_EQ(/obj/critter/domestic_bee/heisenbee, 1),
		CONTENTS_EQ(/obj/decal/poster/wallsign/framed_award/rddiploma, 1),

		// RD stuff
		CONTENTS_EQ(/obj/item/storage/briefcase/toxins, 1),
		CONTENTS_EQ(/obj/item/remote/porter/port_a_sci, 1),
		CONTENTS_EQ(/obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake, 1),
		CONTENTS_EQ(/obj/machinery/computer3/terminal/zeta, 1),
		CONTENTS_EQ(/obj/machinery/recharger, 1), // For the hand tele

		// Heisenbee wonderful collection of goods
		CONTENTS_EQ(/obj/stool/bee_bed/heisenbee, 1),
		CONTENTS_EQ(/obj/item/reagent_containers/food/snacks/beefood, 2),
	)

/datum/map_correctness_check/area_contents/research_director/toxins
	check_name = "Research Director's Office Content Check (maps with toxins)"

	skip_check_on = list(
		// Nadir does not have a toxins lab
		/datum/map_settings/nadir,
	)
	only_check_on = null

	expected_contents = list(
		CONTENTS_EQ(/obj/item/storage/briefcase/toxins , 1)
	)
