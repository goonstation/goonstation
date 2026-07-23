/datum/map_correctness_check/area_contents/medical
	check_name = "Medbay Contents Check"
	only_check_on = null
	skip_check_on = list(
		// Neon's medbay is substantially more compact that other medbays and does not have a break room.
		/datum/map_settings/neon,
	)
	target_areas = list(
		/area/station/medical,
	)
	expected_contents = list(
		// Equipment
		CONTENTS_GT(/obj/health_scanner/floor, 0),
		CONTENTS_GT(/obj/machinery/sleeper/compact, 0),
		CONTENTS_GT(/obj/machinery/computer3/generic/med_data, 0),
		CONTENTS_GT(/obj/machinery/recharger/defibrillator, 1),
		CONTENTS_GT(/obj/machinery/phone, 0),
		// Cryo Cells
		CONTENTS_EQ(/obj/machinery/atmospherics/unary/cryo_cell, 2),
		CONTENTS_EQ(/obj/machinery/portable_atmospherics/canister/oxygen, 1),
		CONTENTS_EQ(/obj/machinery/atmospherics/unary/cold_sink/freezer/cryo, 1),
		CONTENTS_GT(/obj/item/reagent_containers/glass/beaker/cryoxadone, 2),
		CONTENTS_EQ(/obj/item/paper/cryo, 1),
		CONTENTS_GT(/obj/item/wrench, 0),
		// Port-A-Devices & Remotes
		CONTENTS_EQ(/obj/machinery/sleeper/port_a_medbay, 1),
		CONTENTS_GT(/obj/machinery/vending/port_a_nanomed, 0),
		CONTENTS_EQ(/obj/item/remote/porter/port_a_medbay, 1),
		CONTENTS_GT(/obj/item/remote/porter/port_a_nanomed, 0),
		// Supplies
		CONTENTS_GT(/obj/machinery/manufacturer/medical, 0),
		CONTENTS_EQ(/obj/storage/secure/closet/medical/chemical, 1),
		CONTENTS_GT(/obj/storage/secure/closet/medical/medicine, 0),
		CONTENTS_GT(/obj/storage/secure/closet/medical/medkit, 0),
		CONTENTS_GT(/obj/machinery/vending/medical, 0),
		CONTENTS_EQ(/obj/machinery/vending/player/chemicals, 1),
		CONTENTS_EQ(/obj/machinery/computer/chem_requester/medical, 1),
		CONTENTS_GT(/obj/item/reagent_containers/hypospray, 1),
		CONTENTS_GT(/obj/item/storage/box/health_upgrade_kit, 0),
		CONTENTS_GT(/obj/storage/cart/medcart/crash, 0),
		CONTENTS_GT(/obj/item_dispenser/latex_gloves, 0),
		CONTENTS_GT(/obj/item_dispenser/medical_mask, 0),
		CONTENTS_GT(/obj/item/storage/box/stma_kit, 0),
		CONTENTS_GT(/obj/item/storage/box/lglo_kit, 0),
		CONTENTS_GT(/obj/item/storage/box/gl_kit, 0),
		// Reserve Tanks
		CONTENTS_GT(/obj/item/reagent_containers/glass/beaker/large/antitox, 0),
		CONTENTS_GT(/obj/item/reagent_containers/glass/beaker/large/brute, 0),
		CONTENTS_GT(/obj/item/reagent_containers/glass/beaker/large/burn, 0),
		CONTENTS_GT(/obj/item/reagent_containers/glass/beaker/large/epinephrine, 0),
		// Clothing
		CONTENTS_GT(/obj/machinery/vending/jobclothing/medical, 0),
		CONTENTS_GT(/obj/item/clothing/suit/hazard/paramedic, 1),
		CONTENTS_GT(/obj/item/storage/belt/medical, 1),
		// Break Room
		CONTENTS_GT(/obj/machinery/coffeemaker/medbay, 0),
		CONTENTS_GT(/obj/drink_rack/mug, 0),
		CONTENTS_GT(/obj/item/reagent_containers/food/drinks/creamer, 0),
		CONTENTS_GT(/obj/item/kitchen/food_box/sugar_box, 0),
	)

/datum/map_correctness_check/area_contents/medical/neon
	only_check_on = list(
		/datum/map_settings/neon,
	)
	skip_check_on = null
	expected_contents = list(
		// Equipment
		CONTENTS_GT(/obj/machinery/sleeper/compact, 0),
		CONTENTS_GT(/obj/machinery/computer3/generic/med_data, 0),
		CONTENTS_GT(/obj/machinery/recharger/defibrillator, 1),
		CONTENTS_GT(/obj/machinery/phone, 0),
		// Cryo Cells
		CONTENTS_EQ(/obj/machinery/atmospherics/unary/cryo_cell, 2),
		CONTENTS_EQ(/obj/machinery/portable_atmospherics/canister/oxygen, 1),
		CONTENTS_EQ(/obj/machinery/atmospherics/unary/cold_sink/freezer/cryo, 1),
		CONTENTS_GT(/obj/item/reagent_containers/glass/beaker/cryoxadone, 2),
		CONTENTS_EQ(/obj/item/paper/cryo, 1),
		CONTENTS_GT(/obj/item/wrench, 0),
		// Port-A-Devices & Remotes
		CONTENTS_EQ(/obj/machinery/sleeper/port_a_medbay, 1),
		CONTENTS_GT(/obj/machinery/vending/port_a_nanomed, 0),
		CONTENTS_EQ(/obj/item/remote/porter/port_a_medbay, 1),
		CONTENTS_GT(/obj/item/remote/porter/port_a_nanomed, 0),
		// Supplies
		CONTENTS_GT(/obj/machinery/manufacturer/medical, 0),
		CONTENTS_EQ(/obj/storage/secure/closet/medical/chemical, 1),
		CONTENTS_GT(/obj/storage/secure/closet/medical/medicine, 0),
		CONTENTS_GT(/obj/storage/secure/closet/medical/medkit, 0),
		CONTENTS_GT(/obj/machinery/vending/medical, 0),
		CONTENTS_GT(/obj/item/reagent_containers/hypospray, 1),
		CONTENTS_GT(/obj/storage/cart/medcart/crash, 0),
		CONTENTS_GT(/obj/item_dispenser/latex_gloves, 0),
		CONTENTS_GT(/obj/item_dispenser/medical_mask, 0),
		CONTENTS_GT(/obj/item/storage/box/gl_kit, 0),
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
