/datum/antagonist/intangible/flockmind
	id = ROLE_FLOCKMIND
	display_name = "flockmind"
	intangible_mob_path = /mob/living/intangible/flock/flockmind

	give_equipment()
		. = ..()
		if (isflockmob(src.owner.current))
			var/mob/living/intangible/flock/flockmob = src.owner.current
			flockmob.flock.flockmind_mind = src.owner

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/flock, src)

	announce()
		. = ..()
		boutput(src.owner.current, "<B>You are a flockmind, the collective machine consciousness of a flock of drones! Your existence is tied to your flock! Ensure that it survives and thrives!</B>")
		boutput(src.owner.current, "<B>Silicon units are able to detect your transmissions and messages (with some signal corruption), so exercise caution in what you say.</B>")
		boutput(src.owner.current, "<B>On the flipside, you can hear silicon transmissions and all radio signals, but with heavy corruption.</B>")
