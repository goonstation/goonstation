/obj/machinery/artifact/noisy_thing
	name = "artifact noisy thing"
	associated_datum = /datum/artifact/noisy_thing

	ArtifactDeactivated()
		return // hahaha nope

/datum/artifact/noisy_thing
	associated_object = /obj/machinery/artifact/noisy_thing
	rarity_class = 1
	validtypes = list("ancient","martian","wizard","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	activated = 0
	activ_text = "begins making horrible noises!"
	deact_text = "shuts down, falling silent. Thank god for that."
	react_xray = list(9,50,40,3,"TUBULAR")
	var/spamsound = 'sound/effects/screech2.ogg'
	var/harmful = 0
	var/evil = 0
	var/sound_pitch = 1
	var/volume = 100
	var/extrarange = 0
	var/times_to_play = 1
	var/list/sounds = list('sound/machines/fortune_greeting_broken.ogg','sound/machines/engine_highpower.ogg','sound/machines/engine_grump1.ogg','sound/machines/engine_alert1.ogg',
	'sound/machines/engine_alert2.ogg','sound/machines/engine_alert3.ogg','sound/machines/lavamoon_alarm1.ogg','sound/machines/lavamoon_plantalarm.ogg','sound/machines/pod_alarm.ogg',
	'sound/machines/printer_dotmatrix.ogg','sound/machines/printer_thermal.ogg','sound/machines/romhack1.ogg','sound/machines/satcrash.ogg','sound/machines/siren_generalquarters.ogg',
	'sound/machines/signal.ogg','sound/machines/ufo_move.ogg','sound/machines/modem.ogg','sound/effects/creaking_metal1.ogg','sound/ambience/spooky/Void_Screaming.ogg','sound/ambience/industrial/Precursor_Choir.ogg',
	'sound/voice/animal/cat.ogg')

	New(var/loc, var/forceartitype)
		..()
		src.react_heat[2] = "HIGH INTERNAL CONVECTION"
		src.spamsound = pick(sounds)
		src.sound_pitch = rand(2,20)
		src.sound_pitch /= 10
		if(prob(10))
			src.sound_pitch /= 10
		src.volume = pick(prob(25);20, prob(50);30, 40, prob(25);50)
		src.extrarange = (200 - volume)/2 + rand(-20, 20)
		if(prob(40))
			src.extrarange = -10
		if(prob(30))
			src.sound_pitch *= -1
		src.times_to_play = 1
		if(prob(50))
			src.times_to_play = rand(2, 3)
			if(prob(5))
				src.times_to_play = 10

	post_setup()
		var/harmprob = 5
		if (src.artitype.name == "eldritch")
			harmprob += 20
		if (prob(harmprob))
			src.harmful = 1
		if (prob(1))
			evil = 1

	effect_process(var/obj/O)
		if (..())
			return
		var/loops = src.times_to_play
		var/turf/T = get_turf(O)
		if (evil)
			for(var/X in src.sounds)
				playsound(T, X, src.volume, 1, src.extrarange, src.sound_pitch)
		else
			while (loops > 0)
				loops--
				playsound(T, src.spamsound, src.volume, 1, src.extrarange, src.sound_pitch)

		if (src.harmful)
			for (var/mob/living/M in hearers(world.view, O))
				if (issilicon(M) || isintangible(M))
					continue
				if (!M.ears_protected_from_sound())
					boutput(M, "<span class='alert'>The loud, horrible noises painfully batter your eardrums!</span>")
				else
					continue

				var/weak = 0
				var/ear_damage = 2
				var/ear_tempdeaf = 4
				if (prob(10))
					weak = 2

				M.apply_sonic_stun(weak, 0, 0, 0, 0, ear_damage, ear_tempdeaf)

		return
