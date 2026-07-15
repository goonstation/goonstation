/datum/map_correctness_check/area_contents/mechanics_lab
	check_name = "Mechanic's Lab Contents Check"
	target_areas = list(/area/station/engine/elect)
	only_check_on = null
	skip_check_on = list(
		// Atlas does not have mail chutes at all.
		/datum/map_settings/atlas,
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
		CONTENTS_OR(
			list(CONTENTS_EQ(/obj/machinery/disposal/mail/autoname/mechanics, 1)),
			list(CONTENTS_EQ(/obj/machinery/disposal/mail/small/autoname/mechanics, 1)),
		),

		// Tools
		CONTENTS_GT(/obj/item/device/multitool, 0),
		CONTENTS_GT(/obj/item/storage/belt/utility, 0),
		CONTENTS_GT(/obj/item/electronics/soldering, 0),
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

/datum/map_correctness_check/area_contents/mechanics_lab/atlas
	only_check_on = list(
		/datum/map_settings/atlas,
	)
	skip_check_on = null
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
	)
