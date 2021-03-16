#define ALIVE_ANTAGS_THRESHOLD 0.06 //value copied from antag spawn event
#define ALIVE_CREW_THRESHOLD 30
/datum/random_event/major/syndicate_retribution
	name = "Syndicate Retribution"
	required_elapsed_round_time = 40 MINUTES
	weight = 88

#ifdef RP_MODE
	disabled = 1
#endif

	event_effect(var/source,var/turf/T,var/delay,var/duration)
		..()

		if (!istype(T,/turf/))
			T = pick_landmark(LANDMARK_BLOBSTART)
			if(!T)
				message_admins("The Syndicate Retribution event failed to spawn the SWORD (no blobstart landmark found)")
				return

		if (get_alive_antags_percentage() >= ALIVE_ANTAGS_THRESHOLD)
			message_admins("The Syndicate Retribution event failed to spawn the SWORD (too many antags)")
			return

		var/player_count = 0
		for (var/client/cl as anything in clients)
			var/mob/living/L = cl.mob
			if(!istype(L) || isdead(L))
				continue
			player_count++

		if (player_count < ALIVE_CREW_THRESHOLD)
			message_admins("The Syndicate Retribution event failed to spawn the SWORD (not enough crew members)")
			return

		message_admins("Syndicate Weapon: Orion Retribution Device spawning in [T.loc]")
		logTheThing("admin", null, null, "Setting up SWORD event. Source: [source ? "[source]" : "random"]")

		if(!sword_summoned_before)
			new/obj/critter/sword(T)
			sword_summoned_before = true
			disabled = 1

#undef ALIVE_ANTAGS_THRESHOLD
#undef ALIVE_CREW_THRESHOLD
