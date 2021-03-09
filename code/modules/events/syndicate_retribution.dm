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

		message_admins("Syndicate Weapon: Orion Retribution Device spawning in [T.loc]")

		if(!sword_summoned_before)
			new/obj/critter/sword(T)
			sword_summoned_before = true
			disabled = 1