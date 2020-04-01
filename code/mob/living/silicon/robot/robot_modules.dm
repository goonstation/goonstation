/obj/item/robot_module
	name = "cyborg module"
	desc = "A blank cyborg module. It has minimal function in its current state."
	icon = 'icons/obj/items/cyborg_parts/modules.dmi'
	icon_state = "blank"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	w_class = 2.0
	flags = FPRINT |TABLEPASS | CONDUCT
	var/list/modules = list()
	var/mod_hudicon = "unknown"
	var/cosmetic_mods = null
	var/included_items = null
	var/included_cosmetic = null
	var/radio_type = null
	var/obj/item/device/radio/radio = null

	New() //Shit all the mods have - make sure to call ..() at the top of any New() in this class of item
		src.modules += new /obj/item/device/light/flashlight(src)
		src.modules += new /obj/item/tool/omnitool(src)
		src.modules += new /obj/item/device/analyzer/healthanalyzer/borg(src)
		src.modules += new /obj/item/device/reagentscanner(src)
		src.modules += new /obj/item/device/analyzer/atmospheric(src)
		src.modules += new /obj/item/robojumper(src)
		initialize_module()

	proc/initialize_module()
		//Make me pretty
		if(ispath(included_cosmetic, /datum/robot_cosmetic))
			src.cosmetic_mods = new included_cosmetic(src)

		//Make my stuff
		if(islist(src.included_items))
			for(var/T in included_items)
				if(ispath(T))
					src.modules += new T(src)

			src.included_items = null //No need to save all of those types. Every bit helps

		if(src.radio_type != null)
			src.radio = new src.radio_type(src)

		special_module_init()

		//Make sure I don't lose my stuff
		for(var/obj/item/I in src.modules)
			I.cant_drop = 1

	proc/special_module_init()
		//Stub
		return

/obj/item/robot_module/brobocop
	name = "brobocop module"
	desc = "Become the life of the party, and also the scourge of fun."
	icon_state = "brobocop"
	mod_hudicon = "brobocop"
	included_cosmetic = /datum/robot_cosmetic/brobocop
	included_items = list(
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
		/obj/item/hand_labeler
		// TODO: make ticketting machine?
	)
	radio_type = /obj/item/device/radio/headset/security

/datum/robot_cosmetic/brobocop
	head_mod = "Afro and Shades"
	fx = list(90,0,90)
	painted = 0

/*
/datum/robot_cosmetic/brobot
	head_mod = "Afro and Shades"
	legs_mod = "Disco Flares"
	fx = list(90,0,90)
	painted = 0
*/

/obj/item/robot_module/chemistry
	name = "chemistry module"
	desc = "Beakers, syringes and other tools to enable a cyborg to assist in the research of chemicals."
	icon_state = "chemistry"
	mod_hudicon = "chemistry"
	included_cosmetic = /datum/robot_cosmetic/chemistry
	included_items = list(
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
		/obj/item/extinguisher // TODO: make large version?
	)
	radio_type = /obj/item/device/radio/headset/research

/datum/robot_cosmetic/chemistry
	ches_mod = "Lab Coat"
	fx = list(0,0,255)
	painted = 1
	paint = list(0,0,100)

/obj/item/robot_module/civilian
	name = "civilian module"
	desc = "A module suitable for many of the menial tasks covered by the civilian department."
	mod_hudicon = "civilian"

	included_cosmetic = /datum/robot_cosmetic/civilian
	included_items = list(
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
		/obj/item/device/camera_viewer,
		// TODO: some sort of nutrient dispenser?
		/obj/item/kitchen/utensil/knife/bread,
		/obj/item/kitchen/rollingpin/light,
		/obj/item/reagent_containers/glass/bottle/icing
		// TODO: portable oven
	)
	radio_type = /obj/item/device/radio/headset/civilian

/datum/robot_cosmetic/civilian
	fx = list(255,0,0)
	painted = 1
	paint = list(0,0,0)

/obj/item/robot_module/engineering
	name = "engineering module"
	desc = "A module designed to allow for station maintenance and repair work."
	icon_state = "engineering"
	mod_hudicon = "engineering"
	included_cosmetic = /datum/robot_cosmetic/engineering
	included_items = list(
		/obj/item/atmosporter,
		/obj/item/extinguisher, // TODO: make large version
		/obj/item/weldingtool,
		/obj/item/device/t_scanner,
		/obj/item/electronics/scanner,
		/obj/item/electronics/soldering,
		/obj/item/rcd,
	)
	radio_type = /obj/item/device/radio/headset/engineer

	special_module_init()
		..()
		src.modules += new /obj/item/tile/steel{amount = 500} (src)
		src.modules += new /obj/item/rods/steel{amount = 500} (src)
		src.modules += new /obj/item/sheet/steel{amount = 500} (src)
		src.modules += new /obj/item/sheet/glass{amount = 500} (src)
		src.modules += new /obj/item/cable_coil{amount = 1000} (src)

/datum/robot_cosmetic/engineering
	fx = list(255,255,0)
	painted = 1
	paint = list(130,150,0)

/obj/item/robot_module/medical
	name = "medical module"
	desc = "Incorporates medical tools intended for use to save and preserve human life."
	icon_state = "medical"
	mod_hudicon = "medical"
	included_cosmetic = /datum/robot_cosmetic/medical
	included_items = list(
		/obj/item/robodefibrillator,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/surgical_spoon,
		/obj/item/scissors/surgical_scissors,
		/obj/item/hemostat,
		/obj/item/suture,
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
		/obj/item/reagent_containers/dropper
	)
	radio_type = /obj/item/device/radio/headset/medical

/datum/robot_cosmetic/medical
	head_mod = "Medical Mirror"
	ches_mod = "Medical Insignia"
	fx = list(0,255,0)
	painted = 1
	paint = list(150,150,150)

/obj/item/robot_module/mining
	name = "mining module"
	desc = "Tools for use in the excavation and transportation of valuable minerals."
	icon_state = "mining"
	mod_hudicon = "mining"
	included_cosmetic = /datum/robot_cosmetic/mining
	included_items = list(
		// TODO: make versatile satchel (same as civilian module's satchel)
		/obj/item/mining_tool/drill,
		/obj/item/ore_scoop/borg,
		/obj/item/cargotele,
		// TODO: make cargo transporter (i.e. atmosporter, but allow single crate instead of canisters)
		/obj/item/oreprospector,
		/obj/item/satchel/mining/large,
		/obj/item/satchel/mining/large,
		/obj/item/extinguisher, // TODO: make large version
		/obj/item/device/gps
		// TODO: make barcode machine
		// TODO: make internal ore processor
	)
	radio_type = /obj/item/device/radio/headset/engineer

/datum/robot_cosmetic/mining
	head_mod = "Hard Hat"
	fx = list(0,255,255)
	painted = 1
	paint = list(130,90,0)

/obj/item/robot_module/construction_worker
	name = "construction worker module"
	desc = "Everything a construction worker requires."
	icon_state = "construction"
	mod_hudicon = "construction"
	included_cosmetic = /datum/robot_cosmetic/construction
	included_items = list(/obj/item/weldingtool,
							/obj/item/electronics/scanner,
							/obj/item/electronics/soldering,
							/obj/item/room_planner,
							/obj/item/room_marker,
							/obj/item/extinguisher,
							/obj/item/rcd)
	radio_type = /obj/item/device/radio/headset/engineer
	
	special_module_init()
		..()
		src.modules += new /obj/item/tile/steel{amount = 500} (src)
		src.modules += new /obj/item/rods/steel{amount = 500} (src)
		src.modules += new /obj/item/sheet/glass{amount = 500} (src)
		src.modules += new /obj/item/cable_coil{amount = 500} (src)

/datum/robot_cosmetic/construction
	fx = list(0,240,160)
	painted = 1
	paint = list(0,120,80)

/obj/item/robot_module/construction_ai
	included_items = list(/obj/item/rcd,
							/obj/item/electronics/scanner,
							/obj/item/electronics/soldering,
							/obj/item/room_planner,
							/obj/item/room_marker)

	special_module_init()
		..()
		src.modules += new /obj/item/cable_coil{amount = 500} (src)
