/obj/landmark/prefab_load
	deleted_on_start = FALSE
	add_to_landmarks = FALSE

	New()
		..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		..()

/obj/machinery/devtest_prefab_loader
	name = "Prefab Request Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "teleport"
	desc = "A computer for requesting the placement of a devtest prefab"
	density = TRUE
	anchored = ANCHORED

	attack_hand(mob/user)
		. = ..()
		var/choice = tgui_input_list(user, "Choose a prefab. Stay outside the load zone!", "Prefab Selector", recursive_flist("assets/maps/devtest_prefabs"))
		if (!choice) return
		for_by_tcl(landmark, /obj/landmark/prefab_load)
			if (air_master?.is_busy)
				boutput(user, SPAN_ALERT("WAITING FOR AIR PROCESSING TO FINISH TO NOT BREAK SHIT."))
				UNTIL(!air_master?.is_busy, 0)
			boutput(user, SPAN_ALERT("STARTING."))
			for (var/turf/T as anything in block(landmark.x+1, landmark.y+1, landmark.z, landmark.x+19, landmark.y+19, landmark.z))
				T.ReplaceWithSpaceForce()
				for (var/X in T)
					qdel(X)

			var/dmm_suite/asset_loader = new
			boutput(user, SPAN_ALERT("LOADING PREFAB."))
			asset_loader.read_map(file2text(choice), landmark.x+1, landmark.y+1, landmark.z)
			for(var/turf/T as anything in block(landmark.x+1, landmark.y+1, landmark.z, landmark.x+19, landmark.y+19, landmark.z))
				for(var/obj/O in T)
					O.initialize(FALSE)
					O.UpdateIcon()
			boutput(user, SPAN_ALERT("PREFAB LOADED."))
