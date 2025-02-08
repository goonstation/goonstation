
// Fabricator Defines

/obj/machinery/manufacturer/general
	name = "general manufacturer"
	supplemental_desc = "This one produces tools and other hardware, as well as general-purpose items like replacement lights."
	free_resources = list(/obj/item/material_piece/steel = 5,
		/obj/item/material_piece/copper = 5,
		/obj/item/material_piece/glass = 5)
	available = list(/datum/manufacture/screwdriver,
		/datum/manufacture/wirecutters,
		/datum/manufacture/wrench,
		/datum/manufacture/crowbar,
		/datum/manufacture/extinguisher,
		/datum/manufacture/welder,
		/datum/manufacture/flashlight,
		/datum/manufacture/weldingmask,
		/datum/manufacture/metal,
		/datum/manufacture/metal/bulk,
		/datum/manufacture/metalR,
		/datum/manufacture/metalR/bulk,
		/datum/manufacture/rods2,
		/datum/manufacture/glass,
		/datum/manufacture/glass/bulk,
		/datum/manufacture/glassR,
		/datum/manufacture/glassR/bulk,
		/datum/manufacture/atmos_can,
		/datum/manufacture/gastank,
		/datum/manufacture/miniplasmatank,
		/datum/manufacture/minioxygentank,
		/datum/manufacture/player_module,
		/datum/manufacture/cable,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/powercellH,
		/datum/manufacture/light_bulb,
		/datum/manufacture/red_bulb,
		/datum/manufacture/yellow_bulb,
		/datum/manufacture/green_bulb,
		/datum/manufacture/cyan_bulb,
		/datum/manufacture/blue_bulb,
		/datum/manufacture/purple_bulb,
		/datum/manufacture/blacklight_bulb,
		/datum/manufacture/light_tube,
		/datum/manufacture/red_tube,
		/datum/manufacture/yellow_tube,
		/datum/manufacture/green_tube,
		/datum/manufacture/cyan_tube,
		/datum/manufacture/blue_tube,
		/datum/manufacture/purple_tube,
		/datum/manufacture/blacklight_tube,
		/datum/manufacture/table_folding,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/shoes,
#ifdef UNDERWATER_MAP
		/datum/manufacture/flippers,
#endif
		/datum/manufacture/breathmask,
#ifdef MAP_OVERRIDE_NADIR
		/datum/manufacture/nanoloom,
		/datum/manufacture/nanoloom_cart,
#endif
		/datum/manufacture/fluidcanister,
		/datum/manufacture/meteorshieldgen,
		/datum/manufacture/shieldgen,
		/datum/manufacture/doorshieldgen,
		/datum/manufacture/patch,
		/datum/manufacture/saxophone,
		/datum/manufacture/trumpet)
	hidden = list(/datum/manufacture/RCDammo,
		/datum/manufacture/RCDammomedium,
		/datum/manufacture/RCDammolarge,
		/datum/manufacture/bottle,
		/datum/manufacture/vuvuzela,
		/datum/manufacture/harmonica,
		/datum/manufacture/bikehorn,
		/datum/manufacture/bullet_22,
		/datum/manufacture/bullet_smoke,
		/datum/manufacture/stapler,
		/datum/manufacture/bagpipe,
		/datum/manufacture/fiddle,
		/datum/manufacture/whistle)

/obj/machinery/manufacturer/general/grody
	name = "grody manufacturer"
	desc = "It's covered in more gunk than a truck stop ashtray. Is this thing even safe?"
	supplemental_desc = "This one has seen better days. There are bits and pieces of the internal mechanisms poking out the side."
	free_resources = list()
	malfunction = TRUE
	wires = 15 & ~(1 << 3) // This cuts the malfunction wire, so the fab malfunctions immediately

/obj/machinery/manufacturer/robotics
	name = "robotics fabricator"
	supplemental_desc = "This one produces robot parts, cybernetic organs, and other robotics-related equipment."
	icon_state = "fab-robotics"
	icon_base = "robotics"
	free_resources = list(/obj/item/material_piece/steel = 5,
		/obj/item/material_piece/copper = 5,
		/obj/item/material_piece/glass = 5)
	available = list(/datum/manufacture/robo_frame,
		/datum/manufacture/full_cyborg_standard,
		/datum/manufacture/full_cyborg_light,
		/datum/manufacture/robo_head,
		/datum/manufacture/robo_chest,
		/datum/manufacture/robo_arm_r,
		/datum/manufacture/robo_arm_l,
		/datum/manufacture/robo_leg_r,
		/datum/manufacture/robo_leg_l,
		/datum/manufacture/robo_head_light,
		/datum/manufacture/robo_chest_light,
		/datum/manufacture/robo_arm_r_light,
		/datum/manufacture/robo_arm_l_light,
		/datum/manufacture/robo_leg_r_light,
		/datum/manufacture/robo_leg_l_light,
		/datum/manufacture/robo_leg_treads,
		/datum/manufacture/robo_head_screen,
		/datum/manufacture/robo_module,
		/datum/manufacture/cyberheart,
		/datum/manufacture/cybereye,
		/datum/manufacture/cybereye_meson,
		/datum/manufacture/cybereye_spectro,
		/datum/manufacture/cybereye_prodoc,
		/datum/manufacture/cybereye_camera,
		/datum/manufacture/cybereye_monitor,
		/datum/manufacture/shell_frame,
		/datum/manufacture/ai_interface,
		/datum/manufacture/latejoin_brain,
		/datum/manufacture/shell_cell,
		/datum/manufacture/cable,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/powercellH,
		/datum/manufacture/crowbar,
		/datum/manufacture/wrench,
		/datum/manufacture/screwdriver,
		/datum/manufacture/scalpel,
		/datum/manufacture/circular_saw,
		/datum/manufacture/surgical_scissors,
		/datum/manufacture/hemostat,
		/datum/manufacture/suture,
		/datum/manufacture/stapler,
		/datum/manufacture/surgical_spoon,
		/datum/manufacture/implanter,
		/datum/manufacture/secbot,
		/datum/manufacture/medbot,
		/datum/manufacture/firebot,
		/datum/manufacture/floorbot,
		/datum/manufacture/cleanbot,
		/datum/manufacture/digbot,
		/datum/manufacture/visor,
		/datum/manufacture/deafhs,
		/datum/manufacture/robup_jetpack,
		/datum/manufacture/robup_healthgoggles,
		/datum/manufacture/robup_sechudgoggles,
		/datum/manufacture/robup_spectro,
		/datum/manufacture/robup_recharge,
		/datum/manufacture/robup_repairpack,
		/datum/manufacture/robup_speed,
		/datum/manufacture/robup_mag,
		/datum/manufacture/robup_meson,
		/datum/manufacture/robup_aware,
		/datum/manufacture/robup_physshield,
		/datum/manufacture/robup_fireshield,
		/datum/manufacture/robup_teleport,
		/datum/manufacture/robup_visualizer,
		/datum/manufacture/robup_efficiency,
		/datum/manufacture/robup_repair,
		/datum/manufacture/sbradio,
		/datum/manufacture/implant_health,
		/datum/manufacture/implant_antirot,
		/datum/manufacture/cyberappendix,
		/datum/manufacture/cyberpancreas,
		/datum/manufacture/cyberspleen,
		/datum/manufacture/cyberintestines,
		/datum/manufacture/cyberstomach,
		/datum/manufacture/cyberkidney,
		/datum/manufacture/cyberliver,
		/datum/manufacture/cyberlung_left,
		/datum/manufacture/cyberlung_right,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
		/datum/manufacture/glass,
		/datum/manufacture/asimov_laws,
		/datum/manufacture/borg_linker)

	hidden = list(/datum/manufacture/flash,
		/datum/manufacture/cybereye_thermal,
		/datum/manufacture/cybereye_laser,
		/datum/manufacture/cyberbutt,
		/datum/manufacture/robup_expand,
		/datum/manufacture/cardboard_ai,
		/datum/manufacture/corporate_laws,
		/datum/manufacture/robocop_laws)

/obj/machinery/manufacturer/medical
	name = "medical fabricator"
	supplemental_desc = "This one produces medical equipment and sterile clothing."
	icon_state = "fab-med"
	icon_base = "med"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2,
		/obj/item/material_piece/cloth/cottonfabric = 2)
	available = list(
		/datum/manufacture/scalpel,
		/datum/manufacture/circular_saw,
		/datum/manufacture/surgical_scissors,
		/datum/manufacture/hemostat,
		/datum/manufacture/suture,
		/datum/manufacture/stapler,
		/datum/manufacture/surgical_spoon,
		/datum/manufacture/prodocs,
		/datum/manufacture/glasses,
		/datum/manufacture/visor,
		/datum/manufacture/deafhs,
		/datum/manufacture/hypospray,
		/datum/manufacture/patch,
		/datum/manufacture/mender,
		/datum/manufacture/penlight,
		/datum/manufacture/stethoscope,
		/datum/manufacture/latex_gloves,
		/datum/manufacture/surgical_mask,
		/datum/manufacture/surgical_shield,
		/datum/manufacture/scrubs_white,
		/datum/manufacture/scrubs_teal,
		/datum/manufacture/scrubs_maroon,
		/datum/manufacture/scrubs_blue,
		/datum/manufacture/scrubs_purple,
		/datum/manufacture/scrubs_orange,
		/datum/manufacture/scrubs_pink,
		/datum/manufacture/patient_gown,
		/datum/manufacture/eyepatch,
		/datum/manufacture/blindfold,
		/datum/manufacture/muzzle,
		/datum/manufacture/stress_ball,
		/datum/manufacture/body_bag,
		/datum/manufacture/implanter,
		/datum/manufacture/implant_health,
		/datum/manufacture/implant_antirot,
		/datum/manufacture/floppydisk,
		/datum/manufacture/medicalalertbutton,
		/datum/manufacture/crowbar,
		/datum/manufacture/extinguisher,
		/datum/manufacture/empty_kit,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
		/datum/manufacture/glass
	)

	hidden = list()

/obj/machinery/manufacturer/science
	name = "science fabricator"
	supplemental_desc = "This one produces science equipment for experiments as well as expeditions."
	icon_state = "fab-sci"
	icon_base = "sci"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2,
		/obj/item/material_piece/cloth/cottonfabric = 2,
		/obj/item/material_piece/cobryl = 2)
	available = list(
		/datum/manufacture/flashlight,
		/datum/manufacture/gps,
		/datum/manufacture/crowbar,
		/datum/manufacture/extinguisher,
		/datum/manufacture/welder,
		/datum/manufacture/patch,
		/datum/manufacture/atmos_can,
		/datum/manufacture/gastank,
		/datum/manufacture/artifactforms,
		/datum/manufacture/fluidcanister,
		/datum/manufacture/chembarrel,
		/datum/manufacture/chembarrel/yellow,
		/datum/manufacture/chembarrel/red,
		/datum/manufacture/condenser,
		/datum/manufacture/fractionalcondenser,
		/datum/manufacture/dropper_funnel,
		/datum/manufacture/portable_dispenser,
		/datum/manufacture/beaker_lid_box,
		/datum/manufacture/bunsen_burner,
		/datum/manufacture/spectrogoggles,
		/datum/manufacture/atmos_goggles,
		/datum/manufacture/reagentscanner,
		/datum/manufacture/dropper,
		/datum/manufacture/mechdropper,
		/datum/manufacture/patient_gown,
		/datum/manufacture/blindfold,
		/datum/manufacture/muzzle,
		/datum/manufacture/audiotape,
		/datum/manufacture/audiolog,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
		/datum/manufacture/glass)

	hidden = list(/datum/manufacture/scalpel,
		/datum/manufacture/circular_saw,
		/datum/manufacture/surgical_scissors,
		/datum/manufacture/hemostat,
		/datum/manufacture/suture,
		/datum/manufacture/stapler,
		/datum/manufacture/surgical_spoon
	)

/obj/machinery/manufacturer/mining
	name = "mining fabricator"
	supplemental_desc = "This one produces mining equipment like concussive charges and powered tools."
	icon_state = "fab-mining"
	icon_base = "mining"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2)
	available = list(/datum/manufacture/pick,
		/datum/manufacture/powerpick,
		/datum/manufacture/blastchargeslite,
		/datum/manufacture/blastcharges,
		/datum/manufacture/powerhammer,
		/datum/manufacture/drill,
		/datum/manufacture/conc_gloves,
		/datum/manufacture/digbot,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/shoes,
		/datum/manufacture/breathmask,
		/datum/manufacture/engspacesuit,
		/datum/manufacture/lightengspacesuit,
#ifdef UNDERWATER_MAP
		/datum/manufacture/engdivesuit,
		/datum/manufacture/flippers,
#endif
		/datum/manufacture/industrialarmor,
		/datum/manufacture/industrialboots,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/powercellH,
		/datum/manufacture/ore_scoop,
		/datum/manufacture/oresatchel,
		/datum/manufacture/oresatchelL,
		/datum/manufacture/microjetpack,
		/datum/manufacture/jetpack,
#ifdef UNDERWATER_MAP
		/datum/manufacture/jetpackmkII,
#endif
		/datum/manufacture/geoscanner,
		/datum/manufacture/geigercounter,
		/datum/manufacture/eyes_meson,
		/datum/manufacture/flashlight,
		/datum/manufacture/ore_accumulator,
		/datum/manufacture/rods2,
		/datum/manufacture/metal,
#ifndef UNDERWATER_MAP
		/datum/manufacture/mining_magnet
#endif
		)

/obj/machinery/manufacturer/hangar
	name = "ship component fabricator"
	supplemental_desc = "This one produces modules for space pods or minisubs."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2)
	available = list(
#ifdef UNDERWATER_MAP
		/datum/manufacture/sub/preassembeled_parts,
#else
		/datum/manufacture/putt/preassembeled_parts,
		/datum/manufacture/pod/preassembeled_parts,
#endif
		/datum/manufacture/pod/armor_light,
		/datum/manufacture/pod/armor_heavy,
		/datum/manufacture/pod/armor_industrial,
		/datum/manufacture/cargohold,
		/datum/manufacture/storagehold,
#ifndef UNDERWATER_MAP
		/datum/manufacture/lateral_thrusters,
#endif
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/bad_mining,
		/datum/manufacture/pod/weapon/mining,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser,
		/datum/manufacture/engine,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/pod/lock,
		/datum/manufacture/pod/light_shielding,
		/datum/manufacture/pod/heavy_shielding,
		/datum/manufacture/beaconkit,
		/datum/manufacture/podgps
	)

/obj/machinery/manufacturer/uniform // add more stuff to this as needed, but it should be for regular uniforms the HoP might hand out, not tons of gimmicks. -cogwerks
	name = "uniform manufacturer"
	supplemental_desc = "This one can create a wide variety of one-size-fits-all jumpsuits, as well as backpacks and radio headsets."
	icon_state = "fab-jumpsuit"
	icon_base = "jumpsuit"
	free_resources = list(/obj/item/material_piece/cloth/cottonfabric = 5,
		/obj/item/material_piece/steel = 5,
		/obj/item/material_piece/copper = 5)
	accept_blueprints = FALSE
	available = list(/datum/manufacture/shoes,	//hey if you update these please remember to add it to /hop_and_uniform's list too
		/datum/manufacture/shoes_brown,
		/datum/manufacture/shoes_white,
		/datum/manufacture/flippers,
		/datum/manufacture/civilian_headset,
		/datum/manufacture/jumpsuit_assistant,
		/datum/manufacture/jumpsuit_pink,
		/datum/manufacture/jumpsuit_red,
		/datum/manufacture/jumpsuit_orange,
		/datum/manufacture/jumpsuit_yellow,
		/datum/manufacture/jumpsuit_green,
		/datum/manufacture/jumpsuit_blue,
		/datum/manufacture/jumpsuit_purple,
		/datum/manufacture/jumpsuit_black,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/jumpsuit_white,
		/datum/manufacture/jumpsuit_brown,
		/datum/manufacture/pride_lgbt,
		/datum/manufacture/pride_ace,
		/datum/manufacture/pride_aro,
		/datum/manufacture/pride_bi,
		/datum/manufacture/pride_inter,
		/datum/manufacture/pride_lesb,
		/datum/manufacture/pride_gay,
		/datum/manufacture/pride_nb,
		/datum/manufacture/pride_pan,
		/datum/manufacture/pride_poly,
		/datum/manufacture/pride_trans,
		/datum/manufacture/suit_black,
		/datum/manufacture/dress_black,
		/datum/manufacture/hat_black,
		/datum/manufacture/hat_white,
		/datum/manufacture/hat_pink,
		/datum/manufacture/hat_red,
		/datum/manufacture/hat_yellow,
		/datum/manufacture/hat_orange,
		/datum/manufacture/hat_green,
		/datum/manufacture/hat_blue,
		/datum/manufacture/hat_purple,
		/datum/manufacture/hat_tophat,
		/datum/manufacture/backpack,
		/datum/manufacture/backpack_red,
		/datum/manufacture/backpack_green,
		/datum/manufacture/backpack_blue,
		/datum/manufacture/satchel,
		/datum/manufacture/satchel_red,
		/datum/manufacture/satchel_green,
		/datum/manufacture/satchel_blue,
		/datum/manufacture/handkerchief)

	hidden = list(/datum/manufacture/breathmask,
		/datum/manufacture/patch,
		/datum/manufacture/towel,
		/datum/manufacture/tricolor,
		/datum/manufacture/hat_ltophat)

/// cogwerks - a gas extractor for the engine

/obj/machinery/manufacturer/gas
	name = "gas extractor"
	supplemental_desc = "This one can create gas canisters, either empty or filled with gases extracted from certain minerals."
	icon_state = "fab-atmos"
	icon_base = "atmos"
	accept_blueprints = FALSE
	available = list(
		/datum/manufacture/atmos_can,
		/datum/manufacture/air_can/large,
		/datum/manufacture/o2_can,
		/datum/manufacture/co2_can,
		/datum/manufacture/n2_can,
		/datum/manufacture/plasma_can,
		/datum/manufacture/red_o2_grenade)

// a blank manufacturer for mechanics

/obj/machinery/manufacturer/mechanic
	name = "reverse-engineering fabricator"
	desc = "A specialized manufacturing unit designed to create new things (or copies of existing things) from blueprints."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2)

/obj/machinery/manufacturer/personnel
	name = "personnel equipment manufacturer"
	supplemental_desc = "This one can produce blank ID cards and access implants."
	icon_state = "fab-access"
	icon_base = "access"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2)
	available = list(/datum/manufacture/id_card, /datum/manufacture/implant_access,	/datum/manufacture/implanter)
	hidden = list(/datum/manufacture/id_card_gold, /datum/manufacture/implant_access_infinite)

//combine personnel + uniform manufactuer here. this is 'cause destiny doesn't have enough room! arrg!
//and i hate this, i do, but you're gonna have to update this list whenever you update /personnel or /uniform
/obj/machinery/manufacturer/hop_and_uniform
	name = "personnel manufacturer"
	supplemental_desc = "This one is an multi-purpose model, and is able to produce uniforms, headsets, and identification equipment."
	icon_state = "fab-access"
	icon_base = "access"
	free_resources = list(/obj/item/material_piece/steel = 5,
		/obj/item/material_piece/copper = 5,
		/obj/item/material_piece/glass = 5,
		/obj/item/material_piece/cloth/cottonfabric = 5)
	accept_blueprints = FALSE
	available = list(/datum/manufacture/id_card,
		/datum/manufacture/implant_access,
		/datum/manufacture/implanter,
		/datum/manufacture/shoes,
		/datum/manufacture/shoes_brown,
		/datum/manufacture/shoes_white,
		/datum/manufacture/flippers,
		/datum/manufacture/civilian_headset,
		/datum/manufacture/jumpsuit_assistant,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/jumpsuit_white,
		/datum/manufacture/jumpsuit_pink,
		/datum/manufacture/jumpsuit_red,
		/datum/manufacture/jumpsuit_orange,
		/datum/manufacture/jumpsuit_yellow,
		/datum/manufacture/jumpsuit_green,
		/datum/manufacture/jumpsuit_blue,
		/datum/manufacture/jumpsuit_purple,
		/datum/manufacture/jumpsuit_black,
		/datum/manufacture/jumpsuit_brown,
		/datum/manufacture/pride_lgbt,
		/datum/manufacture/pride_ace,
		/datum/manufacture/pride_aro,
		/datum/manufacture/pride_bi,
		/datum/manufacture/pride_inter,
		/datum/manufacture/pride_lesb,
		/datum/manufacture/pride_gay,
		/datum/manufacture/pride_nb,
		/datum/manufacture/pride_pan,
		/datum/manufacture/pride_poly,
		/datum/manufacture/pride_trans,
		/datum/manufacture/hat_black,
		/datum/manufacture/hat_white,
		/datum/manufacture/hat_pink,
		/datum/manufacture/hat_red,
		/datum/manufacture/hat_yellow,
		/datum/manufacture/hat_orange,
		/datum/manufacture/hat_green,
		/datum/manufacture/hat_blue,
		/datum/manufacture/hat_purple,
		/datum/manufacture/hat_tophat,
		/datum/manufacture/handkerchief,)

	hidden = list(/datum/manufacture/id_card_gold,
		/datum/manufacture/implant_access_infinite,
		/datum/manufacture/breathmask,
		/datum/manufacture/patch,
		/datum/manufacture/tricolor,
		/datum/manufacture/hat_ltophat)

/obj/machinery/manufacturer/qm // This manufacturer just creates different crated and boxes for the QM. Lets give their boring lives at least something more interesting.
	name = "crate manufacturer"
	supplemental_desc = "This one produces crates, carts, that sort of thing. Y'know, box stuff."
	icon_state = "fab-crates"
	icon_base = "crates"
	free_resources = list(/obj/item/material_piece/steel = 1,
		/obj/item/material_piece/organic/wood = 1)
	accept_blueprints = FALSE
	available = list(/datum/manufacture/crate,
		/datum/manufacture/packingcrate,
		/datum/manufacture/wooden,
		/datum/manufacture/medical,
		/datum/manufacture/biohazard,
		/datum/manufacture/freezer)

	hidden = list(/datum/manufacture/classcrate)

/obj/machinery/manufacturer/zombie_survival
	name = "\improper Uber-Extreme Survival Manufacturer"
	desc = "This manufacturing unit seems to have been loaded with a bunch of nonstandard blueprints, apparently to be useful in surviving \"extreme scenarios\"."
	icon_state = "fab-crates"
	icon_base = "crates"
	free_resources = list(/obj/item/material_piece/steel = 50,
		/obj/item/material_piece/copper = 50,
		/obj/item/material_piece/glass = 50,
		/obj/item/material_piece/cloth/cottonfabric = 50)
	accept_blueprints = FALSE
	available = list(
		/datum/manufacture/engspacesuit,
		/datum/manufacture/breathmask,
		/datum/manufacture/suture,
		/datum/manufacture/scalpel,
		/datum/manufacture/flashlight,
		/datum/manufacture/armor_vest,
		/datum/manufacture/bullet_22,
		/datum/manufacture/harmonica,
		/datum/manufacture/riot_shotgun,
		/datum/manufacture/riot_shotgun_ammo,
		/datum/manufacture/clock,
		/datum/manufacture/clock_ammo,
		/datum/manufacture/saa,
		/datum/manufacture/saa_ammo,
		/datum/manufacture/riot_launcher,
		/datum/manufacture/riot_launcher_ammo_pbr,
		/datum/manufacture/riot_launcher_ammo_flashbang,
		/datum/manufacture/sniper,
		/datum/manufacture/sniper_ammo,
		/datum/manufacture/tac_shotgun,
		/datum/manufacture/tac_shotgun_ammo,
		/datum/manufacture/gyrojet,
		/datum/manufacture/gyrojet_ammo,
		/datum/manufacture/plank,
		/datum/manufacture/brute_kit,
		/datum/manufacture/burn_kit,
		/datum/manufacture/crit_kit,
		/datum/manufacture/spacecillin,
		/datum/manufacture/bat,
		/datum/manufacture/quarterstaff,
		/datum/manufacture/cleaver,
		/datum/manufacture/fireaxe,
		/datum/manufacture/shovel)

/obj/machinery/manufacturer/engineering
	name = "Engineering Specialist Manufacturer"
	desc = "This one produces specialist engineering devices."
	icon_state = "fab-engineering"
	icon_base = "engineering"
	free_resources = list(/obj/item/material_piece/steel = 2,
		/obj/item/material_piece/copper = 2,
		/obj/item/material_piece/glass = 2)
	available = list(
		/datum/manufacture/screwdriver/yellow,
		/datum/manufacture/wirecutters/yellow,
		/datum/manufacture/wrench/yellow,
		/datum/manufacture/crowbar/yellow,
		/datum/manufacture/extinguisher,
		/datum/manufacture/welder/yellow,
		/datum/manufacture/soldering,
		/datum/manufacture/multitool,
		/datum/manufacture/t_scanner,
		/datum/manufacture/RCD,
		/datum/manufacture/RCDammo,
		/datum/manufacture/RCDammomedium,
		/datum/manufacture/RCDammolarge,
		/datum/manufacture/atmos_goggles,
		/datum/manufacture/engivac,
		/datum/manufacture/lampmanufacturer,
		/datum/manufacture/pod/weapon/efif1,
		/datum/manufacture/breathmask,
		/datum/manufacture/engspacesuit,
		/datum/manufacture/lightengspacesuit,
		/datum/manufacture/floodlight,
		/datum/manufacture/powercell,
		/datum/manufacture/powercellE,
		/datum/manufacture/powercellC,
		/datum/manufacture/powercellH,
#ifdef UNDERWATER_MAP
		/datum/manufacture/engdivesuit,
		/datum/manufacture/flippers,
#endif
#ifdef MAP_OVERRIDE_OSHAN
		/datum/manufacture/cable/reinforced,
#endif
		/datum/manufacture/mechanics/laser_mirror,
		/datum/manufacture/mechanics/laser_splitter,
		/datum/manufacture/interdictor_kit,
		/datum/manufacture/interdictor_board_standard,
		/datum/manufacture/interdictor_board_nimbus,
		/datum/manufacture/interdictor_board_zephyr,
		/datum/manufacture/interdictor_board_devera,
		/datum/manufacture/interdictor_rod_lambda,
		/datum/manufacture/interdictor_rod_sigma,
		/datum/manufacture/interdictor_rod_epsilon,
		/datum/manufacture/interdictor_rod_phi
	)

	New()
		. = ..()
		if (isturf(src.loc)) //not inside a frame or something
			new /obj/item/paper/book/from_file/interdictor_guide(src.loc)
