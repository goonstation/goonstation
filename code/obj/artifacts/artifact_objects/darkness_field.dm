/obj/artifact/darkness_field
	name = "artifact darkness field"
	associated_datum = /datum/artifact/darkness_field

/datum/artifact/darkness_field
	associated_object = /obj/artifact/darkness_field
	rarity_class = 2
	max_triggers = 3
	validtypes = list("wizard","eldritch","precursor")
	react_xray = list(15,90,90,11,"NONE")
	var/field_radius = 0
	var/field_time = 0

	New()
		..()
		field_radius = rand(2,8)
		if (prob(1))
			field_radius *= 2
		field_time = rand(300,1800)

	effect_activate(var/obj/O)
		if (..())
			return
		O.visible_message("<span class='alert'><b>[O]</b> emits a wave of absolute darkness!</span>")
		O.anchored = 1
		for(var/turf/T in circular_range(O,field_radius))
			new /obj/darkness_field(T,field_time)
		SPAWN_DBG(field_time)
			if (O)
				O.anchored = 0
				O.ArtifactDeactivated()
		return

/obj/darkness_field
	name = ""
	desc = ""
	alpha = 0
	icon = 'icons/turf/walls.dmi'
	color = "#000000"
	blend_mode = 1
	anchored = 1
	density = 0
	opacity = 0
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	mouse_opacity = 0

	New(var/loc,var/duration)
		..()
		animate(src, time = 20, alpha = 255, easing = LINEAR_EASING)
		SPAWN_DBG(duration)
			animate(src, time = 20, alpha = 0, easing = LINEAR_EASING)
			SPAWN_DBG(0)
				qdel(src)
