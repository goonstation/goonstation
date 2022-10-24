/*
 * - brobocop
 * - chemistry
 * - civilian
 * - common
 * - engineering
 * - medical
 * - mining
 */

// security officer. bartender. clown.
/datum/robot/module_tool_creator/recursive/module/brobocop
	definitions = list(
		/obj/item/noisemaker,
		/obj/item/robot_foodsynthesizer,
		/obj/item/reagent_containers/food/drinks/bottle/beer/borg,
		/obj/item/reagent_containers/food/drinks/drinkingglass/pitcher,
		/obj/item/pen/omni, // Fancy
		/obj/item/pen/crayon/random/robot,
		/obj/item/pen/crayon/rainbow,
		/obj/item/sponge, // To clean up drawings
		/obj/item/coin_bot,
		/obj/item/dice/robot,
		/obj/item/device/light/zippo/borg,
		/obj/item/device/prisoner_scanner,
		/obj/item/item_box/assorted/stickers/robot,
		// TODO: security grenade fabricator?!
		// /obj/item/handcuffs/tape_roll/crappy,
		/obj/item/c_tube, // TODO: make slightly buffed version?
		/obj/item/device/detective_scanner,
		/obj/item/device/audio_log, // TODO: make larger and non-ejectable version?
		/obj/item/device/camera_viewer,
		/obj/item/hand_labeler,
		/obj/item/device/ticket_writer,
	)

// scientist.
/datum/robot/module_tool_creator/recursive/module/chemistry
	definitions = list(
		/obj/item/hand_labeler,
		/obj/item/robot_chemaster,
		// TODO: utility grenade fabricator?
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/dropper/mechanical,
		// TODO: some sort of chem dispenser?
		/obj/item/reagent_containers/food/drinks/drinkingglass,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/extinguisher/large/cyborg,
	)

// botanist. chef. janitor.
/datum/robot/module_tool_creator/recursive/module/civilian
	definitions = list(
		/obj/item/extinguisher/large/cyborg,
		/obj/item/pen, // TODO: make more versatile version
		/obj/item/seedplanter,
		/obj/item/plantanalyzer,
		/obj/item/device/igniter,
		/obj/item/saw/cyborg,
		/obj/item/satchel/hydro, // TODO: make more versatile version
		/obj/item/satchel/hydro,
		/obj/item/satchel/hydro,
		/obj/item/paper_bin/robot,
		/obj/item/reagent_containers/glass/bucket, // TODO: make large version
		/obj/item/spraybottle/cleaner/robot,
		/obj/item/sponge,
		/obj/item/mop,
		/obj/item/lamp_manufacturer,
		/obj/item/device/camera_viewer,
		// TODO: some sort of nutrient dispenser?
		/obj/item/tongs,
		/obj/item/kitchen/utensil/knife/bread,
		/obj/item/ladle,
		/obj/item/kitchen/rollingpin/light,
		/obj/item/reagent_containers/food/drinks/drinkingglass/icing,
	)

/datum/robot/module_tool_creator/recursive/module/common
	definitions = list(
		/obj/item/device/light/flashlight,
		/obj/item/tool/omnitool/silicon,
		/obj/item/device/analyzer/healthanalyzer/upgraded,
		/obj/item/device/reagentscanner,
		/obj/item/device/analyzer/atmospheric/upgraded,
		/obj/item/robojumper,
		/obj/item/portable_typewriter/borg,
	)

/datum/robot/module_tool_creator/recursive/module/construction_ai
	definitions = list(
		/obj/item/rcd,
		/obj/item/electronics/scanner,
		/obj/item/electronics/soldering,
		/obj/item/room_planner,
		/obj/item/room_marker,
		/datum/robot/module_tool_creator/item_type/amount/cable_coil,
	)

/datum/robot/module_tool_creator/recursive/module/construction_worker
	definitions = list(
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

// engineer. mechanic.
/datum/robot/module_tool_creator/recursive/module/engineering
	definitions = list(
		/obj/item/atmosporter,
		/obj/item/extinguisher/large/cyborg,
		/obj/item/weldingtool,
		/obj/item/device/t_scanner,
		/obj/item/electronics/scanner,
		/obj/item/electronics/soldering,
		/obj/item/rcd,
		/obj/item/lamp_manufacturer,
		/obj/item/deconstructor/borg,
		/obj/item/pinpointer/category/apcs/station,
		#ifdef MAP_OVERRIDE_OSHAN
			/obj/item/mining_tool/power_shovel/borg,
		#endif
		/datum/robot/module_tool_creator/item_type/amount/steel_tile,
		/datum/robot/module_tool_creator/item_type/amount/steel_rod,
		/datum/robot/module_tool_creator/item_type/amount/steel_sheet,
		/datum/robot/module_tool_creator/item_type/amount/glass_sheet,
		/datum/robot/module_tool_creator/item_type/amount/cable_coil,
	)

// medical doctor.
/datum/robot/module_tool_creator/recursive/module/medical
	definitions = list(
		/obj/item/robodefibrillator,
		/obj/item/reagent_containers/mender/brute/medbot,
		/obj/item/reagent_containers/mender/burn/medbot,
		/obj/item/robospray, // TODO: make large version
		/obj/item/reagent_containers/hypospray, // TODO: make large version
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/iv_drip/blood,
		/obj/item/suture,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/surgical_spoon,
		/obj/item/scissors/surgical_scissors,
		/obj/item/hemostat,
		/obj/item/staple_gun,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/dropper,
	)

// miner. quartermaster.
/datum/robot/module_tool_creator/recursive/module/mining
	definitions = list(
		// TODO: make versatile satchel (same as civilian module's satchel)
		/obj/item/mining_tool/drill,
		/obj/item/ore_scoop/borg,
		/obj/item/cargotele,
		// TODO: make cargo transporter (i.e. atmosporter, but allow single crate instead of canisters)
		/obj/item/oreprospector,
		/obj/item/satchel/mining/large,
		/obj/item/satchel/mining/large,
		/obj/item/extinguisher/large/cyborg,
		/obj/item/device/gps,
		/obj/item/device/appraisal,
		/obj/item/device/matanalyzer,
		// TODO: make barcode machine
	)
