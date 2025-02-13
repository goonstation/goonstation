/obj/artifact/lamp
	name = "artifact lamp"
	associated_datum = /datum/artifact/lamp
	var/light_brightness = 1
	var/light_r = 1
	var/light_g = 1
	var/light_b = 1
	var/datum/light/light
	var/obj/effect/bonus_light
	// valid color matrices for the "inverted lamp" effect. Works best if it's a dramatic change, otherwise it just looks kinda mid.
	var/static/list/possible_color_matrices = list(
		COLOR_MATRIX_GRAYSCALE,
		COLOR_MATRIX_FLOCKMANGLED,
		COLOR_MATRIX_INVERSE)

	New()
		..()
		light_brightness = max(0.5, (rand(5, 20) / 10))
		light_r = rand(25,100) / 100
		light_g = rand(25,100) / 100
		light_b = rand(25,100) / 100
		light = new /datum/light/point
		light.set_brightness(light_brightness)
		light.set_color(light_r, light_g, light_b)
		light.attach(src)
		if(prob(100)) //chance this is an inverting lamp
			var/color = pick(possible_color_matrices)
			bonus_light = new /obj/effect/whackylight(src, light.radius, color)
			src.vis_flags |= VIS_HIDE

	disposing()
		. = ..()
		QDEL_NULL(bonus_light) //because it exists on the map, it won't get cleaned up automatically

/datum/artifact/lamp
	associated_object = /obj/artifact/lamp
	type_name = "Lamp"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 450
	validtypes = list("martian","wizard","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,
	/datum/artifact_trigger/cold, /datum/artifact_trigger/language)
	activ_text = "begins to emit a steady light!"
	deact_text = "goes dark and quiet."
	react_xray = list(10,90,90,11,"NONE")
	var/sound/switch_sound = null

	post_setup()
		..()
		src.switch_sound = pick(src.artitype.lightswitch_sounds)

	effect_activate(var/obj/O)
		if (..())
			return
		src.light_on(O)

	effect_deactivate(var/obj/O)
		if (..())
			return
		src.light_off(O)

	proc/light_on(obj/artifact/lamp/L)
		playsound(L, src.switch_sound, 40, TRUE, -10)
		if (L.light)
			L.light.enable()
		var/obj/effect/whackylight/bonus = L.bonus_light
		if(bonus)
			L.vis_contents += bonus
			bonus.active = TRUE
			bonus.update_whacky(L)
		L.anchored = TRUE

	proc/light_off(obj/artifact/lamp/L)
		playsound(L, src.switch_sound, 40, TRUE, -10)
		if (L.light)
			L.light.disable()
		var/obj/effect/whackylight/bonus = L.bonus_light
		if(bonus)
			L.vis_contents -= bonus
			bonus.active = FALSE
			bonus.update_whacky(L)
		L.anchored = FALSE

	effect_touch(obj/artifact/lamp/L, mob/living/user)
		if(..())
			return
		if (!src.activated)
			return
		if (L.light.enabled)
			src.light_off(L)
		else
			src.light_on(L)

/obj/effect/whackylight

	var/radius
	var/active = FALSE
	anchored = TRUE //not really, but we do our own moving thank you very much

	New(loc, radius=2, color=null)
		.=..(get_turf(loc))
		src.radius = radius
		if(isnull(color))
			src.color = COLOR_MATRIX_INVERSE
		else
			src.color = color
		src.appearance_flags |= RESET_TRANSFORM
		update_whacky(loc, null, 0)

	proc/update_whacky(var/atom/movable/thing)
		src.loc = get_turf(thing)
		if(active)
			for(var/turf/T in src.vis_contents)
				if(!IN_EUCLIDEAN_RANGE(src.loc, T, src.radius))
					src.vis_contents -= T
			for(var/turf/T in range(src.loc, src.radius))
				if(IN_EUCLIDEAN_RANGE(src.loc, T, src.radius))
					src.vis_contents += T
					src.pixel_x = min(-world.icon_size*(T.x - src.loc.x), src.pixel_x)
					src.pixel_y = min(-world.icon_size*(T.y - src.loc.y), src.pixel_y)
		else
			src.vis_contents.Cut()
