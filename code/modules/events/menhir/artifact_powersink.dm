//the crown tries out one of its more novel machines
/datum/random_event/menhir/powersink
	name = "A Spire of Synthesis"
	description = "Summons and activates a Synthesizer artifact at an outreach point, draining power to produce valuable minerals."
	message_delay = 1 MINUTE
	weight = 40
	announcement_style = EVENT::MENHIR::NOTIFY::GLOBAL
	centcom_message = "A sustained period of elevated electromagnetic activity from TOREADOR-7I-22408 is currently underway. Personnel are advised to monitor station power grid and deactivate supply if anomalous behavior is detected."

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			var/list/eligible_caretakers = EVENT.MENHIR.FILTER.get_event_candidates()
			if (!length(eligible_caretakers))
				. = FALSE

	event_effect()
		///Location of "outreach".
		var/turf/eventlandmark = pick_landmark(LANDMARK_MENHIR_OUTREACH)
		if (!istype(eventlandmark,/turf/simulated/floor) || is_blocked_turf(eventlandmark))
			eventlandmark = get_open_outreach()
			if(!eventlandmark)
				logTheThing(LOG_DEBUG, null, "Menhir event [src.name] couldn't find a turf to happen at; aborting event.")
				message_admins("Menhir event [src.name] couldn't find a turf to happen at; aborting event.")
				return

		showswirl(eventlandmark)
		playsound(eventlandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_4.ogg', 55, 0, extrarange = 24, pitch = 0.45)
		SPAWN(2)
			var/obj/sinkyboye = Artifact_Spawn(eventlandmark,forceartitype = /datum/artifact/synthesizer)
			sinkyboye.anchored = ANCHORED //give it a sec
			SPAWN(1 SECOND)
				sinkyboye.ArtifactActivated()

		//reading is deliberately not localized

		message_delay = rand(12 SECONDS,16 SECONDS)
		..()
		if (random_events.announce_events)
			SPAWN(message_delay)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', EVENT::MENHIR::ALERT_VOLUME)
			SPAWN(message_delay + 20)
				playsound_global(world, 'sound/misc/announcement_ominous.ogg', EVENT::MENHIR::ALERT_VOLUME)

		logTheThing(LOG_STATION, null, "Menhir event [src.name] at [log_loc(eventlandmark)]")
		message_admins("Menhir event [src.name] triggered at [log_loc(eventlandmark)]")
