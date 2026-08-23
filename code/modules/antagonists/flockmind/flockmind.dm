/datum/antagonist/mob/intangible/flockmind
	id = ROLE_FLOCKMIND
	display_name = "flockmind"
	antagonist_icon = "flockmind"
	mob_path = /mob/living/intangible/flock/flockmind
	uses_pref_name = FALSE
	wiki_link = "https://wiki.ss13.co/Flockmind"
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

	handle_round_end()
		. = ..()

		if (!src.flock.relay_finished)
			return

		src.flock.flockmind_mind.current.unlock_medal("To the stars", TRUE)
		var/time = TIME
		for (var/mob/living/intangible/flock/trace/flocktrace as anything in src.flock.traces)
			if (time - flocktrace.creation_time < 5 MINUTES)
				continue

			if (!istype(flocktrace.loc, /mob/living/critter/flock/drone))
				flocktrace.unlock_medal("To the stars", TRUE)

			else
				var/mob/living/critter/flock/drone/flockdrone = flocktrace.loc
				flockdrone.unlock_medal("To the stars", TRUE)

	get_statistics()
		return list(
			list(
				"name" = "Peak Compute",
				"value" = "[src.flock.stats.peak_compute] compute",
			)
		)
