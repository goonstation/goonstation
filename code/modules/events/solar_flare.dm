/datum/random_event/major/solarflare
	name = "Solar Flare"
	var/space_color = "#FFD446"

	event_effect(var/source)
		..()
		var/signal_loss_initial = rand(66,100)
		var/signal_loss_current = signal_loss_initial
		var/flare_start_time = rand(100,200)
		//spatial interdictor: mitigate signal loss
		//consumes 2,000 units of charge (1 million joules) as the effect is zone-wide and requires significant energetic investment
		for_by_tcl(IX, /obj/machinery/interdictor)
			if(IX.z == 1 && IX.expend_interdict(2000))
				var/itdr_strength = IX.interdict_range
				signal_loss_current = max(0,signal_loss_current - rand(itdr_strength,itdr_strength*2))
				SPAWN(flare_start_time/4)
					if(IX && IX.canInterdict) //just in case
						playsound(IX,'sound/machines/firealarm.ogg',50,FALSE,5,0.6)
						IX.visible_message(SPAN_ALERT("<b>[IX]</b> detects a mass radio-frequency disturbance. Applying wide-spectrum interdiction."))
						//break omitted, multiple interdictors can stack

		if (random_events.announce_events)
			SPAWN(flare_start_time/2)
				var/headline_estimate = min(signal_loss_current + rand(-10,10),100)
				var/headline = "A solar flare has been detected near the [station_or_ship()]. We estimate a signal interference rate of [headline_estimate]% lasting anywhere between three to five minutes."
				if (signal_loss_initial != signal_loss_current)
					headline += "<br>Local spatial interdiction reduced interference by an estimated [min(headline_estimate, signal_loss_initial - signal_loss_current + rand(-5, 5))]%."
				command_alert(headline, "Solar Flare", alert_origin = ALERT_WEATHER)

		SPAWN(flare_start_time)
			signal_loss += signal_loss_current
			global.solar_gen_rate *= signal_loss_current

	#ifndef UNDERWATER_MAP
			for (var/turf/space/S in world)
				LAGCHECK(LAG_LOW)
				if (S.z == 1)
					S.color = src.space_color
				else
					break
	#endif
			sleep(rand(1200,1800))
			signal_loss -= signal_loss_current
			global.solar_gen_rate = DEFAULT_SOLARGENRATE

	#ifndef UNDERWATER_MAP
			for (var/turf/space/S in world)
				LAGCHECK(LAG_LOW)
				if (S.z == 1)
					S.color = null
				else
					break
	#endif

			if (random_events.announce_events)
				command_alert("The solar flare has safely passed [station_name(1)]. Communications should be restored to normal.", "All Clear", alert_origin = ALERT_WEATHER)
			else
				message_admins(SPAN_INTERNAL("Random Radio/Flare Event ceasing."))
