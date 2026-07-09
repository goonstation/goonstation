/datum/map_correctness_check/area_contents/genetics
	check_name = "Medbay Contents Check"
	target_areas = list(
		/area/station/medical,
	)
	expected_contents = list(
		// Equipment
		CONTENTS_GT(/obj/health_scanner/floor, 0),
		CONTENTS_GT(/obj/machinery/sleeper/compact, 0),
		CONTENTS_GT(/obj/machinery/computer3/generic/med_data, 0),
		// Cryo Cells
		CONTENTS_EQ(/obj/machinery/atmospherics/unary/cryo_cell, 2),
		CONTENTS_EQ(/obj/machinery/portable_atmospherics/canister/oxygen, 1),
		CONTENTS_EQ(/obj/machinery/atmospherics/unary/cold_sink/freezer/cryo, 1),
		CONTENTS_EQ(/obj/item/reagent_containers/glass/beaker/cryoxadone, 3),
		CONTENTS_EQ(/obj/item/paper/cryo, 1),
		CONTENTS_GT(/obj/item/wrench, 0),
		// Port-A-Devices & Remotes
		CONTENTS_EQ(/obj/machinery/sleeper/port_a_medbay, 1),
		CONTENTS_EQ(/obj/machinery/vending/port_a_nanomed, 1),
		CONTENTS_EQ(/obj/item/remote/porter/port_a_medbay, 1),
		CONTENTS_EQ(/obj/item/remote/porter/port_a_nanomed, 1),
		// Supplies
		CONTENTS_GT(/obj/machinery/manufacturer/medical, 1),
		CONTENTS_EQ(/obj/storage/secure/closet/medical/chemical, 1),
		CONTENTS_GT(/obj/storage/secure/closet/medical/medicine, 0),
		CONTENTS_GT(/obj/storage/secure/closet/medical/medkit, 0),
		CONTENTS_GT(/obj/machinery/vending/medical, 0),
		CONTENTS_EQ(/obj/machinery/vending/player/chemicals, 1),
		CONTENTS_EQ(/obj/machinery/computer/chem_requester/medical, 1),
		CONTENTS_GT(/obj/item/reagent_containers/hypospray, 1),
		CONTENTS_GT(/obj/item/storage/box/health_upgrade_kit, 0),
		CONTENTS_GT(/obj/storage/cart/medcart/crash, 0),
		CONTENTS_GT(/obj/stool/chair/comfy/wheelchair, 1),
		// Reserve Tanks
		CONTENTS_GT(/obj/item/reagent_containers/glass/beaker/large/antitox, 0),
		CONTENTS_GT(/obj/item/reagent_containers/glass/beaker/large/brute, 0),
		CONTENTS_GT(/obj/item/reagent_containers/glass/beaker/large/burn, 0),
		CONTENTS_GT(/obj/item/reagent_containers/glass/beaker/large/epinephrine, 0),
		// Clothing
		CONTENTS_GT(/obj/machinery/vending/jobclothing/medical, 0),
		CONTENTS_GT(/obj/item/clothing/suit/hazard/paramedic, 1),
		CONTENTS_GT(/obj/item/storage/belt/medical, 1),
	)
