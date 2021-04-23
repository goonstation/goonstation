/obj/item/cell/artifact
	name = "artifact power cell"
	icon = 'icons/obj/artifacts/artifactsitemS.dmi'
	maxcharge = 10000
	var/chargeCap = 10000
	genrate = 50
	specialicon = 1
	artifact = 1
	module_research_no_diminish = 1
	mat_changename = 0
	mat_changedesc = 0
	var/effectProbModifier = 0
	var/noise = null
	var/leakChem = null
	var/smoky = FALSE

	New(var/loc, var/forceartiorigin)
		//src.artifact = new /datum/artifact/powercell(src)
		var/datum/artifact/powercell/AS = new /datum/artifact/powercell(src)
		if (forceartiorigin)
			AS.validtypes = list("[forceartiorigin]")
		src.artifact = AS
		SPAWN_DBG(0)
			src.ArtifactSetup()
			var/datum/artifact/A = src.artifact
			src.maxcharge = rand(15,1000)
			src.maxcharge *= 100
			src.chargeCap = src.maxcharge
			A.react_elec[2] = src.maxcharge

			// effects
			src.effectProbModifier = 1/rand(10,50) 	// probability
			switch(A.artitype.name)										// noise
				if ("martian")
					src.noise = pick("sound/voice/babynoise.ogg", "sound/voice/animal/bugchitter.ogg", "sound/voice/blob/blobdeath.ogg", "sound/voice/farts/frogfart.ogg", "sound/effects/splort.ogg")
				if ("ancient")
					src.noise = pick("sound/effects/electric_shock_short.ogg", "sound/effects/creaking_metal2.ogg","sound/machines/weapons-reloading.ogg", "sound/machines/glitch1.ogg","sound/machines/glitch2.ogg", "sound/machines/glitch3.ogg","sound/machines/glitch4.ogg", "sound/machines/glitch5.ogg", "sound/machines/scan.ogg")
				if ("wizard")
					src.noise = pick("sound/weapons/airzooka.ogg", "sound/misc/newsting.ogg", "sound/misc/chair/glass/scoot5.ogg", "sound/misc/chair/glass/scoot2.ogg")
				if ("precursor") // what does precursor stuff even sound like???
					src.noise = pick("sound/effects/singsuck.ogg", "sound/effects/screech_tone.ogg")

			if(prob(maxcharge/1000)) 									// the more charge the bigger the chance it does dumb stuff
				switch(A.artitype.name) 								// leakage
					if ("martian")
						src.leakChem = pick("space_fungus","blood","vomit","gvomit","urine","meat_slurry","grease","butter","synthflesh","bread","poo","ants","spiders")
					if ("ancient")
						src.leakChem = pick("voltagen","ash","cleaner", "oil", "thermite", "acid", "fuel", "nanites", "radium", "mercury")
					if ("wizard")
						src.leakChem = pick("glitter","sakuride","grassgro","glitter_harmless","glowing_fliptonium", "mugwort")
					if ("precursor")
						src.leakChem = pick(all_functional_reagent_ids) // no way this goes wrong
				if(prob(10))
					src.smoky = TRUE
				src.create_reagents(rand(5,20))
				src.reagents.add_reagent(leakChem, src.reagents.maximum_volume) // so you can reagent scan the cell!


			..()

	examine()
		. = list("You have no idea what this thing is!")
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		if (istext(A.examine_hint))
			. += A.examine_hint

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.Artifact_attackby(W,user))
			..()

	use(amount)
		. = ..()
		if(istype(src.loc, /mob/living))
			src.ArtifactFaultUsed(src.loc)
		if(prob(10 + amount*effectProbModifier))
			var/turf/T = get_turf(src.loc)
			if(src.noise)
				playsound(T, noise, 50, 1, -1)

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
	rarity_weight = 350
	validtypes = list("ancient","martian","wizard","precursor")
	automatic_activation = 1
	react_elec = list("equal",0,10)
	react_xray = list(10,80,95,11,"SEGMENTED")
	examine_hint = "It kinda looks like it's supposed to be inserted into something."
	module_research = list("energy" = 15, "miniaturization" = 20)
	module_research_insight = 1

	New()
		..()
		src.react_heat[2] = "VOLATILE REACTION DETECTED"
