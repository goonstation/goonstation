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
	var/list/authorisedIDs = list()

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
		authorisedIDs = list()
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

	proc/checkRequirements(var/mob/user)
		var/hasID = FALSE
		var/hasAccess = FALSE
		var/maxSecAccess = FALSE
		var/existingAuthorisation = FALSE
		var/canAuth = FALSE
		var/nameOnFile = FALSE
		var/printOnFile = FALSE

		var/obj/item/W
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			W = H.wear_id
		if (W == null)
			W = user.equipped()
		if (istype(W, /obj/item/device/pda2))
			var/obj/item/device/pda2/PDA = W
			if (PDA.ID_card)
				W = PDA.ID_card

		if (W != null)
			if (istype(W, /obj/item/card/id)) // Has an ID.
				hasID = TRUE
				var/obj/item/card/id/ID = W

				if (access_securitylockers in ID.access) // Has Security Equipment access.
					hasAccess = TRUE

				if (access_maxsec in ID.access) // Are they the HoS, or do they have equivalent access?
					maxSecAccess = TRUE

		if (user in authorisations) // Check for authorisations made by the player.
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

		if (nameOnFile == printOnFile)
			canAuth = TRUE

		var/showModal = FALSE
		var/modalText = ""
		if (hasID != TRUE && authed != TRUE)
			modalText = "No ID Given!"
		if (hasAccess != TRUE && hasID == TRUE && authed != TRUE)
			modalText = "Insufficient Access Level!"
		if (GET_COOLDOWN(src, "deauth") && maxSecAccess == TRUE && authed == TRUE)
			modalText = " Before Any Commands May Be Accepted Again."
		if (maxSecAccess != TRUE && authed == TRUE)
			modalText = "Armoury Access Has Been Authorised!"

		if (modalText != "")
			showModal = TRUE
		else
			// Placed after the showModal value assign, as will only display when Auth/Repeal is clicked.
			if ((W in authorisedIDs) && existingAuthorisation != TRUE)
				canAuth = FALSE
				modalText = "Authorisation Already Issued By This ID!"
			if (canAuth != TRUE && maxSecAccess != TRUE)
				if (printOnFile != FALSE)
					modalText = "User Fingerprint ID Already On File!"
				if (nameOnFile != FALSE)
					modalText = "Authorisation Already Issued By User!"

		return list(
			"hasID" = hasID,
			"hasAccess" = hasAccess,
			"maxSecAccess" = maxSecAccess,
			"existingAuthorisation" = existingAuthorisation,
			"canAuth" = canAuth,
			"showModal" = showModal,
			"modalText" = modalText
			)

/obj/machinery/computer/riotgear/attack_hand(mob/user)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		return src.Attackby(H.wear_id, H)
	..()

/obj/machinery/computer/riotgear/attackby(var/obj/item/W, var/mob/user)

	interact_particle(user,src)
	src.add_fingerprint(user)

	if(status & (BROKEN|NOPOWER))
		return
	if (!user)
		return

	return src.ui_interact(user)

/obj/machinery/computer/riotgear/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RiotGear")
		ui.open()

/obj/machinery/computer/riotgear/ui_data(mob/user)
	var/list/reqs = checkRequirements(user)
	. = list(
		"authed" = authed,
		"authorisations" = authorisations,
		"hasID" = reqs["hasID"],
		"hasAccess" = reqs["hasAccess"],
		"maxSecAccess" = reqs["maxSecAccess"],
		"existingAuthorisation" = reqs["existingAuthorisation"],
		"canAuth" = reqs["canAuth"],
		"cooldown" = GET_COOLDOWN(src, "deauth"),
		"showModal" = reqs["showModal"],
		"modalText" = reqs["modalText"]
	)

/obj/machinery/computer/riotgear/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	var/mob/user = ui.user

	var/list/reqs = checkRequirements(user)

	if (reqs["hasID"] != TRUE || reqs["hasAccess"] != TRUE || reqs["canAuth"] != TRUE)
		return

	var/obj/item/W
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		W = H.wear_id
	if (W == null)
		W = user.equipped()
	if (istype(W, /obj/item/device/pda2))
		var/obj/item/device/pda2/PDA = W
		if (PDA.ID_card)
			W = PDA.ID_card
	var/obj/item/card/id/ID = W

	switch (action)
		if ("HoS-Authorise")
			if (reqs["maxSecAccess"] != TRUE)
				return

			authorisations[user] = list("name" = user, "rank" = ID.assignment, "prints" = user.bioHolder.fingerprints)
			authorisedIDs.Add(ID)

			authorize()
			. = TRUE

		if ("Authorise")
			if (reqs["existingAuthorisation"] != FALSE)
				return

			authorisations[user] = list("name" = user, "rank" = ID.assignment, "prints" = user.bioHolder.fingerprints)
			authorisedIDs.Add(ID)

			if (src.authorisations.len < auth_need)
				print_auth_needed(user)
			else
				authorize()
			. = TRUE

		if ("Repeal")
			if (reqs["existingAuthorisation"] != TRUE)
				return

			authorisations.Remove(user)
			authorisedIDs.Remove(ID)

			print_auth_needed(user)
			. = TRUE

		if ("Deauthorise")
			if (reqs["maxSecAccess"] != TRUE || GET_COOLDOWN(src, "deauth"))
				return

			unauthorize()
			. = TRUE
