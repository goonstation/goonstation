#define THROW_TARGET_SELF 0
#define THROW_TARGET_USER 1

/obj/artifact/flinger
	name = "artifact flinger"
	associated_datum = /datum/artifact/flinger

	throw_impact(atom/A, datum/thrown_thing/thr)
		. = ..(A, thr)
		if(iscarbon(A))
			var/mob/living/carbon/impacted_person = A
			if(thr.bonus_throwforce >= 20)
				impacted_person.emote("scream")
		else if(iswall(A))
			if (thr.bonus_throwforce >= 35)
				playsound(thr.thing.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				for (var/mob/M in AIviewers(thr.thing, null))
					if (M.client)
						shake_camera(M, 4, 8, 0.5)
		else if(istype(A, /obj/structure/girder))
			if (thr.bonus_throwforce >= 35)
				playsound(thr.thing.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				for (var/mob/M in AIviewers(thr.thing, null))
					if (M.client)
						shake_camera(M, 4, 1, 8)

/datum/artifact/flinger
	associated_object = /obj/artifact/flinger
	type_name = "Flinger"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	validtypes = list("martian" ,"precursor" ,"wizard" ,"eldritch", "ancient")
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
	var/cooldowns = new/list()
	var/throw_target = THROW_TARGET_SELF

	post_setup()
		. = ..()
		src.recharge_time = rand(1,10) SECONDS
		src.range = rand(1, 15)
		src.throwforce = rand(15, 50)

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
		if(artitype.name == "precursor")
			src.throw_target = THROW_TARGET_USER

		if(prob(25))
			src.fling_dir = pick(cardinal)
			src.random_dir_every_time = FALSE
		else
			src.random_dir_every_time = TRUE
			for (var/i = 0, i < 5, i += 1)
				if(prob(50))
					src.chain_flings += 1
				else
					break
		src.recharge_time += (src.chain_flings*0.2) SECONDS //Prevents the artifact from being activated while being thrown around.
		if(prob(5))
			src.recharge_time = 0

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (!user)
			return
		if(!ON_COOLDOWN(src, "artifact_fling", src.recharge_time))
			var/turf/T = get_turf(O)
			if(iscarbon(user))
				var/remaining_flings = src.chain_flings
				switch(src.throw_target)
					if(THROW_TARGET_SELF)
						fling(O, O)
					if(THROW_TARGET_USER)
						fling(O, user)
				for (var/i = 0, i < remaining_flings, i += 1)
					SPAWN((0.1*i) SECONDS)
						switch(src.throw_target)
							if(THROW_TARGET_SELF)
								fling(O, O)
							if(THROW_TARGET_USER)
								fling(O, user)
				O.ArtifactFaultUsed(user)
				SPAWN(src.recharge_time)
					T.visible_message("<b>[O]</b> tenses up again!")
		else
			boutput(user, SPAN_ALERT("The artifact twitches, but nothing else happens."))
			return

	proc/fling(var/obj/thrower, var/obj/being_thrown)
		if(being_thrown.throwing)
			return

		var/turf/T = get_turf(thrower)
		T.visible_message("<b>[thrower]</b> lunges!")
		playsound(being_thrown.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, 1, -1)

		if(src.random_dir_every_time)
			src.fling_dir = pick(cardinal)

		var/turf/target = get_edge_target_turf(being_thrown, src.fling_dir)
		var/datum/thrown_thing/thr = being_thrown.throw_at(target, src.range, 1, bonus_throwforce=src.throwforce, throw_type=src.throw_type)
		thr?.user = thrower

#undef THROW_TARGET_SELF
#undef THROW_TARGET_USER
