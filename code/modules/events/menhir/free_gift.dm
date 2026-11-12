//pulled one out of cold storage for ya
/datum/random_event/menhir/gift
	name = "A Gift from the Crown"
	description = "Spawns a Precursor artifact. First use places it in a node if possible, second+ place it at an outreach point."
	message_delay = 3 MINUTES
	weight = 150
	var/has_noded = FALSE

	event_effect()
		///Site the gift artifact spawns at; will be in a "node" (outer ball) one time if it can, adding a door to it and disqualifying node from further events
		var/turf/nodelandmark
		///Tag for the node the event is occurring in, when a node is selected
		var/node_tag = null
		///List of eligible walls in node mode; divided by relative position.
		var/list/eligible_walls = list("S" = list(), "N" = list(), "E" = list(), "W" = list())
		///When we've populated a direction with at least one wall from each facing, we're good to go
		var/list/eligibility_flags = 0

		var/can_node = TRUE
		if(src.has_noded) can_node = FALSE
		else if(!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) can_node = FALSE

		if(!can_node) //outreach mode: drop it somewhere on the station
			nodelandmark = pick_landmark(LANDMARK_MENHIR_OUTREACH)
			if (!istype(nodelandmark,/turf/simulated/floor) || is_blocked_turf(nodelandmark))
				nodelandmark = get_open_outreach()
				if(!nodelandmark)
					logTheThing(LOG_DEBUG, null, "Menhir event [src.name] couldn't find an outreach turf; aborting event.")
					message_admins("Menhir event [src.name] couldn't find an outreach turf; aborting event.")
					return
		else //node mode: pick a ball, any ball
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

		if(node_tag)
			var/facing_dir = pick("S","N","E","W")

			for(var/turf/wallturf in eligible_walls[facing_dir])
				var/save_dir = wallturf.icon_state
				var/obj/newdoor = new /obj/machinery/door/unpowered/blue(wallturf)
				if (save_dir == "interior-3") //vertical wall detection
					newdoor.dir = 4

			landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node in node spawns, so future events won't select it again
		else
			showswirl(nodelandmark)
		Artifact_Spawn(nodelandmark,"precursor")
		src.localize_reading(nodelandmark)

		message_delay = rand(2 SECONDS, 4 SECONDS)
		..() //don't send out the message until we have confirmed we can do the event

		if(node_tag)
			logTheThing(LOG_STATION, null, "Menhir event [src.name] at [node_tag] arm - [log_loc(nodelandmark)]")
			message_admins("Menhir event [src.name] triggered at [node_tag] arm - [log_loc(nodelandmark)]")
		else
			logTheThing(LOG_STATION, null, "Menhir event [src.name] (out-of-node) at [log_loc(nodelandmark)]")
			message_admins("Menhir event [src.name] triggered (out-of-node) - [log_loc(nodelandmark)]")

		src.weight = 50 //After we've had one artifact, weight it down
		src.has_noded = TRUE //and avoid using up scarce nodes
