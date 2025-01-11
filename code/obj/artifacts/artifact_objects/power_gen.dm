/obj/machinery/artifact/power_gen
	name = "artifact power generator"
	associated_datum = /datum/artifact/power_gen
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.set_brightness(1)
		light.set_color(0, 1, 1)
		light.attach(src)

/datum/artifact/power_gen
	associated_object = /obj/machinery/artifact/power_gen
	type_name = "Power Generator"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 90
	validtypes = list("ancient")
	validtriggers = list(/datum/artifact_trigger/electric,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS, TOUCH_ONLY_FAULTS)
	activated = 0
	activ_text = "begins to emit an electric hum!"
	deact_text = "sparks and shuts down!"
	examine_hint = "It is sparking with electricity."
	deact_sound = 'sound/effects/singsuck.ogg'
	react_xray = list(10,90,80,10,"NONE")
	touch_descriptors = list("You can feel the electricity flowing through this thing.")
	shard_reward = ARTIFACT_SHARD_POWER
	combine_flags = ARTIFACT_ACCEPTS_ANY_COMBINE | ARTIFACT_COMBINES_INTO_ANY
	combine_effect_priority = ARTIFACT_COMBINATION_TOUCHED
	var/gen_rate = 0
	var/gen_level = 0
	var/mode = 0
	var/obj/cable/attached
	var/list/spark_sounds = list('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg','sound/effects/sparks5.ogg','sound/effects/sparks6.ogg')

	New()
		..()
		// Previously generated a super lame amount of power from 5 KW to 5 MW. Let's make things... INTERESTING? Maybe 500 KW to 500 MW will be more interesting.
		gen_level = rand(1,10) // levels from 1-10
		gen_rate = 500000 * 1.0715 ** ((gen_level-1)*10 + rand(0,10))

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		elecflash(user,power=2)
		user.shock(O, rand(5000, gen_rate / 4))
		if(!user.disposed)
			O.ArtifactFaultUsed(user) // in case you weren't already fucked enough lol
		if(mode == 0)
			var/turf/T = get_turf(O)
			if(isturf(T) && !T.intact)
				attached = locate() in T
				if(!attached)
					boutput(user, "No exposed cable here to attach to.")
				else
					O.anchored = ANCHORED
					mode = 2
					boutput(user, "[O] connects itself to the cable. Weird.")
					playsound(O, 'sound/effects/ship_charge.ogg', 75, TRUE)
					logTheThing(LOG_STATION, user, "connected power generator artifact [O] at [log_loc(O)].")
					var/obj/machinery/artifact/power_gen/L = O
					if (L.light)
						L.light.enable()
			else
				boutput(user, "[O] must be placed over a cable to attach to it.")
		else
			O.anchored = UNANCHORED
			mode = 0
			attached = 0
			boutput(user, "[O] disconnects itself from the cable.")
			playsound(O, 'sound/effects/shielddown2.ogg', 75, TRUE, 0, 2)
			logTheThing(LOG_STATION, user, "discconnected power generator artifact [O] at [log_loc(O)].")
			var/obj/machinery/artifact/power_gen/L = O
			if (L.light)
				L.light.disable()

	effect_process(var/obj/O)
		if (..())
			return
		if(attached)
			var/datum/powernet/PN = attached.get_powernet()
			if(PN)
				PN.newavail += gen_rate
				var/turf/T = get_turf(O)
				playsound(O, 'sound/machines/engine_highpower.ogg', 75, TRUE, 0, 1)
				if (prob(10))
					playsound(O, 'sound/effects/screech2.ogg', 75, TRUE)
					fireflash(O, rand(1,min(5,gen_level)), chemfire = CHEM_FIRE_RED)
					O.visible_message(SPAN_ALERT("[O] erupts in flame!"))
				if (prob(5))
					playsound(O, 'sound/effects/screech2.ogg', 75, TRUE)
					O.visible_message(SPAN_ALERT("[O] rumbles!"))
					for (var/mob/M in range(min(5,gen_level),T))
						shake_camera(M, 5, 8)
						M.changeStatus("knockdown", 3 SECONDS)
					for (var/turf/TF in range(min(5,gen_level),T))
						animate_shake(TF,5,1 * GET_DIST(TF,T),1 * GET_DIST(TF,T))
					if (gen_level >= 5)
						for (var/obj/window/W in range(min(5,gen_level), T))
							W.health = 0
							W.smash()
				if (prob(5))
					playsound(O, 'sound/effects/screech2.ogg', 75, TRUE)
					O.visible_message(SPAN_ALERT("[O] sparks violently!"))
					for (var/mob/M in view(min(5,gen_level),T))
						if (M.invisibility >= INVIS_AI_EYE) continue
						arcFlash(O, M, gen_rate/2)
						if(!M.disposed)
							O.ArtifactFaultUsed(M) // in case you weren't already fucked enough lol
		else
			playsound(O, pick(spark_sounds), 75, 1)
