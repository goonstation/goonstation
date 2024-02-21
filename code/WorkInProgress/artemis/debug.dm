// stuff for debugging Artemis, definitely don't use in real code lol
#if defined(DEBUG_ARTEMIS) || defined(FORCE_ARTEMIS_MODE)
/world/load_mode()
	. = ..()
	master_mode = "freeroam"
#endif

#if defined(DEBUG_ARTEMIS)
/mob/living/carbon/human/New()
	. = ..()
	SPAWN(4 SECONDS)
		if(src.client)
			for(var/turf/T in landmarks[LANDMARK_SHIPS])
				if(landmarks[LANDMARK_SHIPS][T] == "artemis")
					src.set_loc(locate(26, 289, T.z))
#endif
