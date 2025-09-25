/obj/machinery/artifact/wellspring
	name = "wellspring"
	associated_datum = /datum/artifact/wellspring

	New()
		..()
		src.create_reagents(750)


/datum/artifact/wellspring
	associated_object = /obj/machinery/artifact/wellspring

	type_name = "Wellspring"
	rarity_weight = 350
	react_xray = list(5,65,20,11,"HOLLOW")
	validtypes = list("ancient", "martian", "eldritch")
	//validtypes = list("ancient", "martian", "eldritch", "lattice")
	validtriggers = list(/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/silicon_touch, /datum/artifact_trigger/force, /datum/artifact_trigger/heat, /datum/artifact_trigger/cold, /datum/artifact_trigger/radiation, /datum/artifact_trigger/electric, /datum/artifact_trigger/language)
	activated = 1
	activ_text = "begins to flood the area with liquid!"
	deact_text = "stops flooding."
	touch_descriptors = list("It feels damp.")
	var/payload_reagents = list() //If multiple reagents are listed, it will split the payload_amount evenly between them.
	var/payload_amount = 1
	var/payload_cooldown = 1 SECONDS
	var/cooldowns = new/list()

	post_setup()
		. = ..()
		switch(artitype.name)
			if ("ancient")
				src.payload_reagents = list("fuel")
			if ("martian")
				src.payload_reagents = list("water") //water on mars, get it?
			if ("eldritch")
				src.payload_reagents = list("blood")
			//if ("lattice") //Looks like Gnesis can't form liquids.
			//	src.payload_reagents = list("flockdrone_fluid", "water")
		src.payload_amount = rand(100, 750)
		src.payload_cooldown = rand(1, 10) SECONDS

	effect_process(var/obj/O)
		if (..())
			return
		if(!ON_COOLDOWN(src, "deploy_payload", src.payload_cooldown))
			var/turf/location = get_turf(O)
			for (var/i_reagent in src.payload_reagents)
				O.reagents.add_reagent(i_reagent, src.payload_amount/length(src.payload_reagents))
			location.visible_message("<b>[O]</b> pulses.")
			O.reagents.reaction(location, 1, src.payload_amount, can_spawn_fluid=1)
