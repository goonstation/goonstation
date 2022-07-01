/obj/machinery/computer/riotgear
	name = "Armory Authorization"
	desc = "Use this computer to authorize security access to the Armory. You need an ID with security access to do so."
	icon_state = "drawbr"
	density = 0
	glow_in_dark_screen = TRUE
	var/auth_need = 3.0
	var/net_id = null
	var/control_frequency = "1461"
	var/radiorange = 3

	var/list/authorisations = list()
	var/hasID = FALSE
	var/hasAccess = FALSE
	var/mismatchedAppearance = FALSE
	var/mismatchedID = FALSE
	var/maxSecAccess = FALSE
	var/existingAuthorisation = FALSE
	var/nameOnFile = FALSE
	var/printOnFile = FALSE

	light_r =1
	light_g = 0.3
	light_b = 0.3

	var/authed = 0
	var/area/armory_area

	initialize()
		armory_area = get_area_by_type(/area/station/ai_monitored/armory)

		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, control_frequency)

		/*for (var/obj/machinery/door/airlock/D in armory_area)
			if (D.has_access(access_maxsec))
				D.no_access = 1
		*/
		..()

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption || signal.transmission_method != TRANSMISSION_RADIO)
			return

		var/target = signal.data["sender"]
		if (!target) return

		if (signal.data["address_1"] != src.net_id)
			if (signal.data["address_1"] == "ping")
				var/datum/signal/pingsignal = get_free_signal()
				pingsignal.source = src
				pingsignal.data["device"] = "ARM_AUTH"
				pingsignal.data["netid"] = src.net_id
				pingsignal.data["sender"] = src.net_id
				pingsignal.data["address_1"] = target
				pingsignal.data["command"] = "ping_reply"

				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pingsignal, radiorange)
			return

		var/datum/signal/returnsignal = get_free_signal()
		returnsignal.source = src
		returnsignal.data["sender"] = src.net_id
		returnsignal.data["address_1"] = target
		switch(signal.data["command"])
			if ("help")
				if (!signal.data["topic"])
					returnsignal.data["description"] = "Armory Authorization Computer - allows for lowering of armory access level to SECURITY. Wireless authorization requires NETPASS_HEADS"
					returnsignal.data["topics"] = "authorize,unauthorize"
				else
					returnsignal.data["topic"] = signal.data["topic"]
					switch (lowertext(signal.data["topic"]))
						if ("authorize")
							returnsignal.data["description"] = "Authorizes armory access. Requires NETPASS_HEADS. Requires close range transmission."
							returnsignal.data["args"] = "acc_code"
						if ("unauthorize")
							returnsignal.data["description"] = "Unauthorizes armory access. Requires NETPASS_HEADS. Requires close range transmission."
							returnsignal.data["args"] = "acc_code"
						else
							returnsignal.data["description"] = "ERROR: UNKNOWN TOPIC"
			if ("authorize")
				if(!IN_RANGE(signal.source, src, radiorange))
					returnsignal.data["command"] = "nack"
					returnsignal.data["data"] = "outofrange"
				else if (signal.data["acc_code"] == netpass_heads)
					returnsignal.data["command"] = "ack"
					returnsignal.data["acc_code"] = netpass_security
					returnsignal.data["data"] = "authorize"
					authorize()
				else
					returnsignal.data["command"] = "nack"
					returnsignal.data["data"] = "badpass"
			if ("unauthorize")
				if(!IN_RANGE(signal.source, src, radiorange))
					returnsignal.data["command"] = "nack"
					returnsignal.data["data"] = "outofrange"
				else if (signal.data["acc_code"] == netpass_heads)
					returnsignal.data["command"] = "ack"
					returnsignal.data["acc_code"] = netpass_security
					returnsignal.data["data"] = "unauthorize"
					unauthorize()
				else
					returnsignal.data["command"] = "nack"
					returnsignal.data["data"] = "badpass"
			else
				return //COMMAND NOT RECOGNIZED
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, returnsignal, radiorange)

	power_change()
		..()
		if(powered() && authed)
			src.ClearSpecificOverlays("screen_image")
			src.icon_state = "drawbr-alert"
			src.UpdateIcon()

	proc/authorize()
		if(src.authed)
			return

		logTheThing("station", usr, null, "authorized armory access")
		command_announcement("<br><b><span class='alert'>Armory weapons access has been authorized for all security personnel.</span></b>", "Security Level Increased", "sound/misc/announcement_1.ogg")
		authed = 1
		src.ClearSpecificOverlays("screen_image")
		src.icon_state = "drawbr-alert"
		src.UpdateIcon()

		for (var/obj/machinery/door/airlock/D in armory_area)
			if (D.has_access(access_maxsec))
				D.req_access = list(access_security)
				//D.no_access = 0
			LAGCHECK(LAG_REALTIME)

		if (armory_area)
			for(var/obj/O in armory_area)
				if (istype(O,/obj/storage/secure/crate))
					O.req_access = list(access_security)
				else if (istype(O,/obj/machinery/vending))
					O.req_access = list(access_security)

				LAGCHECK(LAG_REALTIME)

	proc/unauthorize()
		if(!src.authed)
			return

		logTheThing("station", usr, null, "unauthorized armory access")
		authed = 0
		authorisations = list()
		src.ClearSpecificOverlays("screen_image")
		icon_state = "drawbr"
		src.UpdateIcon()

		ON_COOLDOWN(src, "deauth", 5 MINUTES)

		for (var/obj/machinery/door/airlock/D in armory_area)
			if (D.has_access(access_security))
				D.req_access = list(access_maxsec)
			LAGCHECK(LAG_REALTIME)

		if (armory_area)
			for(var/obj/O in armory_area)
				if (istype(O,/obj/storage/secure/crate))
					O.req_access = list(access_maxsec)
				else if (istype(O,/obj/machinery/vending))
					O.req_access = list(access_maxsec)

			LAGCHECK(LAG_REALTIME)

	proc/print_auth_needed(var/mob/author)
		if (author)
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[author] request accepted. [src.auth_need - src.authorisations.len] authorizations needed until Armory is opened.\"</span></span>", 2)
		else
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[src.auth_need - src.authorisations.len] authorizations needed until Armory is opened.\"</span></span>", 2)

	proc/checkRequirements(var/mob/user, var/obj/item/W)
		// Reset the variables.
		hasID = FALSE
		hasAccess = FALSE
		mismatchedAppearance = FALSE
		mismatchedID = FALSE
		maxSecAccess = FALSE
		existingAuthorisation = FALSE
		nameOnFile = FALSE
		printOnFile = FALSE

		if (W == null) // No ID.
			return

		if (!istype(W, /obj/item/card/id)) // No ID.
			return
		else
			hasID = TRUE

		var/obj/item/card/id/ID = W

		if (!ID:access) // No access.
			return

		var/list/cardaccess = ID:access
		if (!istype(cardaccess, /list) || !length(cardaccess)) // No access.
			return

		if (access_securitylockers in ID:access) // Has Security Equipment access.
			hasAccess = TRUE

		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.name != strip_html_tags(H.get_heard_name())) // User's appearance must match their voice.
				mismatchedAppearance = TRUE
				boutput(user, "[H.name] | [strip_html_tags(H.get_heard_name())]")
				return

		if (user.name != ID.registered) // Player name must match their ID's registered name.
			mismatchedID = TRUE
			return

		if (access_maxsec in ID:access) // Are they the HoS, or do they have equivalent access?
			maxSecAccess = TRUE

		if (user.name in authorisations) // Check for authorisations that use the player's name.
			nameOnFile = TRUE

		for (var/x in authorisations)
			var/list/params = authorisations[x]
			if (user.bioHolder.fingerprints == params["prints"]) // Check for authorisations that use the player's fingerprints.
				printOnFile = TRUE
				break

		// If both their name and fingerprint are on file, then they may repeal their authorisation.
		// If either only their name or fingerprint are on file, and not the other, then the computer will deny them access.
		if (nameOnFile == TRUE && printOnFile == TRUE)
			existingAuthorisation = TRUE

/obj/machinery/computer/riotgear/attack_hand(mob/user)
	if (ishuman(user))
		return src.Attackby(user:wear_id, user)
	..()

/obj/machinery/computer/riotgear/attackby(var/obj/item/W, var/mob/user)

	interact_particle(user,src)
	src.add_fingerprint(user)

	if(status & (BROKEN|NOPOWER))
		return
	if (!user)
		return

	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card

	checkRequirements(user, W)

	return src.ui_interact(user)

/obj/machinery/computer/riotgear/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RiotGear")
		ui.open()

/obj/machinery/computer/riotgear/ui_data(mob/user)
	. = list(
		"authed" = authed,
		"authorisations" = authorisations,
		"hasID" = hasID,
		"hasAccess" = hasAccess,
		"mismatchedAppearance" = mismatchedAppearance,
		"mismatchedID" = mismatchedID,
		"maxSecAccess" = maxSecAccess,
		"existingAuthorisation" = existingAuthorisation,
		"nameOnFile" = nameOnFile,
		"printOnFile" = printOnFile,
		"cooldown" = GET_COOLDOWN(src, "deauth")
	)

/obj/machinery/computer/riotgear/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	var/mob/user = ui.user
	var/obj/item/W
	if (ishuman(user))
		W = user:wear_id
	if (W == null)
		W = user.equipped()
	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card

	checkRequirements(user, W)

	if (hasID != TRUE || hasAccess != TRUE || mismatchedAppearance != FALSE || mismatchedID != FALSE || nameOnFile != printOnFile || GET_COOLDOWN(src, "deauth")) // Most of the logic is handled by RiotGear.js, however I feel it prudent to check here too.
		return

	var/obj/item/card/id/ID = W

	switch (action)
		if ("HoS-Authorise")
			if (maxSecAccess != TRUE)
				return

			authorisations[user.name] = list("name" = user.name, "rank" = ID:assignment, "prints" = user.bioHolder.fingerprints)

			authorize()
			. = TRUE

		if ("Authorise")
			if (existingAuthorisation != FALSE)
				return

			authorisations[user.name] = list("name" = user.name, "rank" = ID:assignment, "prints" = user.bioHolder.fingerprints)

			if (src.authorisations.len < auth_need)
				print_auth_needed(user)
			else
				authorize()
			. = TRUE

		if ("Repeal")
			if (existingAuthorisation != TRUE)
				return

			authorisations.Remove(user.name)

			print_auth_needed(user)
			. = TRUE

		if ("Deauthorise")
			if (maxSecAccess != TRUE)
				return

			unauthorize()
			. = TRUE

	checkRequirements(user, ID)
