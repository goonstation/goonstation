proc/get_nice_mat_name_for_manufacturers(mat)
	if(mat in material_category_names)
		return material_category_names[mat]
	else
		var/datum/material/nice_mat = getMaterial(mat)
		if (istype(nice_mat))
			return capitalize(nice_mat.name)
		return capitalize(mat) //if all else fails (probably a category instead of a material)

ABSTRACT_TYPE(/datum/manufacture)
/datum/manufacture
	var/name = null                // Name of the schematic
	var/list/item_paths = null   // Materials required (generate from `mats` if null)
	var/list/item_names = null   // Name of each material (generated automatically if null)
	var/list/item_amounts = list() // How many of each material is needed
	var/list/item_outputs = list() // What the schematic outputs
	var/randomise_output = 0
	// 0 - will create each item in the list once per loop (see manufacturer.dm Line 755)
	// 1 - will pick() a random item in the list once per loop
	// 2 - will pick() a random item before the loop begins then output one of the selected item each loop
	var/create = 1                 // How many times it'll make each thing in the list
	var/time = 5                   // How long it takes to build
	var/category = null            // Tool, Clothing, Resource, Component, Machinery or Miscellaneous
	var/sanity_check_exemption = 0
	var/apply_material = 0

	New()
		..()
		if(isnull(item_paths) && length(item_outputs) == 1) // TODO generalize to multiple outputs (currently no such manufacture recipes exist)
			var/item_type = item_outputs[1]
			var/typeinfo/obj/typeinfo = get_type_typeinfo(item_type)
			if(istype(typeinfo) && islist(typeinfo.mats))
				item_paths = list()
				for(var/mat in typeinfo.mats)
					item_paths += mat
					var/amt = typeinfo.mats[mat]
					if(isnull(amt))
						amt = 1
					item_amounts += amt
		if(isnull(item_paths))
			item_paths = list() // a bunch of places expect this to be non-null, like the sanity check
		if (!sanity_check_exemption)
			src.sanity_check()

	proc/sanity_check()
		if (item_paths.len != item_amounts.len || !isnull(item_names) && (item_paths.len != item_names.len || item_names.len != item_amounts.len))
			logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> [src.name]/[src.type] schematic requirement lists not properly configured")
			qdel(src)
			return
		if (!item_outputs.len)
			logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> [src.name]/[src.type] schematic output list not properly configured")
			qdel(src)
			return

	proc/modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		// use this if you want the outputted item to be customised in any way by the manufacturer
		var/active_controls = SEND_SIGNAL(M, COMSIG_WPANEL_STATE_CONTROLS)
		if (!HAS_FLAG(active_controls, WIRE_CONTROL_SAFETY) && M.text_bad_output_adjective.len > 0 && prob(66))
			A.name = "[pick(M.text_bad_output_adjective)] [A.name]"
			//A.quality -= rand(25,50)
		if (src.apply_material && materials.len > 0)
			A.setMaterial(getMaterial(materials[materials[1]]))
		return 1

/datum/manufacture/mechanics
	name = "Reverse-Engineered Schematic"
	item_paths = list("MET-1","CON-1","CRY-1")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/electronics/frame)
	var/frame_path = null

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		if (!(..()))
			return

		if (istype(A,/obj/item/electronics/frame/))
			var/obj/item/electronics/frame/F = A
			if (ispath(src.frame_path))
				if(src.apply_material && materials.len > 0)
					F.removeMaterial()
					var/atom/thing = new frame_path(F)
					thing.setMaterial(getMaterial(materials[materials[1]]))
					F.deconstructed_thing = thing
				else
					F.store_type = src.frame_path
				F.name = "[src.name] frame"
				F.viewstat = 2
				F.secured = 2
				F.icon_state = "dbox"
			else
				qdel(F)
				return 1

/******************** Cloner *******************/

/datum/manufacture/mechanics/clonepod
	name = "cloning pod"
	time = 30 SECONDS
	create = 1
	frame_path = /obj/machinery/clonepod

/datum/manufacture/mechanics/clonegrinder
	name = "enzymatic reclaimer"
	time = 18 SECONDS
	create = 1
	frame_path = /obj/machinery/clonegrinder

/datum/manufacture/mechanics/clone_scanner
	name = "cloning machine scanner"
	time = 30 SECONDS
	create = 1
	frame_path = /obj/machinery/clone_scanner


/******************** Loafer *******************/

/datum/manufacture/mechanics/loafer
	name = "loafer (deploy on plating)"
	item_amounts = list(5,6,4)
	time = 30 SECONDS
	create = 1
	frame_path = /obj/disposalpipe/loafer

/******************** AI Law Rack *******************/

/datum/manufacture/mechanics/lawrack
	name = "AI Law Rack Mount"
	item_paths = list("MET-1", "MET-2", "INS-1" , "CON-1")
	item_amounts = list(20,5,10,10)
	time = 60 SECONDS
	create = 1
	frame_path = /obj/machinery/lawrack

/******************** AI display (temp) *******************/

/datum/manufacture/mechanics/ai_status_display
	name = "AI display"
	time = 5 SECONDS
	create = 1
	frame_path = /obj/machinery/ai_status_display

/datum/manufacture/mechanics/gunbot
	name = "Security Robot"
	item_paths = list("POW-1","MET-2","CON-1")
	item_amounts = list(10,10,10)
	frame_path = /obj/critter/gunbot/heavy
	time = 15 SECONDS
	create = 1

/*
/datum/manufacture/iron
	// purely a test
	name = "Iron"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list("reagent-iron")
	time = 1 SECONDS
	create = 10
	category = "Resource"
*/

/datum/manufacture/crowbar
	name = "Crowbar"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/crowbar)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/screwdriver
	name = "Screwdriver"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/screwdriver)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/wirecutters
	name = "Wirecutters"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/wirecutters)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/wrench
	name = "Wrench"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/wrench)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/flashlight
	name = "Flashlight"
	item_paths = list("MET-1","CON-1","CRY-1")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/device/light/flashlight)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/vuvuzela
	name = "Vuvuzela"
	item_paths = list("ALL")
	item_amounts = list(1)
	item_outputs = list(/obj/item/instrument/vuvuzela)
	time = 5 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/harmonica
	name = "Harmonica"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/instrument/harmonica)
	time = 5 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/bottle
	name = "Glass Bottle"
	item_paths = list("CRY-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/reagent_containers/food/drinks/bottle/soda)
	time = 4 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/saxophone
	name = "Saxophone"
	item_paths = list("MET-2")
	item_amounts = list(15)
	item_outputs = list(/obj/item/instrument/saxophone)
	time = 7 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/whistle
	name = "Whistle"
	item_paths = list("MET-3")
	item_amounts = list(5)
	item_outputs = list(/obj/item/instrument/whistle)
	time = 3 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/trumpet
	name = "Trumpet"
	item_paths = list("MET-2")
	item_amounts = list(10)
	item_outputs = list(/obj/item/instrument/trumpet)
	time = 6 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/bagpipe
	name = "Bagpipe"
	item_paths = list("FAB-1", "MET-2")
	item_amounts = list(10, 25)
	item_outputs = list(/obj/item/instrument/bagpipe)
	time = 5 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/bikehorn
	name = "Bicycle Horn"
	item_paths = list("ALL")
	item_amounts = list(1)
	item_outputs = list(/obj/item/instrument/bikehorn)
	time = 5 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/stunrounds
	name = ".38 Stunner Rounds"
	item_paths = list("MET-1","CON-1", "CRY-1")
	item_amounts = list(3,2,2)
	item_outputs = list(/obj/item/ammo/bullets/a38/stun)
	time = 20 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/bullet_22
	name = ".22 Bullets"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(30,24)
	item_outputs = list(/obj/item/ammo/bullets/bullet_22)
	time = 30 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/bullet_12g_nail
	name = "12 gauge nailshot"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(40,30)
	item_outputs = list(/obj/item/ammo/bullets/nails)
	time = 30 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/bullet_smoke
	name = "40mm Smoke Grenade"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(30,25)
	item_outputs = list(/obj/item/ammo/bullets/smoke)
	time = 35 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/extinguisher
	name = "Fire Extinguisher"
	item_paths = list("MET-2","CRY-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/extinguisher)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/welder
	name = "Welding Tool"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/weldingtool)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/soldering
	name = "Soldering Iron"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(1,2)
	item_outputs = list(/obj/item/electronics/soldering)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/stapler
	name = "Staple Gun"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(2,1)
	item_outputs = list(/obj/item/staple_gun)
	time = 10 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/multitool
	name = "Multi Tool"
	item_outputs = list(/obj/item/device/multitool)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/weldingmask
	name = "Welding Mask"
	item_paths = list("MET-2","CRY-1")
	item_amounts = list(2,2)
	item_outputs = list(/obj/item/clothing/head/helmet/welding)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/light_bulb
	name = "Light Bulb Box"
	item_paths = list("CRY-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs)
	time = 4 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/red_bulb
	name = "Red Light Bulb Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/red)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/yellow_bulb
	name = "Yellow Light Bulb Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/yellow)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/green_bulb
	name = "Green Light Bulb Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/green)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/cyan_bulb
	name = "Cyan Light Bulb Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/cyan)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/blue_bulb
	name = "Blue Light Bulb Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/blue)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/purple_bulb
	name = "Purple Light Bulb Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/purple)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/blacklight_bulb
	name = "Blacklight Bulb Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/blacklight)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/light_tube
	name = "Light Tube Box"
	item_paths = list("CRY-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes)
	time = 4 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/red_tube
	name = "Red Light Tube Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/red)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/yellow_tube
	name = "Yellow Light Tube Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/yellow)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/green_tube
	name = "Green Light Tube Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/green)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/cyan_tube
	name = "Cyan Light Tube Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/cyan)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/blue_tube
	name = "Blue Light Tube Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/blue)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/purple_tube
	name = "Purple Light Tube Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/purple)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/blacklight_tube
	name = "Blacklight Tube Box"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/blacklight)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/table_folding
	name = "Folding Table"
	item_paths = list("MET-1","ALL")
	item_amounts = list(1,2)
	item_outputs = list(/obj/item/furniture_parts/table/folding)
	time = 20 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/metal
	name = "Metal Sheet"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/sheet)
	time = 2 SECONDS
	create = 1
	category = "Resource"
	apply_material = 1

/datum/manufacture/metalR
	name = "Reinforced Metal"
	item_paths = list("MET-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/sheet)
	time = 12 SECONDS
	create = 1
	category = "Resource"
	apply_material = 1

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		..()
		var/obj/item/sheet/S = A
		S.set_reinforcement(getMaterial(materials["MET-1"]))

/datum/manufacture/glass
	name = "Glass Panel"
	item_paths = list("CRY-1")
	item_amounts = list(5)
	item_outputs = list(/obj/item/sheet)
	time = 8 SECONDS
	create = 5
	category = "Resource"
	apply_material = 1

/datum/manufacture/glassR
	name = "Reinforced Glass Panel"
	item_paths = list("CRY-1","MET-2")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/sheet/glass/reinforced)
	time = 12 SECONDS
	create = 1
	category = "Resource"
	apply_material = 1

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		..()
		var/obj/item/sheet/S = A
		S.set_reinforcement(getMaterial(materials["CRY-1"]))

/datum/manufacture/rods2
	name = "Metal Rods (x2)"
	item_paths = list("MET-2")
	item_amounts = list(1)
	item_outputs = list(/obj/item/rods)
	time = 3 SECONDS
	category = "Resource"
	apply_material = 1

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A)
		..()
		var/obj/item/sheet/S = A // this way they are instantly stacked rather than just 2 rods
		S.amount = 2
		S.inventory_counter.update_number(S.amount)

/datum/manufacture/atmos_can
	name = "Portable Gas Canister"
	item_paths = list("MET-2")
	item_amounts = list(3)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/fluidcanister
	name = "Fluid Canister"
	item_paths = list("MET-2")
	item_amounts = list(15)
	item_outputs = list(/obj/machinery/fluid_canister)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/shieldgen
	name = "Energy-Shield Gen."
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(20,10,5)
	item_outputs = list(/obj/machinery/shieldgenerator/energy_shield/nocell)
	time = 60 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/doorshieldgen
	name = "Door-Shield Gen."
	item_paths = list("MET-2","CON-1")
	item_amounts = list(20,15)
	item_outputs = list(/obj/machinery/shieldgenerator/energy_shield/doorlink/nocell)
	time = 60 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/meteorshieldgen
	name = "Meteor-Shield Gen."
	item_paths = list("MET-1","MET-2","CON-1")
	item_amounts = list(10,10,10)
	item_outputs = list(/obj/machinery/shieldgenerator/meteorshield/nocell)
	time = 30 SECONDS
	create = 1
	category = "Machinery"

//// cogwerks - gas extraction stuff


/datum/manufacture/air_can
	name = "Air Canister"
	item_paths = list("MET-2","molitz","viscerite")
	item_amounts = list(3,4,12)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/air)
	time = 50 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/air_can/large
	name = "High-Volume Air Canister"
	item_paths = list("MET-2","molitz","viscerite")
	item_amounts = list(3,10,30)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/air/large)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/co2_can
	name = "CO2 Canister"
	item_paths = list("MET-2","char")
	item_amounts = list(3,10)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/o2_can
	name = "O2 Canister"
	item_paths = list("MET-2","molitz")
	item_amounts = list(3,10)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/plasma_can
	name = "Plasma Canister"
	item_paths = list("MET-2","plasmastone")
	item_amounts = list(3,10)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/toxins)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/n2_can
	name = "N2 Canister"
	item_paths = list("MET-2","viscerite")
	item_amounts = list(3,10)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/n2o_can
	name = "N2O Canister"
	item_paths = list("MET-2","koshmarite")
	item_amounts = list(3,10)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/sleeping_agent)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/red_o2_grenade
	name = "Red Oxygen Grenade"
	item_paths = list("MET-2","CON-1","molitz","char")
	item_amounts = list(2,2,10,1)
	item_outputs = list(/obj/item/old_grenade/oxygen)
	time = 10 SECONDS
	create = 1
	category = "Tool"

////////////////////////////////

/datum/manufacture/player_module
	name = "Vending Module"
	item_paths = list("CON-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/machineboard/vending/player)
	time = 5 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cable
	name = "Electrical Cable Coil"
	item_paths = list("INS-1", "CON-1")
	item_amounts = list(10, 10)
	item_outputs = list(/obj/item/cable_coil)
	time = 3 SECONDS
	create = 1
	category = "Resource"
	apply_material = 0

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A,var/list/materials)
		..()
		var/obj/item/cable_coil/coil = A
		coil.setInsulator(getMaterial(materials["INS-1"]))
		coil.setConductor(getMaterial(materials["CON-1"]))
		return 1

/datum/manufacture/RCD
	name = "Rapid Construction Device"
	item_paths = list("MET-3", "CRY-2", "CON-2", "POW-2")
	item_amounts = list(20, 10, 10, 10)
	item_outputs = list(/obj/item/rcd)
	time = 90 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/RCDammo
	name = "Compressed Matter Cartridge"
	item_paths = list("DEN-1")
	item_amounts = list(30)
	item_outputs = list(/obj/item/rcd_ammo)
	time = 10 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/RCDammomedium
	name = "Medium Compressed Matter Cartridge"
	item_paths = list("DEN-2")
	item_amounts = list(30)
	item_outputs = list(/obj/item/rcd_ammo/medium)
	time = 20 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/RCDammolarge
	name = "Large Compressed Matter Cartridge"
	item_paths = list("uqill")
	item_amounts = list(20)
	item_outputs = list(/obj/item/rcd_ammo/big)
	time = 30 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/sds
	name = "Syndicate Destruction System"
	item_paths = list("MET-3","DEN-1","CON-1")
	item_amounts = list(16,12,8)
	item_outputs = list(/obj/item/syndicate_destruction_system)
	time = 90 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/civilian_headset
	name = "Civilian Headset"
	item_paths = list("MET-1", "CON-1")
	item_amounts = list(2, 1)
	item_outputs = list(/obj/item/device/radio/headset)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_assistant
	name = "Staff Assistant Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/rank)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit
	name = "Grey Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/color/grey)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/shoes
	name = "Black Shoes"
	item_paths = list("FAB-1")
	item_amounts = list(3)
	item_outputs = list(/obj/item/clothing/shoes/black)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/shoes_white
	name = "White Shoes"
	item_paths = list("FAB-1")
	item_amounts = list(3)
	item_outputs = list(/obj/item/clothing/shoes/white)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/flippers
	name = "Flippers"
	item_paths = list("RUB")
	item_amounts = list(5)
	item_outputs = list(/obj/item/clothing/shoes/flippers)
	time = 8 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/cleaner_grenade
	name = "Cleaner Grenade"
	item_paths = list("INS-1", "CRY-1", "molitz", "ice")
	item_amounts = list(8, 8, 10, 10)
	item_outputs = list(/obj/item/chem_grenade/cleaner)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/******************** Medical **************************/

/datum/manufacture/scalpel
	name = "Scalpel"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/scalpel)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/circular_saw
	name = "Circular Saw"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/circular_saw)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/surgical_scissors
	name = "Surgical Scissors"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/scissors/surgical_scissors)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/hemostat
	name = "Hemostat"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/hemostat)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/surgical_spoon
	name = "Enucleation Spoon"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/surgical_spoon)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/suture
	name = "Suture"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/suture)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/deafhs
	name = "Auditory Headset"
	item_paths = list("CON-1","CRY-1")
	item_amounts = list(3,3)
	item_outputs = list(/obj/item/device/radio/headset/deaf)
	time = 40 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/visor
	name = "VISOR Prosthesis"
	item_paths = list("CON-1","CRY-1")
	item_amounts = list(3,3)
	item_outputs = list(/obj/item/clothing/glasses/visor)
	time = 40 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/glasses
	name = "Prescription Glasses"
	item_paths = list("MET-1","CRY-1")
	item_amounts = list(1,2)
	item_outputs = list(/obj/item/clothing/glasses/regular)
	time = 20 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hypospray
	name = "Hypospray"
	item_paths = list("MET-1","CON-1","CRY-1")
	item_amounts = list(2,2,2)
	item_outputs = list(/obj/item/reagent_containers/hypospray)
	time = 40 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/prodocs
	name = "ProDoc Healthgoggles"
	item_paths = list("MET-1","CRY-1")
	item_amounts = list(1,2)
	item_outputs = list(/obj/item/clothing/glasses/healthgoggles)
	time = 20 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/latex_gloves
	name = "Latex Gloves"
	item_paths = list("FAB-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/clothing/gloves/latex)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/body_bag
	name = "Body Bag"
	item_paths = list("FAB-1")
	item_amounts = list(3)
	item_outputs = list(/obj/item/body_bag)
	time = 15 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/cyberheart
	name = "Cyberheart"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(3,3,2)
	item_outputs = list(/obj/item/organ/heart/cyber)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberbutt
	name = "Cyberbutt"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(2,2,2)
	item_outputs = list(/obj/item/clothing/head/butt/cyberbutt)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cardboard_ai
	name = "Cardboard 'AI'"
	item_paths = list("cardboard")
	item_amounts = list(1)
	item_outputs = list(/obj/item/clothing/suit/cardboard_box/ai)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/cyberappendix
	name = "Cyberappendix"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/organ/appendix/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberpancreas
	name = "Cyberpancreas"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/organ/pancreas/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberspleen
	name = "Cyberspleen"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/organ/spleen/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberintestines
	name = "Cyberintestines"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/organ/intestines/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberstomach
	name = "Cyberstomach"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/organ/stomach/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberkidney
	name = "Cyberkidney"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/organ/kidney/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberliver
	name = "Cyberliver"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/organ/liver/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberlung_left
	name = "Left Cyberlung"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/organ/lung/cyber/left)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberlung_right
	name = "Right Cyberlung"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/organ/lung/cyber/right)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye
	name = "Cybereye"
	item_paths = list("CRY-1","MET-1","CON-1","INS-1")
	item_amounts = list(2,1,2,1)
	item_outputs = list(/obj/item/organ/eye/cyber)
	time = 20 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_sunglass
	name = "Polarized Cybereye"
	item_paths = list("CRY-1","MET-1","CON-1","INS-1")
	item_amounts = list(3,1,2,1)
	item_outputs = list(/obj/item/organ/eye/cyber/sunglass)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_sechud
	name = "Security HUD Cybereye"
	item_paths = list("CRY-1","MET-1","CON-1","INS-1")
	item_amounts = list(3,1,2,1)
	item_outputs = list(/obj/item/organ/eye/cyber/sechud)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_thermal
	name = "Thermal Imager Cybereye"
	item_paths = list("CRY-1","MET-1","CON-1","INS-1")
	item_amounts = list(3,1,2,1)
	item_outputs = list(/obj/item/organ/eye/cyber/thermal)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_meson
	name = "Mesonic Imager Cybereye"
	item_paths = list("CRY-1","MET-1","CON-1","INS-1")
	item_amounts = list(3,1,2,1)
	item_outputs = list(/obj/item/organ/eye/cyber/meson)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_spectro
	name = "Spectroscopic Imager Cybereye"
	item_paths = list("CRY-1","MET-1","CON-1","INS-1")
	item_amounts = list(3,1,2,1)
	item_outputs = list(/obj/item/organ/eye/cyber/spectro)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_prodoc
	name = "ProDoc Healthview Cybereye"
	item_paths = list("CRY-1","MET-1","CON-1","INS-1")
	item_amounts = list(3,1,2,1)
	item_outputs = list(/obj/item/organ/eye/cyber/prodoc)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_camera
	name = "Camera Cybereye"
	item_paths = list("CRY-1","MET-1","CON-1","INS-1")
	item_amounts = list(3,1,2,1)
	item_outputs = list(/obj/item/organ/eye/cyber/camera)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_laser
	name = "Laser Cybereye"
	item_paths = list("CRY-1","MET-1","CON-1","INS-1","erebite")
	item_amounts = list(3,1,2,1,1)
	item_outputs = list(/obj/item/organ/eye/cyber/laser)
	time = 40 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/implant_health
	name = "Health Monitor Implant"
	item_paths = list("CON-1","CRY-1")
	item_amounts = list(3,3)
	item_outputs = list(/obj/item/implantcase/health)
	time = 40 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/implant_antirot
	name = "Rotbusttec Implant"
	item_paths = list("CON-1","CRY-1")
	item_amounts = list(2,2)
	item_outputs = list(/obj/item/implantcase/antirot)
	time = 30 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/stress_ball
	name = "Stress Ball"
	item_paths = list("FAB-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/toy/plush/small/stress_ball)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/floppydisk //Cloning disks
	name = "Floppy Disk"
	item_paths = list("MET-1","CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/disk/data/floppy)
	time = 5 SECONDS
	create = 1
	category = "Resource"

/******************** Robotics **************************/

/datum/manufacture/robo_frame
	name = "Cyborg Frame"
	item_paths = list("MET-2")
	item_amounts = list(18)
	item_outputs = list(/obj/item/parts/robot_parts/robot_frame)
	time = 45 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/full_cyborg_standard
	name = "Standard Cyborg Parts"
	item_paths = list("MET-2")
	item_amounts = list(48)
	item_outputs = list(/obj/item/parts/robot_parts/chest/standard,/obj/item/parts/robot_parts/head/standard,
/obj/item/parts/robot_parts/arm/right/standard,/obj/item/parts/robot_parts/arm/left/standard,
/obj/item/parts/robot_parts/leg/right/standard,/obj/item/parts/robot_parts/leg/left/standard)
	time = 120 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/full_cyborg_light
	name = "Light Cyborg Parts"
	item_paths = list("MET-2")
	item_amounts = list(24)
	item_outputs = list(/obj/item/parts/robot_parts/chest/light,/obj/item/parts/robot_parts/head/light,
/obj/item/parts/robot_parts/arm/right/light,/obj/item/parts/robot_parts/arm/left/light,
/obj/item/parts/robot_parts/leg/right/light,/obj/item/parts/robot_parts/leg/left/light)
	time = 62 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_chest
	name = "Cyborg Chest"
	item_paths = list("MET-2")
	item_amounts = list(12)
	item_outputs = list(/obj/item/parts/robot_parts/chest/standard)
	time = 30 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_chest_light
	name = "Light Cyborg Chest"
	item_paths = list("MET-2")
	item_amounts = list(6)
	item_outputs = list(/obj/item/parts/robot_parts/chest/light)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_head
	name = "Cyborg Head"
	item_paths = list("MET-2")
	item_amounts = list(12)
	item_outputs = list(/obj/item/parts/robot_parts/head/standard)
	time = 30 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_head_screen
	name = "Cyborg Screen Head"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(6,2,6)
	item_outputs = list(/obj/item/parts/robot_parts/head/screen)
	time = 24 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_head_light
	name = "Light Cyborg Head"
	item_paths = list("MET-1")
	item_amounts = list(6)
	item_outputs = list(/obj/item/parts/robot_parts/head/light)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_arm_r
	name = "Cyborg Arm (Right)"
	item_paths = list("MET-2")
	item_amounts = list(6)
	item_outputs = list(/obj/item/parts/robot_parts/arm/right/standard)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_arm_r_light
	name = "Light Cyborg Arm (Right)"
	item_paths = list("MET-1")
	item_amounts = list(3)
	item_outputs = list(/obj/item/parts/robot_parts/arm/right/light)
	time = 8 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_arm_l
	name = "Cyborg Arm (Left)"
	item_paths = list("MET-2")
	item_amounts = list(6)
	item_outputs = list(/obj/item/parts/robot_parts/arm/left/standard)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_arm_l_light
	name = "Light Cyborg Arm (Left)"
	item_paths = list("MET-1")
	item_amounts = list(3)
	item_outputs = list(/obj/item/parts/robot_parts/arm/left/light)
	time = 8 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_leg_r
	name = "Cyborg Leg (Right)"
	item_paths = list("MET-2")
	item_amounts = list(6)
	item_outputs = list(/obj/item/parts/robot_parts/leg/right/standard)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_leg_r_light
	name = "Light Cyborg Leg (Right)"
	item_paths = list("MET-1")
	item_amounts = list(3)
	item_outputs = list(/obj/item/parts/robot_parts/leg/right/light)
	time = 8 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_leg_l
	name = "Cyborg Leg (Left)"
	item_paths = list("MET-2")
	item_amounts = list(6)
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/standard)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_leg_l_light
	name = "Light Cyborg Leg (Left)"
	item_paths = list("MET-1")
	item_amounts = list(3)
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/light)
	time = 8 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_leg_treads
	name = "Cyborg Treads"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(12,6)
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/treads, /obj/item/parts/robot_parts/leg/right/treads)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robo_module
	name = "Blank Cyborg Module"
	item_paths = list("CON-1","ALL")
	item_amounts = list(2,3)
	item_outputs = list(/obj/item/robot_module)
	time = 40 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/powercell
	name = "Power Cell"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(4,4,4)
	item_outputs = list(/obj/item/cell/supercell)
	time = 30 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/powercellE
	name = "Erebite Power Cell"
	item_paths = list("MET-1","ALL","erebite")
	item_amounts = list(4,4,2)
	item_outputs = list(/obj/item/cell/erebite)
	time = 45 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/powercellC
	name = "Cerenkite Power Cell"
	item_paths = list("MET-1","ALL","cerenkite")
	item_amounts = list(4,4,2)
	item_outputs = list(/obj/item/cell/cerenkite)
	time = 45 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/powercellH
	name = "Hyper Capacity Power Cell"
	item_paths = list("DEN-2", "CON-2", "POW-2")
	item_amounts = list(5,10,10)
	item_outputs = list(/obj/item/cell/hypercell)
	time = 120 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/core_frame
	name = "AI Core Frame"
	item_paths = list("MET-2")
	item_amounts = list(20)
	item_outputs = list(/obj/ai_core_frame)
	time = 50 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/shell_frame
	name = "AI Shell Frame"
	item_paths = list("MET-2")
	item_amounts = list(12)
	item_outputs = list(/obj/item/shell_frame)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/ai_interface
	name = "AI Interface Board"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(3,5,2)
	item_outputs = list(/obj/item/ai_interface)
	time = 35 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/latejoin_brain
	name = "Spontaneous Intelligence Creation Core"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(6,5,3)
	item_outputs = list(/obj/item/organ/brain/latejoin)
	time = 35 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/shell_cell
	name = "AI Shell Power Cell"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(2,2,1)
	item_outputs = list(/obj/item/cell/shell_cell)
	time = 20 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/flash
	name = "Flash"
	item_paths = list("MET-1","CON-1","CRY-1")
	item_amounts = list(3,5,5)
	item_outputs = list(/obj/item/device/flash)
	time = 15 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/borg_linker
	name = "AI Linker"
	item_paths = list("MET-1","CRY-1","CON-1")
	item_amounts = list(2,1,2)
	item_outputs = list(/obj/item/device/borg_linker)
	time = 15 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/asimov_laws
	name = "Standard Asimov Law Module Set"
	item_paths = list("MET-2")
	item_amounts = list(30)
	item_outputs = list(/obj/item/aiModule/asimov1,/obj/item/aiModule/asimov2,/obj/item/aiModule/asimov3)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/corporate_laws
	name = "Nanotrasen Law Module Set"
	item_paths = list("MET-2")
	item_amounts = list(30)
	item_outputs = list(/obj/item/aiModule/nanotrasen1,/obj/item/aiModule/nanotrasen2,/obj/item/aiModule/nanotrasen3)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robocop_laws
	name = "RoboCop Law Module Set"
	item_paths = list("MET-2")
	item_amounts = list(40)
	item_outputs = list(/obj/item/aiModule/robocop1,/obj/item/aiModule/robocop2,/obj/item/aiModule/robocop3,/obj/item/aiModule/robocop4)
	time = 60 SECONDS
	create = 1
	category = "Component"

// Robotics Research

/datum/manufacture/implanter
	name = "Implanter"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/implanter)
	time = 3 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/secbot
	name = "Security Drone"
	item_paths = list("MET-2","CON-2","POW-1")
	item_amounts = list(30,20,20)
	item_outputs = list(/obj/machinery/bot/secbot)
	time = 120 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/floorbot
	name = "Construction Drone"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(15,10,5)
	item_outputs = list(/obj/machinery/bot/floorbot)
	time = 60 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/medbot
	name = "Medical Drone"
	item_paths = list("MET-1","CON-1","POW-1")
	item_amounts = list(20,15,5)
	item_outputs = list(/obj/machinery/bot/medbot)
	time = 90 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/firebot
	name = "Firefighting Drone"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(15,10,5)
	item_outputs = list(/obj/machinery/bot/firebot)
	time = 60 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/cleanbot
	name = "Sanitation Drone"
	item_paths = list("MET-1","CON-1","ALL")
	item_amounts = list(15,10,5)
	item_outputs = list(/obj/machinery/bot/cleanbot)
	time = 60 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/digbot
	name = "Mining Drone"
	item_paths = list("MET-1","MET-2","CON-1","ALL")
	item_amounts = list(15,5,10,5)
	item_outputs = list(/obj/machinery/bot/mining)
	time = 0 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/robup_jetpack
	name = "Propulsion Upgrade"
	item_paths = list("CON-1","MET-1")
	item_amounts = list(3,5)
	item_outputs = list(/obj/item/roboupgrade/jetpack)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_speed
	name = "Speed Upgrade"
	item_paths = list("CON-1","CRY-1")
	item_amounts = list(3,5)
	item_outputs = list(/obj/item/roboupgrade/speed)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_recharge
	name = "Recharge Pack"
	item_paths = list("CON-1")
	item_amounts = list(5)
	item_outputs = list(/obj/item/roboupgrade/rechargepack)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_repairpack
	name = "Repair Pack"
	item_paths = list("CON-1")
	item_amounts = list(5)
	item_outputs = list(/obj/item/roboupgrade/repairpack)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_physshield
	name = "Force Shield Upgrade"
	item_paths = list("CON-2", "MET-2", "POW-2")
	item_amounts = list(2,10,2)
	item_outputs = list(/obj/item/roboupgrade/physshield)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_fireshield
	name = "Heat Shield Upgrade"
	item_paths = list("CON-2","CRY-1")
	item_amounts = list(2,10)
	item_outputs = list(/obj/item/roboupgrade/fireshield)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_aware
	name = "Recovery Upgrade"
	item_paths = list("CON-2","CRY-1","CON-1")
	item_amounts = list(2,5,5)
	item_outputs = list(/obj/item/roboupgrade/aware)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_efficiency
	name = "Efficiency Upgrade"
	item_paths = list("DEN-1","CON-2")
	item_amounts = list(3,10)
	item_outputs = list(/obj/item/roboupgrade/efficiency)
	time = 120 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_repair
	name = "Self-Repair Upgrade"
	item_paths = list("DEN-1","MET-3")
	item_amounts = list(3,10)
	item_outputs = list(/obj/item/roboupgrade/repair)
	time = 120 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_teleport
	name = "Teleport Upgrade"
	item_paths = list("CON-1","DEN-1", "POW-2") //Okay enough roundstart teleportborgs. Fuck.
	item_amounts = list(10,1, 10)
	item_outputs = list(/obj/item/roboupgrade/teleport)
	time = 120 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_expand
	name = "Expansion Upgrade"
	item_paths = list("CRY-2","POW-3")
	item_amounts = list(3,1)
	item_outputs = list(/obj/item/roboupgrade/expand)
	time = 120 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_meson
	name = "Optical Meson Upgrade"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(2,4)
	item_outputs = list(/obj/item/roboupgrade/opticmeson)
	time = 90 SECONDS
	create = 1
	category = "Component"
/* shit done be broked
/datum/manufacture/robup_thermal
	name = "Optical Thermal Upgrade"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(4,8)
	item_outputs = list(/obj/item/roboupgrade/opticthermal)
	time = 90 SECONDS
	create = 1
	category = "Component"
*/
/datum/manufacture/robup_healthgoggles
	name = "ProDoc Healthgoggle Upgrade"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(4,6)
	item_outputs = list(/obj/item/roboupgrade/healthgoggles)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_sechudgoggles
	name = "Security HUD Upgrade"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(4,6)
	item_outputs = list(/obj/item/roboupgrade/sechudgoggles)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_spectro
	name = "Spectroscopic Scanner Upgrade"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(4,6)
	item_outputs = list(/obj/item/roboupgrade/spectro)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_visualizer
	name = "Construction Visualizer"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(4,6)
	item_outputs = list(/obj/item/roboupgrade/visualizer)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/implant_robotalk
	name = "Machine Translator Implant"
	item_paths = list("CON-1","CRY-1")
	item_amounts = list(3,3)
	item_outputs = list(/obj/item/implantcase/robotalk)
	time = 40 SECONDS
	create = 1
	category = "Resource"


/datum/manufacture/sbradio
	name = "Station Bounced Radio"
	item_paths = list("CON-1","CRY-1")
	item_amounts = list(2,2)
	item_outputs = list(/obj/item/device/radio)
	time = 20 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/thrusters
	name = "Alastor Pattern Thrusters"
	item_paths = list("MET-2")
	item_amounts = list(50)
	item_outputs = list(/obj/item/parts/robot_parts/leg/right/thruster,/obj/item/parts/robot_parts/leg/left/thruster)
	time = 120 SECONDS
	create = 1
	category = "Component"

/******************** Science **************************/

/datum/manufacture/biosuit
	name = "Biosuit Set"
	item_paths = list("FAB-1","CRY-1")
	item_amounts = list(5,2)
	item_outputs = list(/obj/item/clothing/suit/bio_suit,/obj/item/clothing/head/bio_hood)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/spectrogoggles
	name = "Spectroscopic Scanner Goggles"
	item_paths = list("MET-1","CRY-1")
	item_amounts = list(1,2)
	item_outputs = list(/obj/item/clothing/glasses/spectro)
	time = 20 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/gasmask
	name = "Gas Mask"
	item_paths = list("FAB-1", "MET-2", "CRY-1")
	item_amounts = list(2,4,2)
	item_outputs = list(/obj/item/clothing/mask/gas)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/dropper
	name ="Dropper"
	item_paths = list("INS-1", "CRY-1")
	item_amounts = list(1,2)
	item_outputs = list(/obj/item/reagent_containers/dropper)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/mechdropper
	name ="Mechanical Dropper"
	item_paths = list("MET-1", "CON-1")
	item_amounts = list(3,3)
	item_outputs = list(/obj/item/reagent_containers/dropper/mechanical)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/gps
	name ="Space GPS"
	item_paths = list("MET-1", "CON-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/device/gps)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/reagentscanner
	name ="Reagent Scanner"
	item_paths = list("MET-1", "CON-1", "CRY-1")
	item_amounts = list(2,2,1)
	item_outputs = list(/obj/item/device/reagentscanner)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/artifactforms
	name ="Artifact Analysis Forms"
	item_paths = list("MET-1", "FAB-1")
	item_amounts = list(2,5)
	item_outputs = list(/obj/item/paper_bin/artifact_paper)
	time = 10 SECONDS
	create = 1
	category = "Resource"

// Mining Gear
#ifndef UNDERWATER_MAP
/datum/manufacture/mining_magnet
	name = "Mining Magnet Replacement Parts"
	item_paths = list("DEN-1","MET-3","CON-2")
	item_amounts = list(5,30,30)
	item_outputs = list(/obj/item/magnet_parts)
	time = 120 SECONDS
	create = 1
	category = "Component"
#endif

/datum/manufacture/pick
	name = "Pickaxe"
	item_paths = list("MET-2")
	item_amounts = list(1)
	item_outputs = list(/obj/item/mining_tool)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/powerpick
	name = "Powered Pick"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(2,5)
	item_outputs = list(/obj/item/mining_tool/power_pick)
	time = 10 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/blastchargeslite
	name = "Low-Yield Mining Explosives (x5)"
	item_paths = list("MET-1","CRY-1","CON-1")
	item_amounts = list(3,3,7)
	item_outputs = list(/obj/item/breaching_charge/mining/light)
	time = 40 SECONDS
	create = 5
	category = "Resource"

/datum/manufacture/blastcharges
	name = "Mining Explosives (x5)"
	item_paths = list("MET-1","CRY-1","CON-1")
	item_amounts = list(7,7,15)
	item_outputs = list(/obj/item/breaching_charge/mining)
	time = 60 SECONDS
	create = 5
	category = "Resource"

/datum/manufacture/powerhammer
	name = "Power Hammer"
	item_paths = list("DEN-1","CON-1")
	item_amounts = list(1,8)
	item_outputs = list(/obj/item/mining_tool/powerhammer)
	time = 70 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/drill
	name = "Laser Drill"
	item_paths = list("MET-2","MET-3","CON-2")
	item_amounts = list(15,7,10)
	item_outputs = list(/obj/item/mining_tool/drill)
	time = 90 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/conc_gloves
	name = "Concussive Gauntlets"
	item_paths = list("MET-3","CON-2","POW-1")
	item_amounts = list(15,15,2)
	item_outputs = list(/obj/item/clothing/gloves/concussive)
	time = 120 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/ore_accumulator
	name = "Mineral Accumulator"
	item_paths = list("MET-2","CON-2","DEN-1")
	item_amounts = list(25,15,2)
	item_outputs = list(/obj/machinery/oreaccumulator)
	time = 120 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/eyes_meson
	name = "Optical Meson Scanner"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(3,2)
	item_outputs = list(/obj/item/clothing/glasses/meson)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/geoscanner
	name = "Geological Scanner"
	item_paths = list("MET-1","CON-1","CRY-1")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/oreprospector)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/ore_scoop
	name = "Ore Scoop"
	item_paths = list("MET-1","CON-1","CRY-1")
	item_names = list("Metal","Conductive Material","Crystal")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/ore_scoop)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/geigercounter
	name = "Geiger Counter"
	item_paths = list("MET-1","CON-1","CRY-1")
	item_amounts = list(1,1,1)
	item_outputs = list(/obj/item/device/geiger)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/industrialarmor
	name = "Industrial Space Armor Set"
	item_paths = list("MET-3","CON-2","CRY-2")
	item_amounts = list(15,10,5)
	item_outputs = list(/obj/item/clothing/suit/space/industrial,/obj/item/clothing/head/helmet/space/industrial)
	time = 90 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/industrialboots
	name = "Mechanised Boots"
	item_outputs = list(/obj/item/clothing/shoes/industrial)
	time = 40 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jetpackmkII
	name = "Jetpack MKII"
	item_paths = list("MET-2","CON-2","POW-1")
	item_amounts = list(15,10,5)
	item_outputs = list(/obj/item/tank/jetpack/jetpackmk2)
	time = 40 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/breathmask
	name = "Breath Mask"
	item_paths = list("FAB-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/clothing/mask/breath)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/patch
	name = "Chemical Patch"
	item_paths = list("FAB-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/reagent_containers/patch)
	time = 5 SECONDS
	create = 2
	category = "Resource"

/datum/manufacture/mender
	name = "Auto Mender"
	item_paths = list("MET-2","CRY-1", "gold")
	item_amounts = list(5,4, 5)
	item_outputs = list(/obj/item/reagent_containers/mender)
	time = 30 SECONDS
	create = 2
	category = "Resource"

/datum/manufacture/penlight
	name = "Penlight"
	item_paths = list("MET-1","CRY-1")
	item_amounts = list(1,1)
	item_outputs = list(/obj/item/device/light/flashlight/penlight)
	time = 2 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/stethoscope
	name = "Stethoscope"
	item_paths = list("MET-1","CRY-1")
	item_amounts = list(2,1)
	item_outputs = list(/obj/item/medical/medicaldiagnosis/stethoscope)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/spacesuit
	name = "Space Suit Set"
	item_paths = list("FAB-1","MET-1","CRY-1")
	item_amounts = list(3,3,2)
	item_outputs = list(/obj/item/clothing/suit/space,/obj/item/clothing/head/helmet/space)
	time = 15 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/engspacesuit
	name = "Engineering Space Suit Set"
	item_paths = list("FAB-1","MET-1","CRY-1")
	item_amounts = list(3,3,2)
	item_outputs = list(/obj/item/clothing/suit/space/engineer,/obj/item/clothing/head/helmet/space/engineer)
	time = 15 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/engdivesuit
	name = "Engineering Diving Suit Set"
	item_paths = list("FAB-1","MET-1","CRY-1")
	item_amounts = list(3,3,2)
	item_outputs = list(/obj/item/clothing/suit/space/diving/engineering,/obj/item/clothing/head/helmet/space/engineer/diving/engineering)
	time = 15 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/oresatchel
	name = "Ore Satchel"
	item_paths = list("FAB-1")
	item_amounts = list(5)
	item_outputs = list(/obj/item/satchel/mining)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/oresatchelL
	name = "Large Ore Satchel"
	item_paths = list("FAB-1","MET-3")
	item_amounts = list(25,3)
	item_outputs = list(/obj/item/satchel/mining/large)
	time = 15 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/jetpack
	name = "Jetpack"
	item_paths = list("MET-3","CON-2")
	item_amounts = list(10,20)
	item_outputs = list(/obj/item/tank/jetpack)
	time = 60 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/microjetpack
	name = "Micro Jetpack"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(5,10)
	item_outputs = list(/obj/item/tank/jetpack/micro)
	time = 30 SECONDS
	create = 1
	category = "Clothing"

/// Ship Items -- OLD COMPONENTS

/datum/manufacture/engine
	name = "Warp-1 Engine"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(3,5)
	item_outputs = list(/obj/item/shipcomponent/engine)
	time = 10 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/engine2
	name = "Helios Mark-II Engine"
	item_paths = list("MET-2","MET-3","CON-2")
	item_amounts = list(20,10,15)
	item_outputs = list(/obj/item/shipcomponent/engine/helios)
	time = 90 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/engine3
	name = "Hermes 3.0 Engine"
	item_paths = list("MET-3","CON-2","POW-1")
	item_amounts = list(20,20,5)
	item_outputs = list(/obj/item/shipcomponent/engine/hermes)
	time = 120 SECONDS
	create = 1
	category = "Resource"


/datum/manufacture/gps
	name = "Ship's Navigation GPS"
	item_paths = list("MET-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/gps)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/cargohold
	name = "Cargo Hold"
	item_paths = list("MET-2")
	item_amounts = list(20)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/cargo)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/orescoop
	name = "Alloyed Solutions Ore Scoop/Hold"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(20, 10)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/orescoop)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/communications
	name = "Robustco Communication Array"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(10, 20)
	item_outputs = list(/obj/item/shipcomponent/communications)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/communications/mining
	name = "NT Magnet Link Array"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(10, 20)
	item_outputs = list(/obj/item/shipcomponent/communications/mining)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/conclave
	name = "Conclave A-1984 Sensor System"
	item_paths = list("POW-1","CRY-1","CON-2")
	item_amounts = list(1,5,2)
	item_outputs = list(/obj/item/shipcomponent/sensor/mining)
	time = 5 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/shipRCD
	name = "Duracorp Construction Device"
	item_paths = list("MET-3","DEN-1","CON-1")
	item_amounts = list(5,1,10)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/cargo)
	time = 90 SECONDS
	create = 1
	category = "Resource"

//  cogwerks - clothing manufacturer datums

/datum/manufacture/backpack
	name = "Backpack"
	item_paths = list("FAB-1")
	item_amounts = list(8)
	item_outputs = list(/obj/item/storage/backpack)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/backpack_red
	name = "Red Backpack"
	item_paths = list("FAB-1")
	item_amounts = list(8)
	item_outputs = list(/obj/item/storage/backpack/red)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/backpack_green
	name = "Green Backpack"
	item_paths = list("FAB-1")
	item_amounts = list(8)
	item_outputs = list(/obj/item/storage/backpack/green)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/backpack_blue
	name = "Blue Backpack"
	item_paths = list("FAB-1")
	item_amounts = list(8)
	item_outputs = list(/obj/item/storage/backpack/blue)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/satchel
	name = "Satchel"
	item_paths = list("FAB-1")
	item_amounts = list(8)
	item_outputs = list(/obj/item/storage/backpack/satchel)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/satchel_red
	name = "Red Satchel"
	item_paths = list("FAB-1")
	item_amounts = list(8)
	item_outputs = list(/obj/item/storage/backpack/satchel/red)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/satchel_green
	name = "Green Satchel"
	item_paths = list("FAB-1")
	item_amounts = list(8)
	item_outputs = list(/obj/item/storage/backpack/satchel/green)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/satchel_blue
	name = "Blue Satchel"
	item_paths = list("FAB-1")
	item_amounts = list(8)
	item_outputs = list(/obj/item/storage/backpack/satchel/blue)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/shoes_brown
	name = "Brown Shoes"
	item_paths = list("FAB-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/clothing/shoes/brown)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_white
	name = "White Hat"
	item_paths = list("FAB-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/clothing/head/white)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_black
	name = "Black Hat"
	item_paths = list("FAB-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/clothing/head/black)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_blue
	name = "Blue Hat"
	item_paths = list("FAB-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/clothing/head/blue)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_red
	name = "Red Hat"
	item_paths = list("FAB-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/clothing/head/red)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_green
	name = "Green Hat"
	item_paths = list("FAB-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/clothing/head/green)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_yellow
	name = "Yellow Hat"
	item_paths = list("FAB-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/clothing/head/yellow)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_pink
	name = "Pink Hat"
	item_paths = list("FAB-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/clothing/head/pink)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_orange
	name = "Orange Hat"
	item_paths = list("FAB-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/clothing/head/orange)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_purple
	name = "Purple Hat"
	item_paths = list("FAB-1")
	item_amounts = list(2)
	item_outputs = list(/obj/item/clothing/head/purple)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_tophat
	name = "Top Hat"
	item_paths = list("FAB-1")
	item_amounts = list(3)
	item_outputs = list(/obj/item/clothing/head/that)
	time = 3 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_ltophat
	name = "Large Top Hat"
	item_paths = list("FAB-1")
	item_amounts = list(5)
	item_outputs = list(/obj/item/clothing/head/longtophat)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_white
	name = "White Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/color/white)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_red
	name = "Red Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/color/red)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_yellow
	name = "Yellow Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/color/yellow)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_green
	name = "Green Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/color/green)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_pink
	name = "Pink Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/color/pink)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_blue
	name = "Blue Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/color/blue)
	time = 5 SECONDS
	create = 1
	category = "Clothing"


/datum/manufacture/jumpsuit_purple
	name = "Purple Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/color/purple)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_brown
	name = "Brown Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/color/brown)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_black
	name = "Black Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/color)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_orange
	name = "Orange Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/color/orange)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/tricolor
	name = "Tricolor Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/misc/tricolor)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_lgbt
	name = "LGBT Pride Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/pride)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_ace
	name = "Asexual Pride Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/pride/ace)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_aro
	name = "Aromantic Pride Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/pride/aro)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_bi
	name = "Bisexual Pride Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/pride/bi)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_inter
	name = "Intersex Pride Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/pride/inter)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_lesb
	name = "Lesbian Pride Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/pride/lesb)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_gay
	name = "Gay Pride Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/pride/gaymasc)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_nb
	name = "Non-binary Pride Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/pride/nb)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_pan
	name = "Pansexual Pride Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/pride/pan)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_poly
	name = "Polysexual Pride Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/pride/poly)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_trans
	name = "Trans Pride Jumpsuit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/pride/trans)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/suit_black
	name = "Fancy Black Suit"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/suit)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/dress_black
	name = "Fancy Black Dress"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/suit/dress)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/labcoat
	name = "Labcoat"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/suit/labcoat)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_white
	name = "White Scrubs"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/scrub)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_teal
	name = "Teal Scrubs"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/scrub/teal)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_maroon
	name = "Maroon Scrubs"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/scrub/maroon)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_blue
	name = "Navy Scrubs"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/scrub/blue)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_purple
	name = "Violet Scrubs"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/scrub/purple)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_orange
	name = "Orange Scrubs"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/scrub/orange)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_pink
	name = "Hot Pink Scrubs"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/scrub/pink)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/medical_backpack
	name = "Medical Backpack"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/storage/backpack/medic)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/patient_gown
	name = "Gown"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/under/patient_gown)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/surgical_mask
	name = "Sterile Mask"
	item_paths = list("FAB-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/clothing/mask/surgical)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/surgical_shield
	name = "Surgical Face Shield"
	item_paths = list("FAB-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/clothing/mask/surgical_shield)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/eyepatch
	name = "Medical Eyepatch"
	item_paths = list("FAB-1")
	item_amounts = list(5)
	item_outputs = list(/obj/item/clothing/glasses/eyepatch)
	time = 15 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/blindfold
	name = "Blindfold"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/clothing/glasses/blindfold)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/muzzle
	name = "Muzzle"
	item_paths = list("FAB-1", "MET-1")
	item_amounts = list(4, 2)
	item_outputs = list(/obj/item/clothing/mask/muzzle)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hermes
	name = "Offering to the Fabricator Gods"
	item_paths = list("MET-3","CON-2","POW-3","CRY-2","FAB-1","INS-1")
	item_amounts = list(30,30,6,1,30,30)
	item_outputs = list(/obj/item/clothing/shoes/hermes)
	time = 120 //suspense
	create = 3 //because a shoe god has to have acolytes
	category = "Clothing"

/datum/manufacture/towel
	name = "Towel"
	item_paths = list("FAB-1")
	item_amounts = list(8)
	item_outputs = list(/obj/item/cloth/towel/white)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/handkerchief
	name = "Handkerchief"
	item_paths = list("FAB-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/cloth/handkerchief/white)
	time = 4 SECONDS
	create = 1
	category = "Resource"

/////// pod construction components

/datum/manufacture/pod/parts
	name = "Pod Frame Kit"
	item_paths = list("MET-2")
	item_amounts = list(30)
	item_outputs = list(/obj/item/pod/frame_box)
	time = 20 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod/engine
	name = "Engine Manifold"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(10,5)
	item_outputs = list(/obj/item/pod/engine)
	time = 10 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod/boards
	name = "Pod Circuitry"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(5,5)
	item_outputs = list(/obj/item/pod/boards)
	time = 10 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod/armor_light
	name = "Light Pod Armor"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(30,20)
	item_outputs = list(/obj/item/podarmor/armor_light)
	time = 20 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod/armor_heavy
	name = "Heavy Pod Armor"
	item_paths = list("MET-2","MET-3")
	item_amounts = list(30,20)
	item_outputs = list(/obj/item/podarmor/armor_heavy)
	time = 30 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod/armor_industrial
	name = "Industrial Pod Armor"
	item_paths = list("MET-3","CON-2","DEN-1")
	item_amounts = list(25,10,5)
	item_outputs = list(/obj/item/podarmor/armor_industrial)
	time = 50 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod/control
	name = "Pod Control Interface"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(10,10)
	item_outputs = list(/obj/item/pod/control)
	time = 10 SECONDS
	create = 1
	category = "Component"

ABSTRACT_TYPE(/datum/manufacture/sub)

/datum/manufacture/sub/parts
	name = "Minisub Frame Kit"
	item_paths = list("MET-2")
	item_amounts = list(15)
	item_outputs = list(/obj/item/sub/frame_box)
	time = 10 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/sub/engine
	name = "Minisub Engine Manifold"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(5,2)
	item_outputs = list(/obj/item/sub/engine)
	time = 5 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/sub/boards
	name = "Minisub Circuitry"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(2,2)
	item_outputs = list(/obj/item/sub/boards)
	time = 5 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/sub/control
	name = "Minisub Control Interface"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(5,5)
	item_outputs = list(/obj/item/sub/control)
	time = 5 SECONDS
	create = 1
	category = "Component"

ABSTRACT_TYPE(/datum/manufacture/putt)

/datum/manufacture/putt/parts
	name = "MiniPutt Frame Kit"
	item_paths = list("MET-2")
	item_amounts = list(15)
	item_outputs = list(/obj/item/putt/frame_box)
	time = 10 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/putt/engine
	name = "MiniPutt Engine Manifold"
	item_paths = list("MET-2","CON-1")
	item_amounts = list(5,2)
	item_outputs = list(/obj/item/putt/engine)
	time = 5 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/putt/boards
	name = "MiniPutt Circuitry"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(2,2)
	item_outputs = list(/obj/item/putt/boards)
	time = 5 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/putt/control
	name = "MiniPutt Control Interface"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(5,5)
	item_outputs = list(/obj/item/putt/control)
	time = 5 SECONDS
	create = 1
	category = "Component"

//// pod addons

ABSTRACT_TYPE(/datum/manufacture/pod)

ABSTRACT_TYPE(/datum/manufacture/pod/weapon)

/datum/manufacture/pod/weapon/mining
	name = "Plasma Cutter System"
	item_paths = list("POW-1","MET-3","CRY-2")
	item_amounts = list(10,10,20)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/mining)
	time = 20 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/mining/drill
	name = "Rock Drilling Rig"
	item_paths = list("POW-1","MET-3","CRY-2")
	item_amounts = list(10,10,10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/rockdrills)
	time = 20 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/ltlaser
	name = "Mk.1.5 Light Phasers"
	item_paths = list("MET-2","CON-1","CRY-1")
	item_amounts = list(15,15,15)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/phaser)
	time = 20 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/lock
	name = "Pod Locking Mechanism"
	item_paths = list("CRY-1","CON-1")
	item_amounts = list(5,10)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/lock)
	time = 10 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/sps
	name = "Syndicate Purge System"
	item_paths = list("MET-1","CON-1","CRY-1")
	item_amounts = list(8,12,16)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/syndicate_purge_system)
	time = 90 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/srs
	name = "Syndicate Rewind System"
	item_paths = list("MET-1","CON-1","CRY-1")
	item_amounts = list(16,12,8)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/syndicate_rewind_system)
	time = 90 SECONDS
	create = 1
	category = "Tool"
//// deployable warp beacon

/datum/manufacture/beaconkit
	name = "Warp Beacon Frame"
	item_paths = list("CRY-1","CON-1","MET-2")
	item_names = list("Crystal","Conductive Material","Sturdy Metal")
	item_amounts = list(10,10,10)
	item_outputs = list(/obj/beaconkit)
	time = 30 SECONDS
	create = 1
	category = "Machinery"


/******************** HOP *******************/

/datum/manufacture/id_card
	name = "ID card"
	item_paths = list("CON-1","CRY-1")
	item_amounts = list(3,3)
	item_outputs = list(/obj/item/card/id)
	time = 5 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/id_card_gold
	name = "Gold ID card"
	item_paths = list("gold", "CON-2","CRY-1")
	item_amounts = list(5,4,3)
	item_outputs = list(/obj/item/card/id/gold)
	time = 30 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/implant_access
	name = "Electronic Access Implant (2 Access Charges)"
	item_paths = list("CON-1","CRY-1")
	item_amounts = list(3,3)
	item_outputs = list(/obj/item/implantcase/access)
	time = 20 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/acesscase
	name = "ID Briefcase"
	item_paths = list("CON-1","CRY-1","MET-1","gold")
	item_amounts = list(25,15,35,2)
	item_outputs = list(/obj/machinery/computer/card/portable)
	time = 75 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/implant_access_infinite
	name = "Electronic Access Implant (Unlimited Charge)"
	item_paths = list("CON-1","CRY-1")
	item_amounts = list(9,15)
	item_outputs = list(/obj/item/implantcase/access/unlimited)
	time = 60 SECONDS
	create = 1
	category = "Resource"

/******************** QM CRATES *******************/

/datum/manufacture/crate
	name = "Crate"
	item_paths = list("MET-1")
	item_amounts = list(5)
	item_outputs = list(/obj/storage/crate)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/packingcrate
	name = "Random Packing Crate"
	item_paths = list("MET-1")
	item_amounts = list(5)
	item_outputs = list(/obj/storage/crate/packing)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/wooden
	name = "Wooden Crate"
	item_paths = list("MET-1")
	item_amounts = list(5)
	item_outputs = list(/obj/storage/crate/wooden)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/medical
	name = "Medical Crate"
	item_paths = list("MET-1")
	item_amounts = list(5)
	item_outputs = list(/obj/storage/crate/medical)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/biohazard
	name = "Biohazard Crate"
	item_paths = list("MET-1")
	item_amounts = list(5)
	item_outputs = list(/obj/storage/crate/biohazard)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/classcrate
	name = "Class Crate"
	item_paths = list("MET-1")
	item_amounts = list(5)
	item_outputs = list(/obj/storage/crate/classcrate)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/freezer
	name = "Freezer Crate"
	item_paths = list("MET-1")
	item_amounts = list(5)
	item_outputs = list(/obj/storage/crate/freezer)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"
/******************** GUNS *******************/

/datum/manufacture/alastor
	name = "Alastor Pattern Laser Rifle"
	item_paths = list("DEN-1","MET-3","CON-1","CRY-1")
	item_amounts = list(1,10,20,20)
	item_outputs = list(/obj/item/gun/energy/alastor)
	time = 30 SECONDS
	create = 1
	category = "Tool"

/************ INTERDICTOR STUFF ************/

/datum/manufacture/interdictor_kit
	name = "Interdictor Frame Kit"
	item_paths = list("MET-2")
	item_amounts = list(10)
	item_outputs = list(/obj/item/interdictor_kit)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_board_standard
	name = "Standard Interdictor Mainboard"
	item_paths = list("CON-1")
	item_amounts = list(4)
	item_outputs = list(/obj/item/interdictor_board)
	time = 5 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_board_nimbus
	name = "Nimbus Interdictor Mainboard"
	item_paths = list("CON-1","INS-1","CRY-1")
	item_amounts = list(4,2,2)
	item_outputs = list(/obj/item/interdictor_board/nimbus)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_board_zephyr
	name = "Zephyr Interdictor Mainboard"
	item_paths = list("CON-1","viscerite")
	item_amounts = list(4,5)
	item_outputs = list(/obj/item/interdictor_board/zephyr)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_board_devera
	name = "Devera Interdictor Mainboard"
	item_paths = list("CON-1","CRY-1","syreline")
	item_amounts = list(4,2,5)
	item_outputs = list(/obj/item/interdictor_board/devera)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_rod_lambda
	name = "Lambda Phase-Control Rod"
	item_paths = list("MET-2","CON-1","CRY-1","INS-1")
	item_amounts = list(2,10,5,2)
	item_outputs = list(/obj/item/interdictor_rod)
	time = 20 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_rod_sigma
	name = "Sigma Phase-Control Rod"
	item_paths = list("MET-2","CON-2","INS-1","POW-1")
	item_amounts = list(2,10,5,2)
	item_outputs = list(/obj/item/interdictor_rod/sigma)
	time = 20 SECONDS
	create = 1
	category = "Machinery"

/************ NADIR RESONATORS ************/

/datum/manufacture/resonator_type_ax
	name = "Type-AX Resonator"
	item_paths = list("MET-2","CON-2","CRY-1","POW-1")
	item_amounts = list(15,20,20,5)
	item_outputs = list(/obj/machinery/siphon/resonator)
	time = 30 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/resonator_type_sm
	name = "Type-SM Resonator"
	item_paths = list("MET-2","CON-2","CRY-1","INS-1")
	item_amounts = list(10,20,10,10)
	item_outputs = list(/obj/machinery/siphon/resonator/stabilizer)
	time = 30 SECONDS
	create = 1
	category = "Machinery"

/************ NADIR GEAR ************/

/datum/manufacture/nanoloom
	name = "Nanoloom"
	item_paths = list("MET-2","CON-1","cobryl","FAB-1")
	item_amounts = list(4,2,1,3)
	item_outputs = list(/obj/item/device/nanoloom)
	time = 15 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/nanoloom_cart
	name = "Nanoloom Cartridge"
	item_paths = list("MET-2","cobryl","FAB-1")
	item_amounts = list(1,1,3)
	item_outputs = list(/obj/item/nanoloom_cartridge)
	time = 8 SECONDS
	create = 1
	category = "Tool"

//////////////////////UBER-EXTREME SURVIVAL////////////////////////////////
/datum/manufacture/armor_vest	//
	name = "Armor Vest"
	item_paths = list("MET-3")
	item_amounts = list(5)
	item_outputs = list(/obj/item/clothing/suit/armor/vest)
	time = 30 SECONDS
	create = 1
	category = "Weapon"

/datum/manufacture/saa	//
	name = "Colt SAA"
	item_paths = list("MET-2")
	item_amounts = list(7)
	item_outputs = list(/obj/item/gun/kinetic/single_action/colt_saa)
	time = 30 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/saa_ammo	//
	name = "Colt Ammo"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/ammo/bullets/c_45)
	time = 7 SECONDS
	create = 1
	category = "ammo"
/datum/manufacture/clock	//
	name = "Clock 188"
	item_paths = list("MET-1")
	item_amounts = list(10)
	item_outputs = list(/obj/item/gun/kinetic/clock_188)
	time = 10 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/clock_ammo	//
	name = "Clock ammo"
	item_paths = list("MET-1")
	item_amounts = list(3)
	item_outputs = list(/obj/item/ammo/bullets/nine_mm_NATO)
	time = 7 SECONDS
	create = 1
	category = "ammo"

/datum/manufacture/riot_shotgun	//
	name = "Riot Shotgun"
	item_paths = list("MET-1")
	item_amounts = list(20)
	item_outputs = list(/obj/item/gun/kinetic/riotgun)
	time = 20 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/riot_shotgun_ammo	//
	name = "Rubber Bullet ammo"
	item_paths = list("MET-1")
	item_amounts = list(10)
	item_outputs = list(/obj/item/ammo/bullets/abg)
	time = 7 SECONDS
	create = 1
	category = "ammo"

/datum/manufacture/riot_launcher	//
	name = "Riot Launcher"
	item_paths = list("MET-1")
	item_amounts = list(12)
	item_outputs = list(/obj/item/gun/kinetic/riot40mm)
	time = 10 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/riot_launcher_ammo_pbr	//
	name = "Launcher PBR Ammo"
	item_paths = list("MET-1", "CON-1", "CRY-1")
	item_amounts = list(2,4,1)
	item_outputs = list(/obj/item/ammo/bullets/pbr)
	time = 10 SECONDS
	create = 1
	category = "ammo"
/datum/manufacture/riot_launcher_ammo_flashbang	//
	name = "Launcher Flashbang Box"
	item_paths = list("MET-1", "CON-1")
	item_amounts = list(2,3)
	item_outputs = list(/obj/item/storage/box/flashbang_kit)
	time = 10 SECONDS
	create = 1
	category = "ammo"
/datum/manufacture/riot_launcher_ammo_tactical	//
	name = "Launcher Tactical Box"
	item_paths = list("MET-2", "CON-1", "CRY-1")
	item_amounts = list(5, 5, 3)
	item_outputs = list(/obj/item/storage/box/tactical_kit)
	time = 10 SECONDS
	create = 1
	category = "ammo"

/datum/manufacture/sniper	//
	name = "Sniper"
	item_paths = list("DEN-1","MET-3","CON-1","CRY-1")
	item_amounts = list(2, 15, 4, 3)
	item_outputs = list(/obj/item/gun/kinetic/sniper)
	time = 25 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/sniper_ammo	//
	name = "Sniper Ammo"
	item_paths = list("MET-3")
	item_amounts = list(6)
	item_outputs = list(/obj/item/ammo/bullets/rifle_762_NATO)
	time = 10 SECONDS
	create = 1
	category = "ammo"
/datum/manufacture/tac_shotgun	//
	name = "Tactical Shotgun"
	item_paths = list("MET-3", "CON-1")
	item_amounts = list(15, 5)
	item_outputs = list(/obj/item/gun/kinetic/tactical_shotgun)
	time = 20 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/tac_shotgun_ammo	//
	name = "Tactical Shotgun Ammo"
	item_paths = list("MET-3")
	item_amounts = list(5)
	item_outputs = list(/obj/item/ammo/bullets/buckshot_burst)
	time = 7 SECONDS
	create = 1
	category = "ammo"
/datum/manufacture/gyrojet	//
	name = "Gyrojet"
	item_paths = list("DEN-1","MET-3","CON-2")
	item_amounts = list(5, 10, 6)
	item_outputs = list(/obj/item/gun/kinetic/gyrojet)
	time = 30 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/gyrojet_ammo	//
	name = "Gyrojet Ammo"
	item_paths = list("MET-3", "CON-2")
	item_amounts = list(5,2)
	item_outputs = list(/obj/item/ammo/bullets/gyrojet)
	time = 7 SECONDS
	create = 1
	category = "Ammo"
/datum/manufacture/plank	//
	name = "Plank/Barricade"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/plank/anti_zombie)
	time = 5 SECONDS
	create = 1
	category = "Medicine"
/datum/manufacture/brute_kit	//
	name = "Brute Kit"
	item_paths = list("MET-1", "CON-1")
	item_amounts = list(2, 2)
	item_outputs = list(/obj/item/storage/firstaid/brute)
	time = 10 SECONDS
	create = 1
	category = "Medicine"
/datum/manufacture/burn_kit	//
	name = "Burn Kit"
	item_paths = list("MET-1", "CON-1")
	item_amounts = list(2, 2)
	item_outputs = list(/obj/item/storage/firstaid/fire)
	time = 10 SECONDS
	create = 1
	category = "Medicine"
/datum/manufacture/crit_kit //
	name = "Crit Kit"
	item_paths = list("MET-1", "CON-1")
	item_amounts = list(2, 2)
	item_outputs = list(/obj/item/storage/firstaid/crit)
	time = 9 SECONDS
	create = 1
	category = "Medicine"
/datum/manufacture/empty_kit
	name = "Empty First Aid Kit"
	item_paths = list("MET-1")
	item_amounts = list(1)
	item_outputs = list(/obj/item/storage/firstaid/regular/empty)
	time = 4 SECONDS
	create = 1
	category = "Medicine"
/datum/manufacture/spacecillin	//
	name = "Spacecillin"
	item_paths = list("MET-1", "CON-1")
	item_amounts = list(3, 3)
	item_outputs = list(/obj/item/reagent_containers/syringe/antiviral)
	time = 10 SECONDS
	create = 1
	category = "Medicine"
/datum/manufacture/bat	//
	name = "Baseball Bat"
	item_paths = list("MET-2")
	item_amounts = list(15)
	item_outputs = list(/obj/item/bat)
	time = 20 SECONDS
	create = 1
	category = "Miscellaneous"
/datum/manufacture/quarterstaff	//
	name = "Quarterstaff"
	item_paths = list("MET-2")
	item_amounts = list(10)
	item_outputs = list(/obj/item/quarterstaff)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"
/datum/manufacture/cleaver	//
	name = "Cleaver"
	item_paths = list("MET-1")
	item_amounts = list(20)
	item_outputs = list(/obj/item/kitchen/utensil/knife/cleaver)
	time = 16 SECONDS
	create = 1
	category = "Miscellaneous"
/datum/manufacture/dsaber	//
	name = "D-Saber"
	item_paths = list("MET-2", "CON-1")
	item_amounts = list(20, 10)
	item_outputs = list(/obj/item/sword/discount)
	time = 20 SECONDS
	create = 1
	category = "Miscellaneous"
/datum/manufacture/fireaxe	//
	name = "Fireaxe"
	item_paths = list("MET-3", "CON-2")
	item_amounts = list(20, 5)
	item_outputs = list(/obj/item/fireaxe)
	time = 20 SECONDS
	create = 1
	category = "Miscellaneous"
/datum/manufacture/shovel	//
	name = "Shovel"
	item_paths = list("MET-3", "CON-2")
	item_amounts = list(25, 5)
	item_outputs = list(/obj/item/shovel)	//this is powerful)
	time = 40 SECONDS
	create = 1
	category = "Miscellaneous"
