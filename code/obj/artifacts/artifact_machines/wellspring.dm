/obj/machinery/artifact/wellspring
	name = "wellspring"
	associated_datum = /datum/artifact/wellspring

	New()
		..()
		src.create_reagents(3000)


/datum/artifact/wellspring
	associated_object = /obj/machinery/artifact/wellspring

	type_name = "Wellspring"
	rarity_weight = 350
	react_xray = list(5,65,20,11,"HOLLOW")
	validtypes = list("ancient", "martian", "eldritch")
	//validtypes = list("ancient", "martian", "eldritch", "lattice")
	validtriggers = list(/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/silicon_touch, /datum/artifact_trigger/force, /datum/artifact_trigger/heat, /datum/artifact_trigger/cold, /datum/artifact_trigger/radiation, /datum/artifact_trigger/electric, /datum/artifact_trigger/language)
	activated = 0
	activ_text = "begins to flood the area with liquid!"
	deact_text = "stops flooding."
	touch_descriptors = list("It feels damp.")
	var/payload_reagent = "water"
	var/payload_amount = 1
	var/payload_cooldown = 1 SECONDS
	var/cooldowns = new/list()

	post_setup()
		. = ..()
		switch(artitype.name)
			if ("ancient")
				src.payload_reagent = pick("fuel", "charcoal", "silicate", "graphene_compound")
			if ("martian")
				src.payload_reagent = pick("water")
			if ("eldritch")
				src.payload_reagent = pick("blood", "sewage")
			//if ("lattice")
			//	src.payload_reagent = pick("flockdrone_fluid") //Looks like Gnesis can't form liquids.
		src.payload_amount = rand(100, 3000)
		src.payload_cooldown = rand(1, 10) SECONDS

	effect_process(var/obj/O)
		if (..())
			return
		if(!ON_COOLDOWN(src, "deploy_payload", src.payload_cooldown))
			var/turf/location = get_turf(O)
			O.reagents.add_reagent(src.payload_reagent, src.payload_amount)
			location.visible_message("<b>[O]</b> pulses.")
			O.reagents.reaction(location, 1, src.payload_amount, can_spawn_fluid=1)
