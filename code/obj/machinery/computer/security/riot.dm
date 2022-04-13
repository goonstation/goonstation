/obj/machinery/computer/riotgear
	name = "Armory Authorization"
	icon_state = "drawbr"
	density = 0
	glow_in_dark_screen = TRUE
	var/auth_need = 3.0
	var/list/authorized
	var/list/authorized_registered = null
	var/net_id = null
	var/control_frequency = "1461"
	var/radiorange = 3
	desc = "Use this computer to authorize security access to the Armory. You need an ID with security access to do so."

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

		src.authorized = null
		src.authorized_registered = null

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
		if(src.authed)

			logTheThing("station", usr, null, "unauthorized armory access")
			authed = 0
			src.ClearSpecificOverlays("screen_image")
			icon_state = "drawbr"
			src.UpdateIcon()

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
				O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[author] request accepted. [src.auth_need - src.authorized.len] authorizations needed until Armory is opened.\"</span></span>", 2)
		else
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[src.auth_need - src.authorized.len] authorizations needed until Armory is opened.\"</span></span>", 2)


/obj/machinery/computer/riotgear/attack_hand(mob/user as mob)
	if (ishuman(user))
		return src.Attackby(user:wear_id, user)
	..()

//kinda copy paste from shuttle auth :)
/obj/machinery/computer/riotgear/attackby(var/obj/item/W as obj, var/mob/user as mob)
	interact_particle(user,src)
	if(status & (BROKEN|NOPOWER))
		return
	if (!user)
		return

	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (!istype(W, /obj/item/card/id))
		boutput(user, "No ID given.")
		return

	if (!W:access) //no access
		src.add_fingerprint(user)
		boutput(user, "The access level of [W] is not high enough.")
		return

	var/list/cardaccess = W:access
	if(!istype(cardaccess, /list) || !length(cardaccess)) //no access
		src.add_fingerprint(user)
		boutput(user, "The access level of [W] is not high enough.")
		return

	if(!(access_securitylockers in W:access)) //doesn't have this access
		src.add_fingerprint(user)
		boutput(user, "The access level of [W] is not high enough.")
		return

	if(authed && (!(access_maxsec in W:access)))
		boutput(user, "Armory has already been authorized!")
		return

	if(authed && (access_maxsec in W:access))
		var/choice = alert(user, "Would you like to unauthorize security's access to riot gear?", "Armory Unauthorization", "Unauthorize", "No")
		if(BOUNDS_DIST(user, src) > 0) return
		src.add_fingerprint(user)
		switch(choice)
			if("Unauthorize")
				if(GET_COOLDOWN(src, "unauth"))
					boutput(user, "<span class='alert'> The armory computer cannot take your commands at the moment! Wait [GET_COOLDOWN(src, "unauth")/10] seconds!</span>")
					playsound( src.loc,"sound/machines/airlock_deny.ogg", 10, 0 )
					return
				if(!ON_COOLDOWN(src, "unauth", 5 MINUTES))
					unauthorize()
					playsound(src.loc,"sound/machines/chime.ogg", 10, 1)
					boutput(user,"<span class='notice'> The armory's equipments have returned to having their default access!</span>")
					return
			if("No")
				return

	if (!src.authorized)
		src.authorized = list()
		src.authorized_registered = list()

	var/choice = alert(user, text("Would you like to authorize access to riot gear? [] authorization\s are still needed.", src.auth_need - src.authorized.len), "Armory Auth", "Authorize", "Repeal")
	if(BOUNDS_DIST(user, src) > 0 || src.authorized)
		return
	src.add_fingerprint(user)
	switch(choice)
		if("Authorize")
			if (user in src.authorized)
				boutput(user, "You have already authorized! [src.auth_need - src.authorized.len] authorizations from others are still needed.")
				return
			if (W:registered in src.authorized_registered)
				boutput(user, "This ID has already issued an authorization! [src.auth_need - src.authorized.len] authorizations from others are still needed.")
				return
			if (access_maxsec in W:access)
				authorize()
				return

			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (H.bioHolder.Uid in src.authorized)
					boutput(user, "You have already authorized - fingerprints on file! [src.auth_need - src.authorized.len] authorizations from others are still needed.")
					return
				src.authorized += H.bioHolder.Uid
			else
				src.authorized += user //authorize by USER, not by registered ID. prevent the captain from printing out 3 unique ID cards and getting in by themselves.
			src.authorized_registered += W:registered

			if (src.authorized.len < auth_need)
				print_auth_needed(user)
			else
				authorize()

		if("Repeal")

			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				src.authorized -= H.bioHolder.Uid
			else
				src.authorized -= user
			src.authorized_registered -= W:registered

			print_auth_needed(user)
