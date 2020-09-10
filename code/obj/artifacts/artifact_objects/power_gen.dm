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
	rarity_class = 4
	validtypes = list("ancient")
	validtriggers = list(/datum/artifact_trigger/electric,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	activated = 0
	activ_text = "begins to emit an electric hum!"
	deact_text = "sparks and shuts down!"
	examine_hint = "It is sparking with electricity."
	deact_sound = 'sound/effects/singsuck.ogg'
	react_xray = list(10,90,80,10,"NONE")
	touch_descriptors = list("You can feel the electricity flowing through this thing.")
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
		if(mode == 0)
			var/turf/T = get_turf(O)
			if(isturf(T) && !T.intact)
				attached = locate() in T
				if(!attached)
					boutput(user, "No exposed cable here to attach to.")
				else
					O.anchored = 1
					mode = 2
					boutput(user, "[O] connects itself to the cable. Weird.")
					playsound(O, "sound/effects/ship_charge.ogg", 200, 1)
					var/obj/machinery/artifact/power_gen/L = O
					if (L.light)
						L.light.enable()
			else
				boutput(user, "[O] must be placed over a cable to attach to it.")
		else
			O.anchored = 0
			mode = 0
			attached = 0
			boutput(user, "[O] disconnects itself from the cable.")
			playsound(O, "sound/effects/shielddown2.ogg", 200, 1, 0, 2)
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
				playsound(O, "sound/machines/engine_highpower.ogg", 100, 1, 0, 1)
				if (prob(10))
					playsound(O, "sound/effects/screech2.ogg", 200, 1)
					fireflash(O, rand(1,min(5,gen_level)))
					O.visible_message("<span class='alert'>[O] erupts in flame!</span>")
				if (prob(5))
					playsound(O, "sound/effects/screech2.ogg", 200, 1)
					O.visible_message("<span class='alert'>[O] rumbles!</span>")
					for (var/mob/M in range(min(5,gen_level),T))
						shake_camera(M, 5, 8)
						M.changeStatus("weakened", 3 SECONDS)
					for (var/turf/TF in range(min(5,gen_level),T))
						animate_shake(TF,5,1 * get_dist(TF,T),1 * get_dist(TF,T))
					if (gen_level >= 5)
						for (var/obj/window/W in range(min(5,gen_level), T))
							W.health = 0
							W.smash()
				if (prob(5))
					playsound(O, "sound/effects/screech2.ogg", 200, 1)
					O.visible_message("<span class='alert'>[O] sparks violently!</span>")
					for (var/mob/M in range(min(5,gen_level),T))
						arcFlash(O, M, gen_rate/2)
		else
			playsound(O, pick(spark_sounds), 200, 1)
