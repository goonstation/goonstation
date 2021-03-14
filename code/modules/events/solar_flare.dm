/datum/random_event/major/solarflare
	name = "Solar Flare"
	var/space_color = "#FFD446"

	event_effect(var/source)
		..()
		var/signal_loss_current = rand(66,100)
		var/headline_estimate = min(signal_loss_current + rand(-10,10),100)
		if (random_events.announce_events)
			command_alert("A solar flare has been detected near the [station_or_ship()]. We estimate a signal interference rate of [headline_estimate]% lasting anywhere between three to five minutes.", "Solar Flare")
		SPAWN_DBG(rand(50,100))
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
