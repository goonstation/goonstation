/datum/map_correctness_check/area_contents/chemistry
	check_name = "Chemistry Contents Check"
	only_check_on = null
	skip_check_on = list(
		// Neon's chemistry lab is situated across from Medbay, so it doesn't need a ChemLink.
		/datum/map_settings/neon,
	)
	target_areas = list(
		/area/station/science/chemistry,
	)
	expected_contents = list(
		// Equipment
		CONTENTS_GT(/obj/machinery/chem_dispenser/chemical, 0),
		CONTENTS_GT(/obj/machinery/chem_heater, 0),
		CONTENTS_GT(/obj/machinery/chem_shaker, 0),
		CONTENTS_GT(/obj/machinery/chemicompiler_stationary, 0),
		CONTENTS_GT(/obj/machinery/chem_master, 0),
		CONTENTS_GT(/obj/submachine/chem_extractor, 0),
		// Utility
		CONTENTS_GT(/obj/machinery/glass_recycler/chemistry, 0),
		CONTENTS_GT(/obj/machinery/drainage, 0),
		CONTENTS_EQ(/obj/machinery/computer/chem_request_receiver, 1),
		CONTENTS_EQ(/obj/machinery/disposal/chemlink, 1),
		// Supplies
		CONTENTS_OR(
			list(CONTENTS_GT(/obj/storage/secure/closet/research/chemical, 0)),
			list(CONTENTS_GT(/obj/cabinet/chemicals, 0)),
		),
		CONTENTS_GT(/obj/table/reinforced/chemistry/auto/basicsup, 0),
		CONTENTS_GT(/obj/table/reinforced/chemistry/auto/auxsup, 0),
	)


/datum/map_correctness_check/area_contents/chemistry/neon
	check_name = "Chemistry Contents Check"
	only_check_on = list(
		/datum/map_settings/neon,
	)
	skip_check_on = null
	target_areas = list(
		/area/station/science/chemistry,
	)
	expected_contents = list(
		// Equipment
		CONTENTS_GT(/obj/machinery/chem_dispenser/chemical, 0),
		CONTENTS_GT(/obj/machinery/chem_heater, 0),
		CONTENTS_GT(/obj/machinery/chem_shaker, 0),
		CONTENTS_GT(/obj/machinery/chemicompiler_stationary, 0),
		CONTENTS_GT(/obj/machinery/chem_master, 0),
		CONTENTS_GT(/obj/submachine/chem_extractor, 0),
		// Utility
		CONTENTS_GT(/obj/machinery/glass_recycler/chemistry, 0),
		CONTENTS_GT(/obj/machinery/drainage, 0),
		// Supplies
		CONTENTS_OR(
			list(CONTENTS_GT(/obj/storage/secure/closet/research/chemical, 0)),
			list(CONTENTS_GT(/obj/cabinet/chemicals, 0)),
		),
		CONTENTS_GT(/obj/table/reinforced/chemistry/auto/basicsup, 0),
		CONTENTS_GT(/obj/table/reinforced/chemistry/auto/auxsup, 0),
	)
