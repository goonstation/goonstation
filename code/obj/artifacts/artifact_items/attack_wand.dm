/obj/item/artifact/attack_wand
	name = "artifact attack wand"
	associated_datum = /datum/artifact/attack_wand
	flags =  FPRINT | CONDUCT | EXTRADELAY
	module_research_no_diminish = 1

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if (user.equipped() == src)
			if (!src.ArtifactSanityCheck())
				return
			var/datum/artifact/attack_wand/A = src.artifact
			if (!istype(A))
				return
			if (!A.activated)
				return

			user.lastattacked = src
			var/turf/U = (istype(target, /atom/movable) ? target.loc : target)
			A.effect_click_tile(src,user,U)
			src.ArtifactFaultUsed(user)

/datum/artifact/attack_wand
	associated_object = /obj/item/artifact/attack_wand
	rarity_class = 3
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
	module_research = list("weapons" = 5, "energy" = 5, "tools" = 5)
	module_research_insight = 2

	New()
		..()
		recharge_phrase = pick("crackles with static.","emits a quiet tone.","bristles with energy!","heats up.")
		error_phrase = pick("shudders briefly.","grows heavy for a moment.","emits a quiet buzz.","makes a small pop sound.")
		attack_type = pick("lightning","fire","ice","sonic")
		cooldown = rand(25,900)
		if (prob(5))
			cooldown = 0

	effect_click_tile(var/obj/O,var/mob/living/user,var/turf/T)
		if (..())
			return
		if (!ready)
			return

		ready = 0
		SPAWN_DBG(cooldown)
			if (O.loc == user)
				boutput(user, "<b>[O]</b> [recharge_phrase]")
			ready = 1

		switch(attack_type)
			if("fire")
				playsound(T, "sound/effects/bamf.ogg", 50, 1, 0)
				fireflash(T, 2)

				ArtifactLogs(user, T, O, "used", "creating fireball on target turf", 0) // Attack wands need special log handling (Convair880).

			if("ice")
				playsound(T, "sound/effects/mag_iceburstlaunch.ogg", 50, 1, 0)
				for (var/turf/TT in range(T,2))
					if(locate(/obj/decal/icefloor) in TT.contents)
						continue
					var/obj/decal/icefloor/B = new /obj/decal/icefloor(TT)
					SPAWN_DBG(80 SECONDS)
						B.dispose()
				for (var/mob/living/M in range(T,2))
					if (M.bioHolder)
						if (!M.is_cold_resistant())
							new /obj/icecube(get_turf(M), M)

							ArtifactLogs(user, M, O, "weapon", "trapping them in an ice cube", 0)

			if("lightning")
				var/attack_amt = 0
				for (var/mob/living/M in range(T,1))

					ArtifactLogs(user, M, O, "weapon", "zapping them with electricity", 0)

					attack_amt = 1
					var/list/affected = DrawLine(get_turf(M), user, /obj/line_obj/elec ,'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')
					for(var/obj/OB in affected)
						SPAWN_DBG(0.6 SECONDS)
							pool(OB)
						M.TakeDamage("chest", 0, 25)
						M.changeStatus("stunned", 50)
				if (attack_amt)
					playsound(user, "sound/effects/elec_bigzap.ogg", 40, 1)
				else
					boutput(user, "<span class='alert'><b>[O]</b> crackles with electricity for a moment. Perhaps it couldn't find a target?</span>")

			if("sonic")
				playsound(T, "sound/effects/screech.ogg", 100, 1, 0)
				particleMaster.SpawnSystem(new /datum/particleSystem/sonic_burst(T))

				for (var/mob/living/M in all_hearers(world.view, T))
					if (isintangible(M))
						continue
					if (!M.ears_protected_from_sound())
						shake_camera(M, 10, 0)
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
				R.temperature_react()

				if (R.total_volume)
					R.clear_reagents()
		return
