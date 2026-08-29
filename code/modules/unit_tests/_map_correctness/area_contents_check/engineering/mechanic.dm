/datum/map_correctness_check/area_contents/mechanics_lab
	check_name = "Mechanic's Lab Contents Check"
	target_areas = list(/area/station/engine/elect)
	only_check_on = null
	skip_check_on = list(
		// Cogmap mech lab leaks into the SMES room and it looks too nice to change.
		/datum/map_settings/cogmap,
	)

	expected_contents = list(
		// Equipment
		CONTENTS_GT(/obj/storage/secure/closet/engineering/mechanic, 1),
		CONTENTS_GT(/obj/machinery/manufacturer/mechanic, 0),
		CONTENTS_GT(/obj/storage/cart/mechcart/tools, 0),
		CONTENTS_GT(/obj/machinery/vending/mechanics, 0),
		CONTENTS_GT(/obj/machinery/portable_reclaimer, 0),
		CONTENTS_GT(/obj/machinery/rkit, 0),

		// Infrastructure
		CONTENTS_GT(/obj/machinery/power/data_terminal, 1),

		// Tools
		CONTENTS_GT(/obj/item/device/multitool, 0),
		CONTENTS_GT(/obj/item/storage/belt/utility, 0),
		CONTENTS_GT(/obj/item/electronics/soldering, 0),
		CONTENTS_GT(/obj/item/disk/data/cartridge/diagnostics, 2),
	)

/datum/map_correctness_check/area_contents/mechanics_lab/cogmap
	only_check_on = list(
		/datum/map_settings/cogmap,
	)
	skip_check_on = null
	target_areas = list(
		/area/station/engine/elect,
		/area/station/engine/power,
	)
