/obj/machinery/artifact/bio_damage_field_generator
	name = "artifact bio damage field generator"
	associated_datum = /datum/artifact/bio_damage_field_generator

#define ART_HEALING 0
#define ART_HARMING 1
/datum/artifact/bio_damage_field_generator
	associated_object = /obj/machinery/artifact/bio_damage_field_generator
	type_name = "Healing/Damaging Aura"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 200
	validtypes = list("martian","wizard","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS, TOUCH_ONLY_FAULTS) // can't sting you at range
	activated = 0
	activ_text = "begins to radiate a strange energy field!"
	deact_text = "shuts down, causing the energy field to vanish!"
	react_xray = list(12,70,90,11,"COMPLEX")
	var/field_radius = 7
	var/field_type = ART_HEALING
	var/field_strength = 2

	New()
		..()
		src.field_radius = rand(2,9) // field radius
		src.field_type = rand(0,1)
		src.field_strength = rand(1,5)

	post_setup()
		. = ..()
		var/harmprob = 33
		if (src.artitype.name == "eldritch")
			harmprob += 42 // total of 75% chance of it being nasty
		if (prob(harmprob))
			src.field_type = ART_HARMING
		if (src.field_type && src.artitype.name == "eldritch")
			src.field_strength *= 2

	effect_process(var/obj/O)
		if (..())
			return
		for (var/mob/living/carbon/M in range(O,src.field_radius))
			if (src.field_type == ART_HARMING)
				random_brute_damage(M, src.field_strength)
				boutput(M, "<span class='alert'>Waves of painful energy wrack your body!</span>")
			else
				M.HealDamage("All", src.field_strength, src.field_strength)
				boutput(M, "<span class='notice'>Waves of soothing energy wash over you!</span>")
			O.ArtifactFaultUsed(M)

#undef ART_HEALING
#undef ART_HARMING
