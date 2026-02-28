#define JUMPSUIT_COST 10

/datum/manufacture
	/// Player-read name of the blueprint
	var/name = null
	// Player-read name of each material
	var/list/item_names = list()
	/// An associated list of requirement datum to amount of requirement to use. See manufacturing_requirements.dm for more on those.
	/// This list is overriden on children, and on New() the requirement ID strings are resolved to their datum instances in the cache
	var/list/item_requirements = null //PLEASE rather set mats with TYPEINFO()!! Manufactories can derive costs from mats
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
	name = "AI Law Rack"
	item_requirements = list("metal" = 20,
							 "metal_dense" = 5,
							 "insulated" = 10,
							 "conductive" = 10)
	create = 1
	time = 60 SECONDS
	frame_path = /obj/machinery/lawrack

/******************** Gravity Tether *******************/

/datum/manufacture/mechanics/gravity_tether_station
	name = "Station Gravity Tether"
	create = 1
	time = 60 SECONDS
	frame_path = /obj/machinery/gravity_tether/station
	item_requirements = list("metal" = 50,
							"crystal_dense" = 10,
							"metal_superdense" = 30,
							"koshmarite" = 30,
							"energy_high" = 40,)
	category = "Machinery"

/datum/manufacture/mechanics/gravity_tether_area
	name = "Local Gravity Tether"
	create = 1
	time = 20 SECONDS
	frame_path = /obj/machinery/gravity_tether/current_area
	item_requirements = list("metal" = 20,
							 "metal_superdense" = 10,
							 "koshmarite" = 15,
							 "energy_high" = 10,)
	category = "Machinery"



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
	item_outputs = list(/obj/item/crowbar/green)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/crowbar/purple
	item_outputs = list(/obj/item/crowbar/purple)

/datum/manufacture/screwdriver
	name = "Screwdriver"
	item_outputs = list(/obj/item/screwdriver/green)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/wirecutters
	name = "Wirecutters"
	item_outputs = list(/obj/item/wirecutters/green)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/wrench
	name = "Wrench"
	item_outputs = list(/obj/item/wrench/green)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/wrench/purple
	item_outputs = list(/obj/item/wrench/purple)

/datum/manufacture/crowbar/yellow
	name = "Crowbar"
	item_outputs = list(/obj/item/crowbar/yellow)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/screwdriver/yellow
	name = "Screwdriver"
	item_outputs = list(/obj/item/screwdriver/yellow)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/wirecutters/yellow
	name = "Wirecutters"
	item_outputs = list(/obj/item/wirecutters/yellow)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/wrench/yellow
	name = "Wrench"
	item_outputs = list(/obj/item/wrench/yellow)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/flashlight
	name = "Flashlight"
	item_outputs = list(/obj/item/device/light/flashlight)
	create = 1
	time = 5 SECONDS
	category = "Tool"


/datum/manufacture/lantern
	name = "Lantern"
	item_outputs = list(/obj/item/device/light/lantern)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/datum/manufacture/vuvuzela
	name = "Vuvuzela"
	item_outputs = list(/obj/item/instrument/vuvuzela)
	create = 1
	time = 5 SECONDS
	category = "Miscellaneous"

/datum/manufacture/harmonica
	name = "Harmonica"
	item_outputs = list(/obj/item/instrument/harmonica)
	create = 1
	time = 5 SECONDS
	category = "Miscellaneous"

/datum/manufacture/bottle
	name = "Glass Bottle"
	item_outputs = list(/obj/item/reagent_containers/food/drinks/bottle/soda)
	create = 1
	time = 4 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/item/instrument/saxophone) //Move this to it's file later.
	mats = list("metal_dense" = 15)
/datum/manufacture/saxophone
	name = "Saxophone"
	item_outputs = list(/obj/item/instrument/saxophone)
	create = 1
	time = 7 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/item/instrument/whistle) //Move this to it's file later.
	mats = list("metal_superdense" = 5)
/datum/manufacture/whistle
	name = "Whistle"
	item_outputs = list(/obj/item/instrument/whistle)
	create = 1
	time = 3 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/item/instrument/trumpet) //Move this to it's file later.
	mats = list("metal_dense" = 10)
/datum/manufacture/trumpet
	name = "Trumpet"
	item_outputs = list(/obj/item/instrument/trumpet)
	create = 1
	time = 6 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/item/instrument/bagpipe) //Move this to it's file later.
	mats = list("fabric" = 10,
				"metal_dense" = 25)
/datum/manufacture/bagpipe
	name = "Bagpipe"
	item_outputs = list(/obj/item/instrument/bagpipe)
	create = 1
	time = 5 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/item/instrument/fiddle) //Move this to it's file later.
	mats = list("wood" = 25,
				"fabric" = 10)
/datum/manufacture/fiddle
	name = "Fiddle"
	item_outputs = list(/obj/item/instrument/fiddle)
	create = 1
	time = 5 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/item/instrument/bikehorn) //Move this to it's file later.
	mats = list("any" = 1)
/datum/manufacture/bikehorn
	name = "Bicycle Horn"
	item_outputs = list(/obj/item/instrument/bikehorn)
	create = 1
	time = 5 SECONDS
	category = "Miscellaneous"


TYPEINFO(/obj/item/ammo/bullets/a38/stun) //Move this to it's file later.
	mats = list("metal" = 3,
				"conductive" = 2,
				"crystal" = 2)
/datum/manufacture/stunrounds
	name = ".38 Stunner Rounds"
	item_outputs = list(/obj/item/ammo/bullets/a38/stun)
	create = 1
	time = 20 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/ammo/bullets/bullet_22) //Move this to it's file later.
	mats = list("metal_dense" = 30,
				"conductive" = 24)
/datum/manufacture/bullet_22
	name = ".22 Bullets"
	item_outputs = list(/obj/item/ammo/bullets/bullet_22)
	create = 1
	time = 30 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/ammo/bullets/nine_mm_NATO) //Move this to it's file later.
	mats = list("conductive" = 25,
				"rubber" = 15,
				"plastic" = 15,
				"metal" = 10)
/datum/manufacture/bullet_9mm_frangible
	name = "9mm Frangible Rounds"
	item_outputs = list(/obj/item/ammo/bullets/nine_mm_NATO)
	create = 1
	time = 15 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/ammo/bullets/nails) //Move this to it's file later.
	mats = list("metal_dense" = 40,
				"conductive" = 30)
/datum/manufacture/bullet_12g_nail
	name = "12 gauge nailshot"
	item_outputs = list(/obj/item/ammo/bullets/nails)
	create = 1
	time = 30 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/ammo/bullets/smoke) //Move this to it's file later.
	mats = list("metal_dense" = 30,
				"conductive" = 25)
/datum/manufacture/bullet_smoke
	name = "40mm Smoke Grenade"
	item_outputs = list(/obj/item/ammo/bullets/smoke)
	create = 1
	time = 35 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/extinguisher) //Move this to it's file later.
	mats = list("metal_dense" = 1,
				"crystal" = 1) //Should probably be plastic?
/datum/manufacture/extinguisher
	name = "Fire Extinguisher"
	item_outputs = list(/obj/item/extinguisher)
	create = 1
	time = 8 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/weldingtool) //Move this to it's file later.
	mats = list("metal_dense" = 1,
				"conductive" = 1)
/datum/manufacture/welder
	name = "Welding Tool"
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

/datum/manufacture/welder/purple
	item_outputs = list(/obj/item/weldingtool/purple)

TYPEINFO(/obj/item/electronics/soldering) //Move this to it's file later.
	mats = list("metal_dense" = 1,
				"conductive" = 2)
/datum/manufacture/soldering
	name = "Soldering Iron"
	item_outputs = list(/obj/item/electronics/soldering)
	create = 1
	time = 8 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/staple_gun) //Move this to it's file later.
	mats = list("metal_dense" = 2,
				"conductive" = 1)
/datum/manufacture/stapler
	name = "Staple Gun"
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

/datum/manufacture/gravity_scanner
	name = "G-force scanner"
	item_outputs = list(/obj/item/device/analyzer/gravity_scanner)
	create = 1
	time = 8 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/clothing/head/helmet/welding) //Move this to it's file later.
	mats = list("metal_dense" = 2,
				"crystal" = 2)
/datum/manufacture/weldingmask
	name = "Welding Mask"
	item_outputs = list(/obj/item/clothing/head/helmet/welding)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/storage/box/lightbox/bulbs) //Move this to it's file later.
	mats = list("crystal" = 1,
				"conductive" = 1)
/datum/manufacture/light_bulb
	name = "Light Bulb Box"
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs)
	create = 1
	time = 4 SECONDS
	category = "Resource"

/datum/manufacture/red_bulb
	name = "Red Light Bulb Box"
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/red)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/yellow_bulb
	name = "Yellow Light Bulb Box"
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/yellow)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/green_bulb
	name = "Green Light Bulb Box"
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/green)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/cyan_bulb
	name = "Cyan Light Bulb Box"
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/cyan)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/blue_bulb
	name = "Blue Light Bulb Box"
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/blue)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/purple_bulb
	name = "Purple Light Bulb Box"
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/purple)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/blacklight_bulb
	name = "Blacklight Bulb Box"
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/blacklight)
	create = 1
	time = 8 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/storage/box/lightbox/tubes) //Move this to it's file later.
	mats = list("crystal" = 1,
				"conductive" = 1)
/datum/manufacture/light_tube
	name = "Light Tube Box"
	item_outputs = list(/obj/item/storage/box/lightbox/tubes)
	create = 1
	time = 4 SECONDS
	category = "Resource"

/datum/manufacture/red_tube
	name = "Red Light Tube Box"
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/red)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/yellow_tube
	name = "Yellow Light Tube Box"
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/yellow)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/green_tube
	name = "Green Light Tube Box"
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/green)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/cyan_tube
	name = "Cyan Light Tube Box"
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/cyan)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/blue_tube
	name = "Blue Light Tube Box"
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/blue)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/purple_tube
	name = "Purple Light Tube Box"
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/purple)
	create = 1
	time = 8 SECONDS
	category = "Resource"

/datum/manufacture/blacklight_tube
	name = "Blacklight Tube Box"
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/blacklight)
	create = 1
	time = 8 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/furniture_parts/table/folding) //Move this to it's file later.
	mats = list("metal" = 1,
				"any" = 2)
/datum/manufacture/table_folding
	name = "Folding Table"
	item_outputs = list(/obj/item/furniture_parts/table/folding)
	create = 1
	time = 20 SECONDS
	category = "Resource"

/datum/manufacture/metal
	name = "Metal Sheet"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/sheet)
	create = 1
	time = 2 SECONDS
	category = "Resource"
	apply_material = TRUE

/datum/manufacture/metal/bulk
	name = "Metal Sheet (x5)"
	item_requirements = list("metal" = 5)
	create = 5
	time = 5 * /datum/manufacture/metal::time

/datum/manufacture/metalR
	name = "Reinforced Metal"
	item_requirements = list("metal" = 2)
	item_outputs = list(/obj/item/sheet)
	create = 1
	time = 12 SECONDS
	category = "Resource"
	apply_material = TRUE

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		var/obj/item/sheet/S = A
		..()
		var/obj/item/material_piece/applicable_material = locate(materials[getManufacturingRequirement("metal")])
		S.set_reinforcement(applicable_material.material)

/datum/manufacture/metalR/bulk
	name = "Reinforced Metal (x5)"
	item_requirements = list("metal" = 10)
	create = 5
	time = 5 * /datum/manufacture/metalR::time

/datum/manufacture/glass
	name = "Glass Panel"
	item_requirements = list("crystal" = 1)
	item_outputs = list(/obj/item/sheet)
	create = 1
	time = 2 SECONDS
	category = "Resource"
	apply_material = TRUE

/datum/manufacture/glass/bulk
	name = "Glass Panel (x5)"
	item_requirements = list("crystal" = 5)
	create = 5
	time = 5 * /datum/manufacture/glass::time

/datum/manufacture/glassR
	name = "Reinforced Glass Panel"
	item_requirements = list("crystal" = 1,
							 "metal_dense" = 1)
	item_outputs = list(/obj/item/sheet/glass/reinforced)
	create = 1
	time = 12 SECONDS
	category = "Resource"
	apply_material = TRUE

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		..()
		var/obj/item/sheet/S = A
		var/obj/item/material_piece/applicable_material = locate(materials[getManufacturingRequirement("metal_dense")])
		S.set_reinforcement(applicable_material.material)

/datum/manufacture/glassR/bulk
	name = "Reinforced Glass Panel (x5)"
	item_requirements = list("crystal" = 5,
							 "metal_dense" = 5)
	create = 5
	time = 5 * /datum/manufacture/glassR::time


/datum/manufacture/rods2
	name = "Metal Rods (x2)"
	item_requirements = list("metal_dense" = 1)
	item_outputs = list(/obj/item/rods)
	time = 3 SECONDS
	category = "Resource"
	apply_material = TRUE

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A)
		..()
		var/obj/item/sheet/S = A // this way they are instantly stacked rather than just 2 rods
		S.amount = 2
		S.inventory_counter.update_number(S.amount)

TYPEINFO(/obj/machinery/portable_atmospherics/canister) //Move this to it's file later.
	mats = list("metal_dense" = 3)
/datum/manufacture/atmos_can
	name = "Portable Gas Canister"
	item_outputs = list(/obj/machinery/portable_atmospherics/canister)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/fluid_canister) //Move this to it's file later.
	mats = list("metal_dense" = 15)
/datum/manufacture/fluidcanister
	name = "Fluid Canister"
	item_outputs = list(/obj/machinery/fluid_canister)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

TYPEINFO(/obj/reagent_dispensers/chemicalbarrel) //Move this to it's file later.
	mats = list("metal_dense" = 6,
				"cobryl" = 9)
/datum/manufacture/chembarrel
	name = "Chemical Barrel"
	item_outputs = list(/obj/reagent_dispensers/chemicalbarrel)
	create = 1
	time = 30 SECONDS
	category = "Machinery"

	red
		item_outputs = list(/obj/reagent_dispensers/chemicalbarrel/red)

	yellow
		item_outputs = list(/obj/reagent_dispensers/chemicalbarrel/yellow)

TYPEINFO(/obj/machinery/shieldgenerator/energy_shield/nocell) //Move this to it's file later.
	mats = list("metal_dense" = 20,
				"conductive" = 10,
				"crystal" = 5)
/datum/manufacture/shieldgen
	name = "Energy-Shield Gen."
	item_outputs = list(/obj/machinery/shieldgenerator/energy_shield/nocell)
	create = 1
	time = 60 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/shieldgenerator/energy_shield/doorlink/nocell) //Move this to it's file later.
	mats = list("metal_dense" = 20,
				"conductive" = 15)
/datum/manufacture/doorshieldgen
	name = "Door-Shield Gen."
	item_outputs = list(/obj/machinery/shieldgenerator/energy_shield/doorlink/nocell)
	create = 1
	time = 60 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/shieldgenerator/meteorshield/nocell) //Move this to it's file later.
	mats = list("metal" = 10,
				"metal_dense" = 10,
				"conductive" = 10)
/datum/manufacture/meteorshieldgen
	name = "Meteor-Shield Gen."
	item_outputs = list(/obj/machinery/shieldgenerator/meteorshield/nocell)
	create = 1
	time = 30 SECONDS
	category = "Machinery"

//// cogwerks - gas extraction stuff

TYPEINFO(/obj/machinery/portable_atmospherics/canister/air) //Move this to it's file later.
	mats = list("metal_dense" = 3,
				"molitz" = 4,
				"viscerite" = 12)
/datum/manufacture/air_can
	name = "Air Canister"
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/air)
	create = 1
	time = 50 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/portable_atmospherics/canister/air/large) //Move this to it's file later.
	mats = list("metal_dense" = 3,
				"molitz" = 10,
				"viscerite" = 30)
/datum/manufacture/air_can/large
	name = "High-Volume Air Canister"
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/air/large)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/portable_atmospherics/canister/carbon_dioxide) //Move this to it's file later.
	mats = list("metal_dense" = 3,
				"char" = 10)
/datum/manufacture/co2_can
	name = "CO2 Canister"
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/portable_atmospherics/canister/oxygen) //Move this to it's file later.
	mats = list("metal_dense" = 3,
							 "molitz" = 10)
/datum/manufacture/o2_can
	name = "O2 Canister"
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/portable_atmospherics/canister/toxins) //Move this to it's file later.
	mats = list("metal_dense" = 3,
				"plasmastone" = 10)
/datum/manufacture/plasma_can
	name = "Plasma Canister"
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/toxins)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/portable_atmospherics/canister/nitrogen) //Move this to it's file later.
	mats = list("metal_dense" = 3,
				"viscerite" = 10)
/datum/manufacture/n2_can
	name = "N2 Canister"
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/portable_atmospherics/canister/sleeping_agent) //Move this to it's file later.
	mats = list("metal_dense" = 3,
				"koshmarite" = 10)
/datum/manufacture/n2o_can
	name = "N2O Canister"
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/sleeping_agent)
	create = 1
	time = 100 SECONDS
	category = "Machinery"

TYPEINFO(/obj/item/old_grenade/oxygen) //Move this to it's file later.
	mats = list("metal_dense" = 2,
				"conductive" = 2,
				"molitz" = 10,
				"char" = 1)
/datum/manufacture/red_o2_grenade
	name = "Red Oxygen Grenade"
	item_outputs = list(/obj/item/old_grenade/oxygen)
	create = 1
	time = 10 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/engivac) //Move this to it's file later.
	mats = list("metal" = 10,
				"conductive" = 5,
				"crystal" = 5)
/datum/manufacture/engivac
	name = "Material Vacuum"
	item_outputs = list(/obj/item/engivac)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/lamp_manufacturer/organic) //Move this to it's file later.
	mats = list("metal" = 5,
				"conductive" = 10,
				"crystal" = 20)
/datum/manufacture/lampmanufacturer
	name = "Lamp Manufacturer"
	item_outputs = list(/obj/item/lamp_manufacturer/organic)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/reagent_containers/glass/plumbing/condenser) //Move this to it's file later.
	mats = list("crystal" = 5)
/datum/manufacture/condenser
	name = "Chemical Condenser"
	item_outputs = list(/obj/item/reagent_containers/glass/plumbing/condenser)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/reagent_containers/glass/plumbing/condenser/fractional) //Move this to it's file later.
	mats = list("molitz" = 6)
/datum/manufacture/fractionalcondenser
	name = "Fractional Condenser"
	item_outputs = list(/obj/item/reagent_containers/glass/plumbing/condenser/fractional)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/reagent_containers/glass/plumbing/dropper) //Move this to it's file later.
	mats = list("molitz" = 3)
/datum/manufacture/dropper_funnel
	name = "Dropper Funnel"
	item_outputs = list(/obj/item/reagent_containers/glass/plumbing/dropper)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/reagent_containers/glass/plumbing/dispenser) //Move this to it's file later.
	mats = list("molitz" = 3,
				"metal" = 2,
				"miracle" = 2)
/datum/manufacture/portable_dispenser
	name = "Portable Dispenser"
	item_outputs = list(/obj/item/reagent_containers/glass/plumbing/dispenser)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/storage/box/beaker_lids) //Move this to it's file later.
	mats = list("rubber" = 2)
/datum/manufacture/beaker_lid_box
	name = "Beaker Lid Box"
	item_outputs = list(/obj/item/storage/box/beaker_lids)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/bunsen_burner) //Move this to it's file later.
	mats = list("pharosium" = 5)
/datum/manufacture/bunsen_burner
	name = "Bunsen Burner"
	item_outputs = list(/obj/item/bunsen_burner)
	create = 1
	time = 5 SECONDS
	category = "Tool"

////////////////////////////////

TYPEINFO(/obj/item/machineboard/vending/player) //Move this to it's file later.
	mats = list("conductive" = 2)
/datum/manufacture/player_module
	name = "Vending Module"
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

TYPEINFO(/obj/item/rcd) //Move this to it's file later.
	mats = list("metal_superdense" = 20,
				"crystal_dense" = 10,
				"conductive_high" = 10,
				"energy_high" = 10)
/datum/manufacture/RCD
	name = "Rapid Construction Device"
	item_outputs = list(/obj/item/rcd)
	create = 1
	time = 90 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/places_pipes) //Move this to it's file later.
	mats = list("metal_dense" = 12,
				"crystal" = 15,
				"conductive_high" = 10,
				"energy_high" = 10)
/datum/manufacture/places_pipes
	name = "Handheld Pipe Dispenser"
	item_outputs = list(/obj/item/places_pipes)
	create = 1
	time = 90 SECONDS
	category = "Tool"

/datum/manufacture/places_pipes/science
	item_outputs = list(/obj/item/places_pipes/research)

TYPEINFO(/obj/item/rcd_ammo) //Move this to it's file later.
	mats = list("dense" = 30)
/datum/manufacture/RCDammo
	name = "Compressed Matter Cartridge"
	item_outputs = list(/obj/item/rcd_ammo)
	create = 1
	time = 10 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/rcd_ammo/medium) //Move this to it's file later.
	mats = list("dense_super" = 30)
/datum/manufacture/RCDammomedium
	name = "Medium Compressed Matter Cartridge"
	item_outputs = list(/obj/item/rcd_ammo/medium)
	create = 1
	time = 20 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/rcd_ammo/big) //Move this to it's file later.
	mats = list("uqill" = 20)
/datum/manufacture/RCDammolarge
	name = "Large Compressed Matter Cartridge"
	item_outputs = list(/obj/item/rcd_ammo/big)
	create = 1
	time = 30 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/syndicate_destruction_system) //Move this to it's file later.
	mats = list("metal_superdense" = 16,
				"dense" = 12,
				"conductive" = 8)
/datum/manufacture/sds
	name = "Syndicate Destruction System"
	item_outputs = list(/obj/item/syndicate_destruction_system)
	create = 1
	time = 90 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/device/radio/headset) //Move this to it's file later.
	mats = list("metal" = 2,
				"conductive" = 1)
/datum/manufacture/civilian_headset
	name = "Civilian Headset"
	item_outputs = list(/obj/item/device/radio/headset)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/under) //Move this to it's file later.
	mats = list("fabric" = JUMPSUIT_COST)
/datum/manufacture/jumpsuit_assistant
	name = "Staff Assistant Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/rank/assistant)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit
	name = "Grey Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/color/grey)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/shoes) //Move this to it's file later.
	mats = list("fabric" = 3)
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

TYPEINFO(/obj/item/clothing/shoes/flippers) //Move this to it's file later.
	mats = list("rubber" = 5)
/datum/manufacture/flippers
	name = "Flippers"
	item_outputs = list(/obj/item/clothing/shoes/flippers)
	create = 1
	time = 8 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/chem_grenade/cleaner) //Move this to it's file later.
	mats = list("insulated" = 8,
				"crystal" = 8,
				"molitz" = 10,
				"ice" = 10)
/datum/manufacture/cleaner_grenade
	name = "Cleaner Grenade"
	item_outputs = list(/obj/item/chem_grenade/cleaner)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/tank/pocket/extended) //Move this to it's file later.
	mats = list("dense_super" = 10,
				"insulated" = 20,
				"rubber" = 5)
/datum/manufacture/pocketoxyex
	name = "Extended Capacity Pocket Oxygen Tank"
	item_outputs = list(/obj/item/tank/pocket/extended/empty)
	create = 1
	time = 5 SECONDS
	category = "Tool"

/******************** Medical **************************/

TYPEINFO(/obj/item/scalpel) //Move this to it's file later.
	mats = list("metal" = 1)
/datum/manufacture/scalpel
	name = "Scalpel"
	item_outputs = list(/obj/item/scalpel)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/circular_saw) //Move this to it's file later.
	mats = list("metal" = 1)
/datum/manufacture/circular_saw
	name = "Circular Saw"
	item_outputs = list(/obj/item/circular_saw)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/scissors/surgical_scissors) //Move this to it's file later.
	mats = list("metal" = 1)
/datum/manufacture/surgical_scissors
	name = "Surgical Scissors"
	item_outputs = list(/obj/item/scissors/surgical_scissors)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/hemostat) //Move this to it's file later.
	mats = list("metal" = 1)
/datum/manufacture/hemostat
	name = "Hemostat"
	item_outputs = list(/obj/item/hemostat)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/surgical_spoon) //Move this to it's file later.
	mats = list("metal" = 1)
/datum/manufacture/surgical_spoon
	name = "Enucleation Spoon"
	item_outputs = list(/obj/item/surgical_spoon)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/suture) //Move this to it's file later.
	mats = list("metal" = 1)
/datum/manufacture/suture
	name = "Suture"
	item_outputs = list(/obj/item/suture)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/device/radio/headset/deaf) //Move this to it's file later.
	mats = list("conductive" = 3,
				"crystal" = 3)
/datum/manufacture/deafhs
	name = "Auditory Headset"
	item_outputs = list(/obj/item/device/radio/headset/deaf)
	create = 1
	time = 40 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/glasses/visor) //Move this to it's file later.
	mats = list("conductive" = 3,
				"crystal" = 3)
/datum/manufacture/visor
	name = "VISOR Prosthesis"
	item_outputs = list(/obj/item/clothing/glasses/visor)
	create = 1
	time = 40 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/glasses/regular) //Move this to it's file later.
	mats = list("metal" = 1,
				"crystal" = 2)
/datum/manufacture/glasses
	name = "Prescription Glasses"
	item_outputs = list(/obj/item/clothing/glasses/regular)
	create = 1
	time = 20 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/furniture_parts/wheelchair) //Move this to it's file later.
	mats = list("metal" = 8,
				"fabric" = 3)
/datum/manufacture/wheelchair
	name = "Wheelchair Parts"
	item_outputs = list(/obj/item/furniture_parts/wheelchair)
	create = 1
	time = 30 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/reagent_containers/hypospray) //Move this to it's file later.
	mats = list("metal" = 2,
				"conductive" = 2,
				"crystal" = 2)
/datum/manufacture/hypospray
	name = "Hypospray"
	item_outputs = list(/obj/item/reagent_containers/hypospray)
	create = 1
	time = 40 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/clothing/glasses/healthgoggles) //Move this to it's file later.
	mats = list("metal" = 1,
				"crystal" = 2)
/datum/manufacture/prodocs
	name = "ProDoc Healthgoggles"
	item_outputs = list(/obj/item/clothing/glasses/healthgoggles)
	create = 1
	time = 20 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/gloves/latex) //Move this to it's file later.
	mats = list("fabric" = 1)
/datum/manufacture/latex_gloves
	name = "Latex Gloves"
	item_outputs = list(/obj/item/clothing/gloves/latex)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/body_bag) //Move this to it's file later.
	mats = list("fabric" = 3)
/datum/manufacture/body_bag
	name = "Body Bag"
	item_outputs = list(/obj/item/body_bag)
	create = 1
	time = 15 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/organ/heart/cyber) //Move this to it's file later.
	mats = list("metal" = 3,
				"conductive" = 3,
				"any" = 2)
/datum/manufacture/cyberheart
	name = "Cyberheart"
	item_outputs = list(/obj/item/organ/heart/cyber)
	create = 1
	time = 25 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/clothing/head/butt/cyberbutt) //Move this to it's file later.
	mats = list("metal" = 2,
				"conductive" = 2,
				"any" = 2)
/datum/manufacture/cyberbutt
	name = "Cyberbutt"
	item_outputs = list(/obj/item/clothing/head/butt/cyberbutt)
	create = 1
	time = 15 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/clothing/suit/cardboard_box/ai) //Move this to it's file later.
	mats = list("cardboard" = 1)
/datum/manufacture/cardboard_ai
	name = "Cardboard 'AI'"
	item_outputs = list(/obj/item/clothing/suit/cardboard_box/ai)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/organ/appendix/cyber) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"any" = 1)
/datum/manufacture/cyberappendix
	name = "Cyberappendix"
	item_outputs = list(/obj/item/organ/appendix/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/pancreas/cyber) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"any" = 1)
/datum/manufacture/cyberpancreas
	name = "Cyberpancreas"
	item_outputs = list(/obj/item/organ/pancreas/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/spleen/cyber) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"any" = 1)
/datum/manufacture/cyberspleen
	name = "Cyberspleen"
	item_outputs = list(/obj/item/organ/spleen/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/intestines/cyber) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"any" = 1)
/datum/manufacture/cyberintestines
	name = "Cyberintestines"
	item_outputs = list(/obj/item/organ/intestines/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/stomach/cyber) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"any" = 1)
/datum/manufacture/cyberstomach
	name = "Cyberstomach"
	item_outputs = list(/obj/item/organ/stomach/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/kidney/cyber) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"any" = 1)
/datum/manufacture/cyberkidney
	name = "Cyberkidney"
	item_outputs = list(/obj/item/organ/kidney/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/liver/cyber) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"any" = 1)
/datum/manufacture/cyberliver
	name = "Cyberliver"
	item_outputs = list(/obj/item/organ/liver/cyber)
	create = 1
	time = 15 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/lung/cyber/left) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"any" = 1)
/datum/manufacture/cyberlung_left
	name = "Left Cyberlung"
	item_outputs = list(/obj/item/organ/lung/cyber/left)
	create = 1
	time = 15 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/lung/cyber/right) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"any" = 1)
/datum/manufacture/cyberlung_right
	name = "Right Cyberlung"
	item_outputs = list(/obj/item/organ/lung/cyber/right)
	create = 1
	time = 15 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/eye/cyber/configurable) //Move this to it's file later.
	mats =  list("crystal" = 2,
				"metal" = 1,
				"conductive" = 2,
				"insulated" = 1)
/datum/manufacture/cybereye
	name = "Cybereye"
	item_outputs = list(/obj/item/organ/eye/cyber/configurable)
	create = 1
	time = 20 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/eye/cyber/sunglass) //Move this to it's file later.
	mats = list("crystal" = 3,
				"metal" = 1,
				"conductive" = 2,
				"insulated" = 1)
/datum/manufacture/cybereye_sunglass
	name = "Polarized Cybereye"
	item_outputs = list(/obj/item/organ/eye/cyber/sunglass)
	create = 1
	time = 25 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/eye/cyber/sechud) //Move this to it's file later.
	mats = list("crystal" = 3,
				"metal" = 1,
				"conductive" = 2,
				"insulated" = 1)
/datum/manufacture/cybereye_sechud
	name = "Security HUD Cybereye"
	item_outputs = list(/obj/item/organ/eye/cyber/sechud)
	create = 1
	time = 25 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/eye/cyber/thermal) //Move this to it's file later.
	mats = list("crystal" = 3,
				"metal" = 1,
				"conductive" = 2,
				"insulated" = 1)
/datum/manufacture/cybereye_thermal
	name = "Thermal Imager Cybereye"
	item_outputs = list(/obj/item/organ/eye/cyber/thermal)
	create = 1
	time = 25 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/eye/cyber/meson) //Move this to it's file later.
	mats = list("crystal" = 3,
				"metal" = 1,
				"conductive" = 2,
				"insulated" = 1)
/datum/manufacture/cybereye_meson
	name = "Mesonic Imager Cybereye"
	item_outputs = list(/obj/item/organ/eye/cyber/meson)
	create = 1
	time = 25 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/eye/cyber/spectro) //Move this to it's file later.
	mats = list("crystal" = 3,
				"metal" = 1,
				"conductive" = 2,
				"insulated" = 1)
/datum/manufacture/cybereye_spectro
	name = "Spectroscopic Imager Cybereye"
	item_outputs = list(/obj/item/organ/eye/cyber/spectro)
	create = 1
	time = 25 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/eye/cyber/prodoc) //Move this to it's file later.
	mats = list("crystal" = 3,
				"metal" = 1,
				"conductive" = 2,
				"insulated" = 1)
/datum/manufacture/cybereye_prodoc
	name = "ProDoc Healthview Cybereye"
	item_outputs = list(/obj/item/organ/eye/cyber/prodoc)
	create = 1
	time = 25 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/eye/cyber/camera) //Move this to it's file later.
	mats = list("crystal" = 3,
				"metal" = 1,
				"conductive" = 2,
				"insulated" = 1)
/datum/manufacture/cybereye_camera
	name = "Camera Cybereye"
	item_outputs = list(/obj/item/organ/eye/cyber/camera)
	create = 1
	time = 25 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/eye/cyber/monitor) //Move this to it's file later.
	mats = list("crystal" = 3,
				"metal" = 1,
				"conductive" = 2,
				"insulated" = 1)
/datum/manufacture/cybereye_monitor
	name = "Monitor Cybereye"
	item_outputs = list(/obj/item/organ/eye/cyber/monitor)
	create = 1
	time = 25 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/organ/eye/cyber/laser) //Move this to it's file later.
	mats = list("crystal" = 3,
				"metal" = 1,
				"conductive" = 2,
				"insulated" = 1,
				"erebite" = 1)
/datum/manufacture/cybereye_laser
	name = "Laser Cybereye"
	item_outputs = list(/obj/item/organ/eye/cyber/laser)
	create = 1
	time = 40 SECONDS
	category = "Organ"

TYPEINFO(/obj/item/implantcase/health) //Move this to it's file later.
	mats = list("conductive" = 3,
				"crystal" = 3)
/datum/manufacture/implant_health
	name = "Health Monitor Implant"
	item_outputs = list(/obj/item/implantcase/health)
	create = 1
	time = 40 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/implantcase/antirot) //Move this to it's file later.
	mats = list("conductive" = 2,
				"crystal" = 2)
/datum/manufacture/implant_antirot
	name = "Rotbusttec Implant"
	item_outputs = list(/obj/item/implantcase/antirot)
	create = 1
	time = 30 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/device/panicbutton/medicalalert) //Move this to it's file later.
	mats = list("conductive" = 2,
				"metal" = 2)
/datum/manufacture/medicalalertbutton
	name = "Medical Alert Button"
	item_outputs = list(/obj/item/device/panicbutton/medicalalert)
	create = 1
	time = 3 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/reagent_containers/emergency_injector/empty) //Move this to it's file later.
	mats = list("metal" = 1)
/datum/manufacture/empty_autoinjector
	name = "Empty Auto-Injector"
	item_outputs = list(/obj/item/reagent_containers/emergency_injector/empty)
	create = 1
	time = 3 SECONDS
	category = "Tool"

/datum/manufacture/empty_autoinjector/orange
	name = "Empty Auto-Injector"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/reagent_containers/emergency_injector/empty/orange)
	create = 1
	time = 3 SECONDS
	category = "Tool"

/datum/manufacture/empty_autoinjector/red
	name = "Empty Auto-Injector"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/reagent_containers/emergency_injector/empty/red)
	create = 1
	time = 3 SECONDS
	category = "Tool"

/datum/manufacture/empty_autoinjector/blue
	name = "Empty Auto-Injector"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/reagent_containers/emergency_injector/empty/blue)
	create = 1
	time = 3 SECONDS
	category = "Tool"

/datum/manufacture/empty_autoinjector/green
	name = "Empty Auto-Injector"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/reagent_containers/emergency_injector/empty/green)
	create = 1
	time = 3 SECONDS
	category = "Tool"

/datum/manufacture/empty_autoinjector/yellow
	name = "Empty Auto-Injector"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/reagent_containers/emergency_injector/empty/yellow)
	create = 1
	time = 3 SECONDS
	category = "Tool"

/datum/manufacture/empty_autoinjector/purple
	name = "Empty Auto-Injector"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/reagent_containers/emergency_injector/empty/purple)
	create = 1
	time = 3 SECONDS
	category = "Tool"

/datum/manufacture/empty_autoinjector/black
	name = "Empty Auto-Injector"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/reagent_containers/emergency_injector/empty/black)
	create = 1
	time = 3 SECONDS
	category = "Tool"

/datum/manufacture/empty_autoinjector/white
	name = "Empty Auto-Injector"
	item_requirements = list("metal" = 1)
	item_outputs = list(/obj/item/reagent_containers/emergency_injector/empty/white)
	create = 1
	time = 3 SECONDS
	category = "Tool"

TYPEINFO(/obj/nav_sat) //Move this to it's file later.
	mats = list("metal_dense" = 1)//AzrunADJUSTPOSTTESTING)
#ifdef ENABLE_ARTEMIS
/******************** Artemis **************************/
/datum/manufacture/nav_sat
	name = "Navigation Satellite"
	item_outputs = list(/obj/nav_sat)
	create = 1
	time = 45 SECONDS
	category = "Component"

#endif

TYPEINFO(/obj/item/toy/plush/small/stress_ball) //Move this to it's file later.
	mats = list("fabric" = 1)
/datum/manufacture/stress_ball
	name = "Stress Ball"
	item_outputs = list(/obj/item/toy/plush/small/stress_ball)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/disk/data/floppy) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1)
/datum/manufacture/floppydisk //Cloning disks
	name = "Floppy Disk"
	item_outputs = list(/obj/item/disk/data/floppy)
	create = 1
	time = 5 SECONDS
	category = "Resource"

/******************** Robotics **************************/

TYPEINFO(/obj/item/parts/robot_parts/robot_frame) //Move this to it's file later.
	mats = list("metal_dense" = ROBOT_FRAME_COST*10)
/datum/manufacture/robo_frame
	name = "Cyborg Frame"
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
	var/datum/forensic_id/roboprint = null // Give robo arms the same fingerprints

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		..()
		if(istype(A, /obj/item/parts/robot_parts/arm))
			var/obj/item/parts/robot_parts/arm/new_arm = A
			if(roboprint)
				new_arm.limb_print = roboprint
			else
				roboprint = new_arm.limb_print

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
	var/datum/forensic_id/roboprint = null // Give robo arms the same fingerprints

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		..()
		if(istype(A, /obj/item/parts/robot_parts/arm))
			var/obj/item/parts/robot_parts/arm/new_arm = A
			if(roboprint)
				new_arm.limb_print = roboprint
			else
				roboprint = new_arm.limb_print

TYPEINFO(/obj/item/parts/robot_parts/chest/standard) //Move this to it's file later.
	mats = list("metal_dense" = ROBOT_CHEST_COST*10)
/datum/manufacture/robo_chest
	name = "Cyborg Chest"
	item_outputs = list(/obj/item/parts/robot_parts/chest/standard)
	create = 1
	time = 30 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/chest/light) //Move this to it's file later.
	mats = list("metal_dense" = ROBOT_CHEST_COST*ROBOT_LIGHT_COST_MOD*10)
/datum/manufacture/robo_chest_light
	name = "Light Cyborg Chest"
	item_outputs = list(/obj/item/parts/robot_parts/chest/light)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/head/standard) //Move this to it's file later.
	mats = list("metal_dense" = ROBOT_HEAD_COST*10)
/datum/manufacture/robo_head
	name = "Cyborg Head"
	item_outputs = list(/obj/item/parts/robot_parts/head/standard)
	create = 1
	time = 30 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/head/screen) //Move this to it's file later.
	mats = list("metal_dense" = ROBOT_SCREEN_METAL_COST*10,
				"conductive" = 2,
				"crystal" = 6)
/datum/manufacture/robo_head_screen
	name = "Cyborg Screen Head"
	item_outputs = list(/obj/item/parts/robot_parts/head/screen)
	create = 1
	time = 24 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/head/light) //Move this to it's file later.
	mats = list("metal" = ROBOT_HEAD_COST*ROBOT_LIGHT_COST_MOD*10)
/datum/manufacture/robo_head_light
	name = "Light Cyborg Head"
	item_outputs = list(/obj/item/parts/robot_parts/head/light)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/arm/right/standard) //Move this to it's file later.
	mats = list("metal_dense" = ROBOT_LIMB_COST*10)
/datum/manufacture/robo_arm_r
	name = "Cyborg Arm (Right)"
	item_outputs = list(/obj/item/parts/robot_parts/arm/right/standard)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/arm/right/light) //Move this to it's file later.
	mats = list("metal" = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10)
/datum/manufacture/robo_arm_r_light
	name = "Light Cyborg Arm (Right)"
	item_outputs = list(/obj/item/parts/robot_parts/arm/right/light)
	create = 1
	time = 8 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/arm/left/standard) //Move this to it's file later.
	mats = list("metal_dense" = ROBOT_LIMB_COST*10)
/datum/manufacture/robo_arm_l
	name = "Cyborg Arm (Left)"
	item_outputs = list(/obj/item/parts/robot_parts/arm/left/standard)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/arm/left/light) //Move this to it's file later.
	mats = list("metal" = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10)
/datum/manufacture/robo_arm_l_light
	name = "Light Cyborg Arm (Left)"
	item_outputs = list(/obj/item/parts/robot_parts/arm/left/light)
	create = 1
	time = 8 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/leg/right/standard) //Move this to it's file later.
	mats = list("metal_dense" = ROBOT_LIMB_COST*10)
/datum/manufacture/robo_leg_r
	name = "Cyborg Leg (Right)"
	item_outputs = list(/obj/item/parts/robot_parts/leg/right/standard)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/leg/right/light) //Move this to it's file later.
	mats = list("metal" = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10)
/datum/manufacture/robo_leg_r_light
	name = "Light Cyborg Leg (Right)"
	item_outputs = list(/obj/item/parts/robot_parts/leg/right/light)
	create = 1
	time = 8 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/leg/left/standard) //Move this to it's file later.
	mats = list("metal_dense" = ROBOT_LIMB_COST*10)
/datum/manufacture/robo_leg_l
	name = "Cyborg Leg (Left)"
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/standard)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/leg/left/light) //Move this to it's file later.
	mats = list("metal" = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10)
/datum/manufacture/robo_leg_l_light
	name = "Light Cyborg Leg (Left)"
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/light)
	create = 1
	time = 8 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/parts/robot_parts/leg/left/treads) //Move this to it's file later.
	mats = list("metal_dense" = ROBOT_TREAD_METAL_COST*10,
				"conductive" = 3)
TYPEINFO(/obj/item/parts/robot_parts/leg/right/treads) //Move this to it's file later.
	mats = list("metal_dense" = ROBOT_TREAD_METAL_COST*10,
				"conductive" = 3)
/datum/manufacture/robo_leg_treads
	name = "Cyborg Treads"
	item_requirements = list("metal_dense" = ROBOT_TREAD_METAL_COST*2*10,
							 "conductive" = 6)
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/treads, /obj/item/parts/robot_parts/leg/right/treads)
	create = 1
	time = 15 SECONDS
	category = "Component"
	apply_material = TRUE

TYPEINFO(/obj/item/robot_module) //Move this to it's file later.
	mats = list("conductive" = 2,
				"any" = 3)
/datum/manufacture/robo_module
	name = "Blank Cyborg Module"
	item_outputs = list(/obj/item/robot_module)
	create = 1
	time = 40 SECONDS
	category = "Component"

TYPEINFO(/obj/item/cell/supercell) //Move this to it's file later.
	mats = list("metal" = 4,
				"conductive" = 4,
				"any" = 4)
/datum/manufacture/powercell
	name = "Power Cell"
	item_outputs = list(/obj/item/cell/supercell)
	create = 1
	time = 30 SECONDS
	category = "Component"

TYPEINFO(/obj/item/cell/erebite) //Move this to it's file later.
	mats = list("metal" = 4,
				"any" = 4,
				"erebite" = 2)
/datum/manufacture/powercellE
	name = "Erebite Power Cell"
	item_outputs = list(/obj/item/cell/erebite)
	create = 1
	time = 45 SECONDS
	category = "Component"

TYPEINFO(/obj/item/cell/cerenkite) //Move this to it's file later.
	mats = list("metal" = 4,
				"any" = 4,
				"cerenkite" = 2)
/datum/manufacture/powercellC
	name = "Cerenkite Power Cell"
	item_outputs = list(/obj/item/cell/cerenkite)
	create = 1
	time = 45 SECONDS
	category = "Component"

TYPEINFO(/obj/item/cell/hypercell) //Move this to it's file later.
	mats = list("dense_super" = 5,
				"conductive_high" = 10,
				"energy_high" = 10)
/datum/manufacture/powercellH
	name = "Hyper Capacity Power Cell"
	item_outputs = list(/obj/item/cell/hypercell)
	create = 1
	time = 120 SECONDS
	category = "Component"

TYPEINFO(/obj/ai_core_frame) //Move this to it's file later.
	mats = list("metal_dense" = 20)
/datum/manufacture/core_frame
	name = "AI Core Frame"
	item_outputs = list(/obj/ai_core_frame)
	create = 1
	time = 50 SECONDS
	category = "Component"

TYPEINFO(/obj/machinery/disk_rack/clone) //Move this to it's file later.
	mats = list("metal" = 30, "conductive" = 10)
/datum/manufacture/clone_rack
	name = "Clone Rack"
	item_outputs = list(/obj/machinery/disk_rack/clone)
	create = 1
	time = 40 SECONDS

TYPEINFO(/obj/item/shell_frame) //Move this to it's file later.
	mats = list("metal_dense" = 12)
/datum/manufacture/shell_frame
	name = "AI Shell Frame"
	item_outputs = list(/obj/item/shell_frame)
	create = 1
	time = 25 SECONDS
	category = "Component"

TYPEINFO(/obj/item/ai_interface) //Move this to it's file later.
	mats = list("metal_dense" = 3,
				"conductive" = 5,
				"crystal" = 2)
/datum/manufacture/ai_interface
	name = "AI Interface Board"
	item_outputs = list(/obj/item/ai_interface)
	create = 1
	time = 35 SECONDS
	category = "Component"

TYPEINFO(/obj/item/organ/brain/latejoin) //Move this to it's file later.
	mats = list("metal" = 6,
				"conductive" = 5,
				"any" = 3)
/datum/manufacture/latejoin_brain
	name = "Spontaneous Intelligence Creation Core"
	item_outputs = list(/obj/item/organ/brain/latejoin)
	create = 1
	time = 35 SECONDS
	category = "Component"

TYPEINFO(/obj/item/cell/shell_cell) //Move this to it's file later.
	mats = list("metal" = 2,
				"conductive" = 2,
				"any" = 1)
/datum/manufacture/shell_cell
	name = "AI Shell Power Cell"
	item_outputs = list(/obj/item/cell/shell_cell)
	create = 1
	time = 20 SECONDS
	category = "Component"

TYPEINFO(/obj/item/device/flash) //Move this to it's file later.
	mats = list("metal" = 3,
				"conductive" = 5,
				"crystal" = 5)
/datum/manufacture/flash
	name = "Flash"
	item_outputs = list(/obj/item/device/flash)
	create = 1
	time = 15 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/device/borg_linker) //Move this to it's file later.
	mats = list("metal" = 2,
				"crystal" = 1,
				"conductive" = 2)
/datum/manufacture/borg_linker
	name = "AI Linker"
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

TYPEINFO(/obj/item/aiModule) //Move this to it's file later.
	mats = list("metal_dense" = 10)
ABSTRACT_TYPE(/datum/manufacture/aiModule)
/datum/manufacture/aiModule
	name = "AI Law Module - 'YOU SHOULDNT SEE ME'"
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

TYPEINFO(/obj/item/implanter) //Move this to it's file later.
	mats = list("metal" = 1)
/datum/manufacture/implanter
	name = "Implanter"
	item_outputs = list(/obj/item/implanter)
	create = 1
	time = 3 SECONDS
	category = "Tool"

TYPEINFO(/obj/machinery/bot/floorbot) //Move this to it's file later.
	mats = list("metal" = 15,
				"conductive" = 10,
				"any" = 5)
/datum/manufacture/floorbot
	name = "Construction Drone"
	item_outputs = list(/obj/machinery/bot/floorbot)
	create = 1
	time = 60 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/bot/medbot) //Move this to it's file later.
	mats = list("metal" = 20,
				"conductive" = 15,
				"energy" = 5)
/datum/manufacture/medbot
	name = "Medical Drone"
	item_outputs = list(/obj/machinery/bot/medbot)
	create = 1
	time = 90 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/bot/firebot) //Move this to it's file later.
	mats = list("metal" = 15,
				"conductive" = 10,
				"any" = 5)
/datum/manufacture/firebot
	name = "Firefighting Drone"
	item_outputs = list(/obj/machinery/bot/firebot)
	create = 1
	time = 60 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/bot/cleanbot) //Move this to it's file later.
	mats = list("metal" = 15,
				"conductive" = 10,
				"any" = 5)
/datum/manufacture/cleanbot
	name = "Sanitation Drone"
	item_outputs = list(/obj/machinery/bot/cleanbot)
	create = 1
	time = 60 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/bot/mining) //Move this to it's file later.
	mats = list("metal" = 15,
				"metal_dense" = 5,
				"conductive" = 10,
				"any" = 5)
/datum/manufacture/digbot
	name = "Mining Drone"
	item_outputs = list(/obj/machinery/bot/mining)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

TYPEINFO(/obj/item/roboupgrade/jetpack) //Move this to it's file later.
	mats = list("conductive" = 3,
				"metal" = 5)
/datum/manufacture/robup_jetpack
	name = "Propulsion Upgrade"
	item_outputs = list(/obj/item/roboupgrade/jetpack)
	create = 1
	time = 60 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/speed) //Move this to it's file later.
	mats = list("conductive" = 3,
				"crystal" = 5)
/datum/manufacture/robup_speed
	name = "Speed Upgrade"
	item_outputs = list(/obj/item/roboupgrade/speed)
	create = 1
	time = 60 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/magboot) //Move this to it's file later.
	mats = list("conductive" = 5,
				"crystal" = 3)
/datum/manufacture/robup_mag
	name = "Magnetic Traction Upgrade"
	item_outputs = list(/obj/item/roboupgrade/magboot)
	create = 1
	time = 60 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/rechargepack) //Move this to it's file later.
	mats = list("conductive" = 5)
/datum/manufacture/robup_recharge
	name = "Recharge Pack"
	item_outputs = list(/obj/item/roboupgrade/rechargepack)
	create = 1
	time = 60 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/repairpack) //Move this to it's file later.
	mats = list("conductive" = 5)
/datum/manufacture/robup_repairpack
	name = "Repair Pack"
	item_outputs = list(/obj/item/roboupgrade/repairpack)
	create = 1
	time = 60 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/physshield) //Move this to it's file later.
	mats = list("conductive_high" = 2,
				"metal_dense" = 10,
				"energy_high" = 2)
/datum/manufacture/robup_physshield
	name = "Force Shield Upgrade"
	item_outputs = list(/obj/item/roboupgrade/physshield)
	create = 1
	time = 90 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/fireshield) //Move this to it's file later.
	mats = list("conductive_high" = 2,
				"crystal" = 10)
/datum/manufacture/robup_fireshield
	name = "Heat Shield Upgrade"
	item_outputs = list(/obj/item/roboupgrade/fireshield)
	create = 1
	time = 90 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/aware) //Move this to it's file later.
	mats = list("conductive_high" = 2,
				"crystal" = 5,
				"conductive" = 5)
/datum/manufacture/robup_aware
	name = "Recovery Upgrade"
	item_outputs = list(/obj/item/roboupgrade/aware)
	create = 1
	time = 90 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/efficiency) //Move this to it's file later.
	mats = list("dense" = 3,
				"conductive_high" = 10)
/datum/manufacture/robup_efficiency
	name = "Efficiency Upgrade"
	item_outputs = list(/obj/item/roboupgrade/efficiency)
	create = 1
	time = 120 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/repair) //Move this to it's file later.
	mats = list("dense" = 3,
				"metal_superdense" = 10)
/datum/manufacture/robup_repair
	name = "Self-Repair Upgrade"
	item_outputs = list(/obj/item/roboupgrade/repair)
	create = 1
	time = 120 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/teleport) //Move this to it's file later.
	mats = list("conductive" = 10,
				"dense" = 1,
				"telecrystal" = 10)//Okayenoughroundstartteleportborgs.Fuck.
/datum/manufacture/robup_teleport
	name = "Teleport Upgrade"
	item_outputs = list(/obj/item/roboupgrade/teleport)
	create = 1
	time = 120 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/expand) //Move this to it's file later.
	mats = list("crystal_dense" = 3,
				"energy_extreme" = 1)
/datum/manufacture/robup_expand
	name = "Expansion Upgrade"
	item_outputs = list(/obj/item/roboupgrade/expand)
	create = 1
	time = 120 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/opticmeson) //Move this to it's file later.
	mats = list("crystal" = 2,
				"conductive" = 4)
/datum/manufacture/robup_meson
	name = "Optical Meson Upgrade"
	item_outputs = list(/obj/item/roboupgrade/opticmeson)
	create = 1
	time = 90 SECONDS
	category = "Component"
/* shit done be broked
TYPEINFO(obj/item/roboupgrade/opticthermal) //Move this to it's file later.
	mats = list("crystal" = 4,
				"conductive" = 8)
/datum/manufacture/robup_thermal
	name = "Optical Thermal Upgrade"
	item_outputs = list(/obj/item/roboupgrade/opticthermal)
	create = 1
	time = 90 SECONDS
	category = "Component"
*/
TYPEINFO(/obj/item/roboupgrade/healthgoggles) //Move this to it's file later.
	mats = list("crystal" = 4,
				"conductive" = 6)
/datum/manufacture/robup_healthgoggles
	name = "ProDoc Healthgoggle Upgrade"
	item_outputs = list(/obj/item/roboupgrade/healthgoggles)
	create = 1
	time = 90 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/sechudgoggles) //Move this to it's file later.
	mats = list("crystal" = 4,
				"conductive" = 6)
/datum/manufacture/robup_sechudgoggles
	name = "Security HUD Upgrade"
	item_outputs = list(/obj/item/roboupgrade/sechudgoggles)
	create = 1
	time = 90 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/spectro) //Move this to it's file later.
	mats = list("crystal" = 4,
				"conductive" = 6)
/datum/manufacture/robup_spectro
	name = "Spectroscopic Scanner Upgrade"
	item_outputs = list(/obj/item/roboupgrade/spectro)
	create = 1
	time = 90 SECONDS
	category = "Component"

TYPEINFO(/obj/item/roboupgrade/visualizer) //Move this to it's file later.
	mats = list("crystal" = 4,
				"conductive" = 6)
/datum/manufacture/robup_visualizer
	name = "Construction Visualizer"
	item_outputs = list(/obj/item/roboupgrade/visualizer)
	create = 1
	time = 90 SECONDS
	category = "Component"

TYPEINFO(/obj/item/instrument/roboscream) //Move this to it's file later.
	mats = list("conductive" = 2, "metal" = 2, "insulated" = 2)
/datum/manufacture/scream_synth
	name = "Scream Synthesizer"
	item_outputs = list(/obj/item/instrument/roboscream)
	create = 1
	time = 30 SECONDS
	category = "Component"

TYPEINFO(/obj/item/implantcase/robotalk) //Move this to it's file later.
	mats = list("conductive" = 3,
				"crystal" = 3)
/datum/manufacture/implant_robotalk
	name = "Machine Translator Implant"
	item_outputs = list(/obj/item/implantcase/robotalk)
	create = 1
	time = 40 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/device/radio) //Move this to it's file later.
	mats = list("conductive" = 2,
				"crystal" = 2)
/datum/manufacture/sbradio
	name = "Station Bounced Radio"
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

TYPEINFO(/obj/item/clothing/suit/hazard/bio_suit) //Move this to it's file later.
	mats = list("fabric" = 4)
TYPEINFO(/obj/item/clothing/head/bio_hood) //Move this to it's file later.
	mats = list("fabric" = 1,
				"crystal" = 2)
/datum/manufacture/biosuit
	name = "Biosuit Set"
	item_requirements = list("fabric" = 5,
							 "crystal" = 2)
	item_outputs = list(/obj/item/clothing/suit/hazard/bio_suit,/obj/item/clothing/head/bio_hood)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/glasses/spectro) //Move this to it's file later.
	mats = list("metal" = 1,
				"crystal" = 2)
/datum/manufacture/spectrogoggles
	name = "Spectroscopic Scanner Goggles"
	item_outputs = list(/obj/item/clothing/glasses/spectro)
	create = 1
	time = 20 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/mask/gas) //Move this to it's file later.
	mats = list("fabric" = 2,
				"metal_dense" = 4,
				"crystal" = 2)
/datum/manufacture/gasmask
	name = "Gas Mask"
	item_outputs = list(/obj/item/clothing/mask/gas)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/reagent_containers/dropper) //Move this to it's file later.
	mats = list("insulated" = 1,
				"crystal" = 2)
/datum/manufacture/dropper
	name = "Dropper"
	item_outputs = list(/obj/item/reagent_containers/dropper)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/reagent_containers/dropper/mechanical) //Move this to it's file later.
	mats = list("metal" = 3,
				"conductive" = 3)
/datum/manufacture/mechdropper
	name = "Mechanical Dropper"
	item_outputs = list(/obj/item/reagent_containers/dropper/mechanical)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/device/gps) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1)
/datum/manufacture/gps
	name = "Space GPS"
	item_outputs = list(/obj/item/device/gps)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/device/reagentscanner) //Move this to it's file later.
	mats = list("metal" = 2,
				"conductive" = 2,
				"crystal" = 1)
/datum/manufacture/reagentscanner
	name = "Reagent Scanner"
	item_outputs = list(/obj/item/device/reagentscanner)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/paper_bin/artifact_paper) //Move this to it's file later.
	mats = list("metal" = 2,
				"fabric" = 5)
/datum/manufacture/artifactforms
	name = "Artifact Analysis Forms"
	item_outputs = list(/obj/item/paper_bin/artifact_paper)
	create = 1
	time = 10 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/audio_tape) //Move this to it's file later.
	mats = list("metal" = 2)
/datum/manufacture/audiotape
	name = "Audio Tape"
	item_outputs = list(/obj/item/audio_tape)
	create = 1
	time = 4 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/device/audio_log) //Move this to it's file later.
	mats = list("metal" = 3,
				"conductive" = 5)
/datum/manufacture/audiolog
	name = "Audio Log"
	item_outputs = list(/obj/item/device/audio_log)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/magnet_parts) //Move this to it's file later.
	mats = list("dense" = 5,
				"metal_superdense" = 30,
				"conductive_high" = 30)
// Mining Gear
#ifndef UNDERWATER_MAP
/datum/manufacture/mining_magnet
	name = "Mining Magnet Replacement Parts"
	item_outputs = list(/obj/item/magnet_parts)
	create = 1
	time = 120 SECONDS
	category = "Component"
#endif

TYPEINFO(/obj/item/mining_tool) //Move this to it's file later.
	mats = list("metal_dense" = 1)
/datum/manufacture/pick
	name = "Pickaxe"
	item_outputs = list(/obj/item/mining_tool)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/mining_tool/powered/pickaxe) //Move this to it's file later.
	mats = list("metal_dense" = 2,
				"conductive" = 5)
/datum/manufacture/powerpick
	name = "Powered Pick"
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

TYPEINFO(/obj/item/mining_tool/powered/hammer) //Move this to it's file later.
	mats = list("metal_dense" = 15,
				"metal_superdense" = 7,
				"conductive" = 10)
/datum/manufacture/powerhammer
	name = "Power Hammer"
	item_outputs = list(/obj/item/mining_tool/powered/hammer)
	create = 1
	time = 70 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/mining_tool/powered/drill) //Move this to it's file later.
	mats = list("metal_dense" = 15,
				"conductive_high" = 10)
/datum/manufacture/drill
	name = "Laser Drill"
	item_outputs = list(/obj/item/mining_tool/powered/drill)
	create = 1
	time = 90 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/clothing/gloves/concussive) //Move this to it's file later.
	mats = list("metal_superdense" = 15,
				"conductive_high" = 15,
				"energy" = 2)
/datum/manufacture/conc_gloves
	name = "Concussive Gauntlets"
	item_outputs = list(/obj/item/clothing/gloves/concussive)
	create = 1
	time = 120 SECONDS
	category = "Tool"

TYPEINFO(/obj/machinery/oreaccumulator) //Move this to it's file later.
	mats = list("metal_dense" = 25,
				"conductive_high" = 15,
				"dense" = 2)
/datum/manufacture/ore_accumulator
	name = "Mineral Accumulator"
	item_outputs = list(/obj/machinery/oreaccumulator)
	create = 1
	time = 120 SECONDS
	category = "Machinery"

TYPEINFO(/obj/item/clothing/glasses/toggleable/meson) //Move this to it's file later.
	mats = list("crystal" = 3,
				"conductive" = 2)
/datum/manufacture/eyes_meson
	name = "Optical Meson Scanner"
	item_outputs = list(/obj/item/clothing/glasses/toggleable/meson)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/glasses/toggleable/atmos) //Move this to it's file later.
	mats = list("crystal" = 3,
				"conductive" = 2)
/datum/manufacture/atmos_goggles
	name = "Pressure Visualization Goggles"
	item_outputs = list(/obj/item/clothing/glasses/toggleable/atmos)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/oreprospector) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"crystal" = 1)
/datum/manufacture/geoscanner
	name = "Geological Scanner"
	item_outputs = list(/obj/item/oreprospector)
	create = 1
	time = 8 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/ore_scoop) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"crystal" = 1)
/datum/manufacture/ore_scoop
	name = "Ore Scoop"
	item_outputs = list(/obj/item/ore_scoop)
	item_names = list("Metal","Conductive Material","Crystal")
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/device/geiger) //Move this to it's file later.
	mats = list("metal" = 1,
				"conductive" = 1,
				"crystal" = 1)
/datum/manufacture/geigercounter
	name = "Geiger Counter"
	item_outputs = list(/obj/item/device/geiger)
	create = 1
	time = 8 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/clothing/suit/space/industrial) //Move this to it's file later.
	mats = list("metal_superdense" = 12,
				"conductive_high" = 8)
TYPEINFO(/obj/item/clothing/head/helmet/space/industrial) //Move this to it's file later.
	mats = list("metal_superdense" = 3,
				"conductive_high" = 2,
				"crystal_dense" = 5)
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

TYPEINFO(/obj/item/tank/jetpack/jetpackmk2) //Move this to it's file later.
	mats = list("metal_dense" = 15,
				"conductive_high" = 10,
				"energy" = 5)
/datum/manufacture/jetpackmkII
	name = "Jetpack MKII"
	item_outputs = list(/obj/item/tank/jetpack/jetpackmk2)
	create = 1
	time = 40 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/mask/breath) //Move this to it's file later.
	mats = list("fabric" = 1)
/datum/manufacture/breathmask
	name = "Breath Mask"
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
	item_outputs = list(/obj/item/tank/mini/plasma/empty)
	create = 1
	time = 5 SECONDS
	category = "Resource"

/datum/manufacture/minioxygentank
	name = "Mini oxygen tank"
	item_requirements = list("metal_dense" = 1)
	item_outputs = list(/obj/item/tank/mini/oxygen/empty)
	create = 1
	time = 5 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/reagent_containers/patch) //Move this to it's file later.
	mats = list("fabric" = 1)
/datum/manufacture/patch
	name = "Chemical Patch"
	item_outputs = list(/obj/item/reagent_containers/patch)
	create = 2
	time = 5 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/reagent_containers/mender) //Move this to it's file later.
	mats =	list("metal_dense" = 3,
				"crystal" = 2,
				"gold" = 3)
/datum/manufacture/mender
	name = "Auto Mender (x2)"
	item_requirements = list("metal_dense" = 5,
							 "crystal" = 4,
							 "gold" = 5)
	item_outputs = list(/obj/item/reagent_containers/mender)
	create = 2
	time = 30 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/device/light/flashlight/penlight) //Move this to it's file later.
	mats = list("metal" = 1,
				"crystal" = 1)
/datum/manufacture/penlight
	name = "Penlight"
	item_outputs = list(/obj/item/device/light/flashlight/penlight)
	create = 1
	time = 2 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/medicaldiagnosis/stethoscope) //Move this to it's file later.
	mats = list("metal" = 2,
				"crystal" = 1)
/datum/manufacture/stethoscope
	name = "Stethoscope"
	item_outputs = list(/obj/item/medicaldiagnosis/stethoscope)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/clothing/suit/space) //Move this to it's file later.
	mats = list("fabric" = 2,
				"metal" = 2)
TYPEINFO(/obj/item/clothing/head/helmet/space) //Move this to it's file later.
	mats = list("fabric" = 1,
				"metal" = 1,
				"crystal" = 2)
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

TYPEINFO(/obj/item/clothing/suit/space/light/engineer) //Move this to it's file later.
	mats = list("fabric" = 8,
				"metal_superdense" = 4,
				"organic_or_rubber" = 4)
TYPEINFO(/obj/item/clothing/head/helmet/space/light/engineer) //Move this to it's file later.
	mats = list("fabric" = 2,
				"metal_superdense" = 1,
				"crystal" = 2,
				"organic_or_rubber" = 1)
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

TYPEINFO(/obj/item/satchel/mining) //Move this to it's file later.
	mats = list("fabric" = 5)
/datum/manufacture/oresatchel
	name = "Ore Satchel"
	item_outputs = list(/obj/item/satchel/mining)
	create = 1
	time = 5 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/satchel/mining/large) //Move this to it's file later.
	mats = list("fabric" = 25,
				"metal_superdense" = 3)
/datum/manufacture/oresatchelL
	name = "Large Ore Satchel"
	item_outputs = list(/obj/item/satchel/mining/large)
	create = 1
	time = 15 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/storage/breach_pouch) //Move this to it's file later.
	mats = list("fabric" = 10,
				"metal_dense" = 2)
/datum/manufacture/breach_pouch
	name = "Mining charge pouch"
	item_outputs = list(/obj/item/storage/breach_pouch)
	create = 1
	time = 15 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/tank/jetpack) //Move this to it's file later.
	mats = list("metal_superdense" = 10,
				"conductive_high" = 20)
/datum/manufacture/jetpack
	name = "Jetpack"
	item_outputs = list(/obj/item/tank/jetpack)
	create = 1
	time = 60 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/tank/jetpack/micro) //Move this to it's file later.
	mats = list("metal_dense" = 5,
				"conductive" = 10)
/datum/manufacture/microjetpack
	name = "Micro Jetpack"
	item_outputs = list(/obj/item/tank/jetpack/micro)
	create = 1
	time = 30 SECONDS
	category = "Clothing"

/// Ship Items -- OLD COMPONENTS

TYPEINFO(/obj/item/shipcomponent/engine/scout) //Move this to it's file later.
	mats = list("metal_dense" = 5,
				"conductive" = 10)
/datum/manufacture/engine_scout
	name = "Scout Engine"
	item_outputs = list(/obj/item/shipcomponent/engine/scout)
	create = 1
	time = 5 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/shipcomponent/engine) //Move this to it's file later.
	mats = list("metal_dense" = 3,
				"conductive" = 5)
/datum/manufacture/engine
	name = "Warp-1 Engine"
	item_outputs = list(/obj/item/shipcomponent/engine)
	create = 1
	time = 10 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/shipcomponent/engine/helios) //Move this to it's file later.
	mats = list("metal_dense" = 20,
				"metal_superdense" = 10,
				"conductive_high" = 15)
/datum/manufacture/engine2
	name = "Helios Mark-II Engine"
	item_outputs = list(/obj/item/shipcomponent/engine/helios)
	create = 1
	time = 90 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/shipcomponent/engine/hermes) //Move this to it's file later.
	mats = list("metal_superdense" = 20,
				"conductive_high" = 20,
				"energy" = 5)
/datum/manufacture/engine3
	name = "Hermes 3.0 Engine"
	item_outputs = list(/obj/item/shipcomponent/engine/hermes)
	create = 1
	time = 120 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/shipcomponent/secondary_system/gps) //Move this to it's file later.
	mats = list("metal" = 5,
				"conductive" = 5)
/datum/manufacture/podgps
	name = "Ship's Navigation GPS"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/gps)
	create = 1
	time = 12 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/shipcomponent/secondary_system/cargo) //Move this to it's file later.
	mats = list("metal_dense" = 20)
/datum/manufacture/cargohold
	name = "Cargo Hold"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/cargo)
	create = 1
	time = 12 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/shipcomponent/secondary_system/storage) //Move this to it's file later.
	mats = list("metal_dense" = 20)
/datum/manufacture/storagehold
	name = "Storage Hold"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/storage)
	create = 1
	time = 12 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/shipcomponent/secondary_system/orescoop) //Move this to it's file later.
	mats = list("metal_dense" = 20,
				"conductive" = 10)
/datum/manufacture/orescoop
	name = "Alloyed Solutions Ore Scoop/Hold"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/orescoop)
	create = 1
	time = 12 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/shipcomponent/communications) //Move this to it's file later.
	mats = list("metal_dense" = 10,
				"conductive" = 20)
/datum/manufacture/communications
	name = "Robustco Communication Array"
	item_outputs = list(/obj/item/shipcomponent/communications)
	create = 1
	time = 12 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/shipcomponent/communications/mining) //Move this to it's file later.
	mats = list("metal_dense" = 10,
				"conductive" = 20)
/datum/manufacture/communications/mining
	name = "NT Magnet Link Array"
	item_outputs = list(/obj/item/shipcomponent/communications/mining)
	create = 1
	time = 12 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/shipcomponent/sensor/mining) //Move this to it's file later.
	mats = list("energy" = 1,
				"crystal" = 5,
				"conductive_high" = 2)
/datum/manufacture/conclave
	name = "Conclave A-1984 Sensor System"
	item_outputs = list(/obj/item/shipcomponent/sensor/mining)
	create = 1
	time = 5 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/shipcomponent/secondary_system/cargo) //Move this to it's file later.
	mats = list("metal_superdense" = 5,
				"dense" = 1,
				"conductive" = 10)
/datum/manufacture/shipRCD
	name = "Duracorp Construction Device"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/cargo)
	create = 1
	time = 90 SECONDS
	category = "Resource"

//  cogwerks - clothing manufacturer datums

TYPEINFO(/obj/item/storage/backpack) //Move this to it's file later.
	mats = list("fabric" = 8)
/datum/manufacture/backpack
	name = "Backpack"
	item_outputs = list(/obj/item/storage/backpack)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/backpack_red
	name = "Red Backpack"
	item_outputs = list(/obj/item/storage/backpack/empty/red)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/backpack_green
	name = "Green Backpack"
	item_outputs = list(/obj/item/storage/backpack/empty/green)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/backpack_blue
	name = "Blue Backpack"
	item_outputs = list(/obj/item/storage/backpack/empty/blue)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/backpack_brown
	name = "Brown Backpack"
	item_outputs = list(/obj/item/storage/backpack/empty/brown)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/storage/backpack/satchel/empty) //Move this to it's file later.
	mats = list("fabric" = 8)
/datum/manufacture/satchel
	name = "Satchel"
	item_outputs = list(/obj/item/storage/backpack/satchel/empty)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/satchel_red
	name = "Red Satchel"
	item_outputs = list(/obj/item/storage/backpack/satchel/empty/red)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/satchel_green
	name = "Green Satchel"
	item_outputs = list(/obj/item/storage/backpack/satchel/empty/green)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/satchel_blue
	name = "Blue Satchel"
	item_outputs = list(/obj/item/storage/backpack/satchel/empty/blue)
	create = 1
	time = 10 SECONDS
	category = "Clothing"

/datum/manufacture/satchel_brown
	name = "Brown Satchel"
	item_outputs = list(/obj/item/storage/backpack/satchel/empty/brown)
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

TYPEINFO(/obj/item/clothing/head) //Move this to it's file later.
	mats = list("fabric" = 2)
/datum/manufacture/hat_white
	name = "White Hat"
	item_outputs = list(/obj/item/clothing/head/white)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_black
	name = "Black Hat"
	item_outputs = list(/obj/item/clothing/head/black)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_blue
	name = "Blue Hat"
	item_outputs = list(/obj/item/clothing/head/blue)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_red
	name = "Red Hat"
	item_outputs = list(/obj/item/clothing/head/red)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_green
	name = "Green Hat"
	item_outputs = list(/obj/item/clothing/head/green)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_yellow
	name = "Yellow Hat"
	item_outputs = list(/obj/item/clothing/head/yellow)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_pink
	name = "Pink Hat"
	item_outputs = list(/obj/item/clothing/head/pink)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_orange
	name = "Orange Hat"
	item_outputs = list(/obj/item/clothing/head/orange)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

/datum/manufacture/hat_purple
	name = "Purple Hat"
	item_outputs = list(/obj/item/clothing/head/purple)
	create = 1
	time = 2 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/head/that) //Move this to it's file later.
	mats = list("fabric" = 3)
/datum/manufacture/hat_tophat
	name = "Top Hat"
	item_requirements = list("fabric" = 3)
	item_outputs = list(/obj/item/clothing/head/that)
	create = 1
	time = 3 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/head/longtophat) //Move this to it's file later.
	mats = list("fabric" = 5)
/datum/manufacture/hat_ltophat
	name = "Large Top Hat"
	item_requirements = list("fabric" = 5)
	item_outputs = list(/obj/item/clothing/head/longtophat)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_white
	name = "White Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/color/white)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_red
	name = "Red Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/color/red)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_yellow
	name = "Yellow Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/color/yellow)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_green
	name = "Green Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/color/green)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_pink
	name = "Pink Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/color/pink)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_blue
	name = "Blue Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/color/blue)
	create = 1
	time = 5 SECONDS
	category = "Clothing"


/datum/manufacture/jumpsuit_purple
	name = "Purple Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/color/purple)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_brown
	name = "Brown Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/color/brown)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_black
	name = "Black Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/color)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/jumpsuit_orange
	name = "Orange Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/color/orange)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/tricolor
	name = "Tricolor Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/misc/tricolor)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_lgbt
	name = "LGBT Pride Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/pride)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_ace
	name = "Asexual Pride Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/pride/ace)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_aro
	name = "Aromantic Pride Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/pride/aro)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_bi
	name = "Bisexual Pride Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/pride/bi)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_inter
	name = "Intersex Pride Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/pride/inter)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_lesb
	name = "Lesbian Pride Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/pride/lesb)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_gay
	name = "Gay Pride Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/pride/gaymasc)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_nb
	name = "Non-binary Pride Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/pride/nb)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_pan
	name = "Pansexual Pride Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/pride/pan)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_poly
	name = "Polysexual Pride Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/pride/poly)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/pride_trans
	name = "Trans Pride Jumpsuit"
	item_outputs = list(/obj/item/clothing/under/pride/trans)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/suit_black
	name = "Fancy Black Suit"
	item_outputs = list(/obj/item/clothing/under/suit/black)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/dress_black
	name = "Fancy Black Dress"
	item_outputs = list(/obj/item/clothing/under/suit/black/dress)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/suit/labcoat) //Move this to it's file later.
	mats = list("fabric" = 4)
/datum/manufacture/labcoat
	name = "Labcoat"
	item_outputs = list(/obj/item/clothing/suit/labcoat)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_white
	name = "White Scrubs"
	item_outputs = list(/obj/item/clothing/under/scrub)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_teal
	name = "Teal Scrubs"
	item_outputs = list(/obj/item/clothing/under/scrub/teal)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_maroon
	name = "Maroon Scrubs"
	item_outputs = list(/obj/item/clothing/under/scrub/maroon)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_blue
	name = "Navy Scrubs"
	item_outputs = list(/obj/item/clothing/under/scrub/blue)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_purple
	name = "Violet Scrubs"
	item_outputs = list(/obj/item/clothing/under/scrub/purple)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_orange
	name = "Orange Scrubs"
	item_outputs = list(/obj/item/clothing/under/scrub/orange)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/scrubs_pink
	name = "Hot Pink Scrubs"
	item_outputs = list(/obj/item/clothing/under/scrub/pink)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/medical_backpack
	name = "Medical Backpack"
	item_outputs = list(/obj/item/storage/backpack/medic)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

/datum/manufacture/patient_gown
	name = "Gown"
	item_outputs = list(/obj/item/clothing/under/patient_gown)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/mask/surgical) //Move this to it's file later.
	mats = list("fabric" = 1)
/datum/manufacture/surgical_mask
	name = "Sterile Mask"
	item_outputs = list(/obj/item/clothing/mask/surgical)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/mask/surgical_shield) //Move this to it's file later.
	mats = list("fabric" = 1)
/datum/manufacture/surgical_shield
	name = "Surgical Face Shield"
	item_outputs = list(/obj/item/clothing/mask/surgical_shield)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/glasses/eyepatch) //Move this to it's file later.
	mats = list("fabric" = 5)
/datum/manufacture/eyepatch
	name = "Medical Eyepatch"
	item_outputs = list(/obj/item/clothing/glasses/eyepatch)
	create = 1
	time = 15 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/glasses/blindfold) //Move this to it's file later.
	mats = list("fabric" = 4)
/datum/manufacture/blindfold
	name = "Blindfold"
	item_outputs = list(/obj/item/clothing/glasses/blindfold)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/mask/muzzle) //Move this to it's file later.
	mats = list("fabric" = 4,
				"metal" = 2)
/datum/manufacture/muzzle
	name = "Muzzle"
	item_outputs = list(/obj/item/clothing/mask/muzzle)
	create = 1
	time = 5 SECONDS
	category = "Clothing"

TYPEINFO(/obj/item/clothing/shoes/hermes) //Move this to it's file later.
	mats = list("metal_superdense" = 30,
				"conductive_high" = 30,
				"energy_extreme" = 6,
				"crystal_dense" = 1,
				"fabric" = 30,
				"insulated" = 30)
/datum/manufacture/hermes
	name = "Offering to the Fabricator Gods"
	item_outputs = list(/obj/item/clothing/shoes/hermes)
	create = 3 //because a shoe god has to have acolytes
	time = 120 //suspense
	category = "Clothing"

TYPEINFO(/obj/item/cloth/towel/white) //Move this to it's file later.
	mats = list("fabric" = 8)
/datum/manufacture/towel
	name = "Towel"
	item_outputs = list(/obj/item/cloth/towel/white)
	create = 1
	time = 8 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/cloth/handkerchief/colored/white) //Move this to it's file later.
	mats = list("fabric" = 4)
/datum/manufacture/handkerchief
	name = "Handkerchief"
	item_outputs = list(/obj/item/cloth/handkerchief/colored/white)
	create = 1
	time = 4 SECONDS
	category = "Resource"

/////// pod construction components

TYPEINFO(/obj/item/podarmor/armor_light) //Move this to it's file later.
	mats = list("metal_dense" = 30,
				"conductive" = 20)
/datum/manufacture/pod/armor_light
	name = "Light Pod Armor"
	item_outputs = list(/obj/item/podarmor/armor_light)
	create = 1
	time = 20 SECONDS
	category = "Component"

TYPEINFO(/obj/item/podarmor/armor_heavy) //Move this to it's file later.
	mats = list("metal_dense" = 30,
				"metal_superdense" = 20)
/datum/manufacture/pod/armor_heavy
	name = "Heavy Pod Armor"
	item_outputs = list(/obj/item/podarmor/armor_heavy)
	create = 1
	time = 30 SECONDS
	category = "Component"

TYPEINFO(/obj/item/podarmor/armor_industrial) //Move this to it's file later.
	mats = list("metal_superdense" = 25,
				"conductive_high" = 10,
				"dense" = 5)
/datum/manufacture/pod/armor_industrial
	name = "Industrial Pod Armor"
	item_outputs = list(/obj/item/podarmor/armor_industrial)
	create = 1
	time = 50 SECONDS
	category = "Component"

TYPEINFO(/obj/item/preassembled_frame_box/pod) //Move this to it's file later.
	mats = list("metal_dense" = 45,
				"conductive" = 25,
				"crystal" = 19)
/datum/manufacture/pod/preassembeled_parts
	name = "Preassembled Pod Frame Kit"
	item_outputs = list(/obj/item/preassembled_frame_box/pod)
	create = 1
	time = 50 SECONDS
	category = "Component"

TYPEINFO(/obj/item/preassembled_frame_box/sub) //Move this to it's file later.
	mats = list("metal_dense" = 23,
				"conductive" = 12,
				"crystal" = 9)
ABSTRACT_TYPE(/datum/manufacture/sub)
/datum/manufacture/sub/preassembeled_parts
	name = "Preassembled Minisub Frame Kit"
	item_outputs = list(/obj/item/preassembled_frame_box/sub)
	create = 1
	time = 25 SECONDS
	category = "Component"

TYPEINFO(/obj/item/preassembled_frame_box/putt) //Move this to it's file later.
	mats = list("metal_dense" = 23,
				"conductive" = 12,
				"crystal" = 9)
ABSTRACT_TYPE(/datum/manufacture/putt)
/datum/manufacture/putt/preassembeled_parts
	name = "Preassembled MiniPutt Frame Kit"
	item_outputs = list(/obj/item/preassembled_frame_box/putt)
	create = 1
	time = 25 SECONDS
	category = "Component"

//// pod addons

ABSTRACT_TYPE(/datum/manufacture/pod)

ABSTRACT_TYPE(/datum/manufacture/pod/weapon)

TYPEINFO(/obj/item/shipcomponent/mainweapon/bad_mining) //Move this to it's file later.
	mats = list("metal_dense" = 10,
				"conductive" = 10,
				"crystal" = 20)
/datum/manufacture/pod/weapon/bad_mining
	name = "Mining Phaser System"
	item_outputs = list(/obj/item/shipcomponent/mainweapon/bad_mining)
	create = 1
	time = 20 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/mainweapon/mining) //Move this to it's file later.
	mats = list("energy" = 10,
				"metal_superdense" = 10,
				"crystal_dense" = 20)
/datum/manufacture/pod/weapon/mining
	name = "Plasma Cutter System"
	item_outputs = list(/obj/item/shipcomponent/mainweapon/mining)
	create = 1
	time = 20 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/mainweapon/rockdrills) //Move this to it's file later.
	mats = list("energy" = 10,
				"metal_superdense" = 10,
				"crystal_dense" = 10)
/datum/manufacture/pod/weapon/mining/drill
	name = "Rock Drilling Rig"
	item_outputs = list(/obj/item/shipcomponent/mainweapon/rockdrills)
	create = 1
	time = 20 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/mainweapon/phaser) //Move this to it's file later.
	mats = list("metal_dense" = 15,
				"conductive" = 15,
				"crystal" = 15)
/datum/manufacture/pod/weapon/ltlaser
	name = "Mk.1.5 Light Phasers"
	item_outputs = list(/obj/item/shipcomponent/mainweapon/phaser)
	create = 1
	time = 20 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/mainweapon/phaser/burst_phaser) //Move this to it's file later.
	mats = list("metal_dense" = 15,
				"conductive" = 45,
				"crystal" = 45)
/datum/manufacture/pod/weapon/burst_ltlaser
	name = "Mk.1.5e Burst Phasers"
	item_outputs = list(/obj/item/shipcomponent/mainweapon/phaser/burst_phaser)
	create = 1
	time = 25 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/mainweapon/constructor) //Move this to it's file later.
	mats = list("metal_superdense" = 50,
				"claretine" = 20,
				"electrum" = 10)
/datum/manufacture/pod/weapon/efif1
	name = "EFIF-1 Construction System"
	item_outputs = list(/obj/item/shipcomponent/mainweapon/constructor)
	create = 1
	time = 60 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/secondary_system/lock) //Move this to it's file later.
	mats = list("crystal" = 5,
				"conductive" = 10)
/datum/manufacture/pod/lock
	name = "Pod Locking Mechanism"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/lock)
	create = 1
	time = 10 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/secondary_system/thrusters/lateral) //Move this to it's file later.
	mats = list("metal_dense" = 20,
				"conductive" = 10,
				"energy" = 20)
/datum/manufacture/pod/lateral_thrusters
	name = "Lateral Thrusters"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/thrusters/lateral)
	create = 1
	time = 12 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/secondary_system/thrusters/afterburner) //Move this to it's file later.
	mats = list("metal" = 10,
				"conductive" = 20,
				"energy" = 20)
/datum/manufacture/pod/afterburner
	name = "Afterburner"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/thrusters/afterburner)
	create = 1
	time = 12 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/secondary_system/shielding/light) //Move this to it's file later.
	mats = list("metal" = 5,
				"conductive" = 10,
				"energy_high" = 30)
/datum/manufacture/pod/light_shielding
	name = "Light Shielding System"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/shielding/light)
	create = 1
	time = 15 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/secondary_system/shielding/heavy) //Move this to it's file later.
	mats = list("metal" = 5,
				"crystal_dense" = 20,
				"conductive_high" = 10,
				"energy_extreme" = 30)
/datum/manufacture/pod/heavy_shielding
	name = "High Impact Shielding System"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/shielding/heavy)
	create = 1
	time = 25 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/secondary_system/auto_repair_kit) //Move this to it's file later.
	mats = list("metal_dense" = 20,
				"conductive" = 30,
				"energy" = 10)
/datum/manufacture/pod/auto_repair_kit
	name = "Automatic Repair System"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/auto_repair_kit)
	create = 1
	time = 10 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/secondary_system/weapons_loader) //Move this to it's file later.
	mats = list("metal_dense" = 10,
				"conductive" = 10)
/datum/manufacture/pod/weapons_loader
	name = "Weapons Loader"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/weapons_loader)
	create = 1
	time = 17 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/secondary_system/gunner_support) //Move this to it's file later.
	mats = list("metal_dense" = 10,
				"conductive" = 30)
/datum/manufacture/pod/gunner_support
	name = "Gunner Module"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/gunner_support)
	create = 1
	time = 17 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/mainweapon/syndicate_purge_system) //Move this to it's file later.
	mats = list("metal" = 8,
				"conductive" = 12,
				"crystal" = 16)
/datum/manufacture/pod/sps
	name = "Syndicate Purge System"
	item_outputs = list(/obj/item/shipcomponent/mainweapon/syndicate_purge_system)
	create = 1
	time = 90 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/shipcomponent/secondary_system/syndicate_rewind_system) //Move this to it's file later.
	mats = list("metal" = 16,
				"conductive" = 12,
				"crystal" = 8)
/datum/manufacture/pod/srs
	name = "Syndicate Rewind System"
	item_outputs = list(/obj/item/shipcomponent/secondary_system/syndicate_rewind_system)
	create = 1
	time = 90 SECONDS
	category = "Tool"
//// deployable warp beacon

TYPEINFO(/obj/beaconkit) //Move this to it's file later.
	mats = list("crystal" = 10,
				"conductive" = 10,
				"metal_dense" = 10)
/datum/manufacture/beaconkit
	name = "Warp Beacon Frame"
	item_outputs = list(/obj/beaconkit)
	item_names = list("Crystal","Conductive Material","Sturdy Metal")
	create = 1
	time = 30 SECONDS
	category = "Machinery"


/******************** HOP *******************/

TYPEINFO(/obj/item/card/id) //Move this to it's file later.
	mats = list("conductive" = 3,
				"crystal" = 3)
/datum/manufacture/id_card
	name = "ID card"
	item_outputs = list(/obj/item/card/id)
	create = 1
	time = 5 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/card/id/gold) //Move this to it's file later.
	mats = list("gold" = 5,
				"conductive_high" = 4,
				"crystal" = 3)
/datum/manufacture/id_card_gold
	name = "Gold ID card"
	item_outputs = list(/obj/item/card/id/gold)
	create = 1
	time = 30 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/implantcase/access) //Move this to it's file later.
	mats = list("conductive" = 3,
				"crystal" = 3)
/datum/manufacture/implant_access
	name = "Electronic Access Implant (8 Access Charges)"
	item_outputs = list(/obj/item/implantcase/access)
	create = 1
	time = 20 SECONDS
	category = "Resource"

TYPEINFO(/obj/machinery/computer/card/portable) //Move this to it's file later.
	mats = list("conductive" = 25,
				"crystal" = 15,
				"metal" = 35,
				"gold" = 2)
/datum/manufacture/acesscase
	name = "ID Briefcase"
	item_outputs = list(/obj/machinery/computer/card/portable)
	create = 1
	time = 75 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/implantcase/access/unlimited) //Move this to it's file later.
	mats = list("conductive" = 9,
				"crystal" = 15)
/datum/manufacture/implant_access_infinite
	name = "Electronic Access Implant (Unlimited Charge)"
	item_outputs = list(/obj/item/implantcase/access/unlimited)
	create = 1
	time = 60 SECONDS
	category = "Resource"

TYPEINFO(/obj/item/device/radio_upgrade/station) //Move this to it's file later.
	mats = list("conductive" = 9,
				"crystal" = 15)
ABSTRACT_TYPE(/datum/manufacture/radio_upgrade)
/datum/manufacture/radio_upgrade
	name = "Station Radio Upgrade (ABSTRACT-YOUSHOULDNTSEEME)"
	item_outputs = list(/obj/item/device/radio_upgrade/station/civilian)
	create = 1
	time = 20 SECONDS
	category = "Tool"

/datum/manufacture/radio_upgrade/command
	name = "Command Radio Upgrade"
	item_outputs = list(/obj/item/device/radio_upgrade/station/command)

/datum/manufacture/radio_upgrade/security
	name = "Security Radio Upgrade"
	item_outputs = list(/obj/item/device/radio_upgrade/station/security)

/datum/manufacture/radio_upgrade/engineering
	name = "Engineering Radio Upgrade"
	item_outputs = list(/obj/item/device/radio_upgrade/station/engineering)

/datum/manufacture/radio_upgrade/research
	name = "Research Radio Upgrade"
	item_outputs = list(/obj/item/device/radio_upgrade/station/research)

/datum/manufacture/radio_upgrade/medical
	name = "Medical Radio Upgrade"
	item_outputs = list(/obj/item/device/radio_upgrade/station/medical)

/datum/manufacture/radio_upgrade/civilian
	name = "Civilian Radio Upgrade"
	item_outputs = list(/obj/item/device/radio_upgrade/station/civilian)

/******************** QM CRATES *******************/

TYPEINFO(/obj/storage/crate) //Move this to it's file later.
	mats = list("metal" = 1)
/datum/manufacture/crate
	name = "Crate"
	item_outputs = list(/obj/storage/crate)
	create = 1
	time = 10 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/storage/crate/wooden) //Move this to it's file later.
	mats = list("wood" = 1)
/datum/manufacture/crate/wooden
	name = "Wooden Crate"
	item_outputs = list(/obj/storage/crate/wooden)

/datum/manufacture/crate/wooden/packing
	name = "Random Packing Crate"
	item_outputs = list(/obj/storage/crate/packing)

/datum/manufacture/crate/medical
	name = "Medical Crate"
	item_outputs = list(/obj/storage/crate/medical)

/datum/manufacture/crate/biohazard
	name = "Biohazard Crate"
	item_outputs = list(/obj/storage/crate/biohazard)

/datum/manufacture/crate/class
	name = "Class Crate"
	item_outputs = list(/obj/storage/crate/classcrate)

/datum/manufacture/crate/freezer
	name = "Freezer Crate"
	item_outputs = list(/obj/storage/crate/freezer)

TYPEINFO(/obj/storage/secure/crate) //Move this to it's file later.
	mats = list("metal" = 1, "conductive" = 2)
/datum/manufacture/crate/secure
	name = "Secure Crate (Access: None)"
	item_requirements = list("metal" = 1, "conductive" = 2)
	item_outputs = list(/obj/storage/secure/crate)

/datum/manufacture/crate/secure/secure_transfer
	name = "Security Transfer Crate"
	item_outputs = list(/obj/storage/secure/crate/gear/transfer)

/datum/manufacture/crate/secure/confiscated_items
	name = "Confiscated Items Crate"
	item_outputs = list(/obj/storage/secure/crate/weapon/confiscated_items)

/datum/manufacture/crate/secure/armory
	name = "Armory Weapons Crate (Empty)"
	item_outputs = list(/obj/storage/secure/crate/weapon/armory)

/datum/manufacture/crate/secure/hazard
	name = "Research Hazard Transport Crate"
	item_outputs = list(/obj/storage/secure/crate/plasma/hazard)

/datum/manufacture/crate/secure/engineering
	name = "Secure Engineering Crate"
	item_outputs = list(/obj/storage/secure/crate/eng/locked)

/datum/manufacture/crate/secure/medical
	name = "Medical Transport Crate"
	item_outputs = list(/obj/storage/secure/crate/medical)

/datum/manufacture/crate/secure/hydroponics
	name = "Hydroponics Transport Crate"
	item_outputs = list(/obj/storage/secure/crate/bee/locked)

/datum/manufacture/crate/secure/syndicate
	name = "Unmarked Syndicate Crate"
	item_outputs = list(/obj/storage/secure/crate/gear/syndicate)

/******************** GUNS *******************/

TYPEINFO(/obj/item/gun/energy/alastor) //Move this to it's file later.
	mats = list("dense" = 1,
				"metal_superdense" = 10,
				"conductive" = 20,
				"crystal" = 20)
/datum/manufacture/alastor
	name = "Alastor Pattern Laser Rifle"
	item_outputs = list(/obj/item/gun/energy/alastor)
	create = 1
	time = 30 SECONDS
	category = "Tool"

/************ INTERDICTOR STUFF ************/

TYPEINFO(/obj/item/interdictor_kit) //Move this to it's file later.
	mats = list("metal_dense" = 5)
/datum/manufacture/interdictor_kit
	name = "Interdictor Frame Kit"
	item_outputs = list(/obj/item/interdictor_kit)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

TYPEINFO(/obj/item/interdictor_board) //Move this to it's file later.
	mats = list("conductive" = 2)
/datum/manufacture/interdictor_board_standard
	name = "Standard Interdictor Mainboard"
	item_outputs = list(/obj/item/interdictor_board)
	create = 1
	time = 5 SECONDS
	category = "Machinery"

TYPEINFO(/obj/item/interdictor_board/nimbus) //Move this to it's file later.
	mats = list("conductive" = 2,
				"insulated" = 2,
				"crystal" = 2)
/datum/manufacture/interdictor_board_nimbus
	name = "Nimbus Interdictor Mainboard"
	item_outputs = list(/obj/item/interdictor_board/nimbus)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

TYPEINFO(/obj/item/interdictor_board/zephyr) //Move this to it's file later.
	mats = list("conductive" = 2,
				"viscerite" = 5)
/datum/manufacture/interdictor_board_zephyr
	name = "Zephyr Interdictor Mainboard"
	item_outputs = list(/obj/item/interdictor_board/zephyr)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

TYPEINFO(/obj/item/interdictor_board/devera) //Move this to it's file later.
	mats = list("conductive" = 2,
				"crystal" = 2,
				"syreline" = 5)
/datum/manufacture/interdictor_board_devera
	name = "Devera Interdictor Mainboard"
	item_outputs = list(/obj/item/interdictor_board/devera)
	create = 1
	time = 10 SECONDS
	category = "Machinery"

TYPEINFO(/obj/item/interdictor_rod) //Move this to it's file later.
	mats = list("metal_dense" = 2,
				"conductive" = 5,
				"crystal" = 2,
				"insulated" = 2)
/datum/manufacture/interdictor_rod_lambda
	name = "Lambda Phase-Control Rod"
	item_outputs = list(/obj/item/interdictor_rod)
	create = 1
	time = 12 SECONDS
	category = "Machinery"

TYPEINFO(/obj/item/interdictor_rod/sigma) //Move this to it's file later.
	mats = list("metal_dense" = 2,
				"conductive_high" = 5,
				"insulated" = 2,
				"energy" = 2)
/datum/manufacture/interdictor_rod_sigma
	name = "Sigma Phase-Control Rod"
	item_outputs = list(/obj/item/interdictor_rod/sigma)
	create = 1
	time = 15 SECONDS
	category = "Machinery"

TYPEINFO(/obj/item/interdictor_rod/epsilon) //Move this to it's file later.
	mats = list("metal_dense" = 2,
				"electrum" = 5,
				"dense" = 2,
				"energy" = 2)
/datum/manufacture/interdictor_rod_epsilon
	name = "Epsilon Phase-Control Rod"
	item_outputs = list(/obj/item/interdictor_rod/epsilon)
	create = 1
	time = 20 SECONDS
	category = "Machinery"

TYPEINFO(/obj/item/interdictor_rod/phi) //Move this to it's file later.
	mats = list("metal_dense" = 5,
				"conductive" = 5,
				"crystal" = 2)
/datum/manufacture/interdictor_rod_phi
	name = "Phi Phase-Control Rod"
	item_outputs = list(/obj/item/interdictor_rod/phi)
	create = 1
	time = 15 SECONDS
	category = "Machinery"


/************ NADIR RESONATORS ************/

TYPEINFO(/obj/machinery/siphon/resonator) //Move this to it's file later.
	mats = list("metal_dense" = 15,
				"conductive_high" = 20,
				"crystal" = 20,
				"energy" = 5)
/datum/manufacture/resonator_type_ax
	name = "Type-AX Resonator"
	item_outputs = list(/obj/machinery/siphon/resonator)
	create = 1
	time = 30 SECONDS
	category = "Machinery"

TYPEINFO(/obj/machinery/siphon/resonator/stabilizer) //Move this to it's file later.
	mats = list("metal_dense" = 10,
				"conductive_high" = 20,
				"crystal" = 10,
				"insulated" = 10)
/datum/manufacture/resonator_type_sm
	name = "Type-SM Resonator"
	item_outputs = list(/obj/machinery/siphon/resonator/stabilizer)
	create = 1
	time = 30 SECONDS
	category = "Machinery"

/************ NADIR GEAR ************/

TYPEINFO(/obj/item/device/nanoloom) //Move this to it's file later.
	mats = list("metal_dense" = 4,
				"conductive" = 2,
				"cobryl" = 1,
				"fabric" = 3)
/datum/manufacture/nanoloom
	name = "Nanoloom"
	item_outputs = list(/obj/item/device/nanoloom)
	create = 1
	time = 15 SECONDS
	category = "Tool"

TYPEINFO(/obj/item/nanoloom_cartridge) //Move this to it's file later.
	mats = list("metal_dense" = 1,
				"cobryl" = 1,
				"fabric" = 3)
/datum/manufacture/nanoloom_cart
	name = "Nanoloom Cartridge"
	item_outputs = list(/obj/item/nanoloom_cartridge)
	create = 1
	time = 8 SECONDS
	category = "Tool"

//////////////////////UBER-EXTREME SURVIVAL////////////////////////////////
TYPEINFO(/obj/item/clothing/suit/armor/vest) //Move this to it's file later.
	mats = list("metal_superdense" = 5)
/datum/manufacture/armor_vest	//
	name = "Armor Vest"
	item_outputs = list(/obj/item/clothing/suit/armor/vest)
	create = 1
	time = 30 SECONDS
	category = "Weapon"

TYPEINFO(/obj/item/gun/kinetic/single_action/colt_saa) //Move this to it's file later.
	mats = list("metal_dense" = 7)
/datum/manufacture/saa	//
	name = "Colt SAA"
	item_outputs = list(/obj/item/gun/kinetic/single_action/colt_saa)
	create = 1
	time = 30 SECONDS
	category = "Weapon"

TYPEINFO(/obj/item/ammo/bullets/c_45) //Move this to it's file later.
	mats = list("metal" = 1)
/datum/manufacture/saa_ammo	//
	name = "Colt Ammo"
	item_outputs = list(/obj/item/ammo/bullets/c_45)
	create = 1
	time = 7 SECONDS
	category = "ammo"

TYPEINFO(/obj/item/gun/kinetic/clock_188) //Move this to it's file later.
	mats =  list("metal" = 10)
/datum/manufacture/clock	//
	name = "Clock 188"
	item_outputs = list(/obj/item/gun/kinetic/clock_188)
	create = 1
	time = 10 SECONDS
	category = "Weapon"

TYPEINFO(/obj/item/ammo/bullets/nine_mm_NATO) //Move this to it's file later.
	mats = list("metal" = 3)
/datum/manufacture/clock_ammo	//
	name = "Clock ammo"
	item_outputs = list(/obj/item/ammo/bullets/nine_mm_NATO)
	create = 1
	time = 7 SECONDS
	category = "ammo"

TYPEINFO(/obj/item/gun/kinetic/pumpweapon/riotgun) //Move this to it's file later.
	mats = list("metal" = 20)
/datum/manufacture/riot_shotgun	//
	name = "Riot Shotgun"
	item_outputs = list(/obj/item/gun/kinetic/pumpweapon/riotgun)
	create = 1
	time = 20 SECONDS
	category = "Weapon"

TYPEINFO(/obj/item/ammo/bullets/abg) //Move this to it's file later.
	mats = list("metal" = 10)
/datum/manufacture/riot_shotgun_ammo	//
	name = "Rubber Bullet ammo"
	item_outputs = list(/obj/item/ammo/bullets/abg)
	create = 1
	time = 7 SECONDS
	category = "ammo"

TYPEINFO(/obj/item/gun/kinetic/riot40mm) //Move this to it's file later.
	mats = list("metal" = 12)
/datum/manufacture/riot_launcher	//
	name = "Riot Launcher"
	item_outputs = list(/obj/item/gun/kinetic/riot40mm)
	create = 1
	time = 10 SECONDS
	category = "Weapon"

TYPEINFO(/obj/item/ammo/bullets/pbr) //Move this to it's file later.
	mats = list("metal" = 2,
				"conductive" = 4,
				"crystal" = 1)
/datum/manufacture/riot_launcher_ammo_pbr	//
	name = "Launcher PBR Ammo"
	item_outputs = list(/obj/item/ammo/bullets/pbr)
	create = 1
	time = 10 SECONDS
	category = "ammo"

TYPEINFO(/obj/item/storage/box/flashbang_kit) //Move this to it's file later.
	mats = list("metal" = 2,
				"conductive" = 3)
/datum/manufacture/riot_launcher_ammo_flashbang	//
	name = "Launcher Flashbang Box"
	item_outputs = list(/obj/item/storage/box/flashbang_kit)
	create = 1
	time = 10 SECONDS
	category = "ammo"

TYPEINFO(/obj/item/storage/box/tactical_kit) //Move this to it's file later.
	mats = list("metal_dense" = 5,
				"conductive" = 5,
				"crystal" = 3)
/datum/manufacture/riot_launcher_ammo_tactical	//
	name = "Launcher Tactical Box"
	item_outputs = list(/obj/item/storage/box/tactical_kit)
	create = 1
	time = 10 SECONDS
	category = "ammo"

TYPEINFO(/obj/item/gun/kinetic/sniper) //Move this to it's file later.
	mats = list("dense" = 2,
				"metal_superdense" = 15,
				"conductive" = 4,
				"crystal" = 3)
/datum/manufacture/sniper	//
	name = "Sniper"
	item_outputs = list(/obj/item/gun/kinetic/sniper)
	create = 1
	time = 25 SECONDS
	category = "Weapon"

TYPEINFO(/obj/item/ammo/bullets/rifle_762_NATO) //Move this to it's file later.
	mats = list("metal_superdense" = 6)
/datum/manufacture/sniper_ammo	//
	name = "Sniper Ammo"
	item_outputs = list(/obj/item/ammo/bullets/rifle_762_NATO)
	create = 1
	time = 10 SECONDS
	category = "ammo"

TYPEINFO(/obj/item/gun/kinetic/tactical_shotgun) //Move this to it's file later.
	mats = list("metal_superdense" = 15,
				"conductive" = 5)
/datum/manufacture/tac_shotgun	//
	name = "Tactical Shotgun"
	item_outputs = list(/obj/item/gun/kinetic/tactical_shotgun)
	create = 1
	time = 20 SECONDS
	category = "Weapon"

TYPEINFO(/obj/item/ammo/bullets/buckshot_burst) //Move this to it's file later.
	mats = list("metal_superdense" = 5)
/datum/manufacture/tac_shotgun_ammo	//
	name = "Tactical Shotgun Ammo"
	item_outputs = list(/obj/item/ammo/bullets/buckshot_burst)
	create = 1
	time = 7 SECONDS
	category = "ammo"

TYPEINFO(/obj/item/gun/kinetic/gyrojet) //Move this to it's file later.
	mats = list("dense" = 5,
				"metal_superdense" = 10,
				"conductive_high" = 6)
/datum/manufacture/gyrojet	//
	name = "Gyrojet"
	item_outputs = list(/obj/item/gun/kinetic/gyrojet)
	create = 1
	time = 30 SECONDS
	category = "Weapon"

TYPEINFO(/obj/item/ammo/bullets/gyrojet) //Move this to it's file later.
	mats = list("metal_superdense" = 5,
				"conductive_high" = 2)
/datum/manufacture/gyrojet_ammo	//
	name = "Gyrojet Ammo"
	item_outputs = list(/obj/item/ammo/bullets/gyrojet)
	create = 1
	time = 7 SECONDS
	category = "Ammo"

TYPEINFO(/obj/item/sheet/wood/zwood) //Move this to it's file later.
	mats = list("wood" = 1)
/datum/manufacture/plank	//
	name = "Barricade Planks"
	item_outputs = list(/obj/item/sheet/wood/zwood)
	create = 1
	time = 1 SECOND
	category = "Medicine"

TYPEINFO(/obj/item/storage/firstaid/brute) //Move this to it's file later.
	mats = list("metal" = 2,
				"conductive" = 2)
/datum/manufacture/brute_kit	//
	name = "Brute Kit"
	item_outputs = list(/obj/item/storage/firstaid/brute)
	create = 1
	time = 10 SECONDS
	category = "Medicine"

TYPEINFO(/obj/item/storage/firstaid/fire) //Move this to it's file later.
	mats = list("metal" = 2,
				"conductive" = 2)
/datum/manufacture/burn_kit	//
	name = "Burn Kit"
	item_outputs = list(/obj/item/storage/firstaid/fire)
	create = 1
	time = 10 SECONDS
	category = "Medicine"

TYPEINFO(/obj/item/storage/firstaid/crit) //Move this to it's file later.
	mats = list("metal" = 2,
				"conductive" = 2)
/datum/manufacture/crit_kit //
	name = "Crit Kit"
	item_outputs = list(/obj/item/storage/firstaid/crit)
	create = 1
	time = 9 SECONDS
	category = "Medicine"

TYPEINFO(/obj/item/storage/firstaid/regular/empty) //Move this to it's file later.
	mats = list("metal" = 1)
/datum/manufacture/empty_kit
	name = "Empty First Aid Kit"
	item_outputs = list(/obj/item/storage/firstaid/regular/empty)
	create = 1
	time = 4 SECONDS
	category = "Medicine"

TYPEINFO(/obj/item/reagent_containers/syringe/antiviral) //Move this to it's file later.
	mats = list("metal" = 3,
				"conductive" = 3)
/datum/manufacture/spacecillin	//
	name = "Spacecillin"
	item_outputs = list(/obj/item/reagent_containers/syringe/antiviral)
	create = 1
	time = 10 SECONDS
	category = "Medicine"

TYPEINFO(/obj/item/bat) //Move this to it's file later.
	mats = list("metal_dense" = 15)
/datum/manufacture/bat	//
	name = "Baseball Bat"
	item_outputs = list(/obj/item/bat)
	create = 1
	time = 20 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/item/quarterstaff) //Move this to it's file later.
	mats = list("metal_dense" = 10)
/datum/manufacture/quarterstaff	//
	name = "Quarterstaff"
	item_outputs = list(/obj/item/quarterstaff)
	create = 1
	time = 10 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/item/kitchen/utensil/knife/cleaver) //Move this to it's file later.
	mats = list("metal" = 20)
/datum/manufacture/cleaver	//
	name = "Cleaver"
	item_outputs = list(/obj/item/kitchen/utensil/knife/cleaver)
	create = 1
	time = 16 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/item/sword/discount) //Move this to it's file later.
	mats = list("metal_dense" = 20,
				"conductive" = 10)
/datum/manufacture/dsaber	//
	name = "D-Saber"
	item_outputs = list(/obj/item/sword/discount)
	create = 1
	time = 20 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/item/fireaxe) //Move this to it's file later.
	mats = list("metal_superdense" = 20,
				"conductive_high" = 5)
/datum/manufacture/fireaxe	//
	name = "Fireaxe"
	item_outputs = list(/obj/item/fireaxe)
	create = 1
	time = 20 SECONDS
	category = "Miscellaneous"

TYPEINFO(/obj/item/shovel) //Move this to it's file later.
	mats = list("metal_superdense" = 25,
				"conductive_high" = 5)
/datum/manufacture/shovel	//
	name = "Shovel"
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

TYPEINFO(/obj/item/clothing/suit/hazard/fire/heavy) //Move this to it's file later.
	mats = list(
		"fabric" = 20,
		"fibrilith" = 10,
	)
/datum/manufacture/heavy_firesuit
	name = "Heavy Firesuit"
	create = 1
	item_outputs = list(/obj/item/clothing/suit/hazard/fire/heavy)
	category = "Clothing"

/datum/manufacture/magnetic_shoes
	name = "Magnetic Shoes"
	create = 1
	item_outputs = list(/obj/item/clothing/shoes/magnetic)
	time = 6 SECONDS
	category = "Clothing"

TYPEINFO(/obj/turbine_shaft) //Move this to it's file later.
	mats = list("metal_dense" = 20)
/datum/manufacture/turbine_shaft
	name = "Turbine Shaft"
	create = 1
	item_outputs = list(/obj/turbine_shaft)
	time = 30 SECONDS
	category = "Machinery"

TYPEINFO(/obj/turbine_shaft/turbine) //Move this to it's file later.
	mats = list("metal_dense" = 50, "conductive" = 20)
/datum/manufacture/current_turbine
	name = "Current Turbine"
	create = 1
	item_outputs = list(/obj/turbine_shaft/turbine)
	time = 50 SECONDS
	category = "Machinery"

#undef JUMPSUIT_COST
