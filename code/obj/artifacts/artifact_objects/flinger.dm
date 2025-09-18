/obj/artifact/flinger
	name = "artifact flinger"
	associated_datum = /datum/artifact/flinger

	throw_impact(atom/A, datum/thrown_thing/thr)
		. = ..(A, thr)
		if(iscarbon(A))
			var/mob/living/carbon/unit = A
			if(thr.bonus_throwforce >= 20)
				unit.emote("scream")
			if(thr.bonus_throwforce >= 90)
				unit.gib()
				logTheThing(LOG_COMBAT, thr.thing, " gibbed [unit.name] at [log_loc(unit)].")
		else if(iswall(A))
			if (thr.bonus_throwforce >= 35)
				playsound(thr.thing.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				for (var/mob/N in AIviewers(thr.thing, null))
					if (N.client)
						shake_camera(N, 4, 8, 0.5)
		else if(istype(A, /obj/structure/girder))
			if (thr.bonus_throwforce >= 35)
				playsound(thr.thing.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				for (var/mob/N in AIviewers(thr.thing, null))
					if (N.client)
						shake_camera(N, 4, 1, 8)

/datum/artifact/flinger
	associated_object = /obj/artifact/flinger
	type_name = "Flinger"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	validtypes = list("martian","precursor","wizard","eldritch", "silicon")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/language)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	activated = 0
	activ_text = "begins to build tension."
	deact_text = "relaxes."
	react_xray = list(11,70,90,9,"FIBROUS")
	var/range = 1
	var/throwforce = 1
	var/recharge_time = 600
	var/recharging = FALSE
	var/fling_dir = SOUTH
	var/random_dir_every_time = FALSE
	var/chain_flings = 1
	var/throw_type = 1

	post_setup()
		. = ..()
		src.recharge_time = rand(1,10) * 10
		src.range = rand(1, 15)
		src.throwforce = rand(1, 50)

		if(artitype.name == "eldritch")
			//Eldritch artifacts hurt more.
			src.range = src.range*2
			src.throwforce = src.throwforce*2
			//And if they hurt bad enough.. They just cruise through walls.
			if(src.throwforce >= 90)
				src.throw_type = THROW_THROUGH_WALL
		if(artitype.name == "wizard")
			//Silly phasing wizards
			src.throw_type = THROW_PHASE

		if(prob(75))
			src.fling_dir = pick(cardinal)
			src.random_dir_every_time = FALSE
		else
			src.random_dir_every_time = TRUE
			for (var/i = 0, i < 5, i += 1)
				if(prob(30))
					src.chain_flings += 1
				else
					break
		if(prob(5))
			src.recharge_time = 0

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (!user)
			return
		if (src.recharging)
			boutput(user, SPAN_ALERT("The artifact twitches, but nothing else happens."))
			return
		if (src.recharge_time > 0)
			src.recharging = TRUE
		var/turf/T = get_turf(O)
		if(iscarbon(user))
			var/remaining_flings = src.chain_flings
			fling(O)
			for (var/i = 0, i < remaining_flings, i += 1)
				SPAWN(10*i)
					fling(O)

			O.ArtifactFaultUsed(user)

		SPAWN(src.recharge_time + src.chain_flings * 20) //Prevents the artifact from being activated while being thrown around.
			src.recharging = FALSE
			T.visible_message("<b>[O]</b> tenses up again!")

	proc/fling(var/obj/O)
		if(O.throwing)
			return

		var/turf/T = get_turf(O)
		T.visible_message("<b>[O]</b> lunges!")
		playsound(O.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, 1, -1)

		if(src.random_dir_every_time)
			src.fling_dir = pick(cardinal)

		var/turf/target = get_edge_target_turf(O, src.fling_dir)
		var/datum/thrown_thing/thr = O.throw_at(target, src.range, 1, bonus_throwforce=src.throwforce, throw_type=src.throw_type)
		thr?.user = O


