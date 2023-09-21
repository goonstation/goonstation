/obj/artifact/darkness_field
	name = "artifact darkness field"
	associated_datum = /datum/artifact/darkness_field

/datum/artifact/darkness_field
	associated_object = /obj/artifact/darkness_field
	type_name = "Darkness Generator"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	max_triggers = 3
	validtypes = list("wizard","eldritch","precursor")
	react_xray = list(15,90,90,11,"NONE")
	var/field_radius = 0
	var/field_time = 0
	var/max_alpha = 255
	var/list/obj/overlay/darkness_field/darkfields = list()

	New()
		..()
		field_radius = rand(5, 30)
		if (prob(1))
			field_radius *= 2
		field_time = rand(100,600)
		max_alpha = rand(200, 255)

	effect_activate(var/obj/O)
		if (..())
			return
		O.visible_message("<span class='alert'><b>[O]</b> emits a wave of absolute darkness!</span>")
		O.anchored = ANCHORED
		var/turf/T = get_turf(O)
		darkfields += new /obj/overlay/darkness_field(T, null, radius = 0.5 + field_radius, max_alpha = max_alpha)
		darkfields += new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, null, radius = 0.5 + field_radius, max_alpha = max_alpha)
		SPAWN(field_time)
			if (O)
				O.ArtifactDeactivated()

	effect_deactivate(obj/O)
		if(..())
			return
		O.anchored = UNANCHORED
		for(var/obj/overlay/darkness_field/D as anything in darkfields)
			D.deactivate()

/obj/overlay/darkness_field
	icon = 'icons/effects/vision.dmi' // sorry
	icon_state = "nightvision"
	pixel_x = -(480 - 32) / 2 // centering
	pixel_y = -(480 - 32) / 2 // centering
	blend_mode = BLEND_SUBTRACT
	event_handler_flags = IMMUNE_SINGULARITY
	appearance_flags = LONG_GLIDE // PIXEL_SCALE omitted intentionally
	layer = LIGHTING_LAYER_DARKNESS_EFFECTS
	plane = PLANE_LIGHTING
	anchored = ANCHORED_ALWAYS

	New(var/loc, var/duration=null, var/radius=7.5, var/max_alpha=255)
		..()
		var/matrix/tr = matrix()
		tr.Scale(radius / 7)
		src.transform = tr
		src.alpha = 0
		animate(src, time = 2 SECONDS, alpha = max_alpha, easing = LINEAR_EASING)
		if(!isnull(duration))
			SPAWN(duration)
				src.deactivate()

	proc/deactivate()
		animate(src, time = 2 SECONDS, alpha = 0, easing = LINEAR_EASING)
		SPAWN(2 SECONDS)
			qdel(src)
