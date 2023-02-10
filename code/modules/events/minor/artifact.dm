/datum/random_event/minor/artifact
	name = "Artifact Spawn"

	event_effect()
		..()
		var/turf/T = pick_landmark(LANDMARK_BLOBSTART)
		if(!T)
			return
		Artifact_Spawn(T)
		T.visible_message("<span class='alert'><b>An artifact suddenly warps into existence!</b></span>")
		playsound(T, 'sound/effects/teleport.ogg', 50,1)

		var/obj/decal/teleport_swirl/swirl = new /obj/decal/teleport_swirl
		swirl.set_loc(T)
		SPAWN(1.5 SECONDS)
			qdel(swirl)
		return
