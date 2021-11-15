/obj/item/ammo/power_cell/self_charging/artifact
	name = "artifact energy gun power cell"
	icon = 'icons/obj/artifacts/artifactsitemS.dmi'
	artifact = 1
	charge = 400.0
	max_charge = 400.0
	recharge_rate = 0.0
	mat_changename = 0
	mat_changedesc = 0
	var/effectProbModifier = 0
	var/noise = null
	var/leakChem = null
	var/smoky = FALSE

	New(var/loc, var/forceartiorigin)
		var/datum/artifact/energyammo/A = new /datum/artifact/energyammo(src)
		if (forceartiorigin)
			A.validtypes = list("[forceartiorigin]")
		src.artifact = A
		SPAWN_DBG(0)
			src.ArtifactSetup()
			A.react_elec[2] = src.max_charge

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

	ArtifactActivated()
		. = ..()
		processing_items |= src
		AddComponent(/datum/component/power_cell, max_charge, null, recharge_rate)

	ArtifactDeactivated()
		. = ..()
		AddComponent(/datum/component/power_cell, 1, 1, 0)

	reagent_act(reagent_id,volume)
		if (..())
			return
		src.Artifact_reagent_act(reagent_id, volume)
		return

	emp_act()
		src.Artifact_emp_act()
		..()

	use(amount)
		. = ..()
		if(!istype(src.loc, /obj/item/gun/energy/artifact))
			if(prob(20))
				src.ArtifactDevelopFault(100)
				src.visible_message("<span class='alert'>[src] emits \a [pick("ominous", "portentous", "sinister")] sound.</span>")
			else if(prob(20))
				src.ArtifactTakeDamage(20)
				src.visible_message("<span class='alert'>[src] emits a terrible cracking noise.</span>")
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
/datum/artifact/energyammo
	associated_object = /obj/item/ammo/power_cell/self_charging/artifact
	type_name = "Small power cell"
	rarity_weight = 0
	validtypes = list("ancient","eldritch","precursor")
	automatic_activation = 1
	react_elec = list("equal",0,0)
	react_xray = list(8,80,95,11,"SEGMENTED")
	examine_hint = "It kinda looks like it's supposed to be inserted into something."

	New()
		..()
		src.react_heat[2] = "VOLATILE REACTION DETECTED"

	post_setup()
		..()
		var/obj/item/ammo/power_cell/self_charging/artifact/O = src.holder
		O.max_charge = rand(5,100)
		O.max_charge *= 10
		O.charge = O.max_charge
		O.recharge_rate = rand(5,60)

		// effects
		O.effectProbModifier = 1/rand(10,50) 	// probability
		switch(src.artitype.name)					// noise
			if ("martian")
				O.noise = pick("sound/voice/babynoise.ogg", "sound/voice/animal/bugchitter.ogg", "sound/voice/blob/blobdeath.ogg", "sound/voice/farts/frogfart.ogg", "sound/effects/splort.ogg")
			if ("ancient")
				O.noise = pick("sound/effects/electric_shock_short.ogg", "sound/effects/creaking_metal2.ogg","sound/machines/weapons-reloading.ogg", "sound/machines/glitch1.ogg","sound/machines/glitch2.ogg", "sound/machines/glitch3.ogg","sound/machines/glitch4.ogg", "sound/machines/glitch5.ogg", "sound/machines/scan.ogg")
			if ("wizard")
				O.noise = pick("sound/weapons/airzooka.ogg", "sound/misc/newsting.ogg", "sound/misc/chair/glass/scoot5.ogg", "sound/misc/chair/glass/scoot2.ogg")
			if ("precursor") // what does precursor stuff even sound like???
				O.noise = pick("sound/effects/singsuck.ogg", "sound/effects/screech_tone.ogg")

		if(prob(O.max_charge/20)) 			// the more charge the bigger the chance it does dumb stuff
			switch(src.artitype.name) 		// leakage
				if ("martian")
					O.leakChem = pick("space_fungus","blood","vomit","gvomit","urine","meat_slurry","grease","butter","synthflesh","bread","poo","ants","spiders")
				if ("ancient")
					O.leakChem = pick("voltagen","ash","cleaner", "oil", "thermite", "acid", "fuel", "nanites", "radium", "mercury")
				if ("wizard")
					O.leakChem = pick("glitter","sakuride","grassgro","sparkles","glowing_fliptonium", "mugwort")
				if ("precursor")
					O.leakChem = pick(all_functional_reagent_ids) // no way this goes wrong
			if(prob(10))
				O.smoky = TRUE
			O.create_reagents(rand(5,20))
			O.reagents.add_reagent(O.leakChem, O.reagents.maximum_volume) // so you can reagent scan the cell!
