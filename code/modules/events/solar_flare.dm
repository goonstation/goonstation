/datum/random_event/major/solarflare
	name = "Solar Flare"
	var/space_color = "#FFD446"

	event_effect(var/source)
		..()
		var/signal_loss_current = rand(66,100)
		var/headline_estimate = min(signal_loss_current + rand(-10,10),100)
		var/flare_start_time = rand(50,100)
		//spatial interdictor: mitigate signal loss
		//consumes 4,000 units of charge to activate interdiction
		for(var/obj/machinery/interdictor/IX in by_type[/obj/machinery/interdictor])
			if(IX.z == 1 && IX.expend_interdict(4000))
				var/itdr_strength = IX.interdict_range
				signal_loss_current = max(0,signal_loss_current - rand(itdr_strength,itdr_strength*2))
				SPAWN_DBG(flare_start_time)
					if(IX && IX.canInterdict) //just in case
						playsound(IX,'sound/machines/firealarm.ogg',50,0,5,0.6)
						var/adjusted_est = max(signal_loss_current + rand(-5,5),0)
						IX.visible_message("<span class='alert'><b>[IX]</b> detects a radio-frequency disturbance. Estimated strength post-interdiction: [adjusted_est]%.</span>")
						//break omitted, multiple interdictors can stack

		if (random_events.announce_events)
			command_alert("A solar flare has been detected near the [station_or_ship()]. We estimate a signal interference rate of [headline_estimate]% lasting anywhere between three to five minutes.", "Solar Flare")
		SPAWN_DBG(flare_start_time)
			signal_loss += signal_loss_current

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

	#ifndef UNDERWATER_MAP
			for (var/turf/space/S in world)
				LAGCHECK(LAG_LOW)
				if (S.z == 1)
					S.color = null
				else
					break
	#endif

			if (random_events.announce_events)
				command_alert("The solar flare has safely passed [station_name(1)]. Communications should be restored to normal.", "All Clear")
			else
				message_admins("<span class='internal'>Random Radio/Flare Event ceasing.</span>")
