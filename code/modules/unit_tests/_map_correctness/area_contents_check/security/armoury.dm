/datum/map_correctness_check/area_contents/armoury
	check_name = "Armoury Contents Check"
	only_check_on = null
	skip_check_on = list(
		/datum/map_settings/donut3,
	)
	target_areas = list(
		/area/station/ai_monitored/armory,
	)
	expected_contents = list(
		// Crates
		CONTENTS_GT(/obj/storage/secure/crate/gear/armory/equipment, 0),
		CONTENTS_GT(/obj/storage/secure/crate/gear/armory/grenades, 0),
		CONTENTS_GT(/obj/storage/secure/crate/weapon/armory/shotgun, 0),
		CONTENTS_GT(/obj/storage/secure/crate/weapon/armory/pod_weapons, 0),
		CONTENTS_GT(/obj/storage/secure/crate/weapon/armory/tranquilizer, 0),
		CONTENTS_GT(/obj/storage/secure/crate/plasma/armory/anti_biological, 0),
		// Racks
		CONTENTS_GT(/obj/random_item_spawner/armory_goggle_supplies, 0),
		CONTENTS_GT(/obj/random_item_spawner/armory_armor_supplies, 0),
		CONTENTS_GT(/obj/random_item_spawner/armory_breaching_supplies, 0),
		CONTENTS_GT(/obj/random_item_spawner/armory_phasers, 0),
		CONTENTS_GT(/obj/machinery/weapon_stand/rifle_rack/recharger, 0),
		// Utility
		CONTENTS_GT(/obj/machinery/recharger, 0),
		CONTENTS_GT(/obj/machinery/portable_atmospherics/canister/sleeping_agent, 0),
		CONTENTS_GT(/obj/machinery/vending/security_ammo, 0),
		CONTENTS_GT(/obj/machinery/computer3/generic/communications, 0),
	)


/datum/map_correctness_check/area_contents/armoury/donut3
	only_check_on = list(
		/datum/map_settings/donut3,
	)
	skip_check_on = null
	expected_contents = list(
		// Crates
		CONTENTS_GT(/obj/storage/secure/crate/gear/armory/equipment, 0),
		CONTENTS_GT(/obj/storage/secure/crate/gear/armory/grenades, 0),
		CONTENTS_GT(/obj/storage/secure/crate/weapon/armory/shotgun, 0),
		CONTENTS_GT(/obj/storage/secure/crate/weapon/armory/pod_weapons, 0),
		CONTENTS_GT(/obj/storage/secure/crate/plasma/armory/anti_biological, 0),
		// Tranquilisers
		CONTENTS_GT(/obj/item/gun/kinetic/dart_rifle, 1),
		CONTENTS_GT(/obj/item/ammo/bullets/tranq_darts, 1),
		CONTENTS_GT(/obj/item/ammo/bullets/tranq_darts/anti_mutant, 0),
		// Racks
		CONTENTS_GT(/obj/random_item_spawner/armory_goggle_supplies, 0),
		CONTENTS_GT(/obj/random_item_spawner/armory_armor_supplies, 0),
		CONTENTS_GT(/obj/random_item_spawner/armory_breaching_supplies, 0),
		CONTENTS_GT(/obj/random_item_spawner/armory_phasers, 0),
		CONTENTS_GT(/obj/machinery/weapon_stand/rifle_rack/recharger, 0),
		// Utility
		CONTENTS_GT(/obj/machinery/recharger, 0),
		CONTENTS_GT(/obj/machinery/portable_atmospherics/canister/sleeping_agent, 0),
		CONTENTS_GT(/obj/machinery/vending/security_ammo, 0),
		CONTENTS_GT(/obj/machinery/computer3/generic/communications, 0),
	)
