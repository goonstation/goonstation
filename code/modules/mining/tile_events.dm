/datum/ore/event
	var/analysis_string = "Caution! Anomaly detected!"
	var/excavation_string = null
	var/distribution_range = 2
	var/nearby_tile_distribution_min = 0
	var/nearby_tile_distribution_max = 0
	var/scan_decal = null
	var/prevent_excavation = 0
	var/restrict_to_turf_type = null
	var/weight = 100

	set_up(var/datum/ore/event/parent_event)
		..()
		if (parent_event)
			if (!istype(parent_event, /datum/ore/))
				return 1
		return 0

/datum/ore/event/gem
	analysis_string = "Small extraneous mineral deposit detected."
	excavation_string = "Something shiny tumbles out of the collapsing rock!"
	scan_decal = "scan-gem"
	var/gem_type = /obj/item/raw_material/gemstone

	set_up(var/datum/ore/parent)
		if (..() || !parent)
			return 1
		if (length(parent.gems) < 1)
			return 1
		gem_type = pick(parent.gems)

	onExcavate(var/turf/simulated/wall/auto/asteroid/AST)
		if (..())
			return
		var/obj/item/I = new gem_type
		I.set_loc(AST)

/datum/ore/event/rare_metal
	analysis_string = "Unusual metal deposit detected."
	excavation_string = "Something metallic tumbles out of the collapsing rock!"
	scan_decal = "scan-rare_metal"
	var/static/list/metals_to_pick = list(/obj/critter/gunbot/drone/buzzdrone/naniteswarm/rare_metal/iridium = 100,

										  /obj/critter/gunbot/drone/buzzdrone/naniteswarm/rare_metal/plutonium = 50,
										  /obj/item/material_piece/uranium = 25
										 )

	onExcavate(turf/simulated/wall/auto/asteroid/AST)
		if (..())
			return
		var/metal_to_drop = weighted_pick(src.metals_to_pick)
		for (var/i in 1 to rand(1, 3))
			new metal_to_drop(AST)

/datum/ore/event/geode
	analysis_string = "Large crystalline formations detected."
	excavation_string = "A geode was unearthed!"
	scan_decal = "scan-object"
	weight = 200 //let's make these pretty common for now
	///weighted lists of geode types to pick from
	var/static/list/fluid_geode_types = list()
	var/static/list/crystal_geode_types = list()

	onExcavate(turf/simulated/wall/auto/asteroid/AST)
		if (..())
			return
		//horrible weighted caching zone
		if (!length(src.fluid_geode_types))
			for (var/obj/geode/type as anything in concrete_typesof(/obj/geode/fluid))
				src.fluid_geode_types[type] = initial(type.weight)
		if (!length(src.crystal_geode_types))
			for (var/obj/geode/type as anything in concrete_typesof(/obj/geode/crystal))
				src.crystal_geode_types[type] = initial(type.weight)

		var/geode_type = null
		if (prob(30)) //make fluid geodes always a bit rarer since they're more niche
			if (prob(50)) //hardcoded oil chance so the weight stays high as more fluid geodes are added
				geode_type = /obj/geode/fluid/oil
			else
				geode_type = weighted_pick(src.fluid_geode_types)
		else
			geode_type = weighted_pick(src.crystal_geode_types)
		new geode_type(AST)

/datum/ore/event/gem/molitz_b
	analysis_string = "Small unusual crystalline deposit detected."
	excavation_string = "Something unusual tumbles out of the collapsing rock!"

	set_up(var/datum/ore/parent)
		if (..())
			return
		gem_type = /obj/item/raw_material/molitz_beta

	onExcavate(var/turf/simulated/wall/auto/asteroid/AST)
		var/quantity = rand(2,3)
		for(var/i in 1 to quantity)
			..()


/datum/ore/event/rock_worm
	analysis_string = "Caution! Life signs detected!"
	excavation_string = "A rock worm jumps out of the collapsing rock!"
	scan_decal = "scan-object"
	restrict_to_turf_type = /turf/simulated/wall/auto/asteroid

	onExcavate(var/turf/simulated/wall/auto/asteroid/AST)
		if (..())
			return
		new /mob/living/critter/rockworm(AST)

/datum/ore/event/loot_crate
	analysis_string = "Caution! Large object embedded in rock!"
	excavation_string = "An abandoned crate was unearthed!"
	scan_decal = "scan-object"
	weight = 10

	onExcavate(var/turf/simulated/wall/auto/asteroid/AST)
		if (..())
			return
		new /obj/storage/crate/loot(AST)

/datum/ore/event/artifact
	analysis_string = "Caution! Large object embedded in rock!"
	excavation_string = "An artifact was unearthed!"
	scan_decal = "scan-object"

	onExcavate(var/turf/simulated/wall/auto/asteroid/AST)
		if (..())
			return
		Artifact_Spawn(AST)

/datum/ore/event/soft_rock
	analysis_string = "Caution! Weak rock formation detected!"
	hardness_mod = -1
	distribution_range = 4
	nearby_tile_distribution_min = 4
	nearby_tile_distribution_max = 12
	scan_decal = "scan-soft"

	onGenerate(var/turf/simulated/wall/auto/asteroid/AST)
		if (..())
			return
		AST.hardness += hardness_mod

/datum/ore/event/hard_rock
	analysis_string = "Caution! Dense rock formation detected!"
	hardness_mod = 1
	distribution_range = 4
	nearby_tile_distribution_min = 4
	nearby_tile_distribution_max = 12
	scan_decal = "scan-hard"

	onGenerate(var/turf/simulated/wall/auto/asteroid/AST)
		if (..())
			return
		AST.hardness += hardness_mod
		AST.amount += rand(1,3)

/datum/ore/event/volatile
	analysis_string = "Caution! Volatile compounds detected!"
	scan_decal = "scan-danger"
	prevent_excavation = 1
	restrict_to_turf_type = /turf/simulated/wall/auto/asteroid
	var/image/warning_overlay = null

	New()
		..()
		warning_overlay = image('icons/turf/walls/asteroid.dmi', "unstable")

	onHit(var/turf/simulated/wall/auto/asteroid/AST)
		if (..())
			return
		AST.overlays += warning_overlay
		var/timer = rand(3,6) * 10
		SPAWN(timer)
			if (istype(AST)) //Wire note: Fix for Undefined variable /turf/simulated/floor/plating/airless/asteroid/var/invincible
				AST.invincible = 0
				explosion(AST, AST, 1, 2, 3, 4)

/datum/ore/event/radioactive
	analysis_string = "Caution! Radioactive mineral deposits detected!"
	nearby_tile_distribution_min = 4
	nearby_tile_distribution_max = 8
	scan_decal = "scan-danger"
	restrict_to_turf_type = /turf/simulated/wall/auto/asteroid

	onHit(var/turf/simulated/wall/auto/asteroid/AST)
		if (..())
			return
		for (var/mob/living/L in range(1,AST))
			L.take_radiation_dose(0.05 SIEVERTS)

	onExcavate(var/turf/simulated/wall/auto/asteroid/AST)
		if (..())
			return
		for (var/mob/living/L in range(1,AST))
			L.take_radiation_dose(0.1 SIEVERTS)
