/*
 * - brobocop
 * - chemistry
 * - civilian
 * - common
 * - engineering
 * - medical
 * - mining
 */

// convenient bundling of common tools, some modules do not include this as they want the items in a different order
/datum/robot/module_tool_creator/recursive/module/common
	definitions = list(
		/obj/item/portable_typewriter/borg,
		/obj/item/robojumper,
		/obj/item/device/analyzer/atmospheric/upgraded,
		/obj/item/device/reagentscanner,
		/obj/item/device/light/flashlight,
		/obj/item/device/analyzer/healthanalyzer/upgraded,
		/obj/item/tool/omnitool/silicon,
	)

// security officer. bartender. clown.
/datum/robot/module_tool_creator/recursive/module/brobocop
	definitions = list(
		/datum/robot/module_tool_creator/recursive/module/common,
		/obj/item/device/detective_scanner,
		/obj/item/noisemaker,
		/obj/item/robot_foodsynthesizer,
		/obj/item/device/light/zippo/borg,
		/obj/item/instrument/whistle,
		/obj/item/c_tube, // TODO: make slightly buffed version?
		/obj/item/gun/kinetic/foamdartgun/borg,
		/obj/item/item_box/assorted/stickers/robot,
		/obj/item/device/camera_viewer/security,
		/obj/item/device/prisoner_scanner,
		/obj/item/device/ticket_writer,
		/obj/item/sec_tape/vended,
		/obj/item/reagent_containers/food/drinks/bottle/beer/borg,
		/obj/item/reagent_containers/food/drinks/drinkingglass/pitcher,
		/obj/item/sponge, // To clean up drawings
		/obj/item/pen/omni, // Fancy
		/obj/item/pen/crayon/random/robot,
		/obj/item/pen/crayon/rainbow,
		/obj/item/hand_labeler,
		/obj/item/coin_bot,
		/obj/item/dice/robot,
		/obj/item/device/audio_log, // TODO: make larger and non-ejectable version?
		// TODO: security grenade fabricator?!
		// /obj/item/handcuffs/tape_roll/crappy,
	)

// scientist.
/datum/robot/module_tool_creator/recursive/module/science
	definitions = list(
		/datum/robot/module_tool_creator/recursive/module/common,
		/obj/item/device/gps, // Let's them assist with telesci
		/obj/item/extinguisher/large/cyborg,
		/obj/item/hand_labeler,
		/obj/item/item_box/assorted/stickers/robot/science,
		/obj/item/pen/omni,
		/obj/item/robot_chemaster,
		/obj/item/reagent_containers/food/drinks/drinkingglass,
		/obj/item/reagent_containers/glass/beaker/large/cyborg,
		/obj/item/reagent_containers/glass/beaker/large/cyborg,
		/obj/item/reagent_containers/glass/beaker/large/cyborg,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/dropper/mechanical,
		// TODO: utility grenade fabricator?
		// TODO: some sort of chem dispenser?
	)

// botanist. chef. janitor.
/datum/robot/module_tool_creator/recursive/module/civilian
	definitions = list(
		/datum/robot/module_tool_creator/recursive/module/common,
		/obj/item/extinguisher/large/cyborg,
		/obj/item/reagent_containers/glass/bucket, // TODO: make large version
		/obj/item/spraybottle/cleaner/robot,
		/obj/item/sponge,
		/obj/item/mop,
		/obj/item/lamp_manufacturer,
		/obj/item/saw/cyborg,
		/obj/item/seedplanter,
		/obj/item/plantanalyzer,
		/obj/item/gardentrowel,
		/obj/item/device/igniter,
		/obj/item/satchel/hydro, // TODO: make more versatile version
		/obj/item/satchel/hydro,
		/obj/item/satchel/hydro,
		// TODO: some sort of nutrient dispenser?
		/obj/item/tongs,
		/obj/item/kitchen/utensil/knife/bread,
		/obj/item/ladle,
		/obj/item/kitchen/rollingpin/light,
		/obj/item/reagent_containers/food/drinks/drinkingglass/icing,
		/obj/item/fishing_rod/cybernetic,
		/obj/item/storage/fish_box/small,
		/obj/item/device/camera_viewer/public,
		/obj/item/pen/omni,
		/obj/item/paper_bin/robot,
	)

// engineer. mechanic.
/datum/robot/module_tool_creator/recursive/module/engineering
	definitions = list(
		/obj/item/portable_typewriter/borg,
		/obj/item/device/analyzer/healthanalyzer/upgraded,
		/obj/item/device/reagentscanner,
		/obj/item/device/analyzer/atmospheric/upgraded,
		/obj/item/robojumper,
		/obj/item/pinpointer/category/apcs/station,
		/obj/item/device/light/flashlight,
		/obj/item/extinguisher/large/cyborg,
		/obj/item/tool/omnitool/silicon,
		/obj/item/weldingtool,
		/obj/item/rcd,
		/obj/item/deconstructor/borg,
		#ifdef MAP_OVERRIDE_OSHAN
			/obj/item/mining_tool/powered/shovel,
		#endif
		/datum/robot/module_tool_creator/item_type/amount/steel_tile,
		/datum/robot/module_tool_creator/item_type/amount/steel_rod,
		/datum/robot/module_tool_creator/item_type/amount/steel_sheet,
		/datum/robot/module_tool_creator/item_type/amount/glass_sheet,
		/datum/robot/module_tool_creator/item_type/amount/cable_coil,
		#ifdef MAP_OVERRIDE_OSHAN
			/datum/robot/module_tool_creator/item_type/amount/cable_coil/reinforced,
		#endif
		/obj/item/device/t_scanner,
		/obj/item/lamp_manufacturer,
		/obj/item/atmosporter,
		/obj/item/electronics/soldering,
		/obj/item/electronics/scanner,
		/obj/item/blueprint_marker,
	)

// medical doctor.
/datum/robot/module_tool_creator/recursive/module/medical
	definitions = list(
		/obj/item/portable_typewriter/borg,
		/obj/item/robojumper,
		/obj/item/device/analyzer/atmospheric/upgraded,
		/obj/item/device/reagentscanner,
		/obj/item/device/light/flashlight,
		/obj/item/tool/omnitool/silicon,
		/obj/item/robodefibrillator,
		/obj/item/device/analyzer/healthanalyzer/upgraded,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray, // TODO: make large version
		/obj/item/robospray, // TODO: make large version
		/obj/item/reagent_containers/mender/burn/medbot,
		/obj/item/reagent_containers/mender/brute/medbot,
		/obj/item/suture,
		/obj/item/reagent_containers/iv_drip/blood,
		/obj/item/circular_saw,
		/obj/item/scalpel,
		/obj/item/scissors/surgical_scissors,
		/obj/item/hemostat,
		/obj/item/surgical_spoon,
		/obj/item/staple_gun,
		/obj/item/reagent_containers/glass/beaker/large/cyborg,
		/obj/item/reagent_containers/glass/beaker/large/cyborg,
		/obj/item/reagent_containers/dropper,
	)

// miner. quartermaster.
/datum/robot/module_tool_creator/recursive/module/mining
	definitions = list(
		/datum/robot/module_tool_creator/recursive/module/common,
		/obj/item/device/gps,
		/obj/item/extinguisher/large/cyborg,
		/obj/item/mining_tool/powered/drill,
		/obj/item/ore_scoop/borg,
		/obj/item/cargotele,
		/obj/item/satchel/mining/large,
		/obj/item/satchel/mining/large,
		/obj/item/oreprospector,
		/obj/item/device/appraisal,
		/obj/item/device/matanalyzer,
		// TODO: make barcode machine
		// TODO: make versatile satchel (same as civilian module's satchel)
		// TODO: make cargo transporter (i.e. atmosporter, but allow single crate instead of canisters)
	)

/datum/robot/module_tool_creator/recursive/module/eyebot
	definitions = list(
		/datum/robot/module_tool_creator/recursive/module/common,
		/obj/item/device/radio/intercom/AI/handheld)

//These are not publically used anymore
/datum/robot/module_tool_creator/recursive/module/construction_ai
	definitions = list(
		/datum/robot/module_tool_creator/recursive/module/common,
		/obj/item/rcd,
		/obj/item/electronics/scanner,
		/obj/item/electronics/soldering,
		/obj/item/room_planner,
		/obj/item/room_marker,
		/datum/robot/module_tool_creator/item_type/amount/cable_coil,
	)

/datum/robot/module_tool_creator/recursive/module/construction_worker
	definitions = list(
		/datum/robot/module_tool_creator/recursive/module/common,
		/obj/item/weldingtool,
		/obj/item/electronics/scanner,
		/obj/item/electronics/soldering,
		/obj/item/room_planner,
		/obj/item/room_marker,
		/obj/item/extinguisher/large/cyborg,
		/obj/item/rcd,
		/obj/item/deconstructor/borg,
		/datum/robot/module_tool_creator/item_type/amount/steel_tile,
		/datum/robot/module_tool_creator/item_type/amount/steel_rod,
		/datum/robot/module_tool_creator/item_type/amount/steel_sheet,
		/datum/robot/module_tool_creator/item_type/amount/glass_sheet,
		/datum/robot/module_tool_creator/item_type/amount/cable_coil,
	)
