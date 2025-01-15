#define JUMPSUIT_COST 10

/datum/manufacture
	/// Player-read name of the blueprint
	var/name = null
	// Player-read name of each material
	var/list/item_names = list()
	/// An associated list of requirement datum to amount of requirement to use. See manufacturing_requirements.dm for more on those.
	/// This list is overriden on children, and on New() the requirement ID strings are resolved to their datum instances in the cache
	var/list/item_requirements = null
	/// List of object types which the blueprint outputs upon satisfaction of requirements
	var/list/item_outputs = list()
	/// 0 - will create each item in the list once per loop (see manufacturer.dm Line 755)
	/// 1 - will pick() a random item in the list once per loop
	/// 2 - will pick() a random item before the loop begins then output one of the selected item each loop
	var/randomise_output = 0
	/// How many times it'll make each thing in the list - or not, depending on randomize_output
	var/create = 1
	/// How many seconds it takes to complete the blueprint
	var/time = 5 SECONDS
	/// Named category which the blueprint will reside in for manufacturers. See manufacturer.dm for list.
	/// If a blueprint has an invalid category, it will be assigned "Miscellaneous".
	var/category = null
	/// Whether or not to apply a material onto the object upon completion. By default, this is the material used
	/// For the first material requirement specified.
	var/apply_material = FALSE

	New()
		..()
		if(isnull(item_requirements) && length(item_outputs) == 1) // TODO generalize to multiple outputs (currently no such manufacture recipes exist)
			var/item_type = item_outputs[1]
			src.use_generated_costs(item_type)

		src.setup_manufacturing_requirements()
		if (!length(src.item_names))
			for (var/datum/manufacturing_requirement/R as anything in src.item_requirements)
				src.item_names += R.getName()

	/// Setup the manufacturing requirements for this datum, using the cache instead of init() on each
	proc/setup_manufacturing_requirements()
		if (isnull(src.item_requirements))
			src.item_requirements = list()
			return
		var/list/R = list()
		for (var/R_path in src.item_requirements)
			R[getManufacturingRequirement(R_path)] = src.item_requirements[R_path]
		src.item_requirements = R

	proc/use_generated_costs(obj/item_type)
		var/typeinfo/obj/typeinfo = get_type_typeinfo(item_type)
		if(istype(typeinfo) && islist(typeinfo.mats))
			item_requirements = list()
			for(var/req in typeinfo.mats)
				var/amt = typeinfo.mats[req]
				if(isnull(amt))
					amt = 1
				item_requirements[req] = amt

	proc/modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		// use this if you want the outputted item to be customised in any way by the manufacturer
		if (M.malfunction && length(M.text_bad_output_adjective) > 0 && prob(66))
			A.name = "[pick(M.text_bad_output_adjective)] [A.name]"
		if (src.apply_material && length(materials) > 0)
			var/obj/item/material_piece/applicable_material = locate(materials[materials[1]])
			var/datum/material/mat = applicable_material?.material
			A.setMaterial(mat)
		return 1

/datum/manufacture/mechanics
	name = "Reverse-Engineered Schematic"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "crystal" = 1)
	item_outputs = list(/obj/item/electronics/frame)
	/// Path to an item or mob which will be created in a frame upon completion.
	var/frame_path = null
	/// Whether or not to use the default cost assignment in New(), e.g.: for pre-spawned cloner blueprints
	var/generate_costs = FALSE

	New()
		if(src.generate_costs)
			src.item_requirements = list()
			src.use_generated_costs(frame_path)
		. = ..()

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		if (!(..()))
			return

		if (istype(A,/obj/item/electronics/frame/))
			var/obj/item/electronics/frame/F = A
			if (ispath(src.frame_path))
				if(src.apply_material && length(materials) > 0)
					F.removeMaterial()
					var/atom/thing = new frame_path(F)
					// Locate the reference of the first item requirment we use
					var/obj/item/material_piece/applicable_material = locate(materials[materials[1]])
					thing.setMaterial(applicable_material.material)
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
	create = 1
	time = 30 SECONDS
	frame_path = /obj/machinery/clonepod
	generate_costs = TRUE

/datum/manufacture/mechanics/clonegrinder
	name = "enzymatic reclaimer"
	create = 1
	time = 18 SECONDS
	frame_path = /obj/machinery/clonegrinder
	generate_costs = TRUE

/datum/manufacture/mechanics/clone_scanner
	name = "cloning machine scanner"
	create = 1
	time = 30 SECONDS
	frame_path = /obj/machinery/clone_scanner
	generate_costs = TRUE


/******************** Loafer *******************/

/datum/manufacture/mechanics/loafer
	name = "loafer (deploy on plating)"
	item_requirements = list("metal" = 5,
							 "conductive" = 6,
							 "crystal" = 4)
	create = 1
	time = 30 SECONDS
	frame_path = /obj/disposalpipe/loafer

/******************** Communications Dish *******************/

/datum/manufacture/mechanics/comms_dish
	name = "Communications Dish"
	item_requirements = list("metal" = 20,
							 "metal_dense" = 10,
							 "insulated" = 20,
							 "conductive" = 20)
	create = 1
	time = 60 SECONDS
	frame_path = /obj/machinery/communications_dish

/******************** AI Law Rack *******************/

/datum/manufacture/mechanics/lawrack
	name = "AI Law Rack Mount"
	item_requirements = list("metal" = 20,
							 "metal_dense" = 5,
							 "insulated" = 10,
							 "conductive" = 10)
	create = 1
	time = 60 SECONDS
	frame_path = /obj/machinery/lawrack

/******************** AI display (temp) *******************/

/datum/manufacture/mechanics/ai_status_display
	name = "AI display"
	create = 1
	time = 5 SECONDS
	frame_path = /obj/machinery/ai_status_display
	generate_costs = TRUE

/******************** Laser beam things *******************/

/datum/manufacture/mechanics/laser_mirror
	name = "Laser Mirror"
	item_requirements = list("metal" = 10,
							 "crystal" = 10,
							 "reflective" = 30)
	create = 1
	time = 45 SECONDS
	frame_path = /obj/laser_sink/mirror

/datum/manufacture/mechanics/laser_splitter //I'm going to regret this
	name = "Beam Splitter"
	item_requirements = list("metal" = 20,
							 "crystal_dense" = 20,
							 "reflective" = 30)
	create = 1
	time = 90 SECONDS
	frame_path = /obj/laser_sink/splitter
/datum/manufacture/mechanics/gunbot
	name = "Security Robot"
	item_requirements = list("energy" = 10,
							 "metal_dense" = 10,
							 "conductive" = 10)
	create = 1
	time = 15 SECONDS
	frame_path = /mob/living/critter/robotic/gunbot

/*
/datum/manufacture/iron
	name = "Iron"
	item_requirements = list("metal" = 1)
	item_outputs = list("reagent-iron")
	create = 10
	time = 1 SECONDS
	category = "Resource"
	// purely a test
*/

/datum/manufacture/crowbar
	name = "Crowbar"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/crowbar/green)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/screwdriver
	name = "Screwdriver"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/screwdriver/green)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/wirecutters
	name = "Wirecutters"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/wirecutters/green)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/wrench
	name = "Wrench"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/wrench/green)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/crowbar/yellow
	name = "Crowbar"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/crowbar/yellow)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/screwdriver/yellow
	name = "Screwdriver"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/screwdriver/yellow)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/wirecutters/yellow
	name = "Wirecutters"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/wirecutters/yellow)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/wrench/yellow
	name = "Wrench"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/wrench/yellow)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/flashlight
	name = "Flashlight"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "crystal" = 1)
	item_outputs = list(/obj/item/device/light/flashlight)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/vuvuzela
	name = "Vuvuzela"
	item_requirements = list("any" = 1)
	item_outputs = list(/obj/item/instrument/vuvuzela)
	create = 1
	time = 5 SECONDS
	category = "Miscellaneous"

/datum/manufacture/harmonica
	name = "Harmonica"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/instrument/harmonica)
	create = 1
	time = 5 SECONDS
	category = "Miscellaneous"

/datum/manufacture/bottle
	name = "Glass Bottle"
	item_requirements = list("crystal" = 1)
	item_outputs = list(/obj/item/reagent_containers/food/drinks/bottle/soda)
	create = 1
	time = 4 SECONDS
	category = "Miscellaneous"

/datum/manufacture/saxophone
	name = "Saxophone"
	item_requirements = list("metal_dense" = 15)
	item_outputs = list(/obj/item/instrument/saxophone)
	create = 1
	time = 7 SECONDS
	category = "Miscellaneous"

/datum/manufacture/whistle
	name = "Whistle"
	item_requirements = list("metal_superdense" = 5)
	item_outputs = list(/obj/item/instrument/whistle)
	create = 1
	time = 3 SECONDS
	category = "Miscellaneous"

/datum/manufacture/trumpet
	name = "Trumpet"
	item_requirements = list("metal_dense" = 10)
	item_outputs = list(/obj/item/instrument/trumpet)
	create = 1
	time = 6 SECONDS
	category = "Miscellaneous"

/datum/manufacture/bagpipe
	name = "Bagpipe"
	item_requirements = list("fabric" = 10,
							 "metal_dense" = 25)
	item_outputs = list(/obj/item/instrument/bagpipe)
	create = 1
	time = 5 SECONDS
	category = "Miscellaneous"

/datum/manufacture/fiddle
	name = "Fiddle"
	item_requirements = list("wood" = 25,
							 "fabric" = 10)
	item_outputs = list(/obj/item/instrument/fiddle)
	create = 1
	time = 5 SECONDS
	category = "Miscellaneous"

/datum/manufacture/bikehorn
	name = "Bicycle Horn"
	item_requirements = list("any" = 1)
	item_outputs = list(/obj/item/instrument/bikehorn)
	create = 1
	time = 5 SECONDS
	category = "Miscellaneous"

/datum/manufacture/stunrounds
	name = ".38 Stunner Rounds"
	item_requirements = list("metal" = 3,
							 "conductive" = 2,
							 "crystal" = 2)
	item_outputs = list(/obj/item/ammo/bullets/a38/stun)
	create = 1
	time = 20 SECONDS
	category = "Resource"

/datum/manufacture/bullet_22
	name = ".22 Bullets"
	item_requirements = list("metal_dense" = 30,
							 "conductive" = 24)
	item_outputs = list(/obj/item/ammo/bullets/bullet_22)
	create = 1
	time = 30 SECONDS
	category = "Resource"

/datum/manufacture/bullet_12g_nail
	name = "12 gauge nailshot"
	item_requirements = list("metal_dense" = 40,
							 "conductive" = 30)
	item_outputs = list(/obj/item/ammo/bullets/nails)
	create = 1
	time = 30 SECONDS
	category = "Resource"

/datum/manufacture/bullet_smoke
	name = "40mm Smoke Grenade"
	item_requirements = list("metal_dense" = 30,
							 "conductive" = 25)
	item_outputs = list(/obj/item/ammo/bullets/smoke)
	create = 1
	time = 35 SECONDS
	category = "Resource"

/datum/manufacture/extinguisher
	name = "Fire Extinguisher"
	item_requirements = list("metal_dense" = 1,
							 "crystal" = 1)
	item_outputs = list(/obj/item/extinguisher)
	create = 1
	time = 8 SECONDS
	category = "Tool"

/datum/manufacture/welder
	name = "Welding Tool"
	item_requirements = list("metal_dense" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/weldingtool/green)
	create = 1
	time = 8 SECONDS
	category = "Tool"

/datum/manufacture/welder/yellow
	name = "Welding Tool"
	item_requirements = list("metal_dense" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/weldingtool/yellow)
	create = 1
	time = 8 SECONDS
	category = "Tool"

/datum/manufacture/soldering
	name = "Soldering Iron"
	item_requirements = list("metal_dense" = 1,
							 "conductive" = 2)
	item_outputs = list(/obj/item/electronics/soldering)
	create = 1
	time = 8 SECONDS
	category = "Tool"

/datum/manufacture/stapler
	name = "Staple Gun"
	item_requirements = list("metal_dense" = 2,
							 "conductive" = 1)
	item_outputs = list(/obj/item/staple_gun)
	create = 1
	time = 10 SECONDS
	category = "Tool"

/datum/manufacture/multitool
	name = "Multi Tool"
	item_outputs = list(/obj/item/device/multitool)
	create = 1
	time = 8 SECONDS
	category = "Tool"

/datum/manufacture/t_scanner
	name = "T-ray scanner"
	item_outputs = list(/obj/item/device/t_scanner)
	create = 1
	time = 8 SECONDS
	category = "Tool"

/datum/manufacture/weldingmask
	name = "Welding Mask"
	item_requirements = list("metal_dense" = 2,
							 "crystal" = 2)
	item_outputs = list(/obj/item/clothing/head/helmet/welding)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/light_bulb
	name = "Light Bulb Box"
	item_requirements = list("crystal" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs)
	create = 1
	time = 4 SECONDS
	category = "Resource"

/datum/manufacture/red_bulb
	name = "Red Light Bulb Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/red)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/yellow_bulb
	name = "Yellow Light Bulb Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/yellow)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/green_bulb
	name = "Green Light Bulb Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/green)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/cyan_bulb
	name = "Cyan Light Bulb Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/cyan)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/blue_bulb
	name = "Blue Light Bulb Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/blue)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/purple_bulb
	name = "Purple Light Bulb Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/purple)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/blacklight_bulb
	name = "Blacklight Bulb Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/blacklight)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/light_tube
	name = "Light Tube Box"
	item_requirements = list("crystal" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes)
	create = 1
	time = 4 SECONDS
	category = "Resource"

/datum/manufacture/red_tube
	name = "Red Light Tube Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/red)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/yellow_tube
	name = "Yellow Light Tube Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/yellow)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/green_tube
	name = "Green Light Tube Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/green)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/cyan_tube
	name = "Cyan Light Tube Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/cyan)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/blue_tube
	name = "Blue Light Tube Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/blue)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/purple_tube
	name = "Purple Light Tube Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/purple)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/blacklight_tube
	name = "Blacklight Tube Box"
	item_requirements = list("crystal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/blacklight)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/table_folding
	name = "Folding Table"
	item_requirements = list("metal" = 1,
							 "any" = 2)
	item_outputs = list(/obj/item/furniture_parts/table/folding)
	create = 1
	time = 20 SECONDS
	category = "Resource"

/datum/manufacture/metal
	name = "Metal Sheet (x5)"
	item_requirements = list("metal" = 5)
	item_outputs = list(/obj/item/sheet)
	create = 5
	time = 8 SECONDS
	category = "Resource"
	apply_material = TRUE

/datum/manufacture/metalR
	name = "Reinforced Metal (x5)"
	item_requirements = list("metal" = 10)
	item_outputs = list(/obj/item/sheet)
	create = 5
	time = 40 SECONDS
	category = "Resource"
	apply_material = TRUE

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		var/obj/item/sheet/S = A
		..()
		var/obj/item/material_piece/applicable_material = locate(materials[getManufacturingRequirement("metal")])
		S.set_reinforcement(applicable_material.material)

/datum/manufacture/glass
	name = "Glass Panel (x5)"
	item_requirements = list("crystal" = 5)
	item_outputs = list(/obj/item/sheet)
	create = 5
	time = 8 SECONDS
	category = "Resource"
	apply_material = TRUE

/datum/manufacture/glassR
	name = "Reinforced Glass Panel (x5)"
	item_requirements = list("crystal" = 5,
							 "metal_dense" = 5)
	item_outputs = list(/obj/item/sheet/glass/reinforced)
	create = 5
	time = 40 SECONDS
	category = "Resource"
	apply_material = TRUE

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		..()
		var/obj/item/sheet/S = A
		var/obj/item/material_piece/applicable_material = locate(materials[getManufacturingRequirement("metal_dense")])
		S.set_reinforcement(applicable_material.material)

/datum/manufacture/rods2
	name = "Metal Rods (x10)"
	item_requirements = list("metal_dense" = 5)
	item_outputs = list(/obj/item/rods)
	time = 12 SECONDS
	category = "Resource"
	apply_material = TRUE

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A)
		..()
		var/obj/item/sheet/S = A // this way they are instantly stacked rather than just 2 rods
		S.amount = 10
		S.inventory_counter.update_number(S.amount)

/datum/manufacture/atmos_can
	name = "Portable Gas Canister"
	item_requirements = list("metal_dense" = 3)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

/datum/manufacture/fluidcanister
	name = "Fluid Canister"
	item_requirements = list("metal_dense" = 15)
	item_outputs = list(/obj/machinery/fluid_canister)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

/datum/manufacture/chembarrel
	name = "Chemical Barrel"
	item_requirements = list("metal_dense" = 6,
							 "cobryl" = 9)
	item_outputs = list(/obj/reagent_dispensers/chemicalbarrel)
	create = 1
	time = 30 SECONDS
	category = "Machinery"

	red
		item_outputs = list(/obj/reagent_dispensers/chemicalbarrel/red)

	yellow
		item_outputs = list(/obj/reagent_dispensers/chemicalbarrel/yellow)

/datum/manufacture/shieldgen
	name = "Energy-Shield Gen."
	item_requirements = list("metal_dense" = 20,
							 "conductive" = 10,
							 "crystal" = 5)
	item_outputs = list(/obj/machinery/shieldgenerator/energy_shield/nocell)
	create = 1
	time = 60 SECONDS
	category = "Machinery"

/datum/manufacture/doorshieldgen
	name = "Door-Shield Gen."
	item_requirements = list("metal_dense" = 20,
							 "conductive" = 15)
	item_outputs = list(/obj/machinery/shieldgenerator/energy_shield/doorlink/nocell)
	create = 1
	time = 60 SECONDS
	category = "Machinery"

/datum/manufacture/meteorshieldgen
	name = "Meteor-Shield Gen."
	item_requirements = list("metal" = 10,
							 "metal_dense" = 10,
							 "conductive" = 10)
	item_outputs = list(/obj/machinery/shieldgenerator/meteorshield/nocell)
	create = 1
	time = 30 SECONDS
	category = "Machinery"

//// cogwerks - gas extraction stuff


/datum/manufacture/air_can
	name = "Air Canister"
	item_requirements = list("metal_dense" = 3,
							 "molitz" = 4,
							 "viscerite" = 12)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/air)
	create = 1
	time = 50 SECONDS
	category = "Machinery"

/datum/manufacture/air_can/large
	name = "High-Volume Air Canister"
	item_requirements = list("metal_dense" = 3,
							 "molitz" = 10,
							 "viscerite" = 30)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/air/large)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

/datum/manufacture/co2_can
	name = "CO2 Canister"
	item_requirements = list("metal_dense" = 3,
							 "char" = 10)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

/datum/manufacture/o2_can
	name = "O2 Canister"
	item_requirements = list("metal_dense" = 3,
							 "molitz" = 10)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

/datum/manufacture/plasma_can
	name = "Plasma Canister"
	item_requirements = list("metal_dense" = 3,
							 "plasmastone" = 10)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/toxins)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

/datum/manufacture/n2_can
	name = "N2 Canister"
	item_requirements = list("metal_dense" = 3,
							 "viscerite" = 10)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

/datum/manufacture/n2o_can
	name = "N2O Canister"
	item_requirements = list("metal_dense" = 3,
							 "koshmarite" = 10)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/sleeping_agent)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

/datum/manufacture/red_o2_grenade
	name = "Red Oxygen Grenade"
	item_requirements = list("metal_dense" = 2,
							 "conductive" = 2,
							 "molitz" = 10,
							 "char" = 1)
	item_outputs = list(/obj/item/old_grenade/oxygen)
	create = 1
	time = 10 SECONDS
	category = "Tool"

/datum/manufacture/engivac
	name = "Material Vacuum"
	item_requirements = list("metal" = 10,
							 "conductive" = 5,
							 "crystal" = 5)
	item_outputs = list(/obj/item/engivac)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/lampmanufacturer
	name = "Lamp Manufacturer"
	item_requirements = list("metal" = 5,
							 "conductive" = 10,
							 "crystal" = 20)
	item_outputs = list(/obj/item/lamp_manufacturer/organic)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/condenser
	name = "Chemical Condenser"
	item_requirements = list("molitz" = 5)
	item_outputs = list(/obj/item/reagent_containers/glass/plumbing/condenser)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/fractionalcondenser
	name = "Fractional Condenser"
	item_requirements = list("molitz" = 6)
	item_outputs = list(/obj/item/reagent_containers/glass/plumbing/condenser/fractional)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/dropper_funnel
	name = "Dropper Funnel"
	item_requirements = list("molitz" = 3)
	item_outputs = list(/obj/item/reagent_containers/glass/plumbing/dropper)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/portable_dispenser
	name = "Portable Dispenser"
	item_requirements = list("molitz" = 3,
							 "metal" = 2,
							 "miracle" = 2)
	item_outputs = list(/obj/item/reagent_containers/glass/plumbing/dispenser)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/beaker_lid_box
	name = "Beaker Lid Box"
	item_requirements = list("rubber" = 2)
	item_outputs = list(/obj/item/storage/box/beaker_lids)
	create = 1
	time = 5 SECONDS
	category = "Tool"


/datum/manufacture/bunsen_burner
	name = "Bunsen Burner"
	item_requirements = list("pharosium" = 5)
	item_outputs = list(/obj/item/bunsen_burner)
	create = 1
	time = 5 SECONDS
	category = "Tool"

////////////////////////////////

/datum/manufacture/player_module
	name = "Vending Module"
	item_requirements = list("conductive" = 2)
	item_outputs = list(/obj/item/machineboard/vending/player)
	create = 1
	time = 5 SECONDS
	category = "Component"

/datum/manufacture/cable
	name = "Electrical Cable Coil"
	item_requirements = list("insulated" = 10,
							 "conductive" = 10)
	item_outputs = list(/obj/item/cable_coil)
	create = 1
	time = 3 SECONDS
	category = "Resource"
	apply_material = FALSE

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A,var/list/materials)
		..()
		var/obj/item/cable_coil/coil = A
		var/obj/item/material_piece/applicable_insulator = locate(materials[getManufacturingRequirement("insulated")])
		var/obj/item/material_piece/applicable_conductor = locate(materials[getManufacturingRequirement("conductive")])
		coil.setInsulator(applicable_insulator.material)
		coil.setConductor(applicable_conductor.material)
		return 1

/datum/manufacture/cable/reinforced
	name = "Reinforced Cable Coil"
	item_requirements = list("insulative_high" = 1,
							 "pharosium" = 1)
	item_outputs = list(/obj/item/cable_coil/reinforced)
	time = 10 SECONDS

/datum/manufacture/RCD
	name = "Rapid Construction Device"
	item_requirements = list("metal_superdense" = 20,
							 "crystal_dense" = 10,
							 "conductive_high" = 10,
							 "energy_high" = 10)
	item_outputs = list(/obj/item/rcd)
	create = 1
	time = 90 SECONDS
	category = "Tool"

/datum/manufacture/RCDammo
	name = "Compressed Matter Cartridge"
	item_requirements = list("dense" = 30)
	item_outputs = list(/obj/item/rcd_ammo)
	create = 1
	time = 10 SECONDS
	category = "Resource"

/datum/manufacture/RCDammomedium
	name = "Medium Compressed Matter Cartridge"
	item_requirements = list("dense_super" = 30)
	item_outputs = list(/obj/item/rcd_ammo/medium)
	create = 1
	time = 20 SECONDS
	category = "Resource"

/datum/manufacture/RCDammolarge
	name = "Large Compressed Matter Cartridge"
	item_requirements = list("uqill" = 20)
	item_outputs = list(/obj/item/rcd_ammo/big)
	create = 1
	time = 30 SECONDS
	category = "Resource"

/datum/manufacture/sds
	name = "Syndicate Destruction System"
	item_requirements = list("metal_superdense" = 16,
							 "dense" = 12,
							 "conductive" = 8)
	item_outputs = list(/obj/item/syndicate_destruction_system)
	create = 1
	time = 90 SECONDS
	category = "Tool"

/datum/manufacture/civilian_headset
	name = "Civilian Headset"
	item_requirements = list("metal" = 2,
							 "conductive" = 1)
	item_outputs = list(/obj/item/device/radio/headset)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_assistant
	name = "Staff Assistant Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/rank/assistant)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit
	name = "Grey Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/color/grey)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/shoes
	name = "Black Shoes"
	item_requirements = list("fabric" = 3)
	item_outputs = list(/obj/item/clothing/shoes/black)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/shoes_white
	name = "White Shoes"
	item_requirements = list("fabric" = 3)
	item_outputs = list(/obj/item/clothing/shoes/white)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/flippers
	name = "Flippers"
	item_requirements = list("rubber" = 5)
	item_outputs = list(/obj/item/clothing/shoes/flippers)
	create = 1
	time = 8 SECONDS
	category = "Clothing"

/datum/manufacture/cleaner_grenade
	name = "Cleaner Grenade"
	item_requirements = list("insulated" = 8,
							 "crystal" = 8,
							 "molitz" = 10,
							 "ice" = 10)
	item_outputs = list(/obj/item/chem_grenade/cleaner)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/pocketoxyex
	name = "Extended Capacity Pocket Oxygen Tank"
	item_requirements = list("dense_super" = 10,
							 "insulated" = 20,
							 "rubber" = 5)
	item_outputs = list(/obj/item/tank/emergency_oxygen/extended/empty)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/******************** Medical **************************/

/datum/manufacture/scalpel
	name = "Scalpel"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/scalpel)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/circular_saw
	name = "Circular Saw"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/circular_saw)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/surgical_scissors
	name = "Surgical Scissors"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/scissors/surgical_scissors)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/hemostat
	name = "Hemostat"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/hemostat)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/surgical_spoon
	name = "Enucleation Spoon"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/surgical_spoon)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/suture
	name = "Suture"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/suture)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/deafhs
	name = "Auditory Headset"
	item_requirements = list("conductive" = 3,
							 "crystal" = 3)
	item_outputs = list(/obj/item/device/radio/headset/deaf)
	create = 1
	time = 40 SECONDS
	category = "Clothing"

/datum/manufacture/visor
	name = "VISOR Prosthesis"
	item_requirements = list("conductive" = 3,
							 "crystal" = 3)
	item_outputs = list(/obj/item/clothing/glasses/visor)
	create = 1
	time = 40 SECONDS
	category = "Clothing"

/datum/manufacture/glasses
	name = "Prescription Glasses"
	item_requirements = list("metal" = 1,
							 "crystal" = 2)
	item_outputs = list(/obj/item/clothing/glasses/regular)
	create = 1
	time = 20 SECONDS
	category = "Clothing"

/datum/manufacture/hypospray
	name = "Hypospray"
	item_requirements = list("metal" = 2,
							 "conductive" = 2,
							 "crystal" = 2)
	item_outputs = list(/obj/item/reagent_containers/hypospray)
	create = 1
	time = 40 SECONDS
	category = "Tool"

/datum/manufacture/prodocs
	name = "ProDoc Healthgoggles"
	item_requirements = list("metal" = 1,
							 "crystal" = 2)
	item_outputs = list(/obj/item/clothing/glasses/healthgoggles)
	create = 1
	time = 20 SECONDS
	category = "Clothing"

/datum/manufacture/latex_gloves
	name = "Latex Gloves"
	item_requirements = list("fabric" = 1)
	item_outputs = list(/obj/item/clothing/gloves/latex)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/body_bag
	name = "Body Bag"
	item_requirements = list("fabric" = 3)
	item_outputs = list(/obj/item/body_bag)
	create = 1
	time = 15 SECONDS
	category = "Tool"

/datum/manufacture/cyberheart
	name = "Cyberheart"
	item_requirements = list("metal" = 3,
							 "conductive" = 3,
							 "any" = 2)
	item_outputs = list(/obj/item/organ/heart/cyber)
	create = 1
	time = 25 SECONDS
	category = "Organ"

/datum/manufacture/cyberbutt
	name = "Cyberbutt"
	item_requirements = list("metal" = 2,
							 "conductive" = 2,
							 "any" = 2)
	item_outputs = list(/obj/item/clothing/head/butt/cyberbutt)
	create = 1
	time = 15 SECONDS
	category = "Organ"

/datum/manufacture/cardboard_ai
	name = "Cardboard 'AI'"
	item_requirements = list("cardboard" = 1)
	item_outputs = list(/obj/item/clothing/suit/cardboard_box/ai)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/cyberappendix
	name = "Cyberappendix"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "any" = 1)
	item_outputs = list(/obj/item/organ/appendix/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

/datum/manufacture/cyberpancreas
	name = "Cyberpancreas"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "any" = 1)
	item_outputs = list(/obj/item/organ/pancreas/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

/datum/manufacture/cyberspleen
	name = "Cyberspleen"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "any" = 1)
	item_outputs = list(/obj/item/organ/spleen/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

/datum/manufacture/cyberintestines
	name = "Cyberintestines"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "any" = 1)
	item_outputs = list(/obj/item/organ/intestines/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

/datum/manufacture/cyberstomach
	name = "Cyberstomach"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "any" = 1)
	item_outputs = list(/obj/item/organ/stomach/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

/datum/manufacture/cyberkidney
	name = "Cyberkidney"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "any" = 1)
	item_outputs = list(/obj/item/organ/kidney/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

/datum/manufacture/cyberliver
	name = "Cyberliver"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "any" = 1)
	item_outputs = list(/obj/item/organ/liver/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

/datum/manufacture/cyberlung_left
	name = "Left Cyberlung"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "any" = 1)
	item_outputs = list(/obj/item/organ/lung/cyber/left)
	create = 1
	time = 15 SECONDS
	category = "Organ"

/datum/manufacture/cyberlung_right
	name = "Right Cyberlung"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "any" = 1)
	item_outputs = list(/obj/item/organ/lung/cyber/right)
	create = 1
	time = 15 SECONDS
	category = "Organ"

/datum/manufacture/cybereye
	name = "Cybereye"
	item_requirements = list("crystal" = 2,
							 "metal" = 1,
							 "conductive" = 2,
							 "insulated" = 1)
	item_outputs = list(/obj/item/organ/eye/cyber/configurable)
	create = 1
	time = 20 SECONDS
	category = "Organ"

/datum/manufacture/cybereye_sunglass
	name = "Polarized Cybereye"
	item_requirements = list("crystal" = 3,
							 "metal" = 1,
							 "conductive" = 2,
							 "insulated" = 1)
	item_outputs = list(/obj/item/organ/eye/cyber/sunglass)
	create = 1
	time = 25 SECONDS
	category = "Organ"

/datum/manufacture/cybereye_sechud
	name = "Security HUD Cybereye"
	item_requirements = list("crystal" = 3,
							 "metal" = 1,
							 "conductive" = 2,
							 "insulated" = 1)
	item_outputs = list(/obj/item/organ/eye/cyber/sechud)
	create = 1
	time = 25 SECONDS
	category = "Organ"

/datum/manufacture/cybereye_thermal
	name = "Thermal Imager Cybereye"
	item_requirements = list("crystal" = 3,
							 "metal" = 1,
							 "conductive" = 2,
							 "insulated" = 1)
	item_outputs = list(/obj/item/organ/eye/cyber/thermal)
	create = 1
	time = 25 SECONDS
	category = "Organ"

/datum/manufacture/cybereye_meson
	name = "Mesonic Imager Cybereye"
	item_requirements = list("crystal" = 3,
							 "metal" = 1,
							 "conductive" = 2,
							 "insulated" = 1)
	item_outputs = list(/obj/item/organ/eye/cyber/meson)
	create = 1
	time = 25 SECONDS
	category = "Organ"

/datum/manufacture/cybereye_spectro
	name = "Spectroscopic Imager Cybereye"
	item_requirements = list("crystal" = 3,
							 "metal" = 1,
							 "conductive" = 2,
							 "insulated" = 1)
	item_outputs = list(/obj/item/organ/eye/cyber/spectro)
	create = 1
	time = 25 SECONDS
	category = "Organ"

/datum/manufacture/cybereye_prodoc
	name = "ProDoc Healthview Cybereye"
	item_requirements = list("crystal" = 3,
							 "metal" = 1,
							 "conductive" = 2,
							 "insulated" = 1)
	item_outputs = list(/obj/item/organ/eye/cyber/prodoc)
	create = 1
	time = 25 SECONDS
	category = "Organ"

/datum/manufacture/cybereye_camera
	name = "Camera Cybereye"
	item_requirements = list("crystal" = 3,
							 "metal" = 1,
							 "conductive" = 2,
							 "insulated" = 1)
	item_outputs = list(/obj/item/organ/eye/cyber/camera)
	create = 1
	time = 25 SECONDS
	category = "Organ"

/datum/manufacture/cybereye_monitor
	name = "Monitor Cybereye"
	item_requirements = list("crystal" = 3,
							 "metal" = 1,
							 "conductive" = 2,
							 "insulated" = 1)
	item_outputs = list(/obj/item/organ/eye/cyber/monitor)
	create = 1
	time = 25 SECONDS
	category = "Organ"

/datum/manufacture/cybereye_laser
	name = "Laser Cybereye"
	item_requirements = list("crystal" = 3,
							 "metal" = 1,
							 "conductive" = 2,
							 "insulated" = 1,
							 "erebite" = 1)
	item_outputs = list(/obj/item/organ/eye/cyber/laser)
	create = 1
	time = 40 SECONDS
	category = "Organ"

/datum/manufacture/implant_health
	name = "Health Monitor Implant"
	item_requirements = list("conductive" = 3,
							 "crystal" = 3)
	item_outputs = list(/obj/item/implantcase/health)
	create = 1
	time = 40 SECONDS
	category = "Resource"

/datum/manufacture/implant_antirot
	name = "Rotbusttec Implant"
	item_requirements = list("conductive" = 2,
							 "crystal" = 2)
	item_outputs = list(/obj/item/implantcase/antirot)
	create = 1
	time = 30 SECONDS
	category = "Resource"

/datum/manufacture/medicalalertbutton
	name = "Medical Alert Button"
	item_requirements = list("conductive" = 2,
							 "metal" = 2)
	item_outputs = list(/obj/item/device/panicbutton/medicalalert)
	create = 1
	time = 3 SECONDS
	category = "Resource"

#ifdef ENABLE_ARTEMIS
/******************** Artemis **************************/

/datum/manufacture/nav_sat
	name = "Navigation Satellite"
	item_requirements = list("metal_dense" = 1)//AzrunADJUSTPOSTTESTING)
	item_outputs = list(/obj/nav_sat)
	create = 1
	time = 45 SECONDS
	category = "Component"

#endif
/datum/manufacture/stress_ball
	name = "Stress Ball"
	item_requirements = list("fabric" = 1)
	item_outputs = list(/obj/item/toy/plush/small/stress_ball)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/floppydisk //Cloning disks
	name = "Floppy Disk"
	item_requirements = list("metal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/disk/data/floppy)
	create = 1
	time = 5 SECONDS
	category = "Resource"

/******************** Robotics **************************/

/datum/manufacture/robo_frame
	name = "Cyborg Frame"
	item_requirements = list("metal_dense" = ROBOT_FRAME_COST*10)
	item_outputs = list(/obj/item/parts/robot_parts/robot_frame)
	create = 1
	time = 45 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/full_cyborg_standard
	name = "Standard Cyborg Parts"
	item_requirements = list("metal_dense" = (ROBOT_CHEST_COST+ROBOT_HEAD_COST+ROBOT_LIMB_COST*4)*10)
	item_outputs = list(/obj/item/parts/robot_parts/chest/standard,/obj/item/parts/robot_parts/head/standard,
						/obj/item/parts/robot_parts/arm/right/standard,/obj/item/parts/robot_parts/arm/left/standard,
						/obj/item/parts/robot_parts/leg/right/standard,/obj/item/parts/robot_parts/leg/left/standard)
	time = 120 SECONDS
	create = 1
	category = "Component"
	apply_material = TRUE

/datum/manufacture/full_cyborg_light
	name = "Light Cyborg Parts"
	item_requirements = list("metal_dense" = (ROBOT_CHEST_COST+ROBOT_HEAD_COST+ROBOT_LIMB_COST*4)*ROBOT_LIGHT_COST_MOD*10)
	item_outputs = list(/obj/item/parts/robot_parts/chest/light,/obj/item/parts/robot_parts/head/light,
/obj/item/parts/robot_parts/arm/right/light,/obj/item/parts/robot_parts/arm/left/light,
/obj/item/parts/robot_parts/leg/right/light,/obj/item/parts/robot_parts/leg/left/light)
	time = 62 SECONDS
	create = 1
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_chest
	name = "Cyborg Chest"
	item_requirements = list("metal_dense" = ROBOT_CHEST_COST*10)
	item_outputs = list(/obj/item/parts/robot_parts/chest/standard)
	create = 1
	time = 30 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_chest_light
	name = "Light Cyborg Chest"
	item_requirements = list("metal_dense" = ROBOT_CHEST_COST*ROBOT_LIGHT_COST_MOD*10)
	item_outputs = list(/obj/item/parts/robot_parts/chest/light)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_head
	name = "Cyborg Head"
	item_requirements = list("metal_dense" = ROBOT_HEAD_COST*10)
	item_outputs = list(/obj/item/parts/robot_parts/head/standard)
	create = 1
	time = 30 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_head_screen
	name = "Cyborg Screen Head"
	item_requirements = list("metal_dense" = ROBOT_SCREEN_METAL_COST*10,
							 "conductive" = 2,
							 "crystal" = 6)
	item_outputs = list(/obj/item/parts/robot_parts/head/screen)
	create = 1
	time = 24 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_head_light
	name = "Light Cyborg Head"
	item_requirements = list("metal" = ROBOT_HEAD_COST*ROBOT_LIGHT_COST_MOD*10)
	item_outputs = list(/obj/item/parts/robot_parts/head/light)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_arm_r
	name = "Cyborg Arm (Right)"
	item_requirements = list("metal_dense" = ROBOT_LIMB_COST*10)
	item_outputs = list(/obj/item/parts/robot_parts/arm/right/standard)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_arm_r_light
	name = "Light Cyborg Arm (Right)"
	item_requirements = list("metal" = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10)
	item_outputs = list(/obj/item/parts/robot_parts/arm/right/light)
	create = 1
	time = 8 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_arm_l
	name = "Cyborg Arm (Left)"
	item_requirements = list("metal_dense" = ROBOT_LIMB_COST*10)
	item_outputs = list(/obj/item/parts/robot_parts/arm/left/standard)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_arm_l_light
	name = "Light Cyborg Arm (Left)"
	item_requirements = list("metal" = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10)
	item_outputs = list(/obj/item/parts/robot_parts/arm/left/light)
	create = 1
	time = 8 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_leg_r
	name = "Cyborg Leg (Right)"
	item_requirements = list("metal_dense" = ROBOT_LIMB_COST*10)
	item_outputs = list(/obj/item/parts/robot_parts/leg/right/standard)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_leg_r_light
	name = "Light Cyborg Leg (Right)"
	item_requirements = list("metal" = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10)
	item_outputs = list(/obj/item/parts/robot_parts/leg/right/light)
	create = 1
	time = 8 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_leg_l
	name = "Cyborg Leg (Left)"
	item_requirements = list("metal_dense" = ROBOT_LIMB_COST*10)
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/standard)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_leg_l_light
	name = "Light Cyborg Leg (Left)"
	item_requirements = list("metal" = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10)
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/light)
	create = 1
	time = 8 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_leg_treads
	name = "Cyborg Treads"
	item_requirements = list("metal_dense" = ROBOT_TREAD_METAL_COST*2*10,
							 "conductive" = 6)
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/treads, /obj/item/parts/robot_parts/leg/right/treads)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

/datum/manufacture/robo_module
	name = "Blank Cyborg Module"
	item_requirements = list("conductive" = 2,
							 "any" = 3)
	item_outputs = list(/obj/item/robot_module)
	create = 1
	time = 40 SECONDS
	category = "Component"

/datum/manufacture/powercell
	name = "Power Cell"
	item_requirements = list("metal" = 4,
							 "conductive" = 4,
							 "any" = 4)
	item_outputs = list(/obj/item/cell/supercell)
	create = 1
	time = 30 SECONDS
	category = "Component"

/datum/manufacture/powercellE
	name = "Erebite Power Cell"
	item_requirements = list("metal" = 4,
							 "any" = 4,
							 "erebite" = 2)
	item_outputs = list(/obj/item/cell/erebite)
	create = 1
	time = 45 SECONDS
	category = "Component"

/datum/manufacture/powercellC
	name = "Cerenkite Power Cell"
	item_requirements = list("metal" = 4,
							 "any" = 4,
							 "cerenkite" = 2)
	item_outputs = list(/obj/item/cell/cerenkite)
	create = 1
	time = 45 SECONDS
	category = "Component"

/datum/manufacture/powercellH
	name = "Hyper Capacity Power Cell"
	item_requirements = list("dense_super" = 5,
							 "conductive_high" = 10,
							 "energy_high" = 10)
	item_outputs = list(/obj/item/cell/hypercell)
	create = 1
	time = 120 SECONDS
	category = "Component"

/datum/manufacture/core_frame
	name = "AI Core Frame"
	item_requirements = list("metal_dense" = 20)
	item_outputs = list(/obj/ai_core_frame)
	create = 1
	time = 50 SECONDS
	category = "Component"

/datum/manufacture/shell_frame
	name = "AI Shell Frame"
	item_requirements = list("metal_dense" = 12)
	item_outputs = list(/obj/item/shell_frame)
	create = 1
	time = 25 SECONDS
	category = "Component"

/datum/manufacture/ai_interface
	name = "AI Interface Board"
	item_requirements = list("metal_dense" = 3,
							 "conductive" = 5,
							 "crystal" = 2)
	item_outputs = list(/obj/item/ai_interface)
	create = 1
	time = 35 SECONDS
	category = "Component"

/datum/manufacture/latejoin_brain
	name = "Spontaneous Intelligence Creation Core"
	item_requirements = list("metal" = 6,
							 "conductive" = 5,
							 "any" = 3)
	item_outputs = list(/obj/item/organ/brain/latejoin)
	create = 1
	time = 35 SECONDS
	category = "Component"

/datum/manufacture/shell_cell
	name = "AI Shell Power Cell"
	item_requirements = list("metal" = 2,
							 "conductive" = 2,
							 "any" = 1)
	item_outputs = list(/obj/item/cell/shell_cell)
	create = 1
	time = 20 SECONDS
	category = "Component"

/datum/manufacture/flash
	name = "Flash"
	item_requirements = list("metal" = 3,
							 "conductive" = 5,
							 "crystal" = 5)
	item_outputs = list(/obj/item/device/flash)
	create = 1
	time = 15 SECONDS
	category = "Tool"

/datum/manufacture/borg_linker
	name = "AI Linker"
	item_requirements = list("metal" = 2,
							 "crystal" = 1,
							 "conductive" = 2)
	item_outputs = list(/obj/item/device/borg_linker)
	create = 1
	time = 15 SECONDS
	category = "Tool"

/datum/manufacture/asimov_laws
	name = "Standard Asimov Law Module Set"
	item_requirements = list("metal_dense" = 30)
	item_outputs = list(/obj/item/aiModule/asimov1,/obj/item/aiModule/asimov2,/obj/item/aiModule/asimov3)
	create = 1
	time = 60 SECONDS
	category = "Component"

/datum/manufacture/corporate_laws
	name = "Nanotrasen Law Module Set"
	item_requirements = list("metal_dense" = 30)
	item_outputs = list(/obj/item/aiModule/nanotrasen1,/obj/item/aiModule/nanotrasen2,/obj/item/aiModule/nanotrasen3)
	create = 1
	time = 60 SECONDS
	category = "Component"

/datum/manufacture/robocop_laws
	name = "RoboCop Law Module Set"
	item_requirements = list("metal_dense" = 40)
	item_outputs = list(/obj/item/aiModule/robocop1,/obj/item/aiModule/robocop2,/obj/item/aiModule/robocop3,/obj/item/aiModule/robocop4)
	create = 1
	time = 60 SECONDS
	category = "Component"

/datum/manufacture/syndicate_laws
	name = "Syndicate Law Module Set"
	item_requirements = list("metal_dense" = 40)
	item_outputs = list(/obj/item/aiModule/syndicate/law1, /obj/item/aiModule/syndicate/law2, /obj/item/aiModule/syndicate/law3, /obj/item/aiModule/syndicate/law4)
	create = 1
	time = 60 SECONDS
	category = "Component"

ABSTRACT_TYPE(/datum/manufacture/aiModule)
/datum/manufacture/aiModule
	name = "AI Law Module - 'YOU SHOULDNT SEE ME'"
	item_requirements = list("metal_dense" = 10)
	item_outputs = list(/obj/item/aiModule/asimov1)
	create = 1
	time = 20 SECONDS
	category = "Component"

	makeCaptain
		name = "AI Law Module - 'MakeCaptain'"
		item_outputs = list(/obj/item/aiModule/makeCaptain)

	oneHuman
		name = "AI Law Module - 'OneHuman'"
		item_outputs = list(/obj/item/aiModule/oneHuman)

	notHuman
		name = "AI Law Module - 'NotHuman'"
		item_outputs = list(/obj/item/aiModule/notHuman)

	emergency
		name = "AI Law Module - 'Emergency'"
		item_outputs = list(/obj/item/aiModule/emergency)

	removeCrew
		name = "AI Law Module - 'RemoveCrew'"
		item_outputs = list(/obj/item/aiModule/removeCrew)

	freeform
		name = "AI Law Module - 'Freeform'"
		item_outputs = list(/obj/item/aiModule/freeform)


// Robotics Research

/datum/manufacture/implanter
	name = "Implanter"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/implanter)
	create = 1
	time = 3 SECONDS
	category = "Tool"

/datum/manufacture/secbot
	name = "Security Drone"
	item_requirements = list("metal_dense" = 30,
							 "conductive_high" = 20,
							 "energy" = 20)
	item_outputs = list(/obj/machinery/bot/secbot)
	create = 1
	time = 120 SECONDS
	category = "Machinery"

/datum/manufacture/floorbot
	name = "Construction Drone"
	item_requirements = list("metal" = 15,
							 "conductive" = 10,
							 "any" = 5)
	item_outputs = list(/obj/machinery/bot/floorbot)
	create = 1
	time = 60 SECONDS
	category = "Machinery"

/datum/manufacture/medbot
	name = "Medical Drone"
	item_requirements = list("metal" = 20,
							 "conductive" = 15,
							 "energy" = 5)
	item_outputs = list(/obj/machinery/bot/medbot)
	create = 1
	time = 90 SECONDS
	category = "Machinery"

/datum/manufacture/firebot
	name = "Firefighting Drone"
	item_requirements = list("metal" = 15,
							 "conductive" = 10,
							 "any" = 5)
	item_outputs = list(/obj/machinery/bot/firebot)
	create = 1
	time = 60 SECONDS
	category = "Machinery"

/datum/manufacture/cleanbot
	name = "Sanitation Drone"
	item_requirements = list("metal" = 15,
							 "conductive" = 10,
							 "any" = 5)
	item_outputs = list(/obj/machinery/bot/cleanbot)
	create = 1
	time = 60 SECONDS
	category = "Machinery"

/datum/manufacture/digbot
	name = "Mining Drone"
	item_requirements = list("metal" = 15,
							 "metal_dense" = 5,
							 "conductive" = 10,
							 "any" = 5)
	item_outputs = list(/obj/machinery/bot/mining)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

/datum/manufacture/robup_jetpack
	name = "Propulsion Upgrade"
	item_requirements = list("conductive" = 3,
							 "metal" = 5)
	item_outputs = list(/obj/item/roboupgrade/jetpack)
	create = 1
	time = 60 SECONDS
	category = "Component"

/datum/manufacture/robup_speed
	name = "Speed Upgrade"
	item_requirements = list("conductive" = 3,
							 "crystal" = 5)
	item_outputs = list(/obj/item/roboupgrade/speed)
	create = 1
	time = 60 SECONDS
	category = "Component"

/datum/manufacture/robup_mag
	name = "Magnetic Traction Upgrade"
	item_requirements = list("conductive" = 5,
							 "crystal" = 3)
	item_outputs = list(/obj/item/roboupgrade/magboot)
	create = 1
	time = 60 SECONDS
	category = "Component"

/datum/manufacture/robup_recharge
	name = "Recharge Pack"
	item_requirements = list("conductive" = 5)
	item_outputs = list(/obj/item/roboupgrade/rechargepack)
	create = 1
	time = 60 SECONDS
	category = "Component"

/datum/manufacture/robup_repairpack
	name = "Repair Pack"
	item_requirements = list("conductive" = 5)
	item_outputs = list(/obj/item/roboupgrade/repairpack)
	create = 1
	time = 60 SECONDS
	category = "Component"

/datum/manufacture/robup_physshield
	name = "Force Shield Upgrade"
	item_requirements = list("conductive_high" = 2,
							 "metal_dense" = 10,
							 "energy_high" = 2)
	item_outputs = list(/obj/item/roboupgrade/physshield)
	create = 1
	time = 90 SECONDS
	category = "Component"

/datum/manufacture/robup_fireshield
	name = "Heat Shield Upgrade"
	item_requirements = list("conductive_high" = 2,
							 "crystal" = 10)
	item_outputs = list(/obj/item/roboupgrade/fireshield)
	create = 1
	time = 90 SECONDS
	category = "Component"

/datum/manufacture/robup_aware
	name = "Recovery Upgrade"
	item_requirements = list("conductive_high" = 2,
							 "crystal" = 5,
							 "conductive" = 5)
	item_outputs = list(/obj/item/roboupgrade/aware)
	create = 1
	time = 90 SECONDS
	category = "Component"

/datum/manufacture/robup_efficiency
	name = "Efficiency Upgrade"
	item_requirements = list("dense" = 3,
							 "conductive_high" = 10)
	item_outputs = list(/obj/item/roboupgrade/efficiency)
	create = 1
	time = 120 SECONDS
	category = "Component"

/datum/manufacture/robup_repair
	name = "Self-Repair Upgrade"
	item_requirements = list("dense" = 3,
							 "metal_superdense" = 10)
	item_outputs = list(/obj/item/roboupgrade/repair)
	create = 1
	time = 120 SECONDS
	category = "Component"

/datum/manufacture/robup_teleport
	name = "Teleport Upgrade"
	item_requirements = list("conductive" = 10,
							 "dense" = 1,
							 "energy_high" = 10)//Okayenoughroundstartteleportborgs.Fuck.
	item_outputs = list(/obj/item/roboupgrade/teleport)
	create = 1
	time = 120 SECONDS
	category = "Component"

/datum/manufacture/robup_expand
	name = "Expansion Upgrade"
	item_requirements = list("crystal_dense" = 3,
							 "energy_extreme" = 1)
	item_outputs = list(/obj/item/roboupgrade/expand)
	create = 1
	time = 120 SECONDS
	category = "Component"

/datum/manufacture/robup_meson
	name = "Optical Meson Upgrade"
	item_requirements = list("crystal" = 2,
							 "conductive" = 4)
	item_outputs = list(/obj/item/roboupgrade/opticmeson)
	create = 1
	time = 90 SECONDS
	category = "Component"
/* shit done be broked
/datum/manufacture/robup_thermal
	name = "Optical Thermal Upgrade"
	item_requirements = list("crystal" = 4,
							 "conductive" = 8)
	item_outputs = list(/obj/item/roboupgrade/opticthermal)
	create = 1
	time = 90 SECONDS
	category = "Component"
*/
/datum/manufacture/robup_healthgoggles
	name = "ProDoc Healthgoggle Upgrade"
	item_requirements = list("crystal" = 4,
							 "conductive" = 6)
	item_outputs = list(/obj/item/roboupgrade/healthgoggles)
	create = 1
	time = 90 SECONDS
	category = "Component"

/datum/manufacture/robup_sechudgoggles
	name = "Security HUD Upgrade"
	item_requirements = list("crystal" = 4,
							 "conductive" = 6)
	item_outputs = list(/obj/item/roboupgrade/sechudgoggles)
	create = 1
	time = 90 SECONDS
	category = "Component"

/datum/manufacture/robup_spectro
	name = "Spectroscopic Scanner Upgrade"
	item_requirements = list("crystal" = 4,
							 "conductive" = 6)
	item_outputs = list(/obj/item/roboupgrade/spectro)
	create = 1
	time = 90 SECONDS
	category = "Component"

/datum/manufacture/robup_visualizer
	name = "Construction Visualizer"
	item_requirements = list("crystal" = 4,
							 "conductive" = 6)
	item_outputs = list(/obj/item/roboupgrade/visualizer)
	create = 1
	time = 90 SECONDS
	category = "Component"

/datum/manufacture/implant_robotalk
	name = "Machine Translator Implant"
	item_requirements = list("conductive" = 3,
							 "crystal" = 3)
	item_outputs = list(/obj/item/implantcase/robotalk)
	create = 1
	time = 40 SECONDS
	category = "Resource"


/datum/manufacture/sbradio
	name = "Station Bounced Radio"
	item_requirements = list("conductive" = 2,
							 "crystal" = 2)
	item_outputs = list(/obj/item/device/radio)
	create = 1
	time = 20 SECONDS
	category = "Resource"

/datum/manufacture/thrusters
	name = "Alastor Pattern Thrusters"
	item_requirements = list("metal_dense" = ROBOT_THRUSTER_COST*2*10)
	item_outputs = list(/obj/item/parts/robot_parts/leg/right/thruster,/obj/item/parts/robot_parts/leg/left/thruster)
	create = 1
	time = 120 SECONDS
	category = "Component"
	apply_material = TRUE

/******************** Science **************************/

/datum/manufacture/biosuit
	name = "Biosuit Set"
	item_requirements = list("fabric" = 5,
							 "crystal" = 2)
	item_outputs = list(/obj/item/clothing/suit/hazard/bio_suit,/obj/item/clothing/head/bio_hood)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/spectrogoggles
	name = "Spectroscopic Scanner Goggles"
	item_requirements = list("metal" = 1,
							 "crystal" = 2)
	item_outputs = list(/obj/item/clothing/glasses/spectro)
	create = 1
	time = 20 SECONDS
	category = "Clothing"

/datum/manufacture/gasmask
	name = "Gas Mask"
	item_requirements = list("fabric" = 2,
							 "metal_dense" = 4,
							 "crystal" = 2)
	item_outputs = list(/obj/item/clothing/mask/gas)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/dropper
	name = "Dropper"
	item_requirements = list("insulated" = 1,
							 "crystal" = 2)
	item_outputs = list(/obj/item/reagent_containers/dropper)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/mechdropper
	name = "Mechanical Dropper"
	item_requirements = list("metal" = 3,
							 "conductive" = 3)
	item_outputs = list(/obj/item/reagent_containers/dropper/mechanical)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/gps
	name = "Space GPS"
	item_requirements = list("metal" = 1,
							 "conductive" = 1)
	item_outputs = list(/obj/item/device/gps)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/reagentscanner
	name = "Reagent Scanner"
	item_requirements = list("metal" = 2,
							 "conductive" = 2,
							 "crystal" = 1)
	item_outputs = list(/obj/item/device/reagentscanner)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/artifactforms
	name = "Artifact Analysis Forms"
	item_requirements = list("metal" = 2,
							 "fabric" = 5)
	item_outputs = list(/obj/item/paper_bin/artifact_paper)
	create = 1
	time = 10 SECONDS
	category = "Resource"

/datum/manufacture/audiotape
	name = "Audio Tape"
	item_requirements = list("metal" = 2)
	item_outputs = list(/obj/item/audio_tape)
	create = 1
	time = 4 SECONDS
	category = "Tool"

/datum/manufacture/audiolog
	name = "Audio Log"
	item_requirements = list("metal" = 3,
							 "conductive" = 5)
	item_outputs = list(/obj/item/device/audio_log)
	create = 1
	time = 5 SECONDS
	category = "Tool"

// Mining Gear
#ifndef UNDERWATER_MAP
/datum/manufacture/mining_magnet
	name = "Mining Magnet Replacement Parts"
	item_requirements = list("dense" = 5,
							 "metal_superdense" = 30,
							 "conductive_high" = 30)
	item_outputs = list(/obj/item/magnet_parts)
	create = 1
	time = 120 SECONDS
	category = "Component"
#endif

/datum/manufacture/pick
	name = "Pickaxe"
	item_requirements = list("metal_dense" = 1)
	item_outputs = list(/obj/item/mining_tool)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/powerpick
	name = "Powered Pick"
	item_requirements = list("metal_dense" = 2,
							 "conductive" = 5)
	item_outputs = list(/obj/item/mining_tool/powered/pickaxe)
	create = 1
	time = 10 SECONDS
	category = "Tool"

/datum/manufacture/blastchargeslite
	name = "Low-Yield Mining Explosives (x5)"
	item_requirements = list("metal" = 3,
							 "crystal" = 3,
							 "conductive" = 7)
	item_outputs = list(/obj/item/breaching_charge/mining/light)
	create = 5
	time = 40 SECONDS
	category = "Resource"

/datum/manufacture/blastcharges
	name = "Mining Explosives (x5)"
	item_requirements = list("metal" = 7,
							 "crystal" = 7,
							 "conductive" = 15)
	item_outputs = list(/obj/item/breaching_charge/mining)
	create = 5
	time = 60 SECONDS
	category = "Resource"

/datum/manufacture/powerhammer
	name = "Power Hammer"
	item_requirements = list("metal_dense" = 15,
							 "metal_superdense" = 7,
							 "conductive" = 10)
	item_outputs = list(/obj/item/mining_tool/powered/hammer)
	create = 1
	time = 70 SECONDS
	category = "Tool"

/datum/manufacture/drill
	name = "Laser Drill"
	item_requirements = list("metal_dense" = 15,
							 "conductive_high" = 10)
	item_outputs = list(/obj/item/mining_tool/powered/drill)
	create = 1
	time = 90 SECONDS
	category = "Tool"

/datum/manufacture/conc_gloves
	name = "Concussive Gauntlets"
	item_requirements = list("metal_superdense" = 15,
							 "conductive_high" = 15,
							 "energy" = 2)
	item_outputs = list(/obj/item/clothing/gloves/concussive)
	create = 1
	time = 120 SECONDS
	category = "Tool"

/datum/manufacture/ore_accumulator
	name = "Mineral Accumulator"
	item_requirements = list("metal_dense" = 25,
							 "conductive_high" = 15,
							 "dense" = 2)
	item_outputs = list(/obj/machinery/oreaccumulator)
	create = 1
	time = 120 SECONDS
	category = "Machinery"

/datum/manufacture/eyes_meson
	name = "Optical Meson Scanner"
	item_requirements = list("crystal" = 3,
							 "conductive" = 2)
	item_outputs = list(/obj/item/clothing/glasses/toggleable/meson)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/atmos_goggles
	name = "Pressure Visualization Goggles"
	item_requirements = list("crystal" = 3,
							 "conductive" = 2)
	item_outputs = list(/obj/item/clothing/glasses/toggleable/atmos)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/geoscanner
	name = "Geological Scanner"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "crystal" = 1)
	item_outputs = list(/obj/item/oreprospector)
	create = 1
	time = 8 SECONDS
	category = "Tool"

/datum/manufacture/ore_scoop
	name = "Ore Scoop"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "crystal" = 1)
	item_outputs = list(/obj/item/ore_scoop)
	item_names = list("Metal","Conductive Material","Crystal")
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/geigercounter
	name = "Geiger Counter"
	item_requirements = list("metal" = 1,
							 "conductive" = 1,
							 "crystal" = 1)
	item_outputs = list(/obj/item/device/geiger)
	create = 1
	time = 8 SECONDS
	category = "Tool"

/datum/manufacture/industrialarmor
	name = "Industrial Space Armor Set"
	item_requirements = list("metal_superdense" = 15,
							 "conductive_high" = 10,
							 "crystal_dense" = 5)
	item_outputs = list(/obj/item/clothing/suit/space/industrial,/obj/item/clothing/head/helmet/space/industrial)
	create = 1
	time = 90 SECONDS
	category = "Clothing"

/datum/manufacture/industrialboots
	name = "Mechanised Boots"
	item_outputs = list(/obj/item/clothing/shoes/industrial)
	create = 1
	time = 40 SECONDS
	category = "Clothing"

/datum/manufacture/jetpackmkII
	name = "Jetpack MKII"
	item_requirements = list("metal_dense" = 15,
							 "conductive_high" = 10,
							 "energy" = 5)
	item_outputs = list(/obj/item/tank/jetpack/jetpackmk2)
	create = 1
	time = 40 SECONDS
	category = "Clothing"

/datum/manufacture/breathmask
	name = "Breath Mask"
	item_requirements = list("fabric" = 1)
	item_outputs = list(/obj/item/clothing/mask/breath)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/gastank
	name = "Gas tank"
	item_requirements = list("metal_dense" = 1)
	item_outputs = list(/obj/item/tank/empty)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/miniplasmatank
	name = "Mini plasma tank"
	item_requirements = list("metal_dense" = 1)
	item_outputs = list(/obj/item/tank/mini_plasma/empty)
	create = 1
	time = 5 SECONDS
	category = "Resource"

/datum/manufacture/minioxygentank
	name = "Mini oxygen tank"
	item_requirements = list("metal_dense" = 1)
	item_outputs = list(/obj/item/tank/mini_oxygen/empty)
	create = 1
	time = 5 SECONDS
	category = "Resource"

/datum/manufacture/patch
	name = "Chemical Patch"
	item_requirements = list("fabric" = 1)
	item_outputs = list(/obj/item/reagent_containers/patch)
	create = 2
	time = 5 SECONDS
	category = "Resource"

/datum/manufacture/mender
	name = "Auto Mender"
	item_requirements = list("metal_dense" = 5,
							 "crystal" = 4,
							 "gold" = 5)
	item_outputs = list(/obj/item/reagent_containers/mender)
	create = 2
	time = 30 SECONDS
	category = "Resource"

/datum/manufacture/penlight
	name = "Penlight"
	item_requirements = list("metal" = 1,
							 "crystal" = 1)
	item_outputs = list(/obj/item/device/light/flashlight/penlight)
	create = 1
	time = 2 SECONDS
	category = "Tool"

/datum/manufacture/stethoscope
	name = "Stethoscope"
	item_requirements = list("metal" = 2,
							 "crystal" = 1)
	item_outputs = list(/obj/item/medicaldiagnosis/stethoscope)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/spacesuit
	name = "Space Suit Set"
	item_requirements = list("fabric" = 3,
							 "metal" = 3,
							 "crystal" = 2)
	item_outputs = list(/obj/item/clothing/suit/space,/obj/item/clothing/head/helmet/space)
	create = 1
	time = 15 SECONDS
	category = "Clothing"

/datum/manufacture/engspacesuit
	name = "Engineering Space Suit Set"
	item_requirements = list("fabric" = 3,
							 "metal" = 3,
							 "crystal" = 2)
	item_outputs = list(/obj/item/clothing/suit/space/engineer,/obj/item/clothing/head/helmet/space/engineer)
	create = 1
	time = 15 SECONDS
	category = "Clothing"

/datum/manufacture/engdivesuit
	name = "Engineering Diving Suit Set"
	item_requirements = list("fabric" = 3,
							 "metal" = 3,
							 "crystal" = 2)
	item_outputs = list(/obj/item/clothing/suit/space/diving/engineering,/obj/item/clothing/head/helmet/space/engineer/diving/engineering)
	create = 1
	time = 15 SECONDS
	category = "Clothing"

/datum/manufacture/lightengspacesuit
	name = "Light Engineering Space Suit Set"
	item_requirements = list("fabric" = 10,
							 "metal_superdense" = 5,
							 "crystal" = 2,
							 "organic_or_rubber" = 5)
	item_outputs = list(/obj/item/clothing/suit/space/light/engineer,/obj/item/clothing/head/helmet/space/light/engineer)
	create = 1
	time = 15 SECONDS
	category = "Clothing"

/datum/manufacture/oresatchel
	name = "Ore Satchel"
	item_requirements = list("fabric" = 5)
	item_outputs = list(/obj/item/satchel/mining)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/oresatchelL
	name = "Large Ore Satchel"
	item_requirements = list("fabric" = 25,
							 "metal_superdense" = 3)
	item_outputs = list(/obj/item/satchel/mining/large)
	create = 1
	time = 15 SECONDS
	category = "Tool"

/datum/manufacture/jetpack
	name = "Jetpack"
	item_requirements = list("metal_superdense" = 10,
							 "conductive_high" = 20)
	item_outputs = list(/obj/item/tank/jetpack)
	create = 1
	time = 60 SECONDS
	category = "Clothing"

/datum/manufacture/microjetpack
	name = "Micro Jetpack"
	item_requirements = list("metal_dense" = 5,
							 "conductive" = 10)
	item_outputs = list(/obj/item/tank/jetpack/micro)
	create = 1
	time = 30 SECONDS
	category = "Clothing"

/// Ship Items -- OLD COMPONENTS

/datum/manufacture/engine
	name = "Warp-1 Engine"
	item_requirements = list("metal_dense" = 3,
							 "conductive" = 5)
	item_outputs = list(/obj/item/shipcomponent/engine)
	create = 1
	time = 10 SECONDS
	category = "Resource"

/datum/manufacture/engine2
	name = "Helios Mark-II Engine"
	item_requirements = list("metal_dense" = 20,
							 "metal_superdense" = 10,
							 "conductive_high" = 15)
	item_outputs = list(/obj/item/shipcomponent/engine/helios)
	create = 1
	time = 90 SECONDS
	category = "Resource"

/datum/manufacture/engine3
	name = "Hermes 3.0 Engine"
	item_requirements = list("metal_superdense" = 20,
							 "conductive_high" = 20,
							 "energy" = 5)
	item_outputs = list(/obj/item/shipcomponent/engine/hermes)
	create = 1
	time = 120 SECONDS
	category = "Resource"


/datum/manufacture/podgps
	name = "Ship's Navigation GPS"
	item_requirements = list("metal" = 5,
							 "conductive" = 5)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/gps)
	create = 1
	time = 12 SECONDS
	category = "Resource"

/datum/manufacture/cargohold
	name = "Cargo Hold"
	item_requirements = list("metal_dense" = 20)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/cargo)
	create = 1
	time = 12 SECONDS
	category = "Resource"

/datum/manufacture/storagehold
	name = "Storage Hold"
	item_requirements = list("metal_dense" = 20)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/storage)
	create = 1
	time = 12 SECONDS
	category = "Resource"

/datum/manufacture/orescoop
	name = "Alloyed Solutions Ore Scoop/Hold"
	item_requirements = list("metal_dense" = 20,
							 "conductive" = 10)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/orescoop)
	create = 1
	time = 12 SECONDS
	category = "Resource"

/datum/manufacture/communications
	name = "Robustco Communication Array"
	item_requirements = list("metal_dense" = 10,
							 "conductive" = 20)
	item_outputs = list(/obj/item/shipcomponent/communications)
	create = 1
	time = 12 SECONDS
	category = "Resource"

/datum/manufacture/communications/mining
	name = "NT Magnet Link Array"
	item_requirements = list("metal_dense" = 10,
							 "conductive" = 20)
	item_outputs = list(/obj/item/shipcomponent/communications/mining)
	create = 1
	time = 12 SECONDS
	category = "Resource"

/datum/manufacture/conclave
	name = "Conclave A-1984 Sensor System"
	item_requirements = list("energy" = 1,
							 "crystal" = 5,
							 "conductive_high" = 2)
	item_outputs = list(/obj/item/shipcomponent/sensor/mining)
	create = 1
	time = 5 SECONDS
	category = "Resource"

/datum/manufacture/shipRCD
	name = "Duracorp Construction Device"
	item_requirements = list("metal_superdense" = 5,
							 "dense" = 1,
							 "conductive" = 10)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/cargo)
	create = 1
	time = 90 SECONDS
	category = "Resource"

//  cogwerks - clothing manufacturer datums

/datum/manufacture/backpack
	name = "Backpack"
	item_requirements = list("fabric" = 8)
	item_outputs = list(/obj/item/storage/backpack)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/backpack_red
	name = "Red Backpack"
	item_requirements = list("fabric" = 8)
	item_outputs = list(/obj/item/storage/backpack/empty/red)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/backpack_green
	name = "Green Backpack"
	item_requirements = list("fabric" = 8)
	item_outputs = list(/obj/item/storage/backpack/empty/green)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/backpack_blue
	name = "Blue Backpack"
	item_requirements = list("fabric" = 8)
	item_outputs = list(/obj/item/storage/backpack/empty/blue)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/satchel
	name = "Satchel"
	item_requirements = list("fabric" = 8)
	item_outputs = list(/obj/item/storage/backpack/satchel/empty)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/satchel_red
	name = "Red Satchel"
	item_requirements = list("fabric" = 8)
	item_outputs = list(/obj/item/storage/backpack/satchel/empty/red)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/satchel_green
	name = "Green Satchel"
	item_requirements = list("fabric" = 8)
	item_outputs = list(/obj/item/storage/backpack/satchel/empty/green)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/satchel_blue
	name = "Blue Satchel"
	item_requirements = list("fabric" = 8)
	item_outputs = list(/obj/item/storage/backpack/satchel/empty/blue)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/shoes_brown
	name = "Brown Shoes"
	item_requirements = list("fabric" = 2)
	item_outputs = list(/obj/item/clothing/shoes/brown)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_white
	name = "White Hat"
	item_requirements = list("fabric" = 2)
	item_outputs = list(/obj/item/clothing/head/white)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_black
	name = "Black Hat"
	item_requirements = list("fabric" = 2)
	item_outputs = list(/obj/item/clothing/head/black)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_blue
	name = "Blue Hat"
	item_requirements = list("fabric" = 2)
	item_outputs = list(/obj/item/clothing/head/blue)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_red
	name = "Red Hat"
	item_requirements = list("fabric" = 2)
	item_outputs = list(/obj/item/clothing/head/red)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_green
	name = "Green Hat"
	item_requirements = list("fabric" = 2)
	item_outputs = list(/obj/item/clothing/head/green)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_yellow
	name = "Yellow Hat"
	item_requirements = list("fabric" = 2)
	item_outputs = list(/obj/item/clothing/head/yellow)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_pink
	name = "Pink Hat"
	item_requirements = list("fabric" = 2)
	item_outputs = list(/obj/item/clothing/head/pink)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_orange
	name = "Orange Hat"
	item_requirements = list("fabric" = 2)
	item_outputs = list(/obj/item/clothing/head/orange)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_purple
	name = "Purple Hat"
	item_requirements = list("fabric" = 2)
	item_outputs = list(/obj/item/clothing/head/purple)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_tophat
	name = "Top Hat"
	item_requirements = list("fabric" = 3)
	item_outputs = list(/obj/item/clothing/head/that)
	create = 1
	time = 3 SECONDS
	category = "Clothing"

/datum/manufacture/hat_ltophat
	name = "Large Top Hat"
	item_requirements = list("fabric" = 5)
	item_outputs = list(/obj/item/clothing/head/longtophat)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_white
	name = "White Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/color/white)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_red
	name = "Red Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/color/red)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_yellow
	name = "Yellow Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/color/yellow)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_green
	name = "Green Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/color/green)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_pink
	name = "Pink Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/color/pink)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_blue
	name = "Blue Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/color/blue)
	create = 1
	time = 5 SECONDS
	category = "Clothing"


/datum/manufacture/jumpsuit_purple
	name = "Purple Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/color/purple)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_brown
	name = "Brown Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/color/brown)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_black
	name = "Black Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/color)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_orange
	name = "Orange Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/color/orange)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/tricolor
	name = "Tricolor Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/misc/tricolor)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_lgbt
	name = "LGBT Pride Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/pride)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_ace
	name = "Asexual Pride Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/pride/ace)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_aro
	name = "Aromantic Pride Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/pride/aro)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_bi
	name = "Bisexual Pride Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/pride/bi)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_inter
	name = "Intersex Pride Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/pride/inter)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_lesb
	name = "Lesbian Pride Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/pride/lesb)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_gay
	name = "Gay Pride Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/pride/gaymasc)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_nb
	name = "Non-binary Pride Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/pride/nb)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_pan
	name = "Pansexual Pride Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/pride/pan)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_poly
	name = "Polysexual Pride Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/pride/poly)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_trans
	name = "Trans Pride Jumpsuit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/pride/trans)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/suit_black
	name = "Fancy Black Suit"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/suit/black)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/dress_black
	name = "Fancy Black Dress"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/suit/black/dress)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/labcoat
	name = "Labcoat"
	item_requirements = list("fabric" = 4)
	item_outputs = list(/obj/item/clothing/suit/labcoat)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_white
	name = "White Scrubs"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/scrub)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_teal
	name = "Teal Scrubs"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/scrub/teal)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_maroon
	name = "Maroon Scrubs"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/scrub/maroon)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_blue
	name = "Navy Scrubs"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/scrub/blue)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_purple
	name = "Violet Scrubs"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/scrub/purple)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_orange
	name = "Orange Scrubs"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/scrub/orange)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_pink
	name = "Hot Pink Scrubs"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/scrub/pink)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/medical_backpack
	name = "Medical Backpack"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/storage/backpack/medic)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/patient_gown
	name = "Gown"
	item_requirements = list("fabric" = JUMPSUIT_COST)
	item_outputs = list(/obj/item/clothing/under/patient_gown)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/surgical_mask
	name = "Sterile Mask"
	item_requirements = list("fabric" = 1)
	item_outputs = list(/obj/item/clothing/mask/surgical)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/surgical_shield
	name = "Surgical Face Shield"
	item_requirements = list("fabric" = 1)
	item_outputs = list(/obj/item/clothing/mask/surgical_shield)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/eyepatch
	name = "Medical Eyepatch"
	item_requirements = list("fabric" = 5)
	item_outputs = list(/obj/item/clothing/glasses/eyepatch)
	create = 1
	time = 15 SECONDS
	category = "Clothing"

/datum/manufacture/blindfold
	name = "Blindfold"
	item_requirements = list("fabric" = 4)
	item_outputs = list(/obj/item/clothing/glasses/blindfold)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/muzzle
	name = "Muzzle"
	item_requirements = list("fabric" = 4,
							 "metal" = 2)
	item_outputs = list(/obj/item/clothing/mask/muzzle)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/hermes
	name = "Offering to the Fabricator Gods"
	item_requirements = list("metal_superdense" = 30,
							 "conductive_high" = 30,
							 "energy_extreme" = 6,
							 "crystal_dense" = 1,
							 "fabric" = 30,
							 "insulated" = 30)
	item_outputs = list(/obj/item/clothing/shoes/hermes)
	create = 3 //because a shoe god has to have acolytes
	time = 120 //suspense
	category = "Clothing"

/datum/manufacture/towel
	name = "Towel"
	item_requirements = list("fabric" = 8)
	item_outputs = list(/obj/item/cloth/towel/white)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/handkerchief
	name = "Handkerchief"
	item_requirements = list("fabric" = 4)
	item_outputs = list(/obj/item/cloth/handkerchief/colored/white)
	create = 1
	time = 4 SECONDS
	category = "Resource"

/////// pod construction components

/datum/manufacture/pod/armor_light
	name = "Light Pod Armor"
	item_requirements = list("metal_dense" = 30,
							 "conductive" = 20)
	item_outputs = list(/obj/item/podarmor/armor_light)
	create = 1
	time = 20 SECONDS
	category = "Component"

/datum/manufacture/pod/armor_heavy
	name = "Heavy Pod Armor"
	item_requirements = list("metal_dense" = 30,
							 "metal_superdense" = 20)
	item_outputs = list(/obj/item/podarmor/armor_heavy)
	create = 1
	time = 30 SECONDS
	category = "Component"

/datum/manufacture/pod/armor_industrial
	name = "Industrial Pod Armor"
	item_requirements = list("metal_superdense" = 25,
							 "conductive_high" = 10,
							 "dense" = 5)
	item_outputs = list(/obj/item/podarmor/armor_industrial)
	create = 1
	time = 50 SECONDS
	category = "Component"

/datum/manufacture/pod/preassembeled_parts
	name = "Preassembled Pod Frame Kit"
	item_requirements = list("metal_dense" = 45,
							 "conductive" = 25,
							 "crystal" = 19)
	item_outputs = list(/obj/item/preassembled_frame_box/pod)
	create = 1
	time = 50 SECONDS
	category = "Component"

ABSTRACT_TYPE(/datum/manufacture/sub)
/datum/manufacture/sub/preassembeled_parts
	name = "Preassembled Minisub Frame Kit"
	item_requirements = list("metal_dense" = 23,
							 "conductive" = 12,
							 "crystal" = 9)
	item_outputs = list(/obj/item/preassembled_frame_box/sub)
	create = 1
	time = 25 SECONDS
	category = "Component"

ABSTRACT_TYPE(/datum/manufacture/putt)
/datum/manufacture/putt/preassembeled_parts
	name = "Preassembled MiniPutt Frame Kit"
	item_requirements = list("metal_dense" = 23,
							 "conductive" = 12,
							 "crystal" = 9)
	item_outputs = list(/obj/item/preassembled_frame_box/putt)
	create = 1
	time = 25 SECONDS
	category = "Component"

//// pod addons

ABSTRACT_TYPE(/datum/manufacture/pod)

ABSTRACT_TYPE(/datum/manufacture/pod/weapon)

/datum/manufacture/pod/weapon/bad_mining
	name = "Mining Phaser System"
	item_requirements = list("metal_dense" = 10,
							 "conductive" = 10,
							 "crystal" = 20)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/bad_mining)
	create = 1
	time = 20 SECONDS
	category = "Tool"

/datum/manufacture/pod/weapon/mining
	name = "Plasma Cutter System"
	item_requirements = list("energy" = 10,
							 "metal_superdense" = 10,
							 "crystal_dense" = 20)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/mining)
	create = 1
	time = 20 SECONDS
	category = "Tool"

/datum/manufacture/pod/weapon/mining/drill
	name = "Rock Drilling Rig"
	item_requirements = list("energy" = 10,
							 "metal_superdense" = 10,
							 "crystal_dense" = 10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/rockdrills)
	create = 1
	time = 20 SECONDS
	category = "Tool"

/datum/manufacture/pod/weapon/ltlaser
	name = "Mk.1.5 Light Phasers"
	item_requirements = list("metal_dense" = 15,
							 "conductive" = 15,
							 "crystal" = 15)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/phaser)
	create = 1
	time = 20 SECONDS
	category = "Tool"

/datum/manufacture/pod/weapon/efif1
	name = "EFIF-1 Construction System"
	item_requirements = list("metal_superdense" = 50,
							 "claretine" = 20,
							 "electrum" = 10)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/constructor)
	create = 1
	time = 60 SECONDS
	category = "Tool"

/datum/manufacture/pod/lock
	name = "Pod Locking Mechanism"
	item_requirements = list("crystal" = 5,
							 "conductive" = 10)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/lock)
	create = 1
	time = 10 SECONDS
	category = "Tool"


/datum/manufacture/lateral_thrusters
	name = "Lateral Thrusters"
	item_requirements = list("metal_dense" = 20,
							 "conductive" = 10,
							 "energy" = 20)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/lateral_thrusters)
	create = 1
	time = 12 SECONDS
	category = "Tool"

/datum/manufacture/pod/sps
	name = "Syndicate Purge System"
	item_requirements = list("metal" = 8,
							 "conductive" = 12,
							 "crystal" = 16)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/syndicate_purge_system)
	create = 1
	time = 90 SECONDS
	category = "Tool"

/datum/manufacture/pod/srs
	name = "Syndicate Rewind System"
	item_requirements = list("metal" = 16,
							 "conductive" = 12,
							 "crystal" = 8)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/syndicate_rewind_system)
	create = 1
	time = 90 SECONDS
	category = "Tool"
//// deployable warp beacon

/datum/manufacture/beaconkit
	name = "Warp Beacon Frame"
	item_requirements = list("crystal" = 10,
							 "conductive" = 10,
							 "metal_dense" = 10)
	item_outputs = list(/obj/beaconkit)
	item_names = list("Crystal","Conductive Material","Sturdy Metal")
	create = 1
	time = 30 SECONDS
	category = "Machinery"


/******************** HOP *******************/

/datum/manufacture/id_card
	name = "ID card"
	item_requirements = list("conductive" = 3,
							 "crystal" = 3)
	item_outputs = list(/obj/item/card/id)
	create = 1
	time = 5 SECONDS
	category = "Resource"

/datum/manufacture/id_card_gold
	name = "Gold ID card"
	item_requirements = list("gold" = 5,
							 "conductive_high" = 4,
							 "crystal" = 3)
	item_outputs = list(/obj/item/card/id/gold)
	create = 1
	time = 30 SECONDS
	category = "Resource"

/datum/manufacture/implant_access
	name = "Electronic Access Implant (8 Access Charges)"
	item_requirements = list("conductive" = 3,
							 "crystal" = 3)
	item_outputs = list(/obj/item/implantcase/access)
	create = 1
	time = 20 SECONDS
	category = "Resource"

/datum/manufacture/acesscase
	name = "ID Briefcase"
	item_requirements = list("conductive" = 25,
							 "crystal" = 15,
							 "metal" = 35,
							 "gold" = 2)
	item_outputs = list(/obj/machinery/computer/card/portable)
	create = 1
	time = 75 SECONDS
	category = "Resource"

/datum/manufacture/implant_access_infinite
	name = "Electronic Access Implant (Unlimited Charge)"
	item_requirements = list("conductive" = 9,
							 "crystal" = 15)
	item_outputs = list(/obj/item/implantcase/access/unlimited)
	create = 1
	time = 60 SECONDS
	category = "Resource"

/******************** QM CRATES *******************/

/datum/manufacture/crate
	name = "Crate"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/storage/crate)
	create = 1
	time = 10 SECONDS
	category = "Miscellaneous"

/datum/manufacture/packingcrate
	name = "Random Packing Crate"
	item_requirements = list("wood" = 1)
	item_outputs = list(/obj/storage/crate/packing)
	create = 1
	time = 10 SECONDS
	category = "Miscellaneous"

/datum/manufacture/wooden
	name = "Wooden Crate"
	item_requirements = list("wood" = 1)
	item_outputs = list(/obj/storage/crate/wooden)
	create = 1
	time = 10 SECONDS
	category = "Miscellaneous"

/datum/manufacture/medical
	name = "Medical Crate"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/storage/crate/medical)
	create = 1
	time = 10 SECONDS
	category = "Miscellaneous"

/datum/manufacture/biohazard
	name = "Biohazard Crate"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/storage/crate/biohazard)
	create = 1
	time = 10 SECONDS
	category = "Miscellaneous"

/datum/manufacture/classcrate
	name = "Class Crate"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/storage/crate/classcrate)
	create = 1
	time = 10 SECONDS
	category = "Miscellaneous"

/datum/manufacture/freezer
	name = "Freezer Crate"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/storage/crate/freezer)
	create = 1
	time = 10 SECONDS
	category = "Miscellaneous"
/******************** GUNS *******************/

/datum/manufacture/alastor
	name = "Alastor Pattern Laser Rifle"
	item_requirements = list("dense" = 1,
							 "metal_superdense" = 10,
							 "conductive" = 20,
							 "crystal" = 20)
	item_outputs = list(/obj/item/gun/energy/alastor)
	create = 1
	time = 30 SECONDS
	category = "Tool"

/************ INTERDICTOR STUFF ************/

/datum/manufacture/interdictor_kit
	name = "Interdictor Frame Kit"
	item_requirements = list("metal_dense" = 10)
	item_outputs = list(/obj/item/interdictor_kit)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

/datum/manufacture/interdictor_board_standard
	name = "Standard Interdictor Mainboard"
	item_requirements = list("conductive" = 4)
	item_outputs = list(/obj/item/interdictor_board)
	create = 1
	time = 5 SECONDS
	category = "Machinery"

/datum/manufacture/interdictor_board_nimbus
	name = "Nimbus Interdictor Mainboard"
	item_requirements = list("conductive" = 4,
							 "insulated" = 2,
							 "crystal" = 2)
	item_outputs = list(/obj/item/interdictor_board/nimbus)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

/datum/manufacture/interdictor_board_zephyr
	name = "Zephyr Interdictor Mainboard"
	item_requirements = list("conductive" = 4,
							 "viscerite" = 5)
	item_outputs = list(/obj/item/interdictor_board/zephyr)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

/datum/manufacture/interdictor_board_devera
	name = "Devera Interdictor Mainboard"
	item_requirements = list("conductive" = 4,
							 "crystal" = 2,
							 "syreline" = 5)
	item_outputs = list(/obj/item/interdictor_board/devera)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

/datum/manufacture/interdictor_rod_lambda
	name = "Lambda Phase-Control Rod"
	item_requirements = list("metal_dense" = 2,
							 "conductive" = 10,
							 "crystal" = 5,
							 "insulated" = 2)
	item_outputs = list(/obj/item/interdictor_rod)
	create = 1
	time = 12 SECONDS
	category = "Machinery"

/datum/manufacture/interdictor_rod_sigma
	name = "Sigma Phase-Control Rod"
	item_requirements = list("metal_dense" = 2,
							 "conductive_high" = 10,
							 "insulated" = 5,
							 "energy" = 2)
	item_outputs = list(/obj/item/interdictor_rod/sigma)
	create = 1
	time = 15 SECONDS
	category = "Machinery"

/datum/manufacture/interdictor_rod_epsilon
	name = "Epsilon Phase-Control Rod"
	item_requirements = list("metal_dense" = 2,
							 "electrum" = 10,
							 "dense" = 5,
							 "energy" = 2)
	item_outputs = list(/obj/item/interdictor_rod/epsilon)
	create = 1
	time = 20 SECONDS
	category = "Machinery"

/datum/manufacture/interdictor_rod_phi
	name = "Phi Phase-Control Rod"
	item_requirements = list("metal_dense" = 5,
							 "crystal" = 10,
							 "conductive" = 5)
	item_outputs = list(/obj/item/interdictor_rod/phi)
	create = 1
	time = 15 SECONDS
	category = "Machinery"


/************ NADIR RESONATORS ************/

/datum/manufacture/resonator_type_ax
	name = "Type-AX Resonator"
	item_requirements = list("metal_dense" = 15,
							 "conductive_high" = 20,
							 "crystal" = 20,
							 "energy" = 5)
	item_outputs = list(/obj/machinery/siphon/resonator)
	create = 1
	time = 30 SECONDS
	category = "Machinery"

/datum/manufacture/resonator_type_sm
	name = "Type-SM Resonator"
	item_requirements = list("metal_dense" = 10,
							 "conductive_high" = 20,
							 "crystal" = 10,
							 "insulated" = 10)
	item_outputs = list(/obj/machinery/siphon/resonator/stabilizer)
	create = 1
	time = 30 SECONDS
	category = "Machinery"

/************ NADIR GEAR ************/

/datum/manufacture/nanoloom
	name = "Nanoloom"
	item_requirements = list("metal_dense" = 4,
							 "conductive" = 2,
							 "cobryl" = 1,
							 "fabric" = 3)
	item_outputs = list(/obj/item/device/nanoloom)
	create = 1
	time = 15 SECONDS
	category = "Tool"

/datum/manufacture/nanoloom_cart
	name = "Nanoloom Cartridge"
	item_requirements = list("metal_dense" = 1,
							 "cobryl" = 1,
							 "fabric" = 3)
	item_outputs = list(/obj/item/nanoloom_cartridge)
	create = 1
	time = 8 SECONDS
	category = "Tool"

//////////////////////UBER-EXTREME SURVIVAL////////////////////////////////
/datum/manufacture/armor_vest	//
	name = "Armor Vest"
	item_requirements = list("metal_superdense" = 5)
	item_outputs = list(/obj/item/clothing/suit/armor/vest)
	create = 1
	time = 30 SECONDS
	category = "Weapon"

/datum/manufacture/saa	//
	name = "Colt SAA"
	item_requirements = list("metal_dense" = 7)
	item_outputs = list(/obj/item/gun/kinetic/single_action/colt_saa)
	create = 1
	time = 30 SECONDS
	category = "Weapon"
/datum/manufacture/saa_ammo	//
	name = "Colt Ammo"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/ammo/bullets/c_45)
	create = 1
	time = 7 SECONDS
	category = "ammo"
/datum/manufacture/clock	//
	name = "Clock 188"
	item_requirements = list("metal" = 10)
	item_outputs = list(/obj/item/gun/kinetic/clock_188)
	create = 1
	time = 10 SECONDS
	category = "Weapon"
/datum/manufacture/clock_ammo	//
	name = "Clock ammo"
	item_requirements = list("metal" = 3)
	item_outputs = list(/obj/item/ammo/bullets/nine_mm_NATO)
	create = 1
	time = 7 SECONDS
	category = "ammo"

/datum/manufacture/riot_shotgun	//
	name = "Riot Shotgun"
	item_requirements = list("metal" = 20)
	item_outputs = list(/obj/item/gun/kinetic/pumpweapon/riotgun)
	create = 1
	time = 20 SECONDS
	category = "Weapon"
/datum/manufacture/riot_shotgun_ammo	//
	name = "Rubber Bullet ammo"
	item_requirements = list("metal" = 10)
	item_outputs = list(/obj/item/ammo/bullets/abg)
	create = 1
	time = 7 SECONDS
	category = "ammo"

/datum/manufacture/riot_launcher	//
	name = "Riot Launcher"
	item_requirements = list("metal" = 12)
	item_outputs = list(/obj/item/gun/kinetic/riot40mm)
	create = 1
	time = 10 SECONDS
	category = "Weapon"
/datum/manufacture/riot_launcher_ammo_pbr	//
	name = "Launcher PBR Ammo"
	item_requirements = list("metal" = 2,
							 "conductive" = 4,
							 "crystal" = 1)
	item_outputs = list(/obj/item/ammo/bullets/pbr)
	create = 1
	time = 10 SECONDS
	category = "ammo"
/datum/manufacture/riot_launcher_ammo_flashbang	//
	name = "Launcher Flashbang Box"
	item_requirements = list("metal" = 2,
							 "conductive" = 3)
	item_outputs = list(/obj/item/storage/box/flashbang_kit)
	create = 1
	time = 10 SECONDS
	category = "ammo"
/datum/manufacture/riot_launcher_ammo_tactical	//
	name = "Launcher Tactical Box"
	item_requirements = list("metal_dense" = 5,
							 "conductive" = 5,
							 "crystal" = 3)
	item_outputs = list(/obj/item/storage/box/tactical_kit)
	create = 1
	time = 10 SECONDS
	category = "ammo"

/datum/manufacture/sniper	//
	name = "Sniper"
	item_requirements = list("dense" = 2,
							 "metal_superdense" = 15,
							 "conductive" = 4,
							 "crystal" = 3)
	item_outputs = list(/obj/item/gun/kinetic/sniper)
	create = 1
	time = 25 SECONDS
	category = "Weapon"
/datum/manufacture/sniper_ammo	//
	name = "Sniper Ammo"
	item_requirements = list("metal_superdense" = 6)
	item_outputs = list(/obj/item/ammo/bullets/rifle_762_NATO)
	create = 1
	time = 10 SECONDS
	category = "ammo"
/datum/manufacture/tac_shotgun	//
	name = "Tactical Shotgun"
	item_requirements = list("metal_superdense" = 15,
							 "conductive" = 5)
	item_outputs = list(/obj/item/gun/kinetic/tactical_shotgun)
	create = 1
	time = 20 SECONDS
	category = "Weapon"
/datum/manufacture/tac_shotgun_ammo	//
	name = "Tactical Shotgun Ammo"
	item_requirements = list("metal_superdense" = 5)
	item_outputs = list(/obj/item/ammo/bullets/buckshot_burst)
	create = 1
	time = 7 SECONDS
	category = "ammo"
/datum/manufacture/gyrojet	//
	name = "Gyrojet"
	item_requirements = list("dense" = 5,
							 "metal_superdense" = 10,
							 "conductive_high" = 6)
	item_outputs = list(/obj/item/gun/kinetic/gyrojet)
	create = 1
	time = 30 SECONDS
	category = "Weapon"
/datum/manufacture/gyrojet_ammo	//
	name = "Gyrojet Ammo"
	item_requirements = list("metal_superdense" = 5,
							 "conductive_high" = 2)
	item_outputs = list(/obj/item/ammo/bullets/gyrojet)
	create = 1
	time = 7 SECONDS
	category = "Ammo"
/datum/manufacture/plank	//
	name = "Barricade Planks"
	item_requirements = list("wood" = 1)
	item_outputs = list(/obj/item/sheet/wood/zwood)
	create = 1
	time = 1 SECOND
	category = "Medicine"
/datum/manufacture/brute_kit	//
	name = "Brute Kit"
	item_requirements = list("metal" = 2,
							 "conductive" = 2)
	item_outputs = list(/obj/item/storage/firstaid/brute)
	create = 1
	time = 10 SECONDS
	category = "Medicine"
/datum/manufacture/burn_kit	//
	name = "Burn Kit"
	item_requirements = list("metal" = 2,
							 "conductive" = 2)
	item_outputs = list(/obj/item/storage/firstaid/fire)
	create = 1
	time = 10 SECONDS
	category = "Medicine"
/datum/manufacture/crit_kit //
	name = "Crit Kit"
	item_requirements = list("metal" = 2,
							 "conductive" = 2)
	item_outputs = list(/obj/item/storage/firstaid/crit)
	create = 1
	time = 9 SECONDS
	category = "Medicine"
/datum/manufacture/empty_kit
	name = "Empty First Aid Kit"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/storage/firstaid/regular/empty)
	create = 1
	time = 4 SECONDS
	category = "Medicine"
/datum/manufacture/spacecillin	//
	name = "Spacecillin"
	item_requirements = list("metal" = 3,
							 "conductive" = 3)
	item_outputs = list(/obj/item/reagent_containers/syringe/antiviral)
	create = 1
	time = 10 SECONDS
	category = "Medicine"
/datum/manufacture/bat	//
	name = "Baseball Bat"
	item_requirements = list("metal_dense" = 15)
	item_outputs = list(/obj/item/bat)
	create = 1
	time = 20 SECONDS
	category = "Miscellaneous"
/datum/manufacture/quarterstaff	//
	name = "Quarterstaff"
	item_requirements = list("metal_dense" = 10)
	item_outputs = list(/obj/item/quarterstaff)
	create = 1
	time = 10 SECONDS
	category = "Miscellaneous"
/datum/manufacture/cleaver	//
	name = "Cleaver"
	item_requirements = list("metal" = 20)
	item_outputs = list(/obj/item/kitchen/utensil/knife/cleaver)
	create = 1
	time = 16 SECONDS
	category = "Miscellaneous"
/datum/manufacture/dsaber	//
	name = "D-Saber"
	item_requirements = list("metal_dense" = 20,
							 "conductive" = 10)
	item_outputs = list(/obj/item/sword/discount)
	create = 1
	time = 20 SECONDS
	category = "Miscellaneous"
/datum/manufacture/fireaxe	//
	name = "Fireaxe"
	item_requirements = list("metal_superdense" = 20,
							 "conductive_high" = 5)
	item_outputs = list(/obj/item/fireaxe)
	create = 1
	time = 20 SECONDS
	category = "Miscellaneous"
/datum/manufacture/shovel	//
	name = "Shovel"
	item_requirements = list("metal_superdense" = 25,
							 "conductive_high" = 5)
	item_outputs = list(/obj/item/shovel)	//this is powerful)
	create = 1
	time = 40 SECONDS
	category = "Miscellaneous"

/datum/manufacture/floodlight
	name = "Floodlight"
	item_outputs = list(/obj/item/device/light/floodlight)
	create = 1
	time = 8 SECONDS
	category = "Tool"

#undef JUMPSUIT_COST
