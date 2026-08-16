/datum/map_correctness_check/area_contents/captain
	check_name = "Captain's Office Content Check"
	target_areas = list(
		/area/station/crew_quarters/captain,
		/area/station/bridge/execrestroom,
		/area/station/bridge/captain,
		/area/station/captain,
	)

	expected_contents = list(
		// Generic head stuff
		CONTENTS_EQ(/obj/storage/secure/closet/command/captain, 1),
		CONTENTS_EQ(/obj/item/stamp/cap, 1),

		// CAP stuff (large)
		CONTENTS_EQ(/obj/shrub/captainshrub, 1),
		CONTENTS_EQ(/obj/item/reagent_containers/food/drinks/bottle/thegoodstuff, 1),
		CONTENTS_EQ(/obj/displaycase/captain, 1),
		CONTENTS_EQ(/obj/item/storage/toilet/goldentoilet, 1),
		CONTENTS_EQ(/obj/machinery/recharger, 1),
		CONTENTS_EQ(/obj/item/storage/secure/ssafe, 1),

		// computers
		CONTENTS_EQ(/obj/machinery/computer/announcement/station/captain, 1),
		CONTENTS_EQ(/obj/machinery/computer3/generic/communications, 1),

		// CAP stuff (items)
		CONTENTS_EQ(/obj/item/card/id/gold/captains_spare, 1),
		CONTENTS_EQ(/obj/item/hand_tele, 1),
		CONTENTS_EQ(/obj/item/pinpointer/disk, 1),

		// EVA
		CONTENTS_EQ(/obj/item/clothing/mask/gas/emergency, 1),
		CONTENTS_EQ(/obj/item/tank/jetpack, 1),
		CONTENTS_OR(
			list(
				CONTENTS_EQ(/obj/item/clothing/suit/space/captain, 1),
				CONTENTS_EQ(/obj/item/clothing/head/helmet/space/captain, 1),
			),
			list(
				CONTENTS_EQ(/obj/item/clothing/suit/space/diving/command, 1),
				CONTENTS_EQ(/obj/item/clothing/head/helmet/space/engineer/diving/command, 1),
			),
		)
	)
