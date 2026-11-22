//some little fellas!
/datum/random_event/menhir/probes
	name = "Emissaries of the Crown"
	description = "Several probes are deployed to investigate the Enclave. They may tamper with machinery, and leave a gift if undisturbed."
	weight = 300
	var/list/deployed_probes = list()

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (length(src.deployed_probes)) //we're already deployed!
				. = FALSE

	event_effect()
		var/list/candidate_landmarks = list()
		for (var/turf/T in landmarks[LANDMARK_HALLOWEEN_SPAWN])
			candidate_landmarks += T
		for (var/turf/T in landmarks[LANDMARK_MENHIR_OUTREACH])
			if(istype(get_area(T),/area/station/maintenance)) continue
			candidate_landmarks += T

		var/probe_deployments = rand(8,11)
		var/have_deployed = 0
		SPAWN(1) //don't hold up other operations
			var/turf/rolling_target
			while(have_deployed < probe_deployments)
				rolling_target = pick(candidate_landmarks)
				candidate_landmarks -= rolling_target
				showswirl(rolling_target)
				var/mob/living/critter/robotic/probe/deployed_probe
				if(have_deployed < 2)
					deployed_probe = new /mob/living/critter/robotic/probe/arbitor(rolling_target)
				else
					deployed_probe = new /mob/living/critter/robotic/probe(rolling_target)
				deployed_probe.emissary = TRUE
				src.deployed_probes += deployed_probe
				have_deployed++
				sleep(1)

		SPAWN(rand(3 MINUTES, 5 MINUTES))
			for (var/mob/M in deployed_probes)
				if(!QDELETED(M))
					var/turf/T = get_turf(M)
					showswirl_out(T)
					deployed_probes -= M
					qdel(M)
					sleep(1)
			deployed_probes = list()
			logTheThing(LOG_STATION, null, "Menhir event [src.name] concluded.")
			message_admins("Menhir event [src.name] concluded.")

		logTheThing(LOG_STATION, null, "Menhir event [src.name] deployed [probe_deployments] probes.")
		message_admins("Menhir event [src.name] deployed [probe_deployments] probes.")

		message_delay = rand(2 SECONDS, 4 SECONDS)
		..()
