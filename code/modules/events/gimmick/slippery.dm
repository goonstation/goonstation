/datum/random_event/special/slippery
	name = "Slippery Floors"

	event_effect()
		..()
		if (random_events.announce_events)
			command_alert("Our [pick("sensors","scientists","monitors","fluidity regulators","janitor consultants")] have [pick("detected","found","discovered","noted","warned us that")] \a [pick("strange gathering of fluid","overabundance of moisture","large amount of moist material","spillage of janitorial supplies")] [pick("has built up on","has formed a hazardous mass on","has assembled rapidly on","has flooded")] the station.", "Anomaly Alert")
		for (var/turf/simulated/floor/T in world)
			LAGCHECK(LAG_LOW)
			T.wet = 2
		SPAWN(rand(100,1200))
			for (var/turf/simulated/floor/T in world)
				LAGCHECK(LAG_LOW)
				T.wet = 0
