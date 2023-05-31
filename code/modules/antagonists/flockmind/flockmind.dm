/datum/antagonist/mob/intangible/flockmind
	id = ROLE_FLOCKMIND
	display_name = "flockmind"
	mob_path = /mob/living/intangible/flock/flockmind
	uses_pref_name = FALSE
	var/datum/flock/flock = null

	give_equipment()
		. = ..()
		if (isflockmob(src.owner.current))
			var/mob/living/intangible/flock/flockmob = src.owner.current
			flockmob.flock.flockmind_mind = src.owner
			src.flock = flockmob.flock

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/flock, src)

	announce()
		. = ..()
		boutput(src.owner.current, "<B>You are a flockmind, the collective machine consciousness of a flock of drones! Your existence is tied to your flock! Ensure that it survives and thrives!</B>")
		boutput(src.owner.current, "<B>Silicon units are able to detect your transmissions and messages (with some signal corruption), so exercise caution in what you say.</B>")
		boutput(src.owner.current, "<B>On the flipside, you can hear silicon transmissions and all radio signals, but with heavy corruption.</B>")

	handle_round_end(log_data)
		. = ..()
		. += "Peak total compute value reached: [flock.stats.peak_compute]"
		if(length(src.flock.trace_minds))
			. += "Flocktraces:"
			for (var/trace_name in src.flock.trace_minds)
				var/datum/mind/trace_mind = flock.trace_minds[trace_name]
				//the first character in this string is an invisible brail character, because otherwise DM eats my indentation
				. += "<b>⠀   [trace_name] (played by [trace_mind.displayed_key])<b>"

		if (src.flock.relay_finished)
			src.flock.flockmind_mind.current.unlock_medal("To the stars", TRUE)
			var/time = TIME
			for (var/mob/living/intangible/flock/trace/flocktrace as anything in src.flock.traces)
				if (time - flocktrace.creation_time >= 5 MINUTES)
					if (!istype(flocktrace.loc, /mob/living/critter/flock/drone))
						flocktrace.unlock_medal("To the stars", TRUE)
					else
						var/mob/living/critter/flock/drone/flockdrone = flocktrace.loc
						flockdrone.unlock_medal("To the stars", TRUE)
