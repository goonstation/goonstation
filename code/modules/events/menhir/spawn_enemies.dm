//the ancient ones remembered in the deep of the Crown have noticed your presence. and SHIT IS GOIN DOWN
/datum/random_event/menhir/shadow
	name = "Of Memory Is Borne Lament"
	description = "Shadows remembered in the Crown seize control of it for a moment, causing a local lighting blowout and flooding the Crown with enemies."
	message_delay = 30 SECONDS
	required_elapsed_round_time = 22 MINUTES
	announcement_style = EVENT::MENHIR::NOTIFY::GLOBAL
	centcom_headline = "ARTIFACT CONDITION ALERT"
	centcom_message = "A massive spike in electromagnetic activity that does not match prior readings has been detected from TOREADOR-7I-22408. All personnel should immediately make ready for hazardous conditions."
	weight = 10

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			var/obj/machinery/door/unpowered/blue/seal = locate("vestibule_of_grief")
			if (!seal || seal.density) //the way has not been opened; is the disturbance great enough regardless?
				var/list/eligible_caretakers = EVENT.MENHIR.FILTER.get_event_candidates()
				if (length(eligible_caretakers) < 16)
					. = FALSE

			if (!landmarks[LANDMARK_MENHIR_DARK] || length(landmarks[LANDMARK_MENHIR_DARK]) < 1)
				. = FALSE //they have already made their ingress
	event_effect()
		if (!landmarks[LANDMARK_MENHIR_DARK] || length(landmarks[LANDMARK_MENHIR_DARK]) < 1) return //manual call safeguard
		for (var/turf/T in landmarks[LANDMARK_MENHIR_DARK])
			if (istype(T,/turf/unsimulated/wall))
				var/save_dir = T.icon_state
				var/obj/newdoor = new /obj/machinery/door/unpowered/blue(T)
				if (save_dir == "interior-3") //vertical wall detection
					newdoor.dir = 4
			else
				SPAWN(rand(0,200))
					new /mob/living/critter/shade/invader(T)

		playsound_global(Z_LEVEL_STATION, 'sound/musical_instruments/artifact/Artifact_Void_2.ogg', 70, 0, 0.45)
		var/remusic = 110 SECONDS
		SPAWN(remusic)
			playsound_global(Z_LEVEL_STATION, 'sound/musical_instruments/artifact/Artifact_Void_2.ogg', 70, 0, 0.45)

		SPAWN(rand(2 SECONDS, 3 SECONDS))
			playsound_global(Z_LEVEL_STATION, pick(list('sound/voice/creepywhisper_1.ogg', 'sound/voice/creepywhisper_2.ogg', 'sound/voice/creepywhisper_3.ogg')), 60)
			for (var/obj/machinery/power/apc/apc in machine_registry[MACHINES_POWER])
				if (!istype(apc.area,/area/station/hallway/primary))
					continue
				apc.overload_lighting()

		for_by_tcl(light,/obj/map/light/cyan/menhir)
			SPAWN(rand(1,10))
				light.alterlight(0.42,0.3,0.3)

		message_delay = rand(5 SECONDS, 8 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.3)
			SPAWN(message_delay + 15)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.3)
			SPAWN(message_delay + 30)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', 60, pitch = 1.3)

		landmarks[LANDMARK_MENHIR_DARK] = null
		logTheThing(LOG_STATION, null, "Menhir event [src.name] triggered.")
		message_admins("Menhir event [src.name] triggered.")
