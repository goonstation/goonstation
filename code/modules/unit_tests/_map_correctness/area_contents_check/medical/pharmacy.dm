/datum/map_correctness_check/area_contents/pharmacy
	check_name = "Pharmacy Contents Check"

	target_areas = list(
		/area/station/medical/medbay/pharmacy,
	)
	expected_contents = list(
		//Equipment
		CONTENTS_GT(/obj/submachine/chem_extractor, 0),
		CONTENTS_GT(/obj/machinery/chem_heater/chemistry, 0),
		CONTENTS_GT(/obj/machinery/chem_dispenser/chemical, 0),
		CONTENTS_GT(/obj/machinery/chem_master, 0),
		CONTENTS_GT(/obj/machinery/glass_recycler, 0),
		//Supplies
		CONTENTS_GT(/obj/storage/secure/closet/research/chemical/pharmacy, 0),
		CONTENTS_GT(/obj/item/storage/box/beakerbox, 0),
		CONTENTS_GT(/obj/item/hand_labeler, 0),
		CONTENTS_GT(/obj/mapping_helper/glassware_spawn, 0),
		CONTENTS_GT(/obj/item/device/reagentscanner, 0),
		CONTENTS_GT(/obj/item/paper/book/from_file/pharmacopia, 0),
		CONTENTS_GT(/obj/item/clothing/glasses/spectro, 0),
		CONTENTS_GT(/obj/item/reagent_containers/dropper, 0),
		CONTENTS_GT(/obj/item/clothing/gloves/latex, 0)
	)
