/datum/map_correctness_check/area_contents/engineering_storage
	check_name = "Engineering Storage Check"
	target_areas = list(/area/station/engine/storage)
	only_check_on = null
	skip_check_on = list(
		// Both Abzu maps split the storage between itself and a distinct "engineering eva" storage
		/datum/map_settings/neon,
		/datum/map_settings/oshan,
	)

	expected_contents = list(
		// Tools
		CONTENTS_GT(/obj/item/storage/toolbox/electrical, 1),
		CONTENTS_GT(/obj/item/storage/toolbox/mechanical, 1),
		CONTENTS_GT(/obj/item/device/t_scanner, 1),
		CONTENTS_GT(/obj/item/device/multitool, 1),
		CONTENTS_GT(/obj/item/chem_grenade/metalfoam, 2),

		// Equipment - General
		CONTENTS_GT(/obj/item/clothing/gloves/yellow, 1),
		CONTENTS_GT(/obj/item/storage/belt/utility, 1),
		CONTENTS_GT(/obj/item/clothing/ears/earmuffs, 2),

		// Fire fighter
		CONTENTS_GT(/obj/item/clothing/suit/hazard/fire, 1),
		CONTENTS_GT(/obj/item/clothing/head/helmet/firefighter, 1),
		CONTENTS_GT(/obj/item/clothing/mask/gas/emergency, 1),
		CONTENTS_GT(/obj/item/tank/air, 1),
		CONTENTS_GT(/obj/item/extinguisher, 2),
		CONTENTS_GT(/obj/item/chem_grenade/firefighting, 2),

		// Material
		CONTENTS_GT(/obj/item/sheet/steel/fullstack, 0),
		CONTENTS_GT(/obj/item/sheet/steel/reinforced/fullstack, 0),
		CONTENTS_GT(/obj/item/sheet/glass/fullstack, 0),
		CONTENTS_GT(/obj/item/sheet/glass/reinforced/fullstack, 0),
		CONTENTS_GT(/obj/item/rods/steel/fullstack, 0),
		CONTENTS_GT(/obj/item/storage/box/cablesbox, 0),
		CONTENTS_GT(/obj/item/reagent_containers/food/drinks/fueltank, 2),

		// Draggables
		CONTENTS_GT(/obj/storage/cart/mechcart/breach, 0),
		CONTENTS_EQ(/obj/reagent_dispensers/foamtank, 1),
		CONTENTS_EQ(/obj/reagent_dispensers/fueltank, 1),

		// space / ocean eva
		CONTENTS_OR(
			list(
				CONTENTS_GT(/obj/item/old_grenade/oxygen, 2),
				CONTENTS_GT(/obj/item/clothing/suit/space/engineer, 1),
				CONTENTS_GT(/obj/item/clothing/head/helmet/space/engineer, 1),
				CONTENTS_GT(/obj/item/clothing/shoes/magnetic, 1),
			),
			list(
				CONTENTS_GT(/obj/item/clothing/head/helmet/space/engineer/diving/engineering, 1),
				CONTENTS_GT(/obj/item/clothing/suit/space/diving/engineering, 1),
				CONTENTS_GT(/obj/item/clothing/shoes/flippers, 1),
			)
		),
		CONTENTS_GT(/obj/item/clothing/mask/breath, 1),

	)

/datum/map_correctness_check/area_contents/engineering_storage/abzu
	target_areas = list(
		/area/station/engine/storage,
		/area/station/engine/eva
	)
	only_check_on = list(
		/datum/map_settings/neon,
		/datum/map_settings/oshan,
	)
	skip_check_on = null
