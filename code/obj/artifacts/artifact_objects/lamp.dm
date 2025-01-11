/obj/artifact/lamp
	name = "artifact lamp"
	associated_datum = /datum/artifact/lamp
	var/light_brightness = 1
	var/light_r = 1
	var/light_g = 1
	var/light_b = 1
	var/datum/light/light

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

/datum/artifact/lamp
	associated_object = /obj/artifact/lamp
	type_name = "Lamp"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 450
	validtypes = list("martian","wizard","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch,
	/datum/artifact_trigger/cold, /datum/artifact_trigger/language)
	combine_flags = ARTIFACT_ACCEPTS_ANY_COMBINE | ARTIFACT_COMBINES_INTO_ANY
	activ_text = "begins to emit a steady light!"
	deact_text = "goes dark and quiet."
	react_xray = list(10,90,90,11,"NONE")

	effect_activate(var/obj/O)
		if (..())
			return
		var/obj/artifact/lamp/L = O
		if (L.light)
			L.light.enable()

	effect_deactivate(var/obj/O)
		if (..())
			return
		var/obj/artifact/lamp/L = O
		if (L.light)
			L.light.disable()
