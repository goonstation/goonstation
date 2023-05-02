/datum/antagonist/slasher
	id = ROLE_SLASHER
	display_name = "slasher"

	give_equipment()
		var/mob/current_mob = src.owner.current
		var/mob/living/carbon/human/slasher/slasher_mob = new/mob/living/carbon/human/slasher(get_turf(current_mob))
		src.owner.transfer_to(slasher_mob)
		qdel(current_mob)

	remove_equipment()
		var/mob/current_mob = src.owner.current
		src.owner.current.ghostize()
		qdel(current_mob)

	relocate()
		var/turf/T = get_turf(src.owner.current)
		if (!(T && isturf(T)) || (T.z != Z_LEVEL_STATION))
			var/spawn_loc = pick_landmark(LANDMARK_LATEJOIN, locate(1, 1, Z_LEVEL_STATION))
			if (spawn_loc)
				src.owner.current.set_loc(spawn_loc)
			else
				src.owner.current.z = Z_LEVEL_STATION
		else
			src.owner.current.set_loc(T)
