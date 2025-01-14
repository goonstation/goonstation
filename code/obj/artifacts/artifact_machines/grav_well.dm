/obj/machinery/artifact/gravity_well_generator
	name = "artifact gravity well generator"
	associated_datum = /datum/artifact/gravity_well_generator

	New()
		..()
		START_TRACKING_CAT(TR_CAT_SINGULO_MAGNETS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_SINGULO_MAGNETS)
		. = ..()

/obj/effect/grav_pulse
	icon='icons/effects/overlays/lensing.dmi'
	icon_state="blank" //haha such hackery
	pixel_x = -224
	pixel_y = -224
	plane = PLANE_DISTORTION
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA

	proc/pulse()
		flick("pulse",src)

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
	var/obj/effect/grav_pulse/lense
	shard_reward = ARTIFACT_SHARD_SPACETIME
	combine_flags = ARTIFACT_COMBINES_INTO_ANY | ARTIFACT_ACCEPTS_ANY_COMBINE

	New()
		..()
		src.field_radius = rand(4,9) // well radius
		src.gravity_type = rand(0,1) // 0 for pull, 1 for push
		lense = new()

	disposing()
		qdel(lense)
		lense = null
		..()

	effect_activate(obj/O)
		. = ..()
		O.vis_contents += lense

	effect_deactivate(obj/O)
		. = ..()
		O.vis_contents -= lense

	effect_process(var/obj/O)
		if (..())
			return

		lense.pulse()

		for(var/turf/T in orange(src.field_radius,get_turf(O)))
			var/fuckcrap_limit = 0
			for (var/obj/V in T)
				if(fuckcrap_limit++ > 30)
					break
				if (V.anchored)
					continue
				if (src.gravity_type)
					step_away(V,O)
				else
					step_towards(V,O)
			fuckcrap_limit = min(fuckcrap_limit, 25)
			for (var/mob/living/M in T)
				if(fuckcrap_limit++ > 30)
					break
				if(isintangible(M))
					continue
				if (src.gravity_type)
					step_away(M,O)
				else
					step_towards(M,O)
				if(O.ArtifactFaultUsed(M) == FAULT_RESULT_STOP)
					break

