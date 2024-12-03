/obj/artifact/temporal_sphere
	name = "artifact temporal sphere"
	associated_datum = /datum/artifact/temporal_sphere

/datum/artifact/temporal_sphere
	associated_object = /obj/artifact/temporal_sphere
	type_name = "Temporal Sphere"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	validtriggers = list(/datum/artifact_trigger/carbon_touch)
	validtypes = list("wizard", "clockwork")
	react_xray = list(15,90,90,11,"NONE")
	var/field_time = 0
	var/scale_mod = 0
	var/sphere_type = null
	var/obj/effect/status_area/slow_globe/sphere

	New()
		..()
		src.field_time = rand(100,600)
		src.scale_mod = rand(1, 2)

	effect_activate(var/obj/O)
		if (..())
			return
		O.visible_message(SPAN_ALERT("<b>[O]</b> emits an aura of temporal energy!"))
		O.anchored = ANCHORED
		var/turf/T = get_turf(O)
		if (!src.sphere_type)
			switch (rand(1,4))
				if(1)
					src.sphere_type = /obj/effect/status_area/slow_globe
				if(2)
					src.sphere_type = /obj/effect/status_area/slow_globe/strong
				if(3)
					src.sphere_type = /obj/effect/status_area/slow_globe/reversed
				if(4)
					src.sphere_type = /obj/effect/status_area/slow_globe/reversed_strong

		src.sphere = new src.sphere_type(T, O, src.scale_mod)

		SPAWN(src.field_time)
			if (O)
				O.ArtifactDeactivated()

	effect_deactivate(obj/O)
		if(..())
			return
		O.anchored = UNANCHORED
		qdel(src.sphere)
