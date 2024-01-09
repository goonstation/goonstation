/datum/random_event/minor/artifact
	name = "Artifact Spawn"

	event_effect()
		..()
		var/turf/T = pick_landmark(LANDMARK_BLOBSTART)
		if(!T)
			return
		Artifact_Spawn(T)
		T.visible_message(SPAN_ALERT("<b>An artifact suddenly warps into existence!</b>"))
		playsound(T, 'sound/effects/teleport.ogg', 50,TRUE)

		var/obj/decal/teleport_swirl/swirl = new /obj/decal/teleport_swirl
		swirl.set_loc(T)
		SPAWN(1.5 SECONDS)
			qdel(swirl)
		return
