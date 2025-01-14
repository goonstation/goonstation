/obj/item/cell/artifact
	name = "artifact power cell"
	icon = 'icons/obj/artifacts/artifactsitemS.dmi'
	maxcharge = 1
	var/chargeCap = 10000
	genrate = 50
	specialicon = 1
	artifact = 1
	mat_changename = 0
	mat_changedesc = 0
	var/effectProbModifier = 0
	var/noise = null
	var/leakChem = null
	var/smoky = FALSE

	New(var/loc, var/forceartiorigin)
		var/datum/artifact/powercell/AS = new /datum/artifact/powercell(src)
		if (forceartiorigin)
			AS.validtypes = list("[forceartiorigin]")
		src.artifact = AS
		SPAWN(0)
			src.ArtifactSetup()
		..()

	examine()
		. = list("You have no idea what this thing is!")
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		if (istext(A.examine_hint) && (usr && (usr.traitHolder?.hasTrait("training_scientist")) || isobserver(usr)))
			. += SPAN_ARTHINT(A.examine_hint)

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attackby(obj/item/W, mob/user)
		if (src.Artifact_attackby(W,user))
			..()

	use(amount)
		. = ..()
		if(istype(src.loc, /mob/living))
			src.ArtifactFaultUsed(src.loc)
		if(prob(10 + amount*effectProbModifier))
			var/turf/T = get_turf(src.loc)
			if(src.noise)
				playsound(T, noise, 50, TRUE, -1)

			if(leakChem && prob(50))
				if(src.smoky)
					smoke_reaction(src.reagents, 1, T)
				else
					src.reagents.reaction(T, TOUCH)
				src.reagents.clear_reagents()
				src.reagents.add_reagent(leakChem, src.reagents.maximum_volume)

			if(!issilicon(src.loc) && prob(10))
				elecflash(T)

	ArtifactActivated()
		. = ..()
		src.maxcharge = src.chargeCap
		processing_items |= src				// in case someone decides to make big cells work like small cells

	ArtifactDeactivated()
		. = ..()
		src.maxcharge = 1
		src.charge = 1

	reagent_act(reagent_id,volume)
		if (..())
			return
		src.Artifact_reagent_act(reagent_id, volume)
		return

	emp_act()
		src.Artifact_emp_act()
		..()

/datum/artifact/powercell
	associated_object = /obj/item/cell/artifact
	type_name = "Large power cell"
	type_size = ARTIFACT_SIZE_TINY
	rarity_weight = 350
	validtypes = list("ancient","martian","wizard","precursor")
	automatic_activation = 0
	react_elec = list("equal",0,10)
	react_xray = list(10,80,95,11,"SEGMENTED")
	examine_hint = "It kinda looks like it's supposed to be inserted into something."
	shard_reward = ARTIFACT_SHARD_POWER
	combine_flags = ARTIFACT_ACCEPTS_ANY_COMBINE

	New()
		..()
		src.react_heat[2] = "VOLATILE REACTION DETECTED"

	post_setup()
		..()
		var/obj/item/cell/artifact/O = src.holder
		O.chargeCap = rand(15,1000)
		O.chargeCap *= 100
		src.react_elec[2] = O.chargeCap

		// effects
		O.effectProbModifier = 1/rand(10,50) 	// probability
		switch(src.artitype.name)					// noise
			if ("martian")
				O.noise = pick('sound/voice/babynoise.ogg', 'sound/voice/animal/bugchitter.ogg', 'sound/voice/blob/blobdeath.ogg', 'sound/voice/farts/frogfart.ogg', 'sound/effects/splort.ogg')
			if ("ancient")
				O.noise = pick('sound/effects/electric_shock_short.ogg', 'sound/effects/creaking_metal2.ogg','sound/machines/weapons-reloading.ogg', 'sound/machines/glitch1.ogg','sound/machines/glitch2.ogg', 'sound/machines/glitch3.ogg','sound/machines/glitch4.ogg', 'sound/machines/glitch5.ogg', 'sound/machines/scan.ogg')
			if ("wizard")
				O.noise = pick('sound/weapons/airzooka.ogg', 'sound/misc/chair/glass/scoot5.ogg', 'sound/misc/chair/glass/scoot2.ogg')
			if ("precursor") // what does precursor stuff even sound like???
				O.noise = pick('sound/effects/singsuck.ogg', 'sound/effects/screech_tone.ogg')

		if(prob(O.chargeCap/1000)) 			// the more charge the bigger the chance it does dumb stuff
			switch(src.artitype.name) 		// leakage
				if ("martian")
					O.leakChem = pick("space_fungus","blood","vomit","gvomit","meat_slurry","grease","butter","synthflesh","bread","poo","ants","spiders")
				if ("ancient")
					O.leakChem = pick("voltagen","ash","cleaner", "oil", "thermite", "acid", "fuel", "nanites", "radium", "mercury")
				if ("wizard")
					O.leakChem = pick("glitter","sakuride","grassgro","sparkles","mirabilis", "mugwort", "carpet")
				if ("precursor")
					O.leakChem = pick(all_functional_reagent_ids) // no way this goes wrong
			if(prob(10))
				O.smoky = TRUE
			O.create_reagents(rand(5,20))
			O.reagents.add_reagent(O.leakChem, O.reagents.maximum_volume) // so you can reagent scan the cell!
