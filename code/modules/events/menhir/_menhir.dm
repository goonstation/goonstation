///List of people who are present on station for events, updated once a cycle for events to check. SHOULD NOT BE ACCESSED DIRECTLY - use helper.
var/global/list/menhir_local_event_candidates = list()
///Time at which the list of people present on station for events was last updated.
var/global/menhir_candidates_last_built = 0

ABSTRACT_TYPE(/datum/random_event/menhir)
/datum/random_event/menhir
	centcom_headline = "Artifact Condition Advisory"
	centcom_message = "A spike in electromagnetic activity from TOREADOR-7I-22408 was recently recorded. Personnel on site are advised to monitor artifact for changes in structure or activity."
	centcom_origin = ALERT_ANOMALY
	///Events may be entirely unannounced, directed only to the science team by PDA, or broadcast stationwide.
	var/announcement_style = EVENT::MENHIR::NOTIFY::PDA

	New()
		. = ..()
		if(src.announcement_style != EVENT::MENHIR::NOTIFY:GLOBAL)
			src.centcom_headline = null //deactivates announcement

	event_effect()
		if(src.announcement_style == EVENT::MENHIR::NOTIFY::PDA)
			SPAWN(src.message_delay)
				var/obj/machinery/networked/radio/sciradio = locate("lrad_bouncepoint")
				if(sciradio && istype(sciradio) && sciradio.powered())
					var/datum/signal/pdaSignal = get_free_signal()
					pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="LRAD-TOREADOR", "group"=list(MGD_RESEARCH), "sender"="00000000", "message"="[src.centcom_message]")
					radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)
		. = ..()

	///Outreach turfs are locations that start open and are suitable for an event to occur at. Events should pick and check one blindly at first, and fall back to this if necessary.
	proc/get_open_outreach()
		. = FALSE
		var/list/eligible_sites = list()
		for (var/turf/T in landmarks[LANDMARK_MENHIR_OUTREACH])
			if(istype(T,/turf/simulated/floor) && !is_blocked_turf(T))
				eligible_sites += T
		if(length(eligible_sites))
			. = pick(eligible_sites)

	///For events localized to a particular site, update the message to direct people towards the site. Somewhat fuzzy unless accuracy is guaranteed.
	proc/localize_reading(var/atom/target,var/always_accurate = FALSE)
		///Text given to orientate the announcement.
		var/sumtext = "spinal"
		///X-axis report text (may remain null).
		var/x_string = null
		///Y-axis report text (may remain null).
		var/y_string = null
		///X-axis distance (east-west) between the center of the Crown and the incidence site.
		var/x_main = clamp(target.x - EVENT::MENHIR::CORE_X, -50, 50)
		///Y-axis distance (north-south) between the center of the Crown and the incidence site.
		var/y_main = clamp(target.y - EVENT::MENHIR::CORE_Y, -50, 50)

		//Tie odds of successful directional indication to the axial distance, with 100% base certainty of the localization at 50+ tiles from center.
		//This sometimes will fail despite that, but never explicitly direct people in the opposite direction.
		var/x_positive_clamped = max(0,x_main) * 2
		var/x_negative_clamped = max(0,-x_main) * 2
		var/y_positive_clamped = max(0,y_main) * 2
		var/y_negative_clamped = max(0,-y_main) * 2

		//Y string first (directional convention)
		if(prob(10) && !always_accurate) //10% chance for localization on the axis to fail
			y_string = null
		else if(prob(y_positive_clamped) || (y_positive_clamped && always_accurate))
			y_string = "north"
		else if(prob(y_negative_clamped) || (y_negative_clamped && always_accurate))
			y_string = "south"

		//X string after
		if(prob(10) && !always_accurate) //10% chance for localization on the axis to fail
			x_string = null
		else if(prob(x_positive_clamped) || (x_positive_clamped && always_accurate))
			x_string = "east"
		else if(prob(x_negative_clamped) || (x_negative_clamped && always_accurate))
			x_string = "west"

		//pull them all together
		if (x_string || y_string)
			sumtext = ""
			if(y_string) sumtext += y_string
			if(x_string) sumtext += x_string

		src.centcom_message = "A spike in electromagnetic activity from TOREADOR-7I-22408 was recently recorded, with notable projection on the [sumtext] axis."
		if(!always_accurate)
			src.centcom_message += " Structural alteration is probable, and may not be confined to the artifact itself."
