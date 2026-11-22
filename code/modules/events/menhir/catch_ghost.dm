//there are wisps of consciousness around. let's see if we can entice one
/datum/random_event/menhir/dreamcatcher
	name = "Thoughts Which Fall Like Rain"
	description = "Summons a 'dreamcatcher' capable of capturing one ghost and ensouling it into a Precursor probe with its own unique rules."
	announcement_style = EVENT::MENHIR::NOTIFY::NONE

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (game_stats.GetStat("playerdeaths") < 1) //none have fallen, none may return
				. = FALSE
			if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //if no eligible nodes remain, do not trigger event
				. = FALSE

	event_effect()
		///Site the dreamcatcher spawns at; selects one of the outer nodes, adding a door to it and disqualifying it from further events
		var/turf/nodelandmark
		///Tag for the node the event is occurring in
		var/node_tag = null
		///List of eligible walls; divided by relative position.
		var/list/eligible_walls = list("S" = list(), "N" = list(), "E" = list(), "W" = list())
		///When we've populated a direction with at least one wall from each facing, we're good to go
		var/list/eligibility_flags = 0

		if(!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) return //manual call safeguard

		nodelandmark = pick_landmark(LANDMARK_MENHIR_NODE)
		node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

		for (var/turf/T in landmarks[LANDMARK_MENHIR_DOOR])
			if (landmarks[LANDMARK_MENHIR_DOOR][T] == node_tag)
				//categorize nodes based on positional block (set up this way to allow east/west entrance sides to be more than 1 door)
				if(T.x > nodelandmark.x)
					eligible_walls["E"] += T
					eligibility_flags |= EAST
				else if(T.x < nodelandmark.x)
					eligible_walls["W"] += T
					eligibility_flags |= WEST
				else
					if(T.y > nodelandmark.y)
						eligible_walls["N"] += T
						eligibility_flags |= NORTH
					else
						eligible_walls["S"] += T
						eligibility_flags |= SOUTH

		if (eligibility_flags < (NORTH|SOUTH|EAST|WEST))
			logTheThing(LOG_DEBUG, null, "Menhir event [src.name] didn't find all directions for the [node_tag] node! This shouldn't happen.")
			message_admins("Menhir event [src.name] didn't find all directions for the [node_tag] node! This shouldn't happen. Aborting event")
			return

		if(prob(60))
			playsound(nodelandmark, 'sound/effects/ring_happi.ogg', 65, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(nodelandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 65, 0, extrarange = 24)

		var/facing_dir = pick("S","N","E","W")

		for(var/turf/wallturf in eligible_walls[facing_dir])
			var/save_dir = wallturf.icon_state
			var/obj/newdoor = new /obj/machinery/door/unpowered/blue(wallturf)
			if (save_dir == "interior-3") //vertical wall detection
				newdoor.dir = 4

		for(var/obj/effects/menhir_fog/O in range(1,nodelandmark)) //stick out to ghosts
			animate(O, alpha = 0, time = 3 SECONDS)
			SPAWN(4 SECONDS)
				qdel(O)

		SPAWN(5 SECONDS)
			for(var/obj/effects/menhir_fog/O in orange(2,nodelandmark))
				O.UpdateIcon()

		landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node in node spawns, so future events won't select it again

		new /obj/dreamcatcher(nodelandmark)

		..()

		logTheThing(LOG_STATION, null, "Menhir event [src.name] at [node_tag] arm - [log_loc(nodelandmark)]")
		message_admins("Menhir event [src.name] triggered at [node_tag] arm - [log_loc(nodelandmark)]")
