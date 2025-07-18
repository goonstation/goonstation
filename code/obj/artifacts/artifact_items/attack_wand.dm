/obj/item/artifact/attack_wand
	name = "artifact attack wand"
	associated_datum = /datum/artifact/attack_wand
	flags =  CONDUCT | EXTRADELAY

	// this is necessary so that this returns null
	// else afterattack will not be called when out of range
	pixelaction(atom/target, params, mob/user, reach)
		..()
/datum/artifact/attack_wand
	associated_object = /obj/item/artifact/attack_wand
	type_name = "Elemental Wand"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 200
	validtypes = list("wizard")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/force)
	react_xray = list(8,80,60,11,"COMPLEX")
	examine_hint = "It seems to have a handle you're supposed to hold it by."
	var/ready = 1
	var/cooldown = 180
	var/attack_type = null
	var/recharge_phrase = ""
	var/error_phrase = ""
	var/list/powerVars = list()

	New()
		..()
		recharge_phrase = pick("crackles with static.","emits a quiet tone.","bristles with energy!","heats up.")
		error_phrase = pick("shudders briefly.","grows heavy for a moment.","emits a quiet buzz.","makes a small pop sound.")
		attack_type = pick("lightning","fire","ice","sonic")
		if(prob(10))
			attack_type = "all"
		// cooldown
		cooldown = rand(3 SECONDS, 70 SECONDS)
		if(attack_type == "lightning")
			cooldown = max(30 SECONDS, cooldown)
		// fire
		powerVars["fireTemp"] = rand(1000,10000)
		if(prob(10))
			powerVars["fireTemp"] *= 4
		powerVars["fireRadius"] = rand(1,4)
		// ice
		powerVars["cubeHealth"] = rand(5,25) // default cube is 10, 100 units of cryostylane would make 20, for reference
		powerVars["iceRadius"] = rand(1,4)
		// lightning
		powerVars["wattage"] = rand(30000,2e6) 				// goes up to 80 damage, so no potential electrogibs or anything
		if(prob(5))																		// unless...
			powerVars["wattage"] *= 2
		// sonic
		// yeah, I got nothing

	effect_click_tile(var/obj/O,var/mob/living/user,var/turf/T)
		if (..())
			return
		if (!ready)
			return

		ready = 0
		SPAWN(cooldown)
			if (O.loc == user)
				boutput(user, "<b>[O]</b> [recharge_phrase]")
			ready = 1

		var/curAttack = attack_type
		if(attack_type == "all")
			curAttack = pick("lightning","fire","ice","sonic")

		// copied from gun_parent.dm->shoot
		for(var/mob/viewer in AIviewers(user, null))
			viewer.show_message(SPAN_ALERT("<B>[user] points [O] at [T]!</B>"), 1, SPAN_ALERT("You hear surge of magic!"), 2)

		switch(curAttack)
			if("fire")
				playsound(T, 'sound/effects/bamf.ogg', 50, TRUE, 0)
				fireflash(T, powerVars["fireRadius"], powerVars["fireTemp"], chemfire = CHEM_FIRE_RED)

				ArtifactLogs(user, T, O, "used", "creating fireball on target turf", 0) // Attack wands need special log handling (Convair880).

			if("ice")
				playsound(T, 'sound/effects/mag_iceburstlaunch.ogg', 50, TRUE, 0)
				for (var/turf/TT in range(T,powerVars["iceRadius"]))
					if(locate(/obj/decal/icefloor) in TT.contents)
						continue
					var/obj/decal/icefloor/B = new /obj/decal/icefloor(TT)
					SPAWN(80 SECONDS)
						B.dispose()
				for (var/mob/living/M in range(T,powerVars["iceRadius"]))
					if (M.bioHolder)
						if (!M.is_cold_resistant())
							var/obj/icecube/cube = new /obj/icecube(get_turf(M), M)
							cube.health = powerVars["cubeHealth"]
							O.ArtifactFaultUsed(M)

							ArtifactLogs(user, M, O, "weapon", "trapping them in an ice cube", 0)

			if("lightning")
				arcFlashTurf(user, T, powerVars["wattage"])
				for (var/mob/living/M in range(T,powerVars["iceRadius"]))
					O.ArtifactFaultUsed(M)
					ArtifactLogs(user, M, O, "weapon", "zapping them with electricity", 0)

			if("sonic")
				playsound(T, 'sound/effects/screech.ogg', 50, TRUE, 0)
				particleMaster.SpawnSystem(new /datum/particleSystem/sonic_burst(T))

				for (var/mob/living/M in all_hearers(world.view, T))
					if (isintangible(M))
						continue
					if (!M.ears_protected_from_sound())
						O.ArtifactFaultUsed(M)
					else
						continue

					ArtifactLogs(user, M, O, "weapon", "inflicting ear damage", 0)

				// Here used to be a C&P of what sonic powder does anyway (Convair880).
				var/datum/reagents/R = O.reagents

				if (!R || !istype(R))
					R = new /datum/reagents(15)
					O.reagents = R
					R.my_atom = O
				else if (R && istype(R) && R.my_atom != O)
					R.my_atom = O

				R.clear_reagents()
				if (R.maximum_volume < 15)
					R.maximum_volume = 15

				R.add_reagent("sonicpowder_nofluff", 15, null, T0C + 200)

				if (R.total_volume)
					R.clear_reagents()

		O.ArtifactFaultUsed(user)
		return
