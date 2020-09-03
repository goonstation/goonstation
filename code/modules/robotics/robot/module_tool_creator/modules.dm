/*
 * - brobocop
 * - chemistry
 * - civilian
 * - common
 * - engineering
 * - medical
 * - mining
 */

/datum/robot/module_tool_creator/recursive/module/brobocop
	definitions = list(
		/obj/item/noisemaker,
		/obj/item/robot_foodsynthesizer,
		/obj/item/reagent_containers/food/drinks/bottle/beer/borg,
		/obj/item/reagent_containers/food/drinks/drinkingglass,
		/obj/item/coin_bot,
		/obj/item/dice_bot,
		/obj/item/device/light/zippo/borg,
		/obj/item/pen, // TODO: make more versatile version
		/obj/item/device/prisoner_scanner,
		/obj/item/item_box/assorted/stickers/robot,
		// TODO: security grenade fabricator?!
		// TODO: nerfed/limited cuffs/zip-ties?
		/obj/item/c_tube, // TODO: make slightly buffed version?
		/obj/item/device/detective_scanner,
		/obj/item/device/audio_log, // TODO: make larger and non-ejectable version?
		/obj/item/device/camera_viewer,
		/obj/item/hand_labeler,
		// TODO: make ticketting machine?
	)

/datum/robot/module_tool_creator/recursive/module/chemistry
	definitions = list(
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
		/obj/item/extinguisher, // TODO: make large version?
	)

/datum/robot/module_tool_creator/recursive/module/civilian
	definitions = list(
		/obj/item/extinguisher, // TODO: make large version
		/obj/item/pen, // TODO: make more versatile version
		/obj/item/seedplanter,
		/obj/item/plantanalyzer,
		/obj/item/device/igniter,
		/obj/item/saw/cyborg,
		/obj/item/satchel/hydro, // TODO: make more versatile version
		/obj/item/reagent_containers/glass/bucket, // TODO: make large version
		/obj/item/spraybottle/cleaner,
		/obj/item/mop,
		/obj/item/lamp_manufacturer,
		/obj/item/device/camera_viewer,
		// TODO: some sort of nutrient dispenser?
		/obj/item/kitchen/utensil/knife/bread,
		/obj/item/kitchen/rollingpin/light,
		/obj/item/reagent_containers/glass/bottle/icing,
		// TODO: portable oven
	)

/datum/robot/module_tool_creator/recursive/module/common
	definitions = list(
		/obj/item/device/light/flashlight,
		/obj/item/tool/omnitool/silicon,
		/obj/item/device/analyzer/healthanalyzer/borg,
		/obj/item/device/reagentscanner,
		/obj/item/device/analyzer/atmospheric/upgraded,
		/obj/item/robojumper,
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
		/obj/item/extinguisher,
		/obj/item/rcd,
		/obj/item/deconstructor/borg,
		/datum/robot/module_tool_creator/item_type/amount/steel_tile,
		/datum/robot/module_tool_creator/item_type/amount/steel_rod,
		/datum/robot/module_tool_creator/item_type/amount/steel_sheet,
		/datum/robot/module_tool_creator/item_type/amount/glass_sheet,
		/datum/robot/module_tool_creator/item_type/amount/cable_coil,
	)

/datum/robot/module_tool_creator/recursive/module/engineering
	definitions = list(
		/obj/item/atmosporter,
		/obj/item/extinguisher, // TODO: make large version
		/obj/item/weldingtool,
		/obj/item/device/t_scanner,
		/obj/item/electronics/scanner,
		/obj/item/electronics/soldering,
		/obj/item/rcd,
		/obj/item/lamp_manufacturer,
		/obj/item/deconstructor/borg,
		/datum/robot/module_tool_creator/item_type/amount/steel_tile,
		/datum/robot/module_tool_creator/item_type/amount/steel_rod,
		/datum/robot/module_tool_creator/item_type/amount/steel_sheet,
		/datum/robot/module_tool_creator/item_type/amount/glass_sheet,
		/datum/robot/module_tool_creator/item_type/amount/cable_coil,
	)

/datum/robot/module_tool_creator/recursive/module/medical
	definitions = list(
		/obj/item/robodefibrillator,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/surgical_spoon,
		/obj/item/scissors/surgical_scissors,
		/obj/item/hemostat,
		/obj/item/suture,
		/obj/item/staple_gun,
		/obj/item/reagent_containers/iv_drip/blood,
		///obj/item/reagent_containers/patch/burn/medbot,
		///obj/item/reagent_containers/patch/bruise/medbot,
		/obj/item/reagent_containers/mender/brute/medbot,
		/obj/item/reagent_containers/mender/burn/medbot,
		/obj/item/reagent_containers/hypospray, // TODO: make large version
		/obj/item/reagent_containers/hypospray, // TODO: make large version
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/glass/beaker/large/epinephrine,
		/obj/item/reagent_containers/glass/beaker/large/antitox,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/dropper,
	)

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
		/obj/item/extinguisher, // TODO: make large version
		/obj/item/device/gps,
		// TODO: make barcode machine
		// TODO: make internal ore processor
	)
