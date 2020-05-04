/datum/random_event/minor/artifact
	name = "Artifact Spawn"

	event_effect()
		..()
		if (blobstart.len < 1)
			return
		var/turf/T = pick(blobstart)
		Artifact_Spawn(T)
		T.visible_message("<span class='alert'><b>An artifact suddenly warps into existence!</b></span>")
		playsound(T,"sound/effects/teleport.ogg",50,1)

		var/obj/decal/teleport_swirl/swirl = unpool(/obj/decal/teleport_swirl)
		swirl.set_loc(T)
		SPAWN_DBG(1.5 SECONDS)
			pool(swirl)
		return
