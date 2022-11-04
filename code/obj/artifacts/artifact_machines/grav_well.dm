/obj/machinery/artifact/gravity_well_generator
	name = "artifact gravity well generator"
	associated_datum = /datum/artifact/gravity_well_generator

/datum/artifact/gravity_well_generator
	associated_object = /obj/machinery/artifact/gravity_well_generator
	type_name = "Gravity Well"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 450
	validtypes = list("wizard","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS, TOUCH_ONLY_FAULTS)
	activated = 0
	activ_text = "activates and begins to warp gravity around it!"
	deact_text = "shuts down, returning gravity to normal!"
	activ_sound = 'sound/effects/mag_warp.ogg'
	deact_sound = 'sound/effects/singsuck.ogg'
	react_xray = list(20,80,99,0,"ULTRADENSE")
	touch_descriptors = list("You seem to have a little difficulty taking your hand off its surface.")
	var/field_radius = 7
	var/gravity_type = 0 // push or pull?
	examine_hint = "It is covered in very conspicuous markings."

	New()
		..()
		src.field_radius = rand(4,9) // well radius
		src.gravity_type = rand(0,1) // 0 for pull, 1 for push

	effect_process(var/obj/O)
		if (..())
			return
		for (var/obj/V in orange(src.field_radius,get_turf(O)))
			if (V.anchored)
				continue

			if (src.gravity_type)
				step_away(V,O)
			else
				step_towards(V,O)
		for (var/mob/living/M in orange(src.field_radius,get_turf(O)))
			if (src.gravity_type)
				step_away(M,O)
			else
				step_towards(M,O)
			if(O.ArtifactFaultUsed(M) == FAULT_RESULT_STOP)
				break

