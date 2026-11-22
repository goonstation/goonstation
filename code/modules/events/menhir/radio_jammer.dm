//too much, too much. too little, too little. a disharmony grows
/datum/random_event/menhir/schism
	name = "A Schism in the Song"
	description = "Opens a pale anomaly in a Crown node, which creates an expanding field of radio suppression. It must be closed by interdiction."
	message_delay = 1 MINUTE
	weight = 10

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
		///List of eligible walls in node mode; divided by relative position.
		var/list/eligible_walls = list("S" = list(), "N" = list(), "E" = list(), "W" = list())
		///When we've populated a direction with at least one wall from each facing, we're good to go
		var/list/eligibility_flags = 0

		if(!landmarks[LANDMARK_MENHIR_NODE] || length(landmarks[LANDMARK_MENHIR_NODE]) < 1) //fallback mode: pick a curated station tile instead
			logTheThing(LOG_DEBUG, null, "Menhir event [src.name] couldn't find a fallback turf after all nodes expended; aborting event.")
			message_admins("Menhir event [src.name] couldn't find a fallback turf after all nodes expended; aborting event.")
			return

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

		landmarks[LANDMARK_MENHIR_NODE].Remove(nodelandmark) //"expend" the node in node spawns, so future events won't select it again

		new /obj/anomaly/pale(nodelandmark)

		playsound(nodelandmark, 'sound/ambience/industrial/Precursor_Drone3.ogg', 65, 0, extrarange = 30)
		SPAWN(7)
			playsound_global(Z_LEVEL_STATION, 'sound/voice/creepywhisper_3.ogg', 20)

		var/facing_dir = pick("S","N","E","W")

		for(var/turf/wallturf in eligible_walls[facing_dir])
			var/save_dir = wallturf.icon_state
			var/obj/newdoor = new /obj/machinery/door/unpowered/blue(wallturf)
			if (save_dir == "interior-3") //vertical wall detection
				newdoor.dir = 4

		src.localize_reading(nodelandmark,TRUE)
		src.centcom_message += " All signal capture, including non-anomalous, has dropped precipitously since event detection; immediate investigation is advised."

		message_delay = rand(15 SECONDS, 35 SECONDS)
		..() //don't send out the message until we have confirmed we can do the event

		logTheThing(LOG_STATION, null, "Menhir event [src.name] at [node_tag] arm - [log_loc(nodelandmark)]")
		message_admins("Menhir event [src.name] triggered at [node_tag] arm - [log_loc(nodelandmark)]")



/obj/anomaly/pale
	name = "pale anomaly"
	desc = "The air around it shudders as though caught in a spider's web."
	icon = 'icons/effects/electile.dmi'
	icon_state = "6b"
	color = "#CCCCEE"
	alpha = 0
	plane = PLANE_NOSHADOW_BELOW
	anchored = ANCHORED_ALWAYS
	event_handler_flags = IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
	has_processing_loop = TRUE
	density = FALSE
	HELP_MESSAGE_OVERRIDE("It seems strangely familiar. Maybe somebody else could take a better guess...")

	var/effect_tick = 5 //! how many process ticks to wait before an expansion wave
	var/anomaly_strength = 5 //! how strong/wide the anomaly currently is (signals within radius equal to strength are jammed)
	var/max_anomaly_strength = 30 //! how strong/wide the anomaly can get, at maximum (interdictors can whittle away at this)

	var/obj/effect/pale_shroud/shroud = null

/obj/anomaly/pale/New()
	..()
	src.shroud = new /obj/effect/pale_shroud(src)
	src.vis_contents += src.shroud
	animate(src, alpha = 66, time = 20, easing = LINEAR_EASING)
	START_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)

	for_clients_in_range(C, get_turf(src), 25)
		boutput(C, SPAN_ALERT("A strange tremor [pick("propagates", "shudders", "resonates")] through the air. Something is wrong."))
		shake_camera(C.mob, 6, 1)

/obj/anomaly/pale/proc/shut_anomaly()
	playsound(src.loc, 'sound/musical_instruments/artifact/Artifact_Precursor_3.ogg', 60, 0)
	var/list/parting_messages = list(
		"« 96 77 97 76 96 66 23 38 17 87 97 38 23 96 27 48 23 96 68 56 27 23 86 96 67 66 58 97 28 48 «",
		"« 38 28 96 28 56 96 66 96 87 97 48 23 28 58 97 98 23 96 28 56 23 86 96 38 38 96 67 66 «",
		"« 96 76 56 96 08 23 87 37 23 38 17 87 37 38 23 38 58 28 97 27 76 23 96 27 48 «",
		"« 87 37 56 17 56 23 27 48 56 96 28 66 23 38 78 56 28 86 23 17 87 97 38 23 28 58 97 «",
		"« 28 96 27 48 96 17 97 48 23 17 87 37 38 23 38 17 87 97 38 23 28 58 97 23 98 56 77 «",
	)
	for_clients_in_range(C, get_turf(src), 6)
		boutput(C, SPAN_DISARM(pick(parting_messages)))
		shake_camera(C.mob, 6, 1)
	src.effect_tick = 999
	animate(src, alpha = 200, time = 8, easing = BOUNCE_EASING | EASE_IN)
	SPAWN(1 SECOND)
		var/turf/nearby_spot = null
		for(var/D in alldirs)
			var/turf/proxturf = get_step(src,D)
			if(!is_blocked_turf(proxturf))
				nearby_spot = proxturf
				break
		if(nearby_spot)
			showswirl(nearby_spot)
			new /obj/item/raw_material/starstone(nearby_spot)
		animate(src, alpha = 0, time = 16, easing = BACK_EASING)
	SPAWN(3 SECONDS)
		qdel(src)

/obj/anomaly/pale/disposing()
	src.vis_contents -= src.shroud
	qdel(src.shroud)
	src.shroud = null
	STOP_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)
	. = ..()

/obj/anomaly/pale/process()
	. = ..()
	if (src.effect_tick > 0)
		src.effect_tick--
		return

	//Always gains anomaly strength each cycle, your interdictor(s) will need to overcome it either acutely or in the long haul
	src.anomaly_strength = min(src.anomaly_strength + rand(1,2), src.max_anomaly_strength)

	for_by_tcl(IX, /obj/machinery/interdictor)
		if (src.anomaly_strength <= 1) break
		///Estimate how strong of an interruption we can steadily apply, based on the amount of charge remaining in the internal capacitor
		var/target_strength = floor(IX.intcap.charge/2500)
		///Each interrupt strength costs 1,500 cell units and cuts 1 current and maximum anomaly strength
		var/interrupt_strength = clamp(target_strength,1,3)
		if (IX.expend_interdict(interrupt_strength*1500, src))
			if(src.max_anomaly_strength == initial(src.max_anomaly_strength)) //haven't interdicted yet
				playsound(IX,'sound/machines/alarm_a.ogg',20,FALSE,5,-1.5)
				IX.visible_message(SPAN_ALERT("<b>[IX] emits an unknown anomaly warning!</b>"))
			src.max_anomaly_strength = max(src.max_anomaly_strength - interrupt_strength, 1)
			src.anomaly_strength = max(src.anomaly_strength - interrupt_strength, src.max_anomaly_strength, 1)

	playsound(src.loc, "sound/items/pickup_[rand(1,3)].ogg", 50, 0, pitch = 0.2, extrarange = 24)

	var/kernel_alpha = 66 + (anomaly_strength*2)
	animate(src, alpha = kernel_alpha, time = 6 SECONDS, easing = LINEAR_EASING)

	var/anom_alpha = min(10 + (anomaly_strength*2), 45)
	var/anom_scale = 0.17 * anomaly_strength
	animate(src.shroud, alpha = anom_alpha, time = 6 SECONDS, transform = matrix()*anom_scale, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	if(src.anomaly_strength <= 1) src.shut_anomaly()

	src.effect_tick = initial(src.effect_tick) - rand(0,2)

/obj/anomaly/pale/get_help_message(dist, mob/user)
	. = ..()
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.traitHolder.hasTraitInList(list("training_scientist")))
			return "There's some sort of field emanating from this. It might be possible to close it with a <b>spatial interdictor</b>."
		if(H.traitHolder.hasTraitInList(list("training_engineer")))
			return "The ambient hum of the station is unnervingly dull. Seems like trouble - a <b>spatial interdictor</b> might be warranted."

/obj/effect/pale_shroud
	icon = 'icons/effects/320x320.dmi'
	icon_state = "background"
	pixel_x = -144
	pixel_y = -144
	color = "#a4aaac"
	blend_mode = BLEND_OVERLAY
	plane = OVERLAY_EFFECT_LAYER_BASE
	appearance_flags = RESET_COLOR | RESET_ALPHA
	alpha = 0
