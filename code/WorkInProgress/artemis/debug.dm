// stuff for debugging Artemis, definitely don't use in real code lol
#ifdef DEBUG_ARTEMIS
/world/load_mode()
	. = ..()
	master_mode = "freeroam"

/mob/living/carbon/human/New()
	. = ..()
	SPAWN_DBG(4 SECONDS)
		if(src.client)
			for(var/turf/T in landmarks[LANDMARK_SHIPS])
				if(landmarks[LANDMARK_SHIPS][T] == "artemis")
					src.set_loc(locate(26, 289, T.z))
#endif
