//untangle the snare, untangle a prize
/datum/random_event/menhir/knot
	name = "A Receptacle of Reflection"
	description = "Summons a puzzle into one of the Crown's outer nodes. When untangled, a pedestal becomes available that duplicates a whitelisted item."
	message_delay = 3 MINUTES
	weight = 70

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //if no eligible nodes remain, do not trigger event
				. = FALSE

	event_effect()
		///Site the puzzle room spawns at
		var/turf/nodelandmark
		///Tag for the node the event is occurring in
		var/node_tag = null
		///List of walls associated with the node (we'll be installing doors onto these)
		var/list/walls_to_door = list()

		if(!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //fallback mode: pick a curated station tile instead
			logTheThing(LOG_DEBUG, null, "Menhir event [src.name] couldn't trigger due to a lack of available node; aborting event.")
			message_admins("Menhir event [src.name] couldn't trigger due to a lack of available node; aborting event.")
			return

		nodelandmark = pick_landmark(LANDMARK_MENHIR_NODE)
		node_tag = landmarks[LANDMARK_MENHIR_NODE][nodelandmark]

		for (var/turf/T in landmarks[LANDMARK_MENHIR_DOOR])
			if (landmarks[LANDMARK_MENHIR_DOOR][T] == node_tag)
				walls_to_door += T

		if (length(walls_to_door) < 4)
			logTheThing(LOG_DEBUG, null, "Menhir event [src.name] couldn't find expected door count! This shouldn't happen.")
			message_admins("Menhir event [src.name] couldn't find expected door count! This shouldn't happen. Aborting event")
			return

		landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node in node spawns, so future events won't select it again

		for(var/D in cardinal)
			var/turf/onestep = get_step(nodelandmark, D)
			var/turf/twostep = get_step(onestep, D)
			var/obj/precursor_puzzle/rotator/speen = new /obj/precursor_puzzle/rotator(twostep)
			speen.id = node_tag
			speen.dir = D
			speen.set_opacity(0)

		new /obj/rack/precursor/pressure/knot(nodelandmark)

		var/obj/precursor_puzzle/controller/hub = new /obj/precursor_puzzle/controller(nodelandmark)
		hub.pixel_y = -15
		hub.layer = 3.2
		hub.id = "[node_tag]"
		hub.tag = "controller_[node_tag]"
		hub.self_removing = TRUE
		hub.set_opacity(0)

		for(var/D in alldirs)
			var/turf/proxturf = get_step(nodelandmark,D)
			var/obj/precursor_puzzle/shield/S = new /obj/precursor_puzzle/shield(proxturf)
			S.id = node_tag
			S.dir = D

		if(prob(60))
			playsound(nodelandmark, 'sound/effects/ring_happi.ogg', 65, 0, pitch = 0.45, extrarange = 24)
		else
			playsound(nodelandmark, 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg', 65, 0, extrarange = 24)

		for(var/turf/wallturf in walls_to_door)
			var/save_dir = wallturf.icon_state
			var/obj/newdoor = new /obj/machinery/door/unpowered/blue(wallturf)
			if (save_dir == "interior-3") //vertical wall detection
				newdoor.dir = 4

		src.localize_reading(nodelandmark)

		message_delay = rand(2 MINUTES, 3 MINUTES)
		..() //don't send out the message until we have confirmed we can do the event

		logTheThing(LOG_STATION, null, "Menhir event [src.name] at [node_tag] arm - [log_loc(nodelandmark)]")
		message_admins("Menhir event [src.name] triggered at [node_tag] arm - [log_loc(nodelandmark)]")
