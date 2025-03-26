/obj/machinery/computer/riotgear
	name = "Armory Authorization"
	icon_state = "drawbr"
	density = 0
	glow_in_dark_screen = TRUE
	var/auth_need = 3
	var/list/authorized
	var/list/authorized_registered = null
	var/net_id = null
	var/control_frequency = FREQ_ARMORY
	var/radiorange = 3
	/// Was the armory authorized via authdisk?
	var/authdisk_authorized = FALSE
	desc = "Use this computer to authorize security access to the Armory. You need an ID with security access to do so."

	light_r =1
	light_g = 0.3
	light_b = 0.3

	var/authed = 0
	var/area/armory_area

	New()
		..()
		START_TRACKING

	initialize()
		armory_area = get_area_by_type(/area/station/ai_monitored/armory)

		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, control_frequency)
		..()

	disposing()
		STOP_TRACKING
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

	get_help_message()
		if (src.authed)
			. = "Three security personnel, or the Head of Security can revoke armory access."
			if(!authdisk_authorized)
				. += "<br>You can also use the <b>Authentication Disk</b> to issue an emergency revocation."
		else
			. = "Three security personnel, or the Head of Security, can authorize armory access."
			if(!authdisk_authorized)
				. += "<br>You can also use the <b>Authentication Disk</b> to issue an emergency override."

	proc/authorize()
		if(src.authed)
			return

		logTheThing(LOG_STATION, usr, "authorized armory access")
		message_ghosts("<b>Armory authorized [log_loc(src.loc, ghostjump=TRUE)].")
		command_announcement("<br><b>[SPAN_ALERT("Armory weapons access has been authorized for all security personnel.")]</b>", "Security Level Increased", 'sound/misc/announcement_1.ogg')
		authed = 1
		src.ClearSpecificOverlays("screen_image")
		src.icon_state = "drawbr-alert"
		src.UpdateIcon()

		ON_COOLDOWN(src, "unauth", 5 SECONDS)

		src.authorized = null
		src.authorized_registered = null

		SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_ARMORY_AUTH)

		if (armory_area)
			for(var/obj/O in armory_area)
				if(!(access_armory in O.req_access)) //Did it have armory access in the first place?
					continue
				O.req_access += access_security
				LAGCHECK(LAG_REALTIME)

		SPAWN(0.5 SECONDS)
			playsound(src, 'sound/vox/armory.ogg', 50, vary=FALSE, extrarange=10)
			sleep(0.7 SECONDS)
			playsound(src, 'sound/vox/authorized.ogg', 50, vary=FALSE, extrarange=10)

	proc/unauthorize()
		if(!src.authed)
			return

		logTheThing(LOG_STATION, usr, "unauthorized armory access")
		command_announcement("<br><b>[SPAN_ALERT("Armory weapons access has been revoked from all security personnel. All crew are advised to hand in riot gear to the Head of Security.")]</b>", "Security Level Decreased", "sound/misc/announcement_1.ogg")
		authed = 0
		src.ClearSpecificOverlays("screen_image")
		icon_state = "drawbr"
		src.UpdateIcon()

		src.authorized = null
		src.authorized_registered = null

		SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_ARMORY_UNAUTH)

		if (armory_area)
			for(var/obj/O in armory_area)
				if(!(access_armory in O.req_access)) //Did it have armory access in the first place?
					continue
				O.req_access = list(access_armory)
				LAGCHECK(LAG_REALTIME)

	proc/print_auth_needed(var/mob/author)
		if (author)
			for (var/mob/O in hearers(src, null))
				O.show_message(SPAN_SUBTLE(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"[author] request accepted. [src.auth_need - src.authorized.len] authorizations needed until Armory is [src.authed ? "closed" : "opened"].\"")), 2)
		else
			for (var/mob/O in hearers(src, null))
				O.show_message(SPAN_SUBTLE(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"[src.auth_need - src.authorized.len] authorizations needed until Armory is [src.authed ? "closed" : "opened"].\"")), 2)


/obj/machinery/computer/riotgear/attack_hand(mob/user)
	if (ishuman(user))
		return src.Attackby(user:wear_id, user)
	..()

//kinda copy paste from shuttle auth :)
/obj/machinery/computer/riotgear/attackby(var/obj/item/W, var/mob/user)
	interact_particle(user,src)
	if(status & (BROKEN|NOPOWER))
		return
	if (!user)
		return

	if (istype(W, /obj/item/disk/data/floppy/read_only/authentication))
		if(src.authdisk_authorized)
			boutput(user, SPAN_ALERT("Emergency armory authorizations cannot be cleared or reissued!"))
			return
		if(src.authed)
			src.manual_unauthorize(user, null, TRUE)
			return
		var/emergency_auth = tgui_alert(user, "This cannot be undone by Authentication Disk!", "Authentication Warning", list("Emergency Authorization", "Cancel"))
		if(emergency_auth == "Emergency Authorization" && in_interact_range(src, user) && equipped_or_holding(W, user))
			src.authdisk_authorized = TRUE
			src.authorize()
		return

	var/obj/item/card/id/id_card = get_id_card(W)

	if (!istype(id_card, /obj/item/card/id))
		boutput(user, "No ID given.")
		return
	W = id_card

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

	if (!src.authorized)
		src.authorized = list()
		src.authorized_registered = list()

	if(authed)
		src.manual_unauthorize(user, W)
		return

	var/choice = tgui_alert(user, "Would you like to authorize access to riot gear? [src.auth_need - length(src.authorized)] authorization\s are still needed.", "Armory Auth", list("Authorize", "Repeal"))
	if(BOUNDS_DIST(user, src) > 0 || src.authed)
		return
	src.add_fingerprint(user)
	if (!choice)
		return
	switch(choice)
		if("Authorize")
			if (user in src.authorized)
				boutput(user, "You have already authorized! [src.auth_need - src.authorized.len] authorizations from others are still needed.")
				return
			if (W:registered in src.authorized_registered)
				boutput(user, "This ID has already issued an authorization! [src.auth_need - src.authorized.len] authorizations from others are still needed.")
				return
			if (access_armory in W:access)
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

			if (length(src.authorized) < auth_need)
				logTheThing(LOG_STATION, user, "added an approval for armory access using [W]. [length(src.authorized)] total approvals.")
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
			logTheThing(LOG_STATION, user, "removed an approval for armory access using [W]. [length(src.authorized)] total approvals.")
			print_auth_needed(user)

/// Handles unauthorization from armory computer interaction
/obj/machinery/computer/riotgear/proc/manual_unauthorize(mob/user, var/obj/item/W, var/is_auth_disk = FALSE)
	if(GET_COOLDOWN(src, "unauth"))
		boutput(user, SPAN_ALERT(" The armory computer cannot take your commands at the moment! Wait [GET_COOLDOWN(src, "unauth")/10] seconds!"))
		playsound( src.loc, 'sound/machines/airlock_deny.ogg', 10, 0 )
		return

	// Basically the same as authing
	var/choice = tgui_alert(user, "Would you like to revoke security's access to riot gear? [src.auth_need - length(src.authorized)] unauthorization\s are still needed.", "Armory Unauthorization", list("Unauthorize", "Repeal"))
	if(BOUNDS_DIST(user, src) > 0 || !src.authed)
		return
	src.add_fingerprint(user)
	if (!choice)
		return
	switch(choice)
		if("Unauthorize")
			if (is_auth_disk)
				unauthorize()
				playsound(src.loc, 'sound/machines/chime.ogg', 10, 1)
				boutput(user,SPAN_NOTICE(" The armory's equipments have returned to having their default access!"))
				return
			if (user in src.authorized)
				boutput(user, "You have already unauthorized! [src.auth_need - src.authorized.len] unauthorizations from others are still needed.")
				return
			if (W:registered in src.authorized_registered)
				boutput(user, "This ID has already issued an unauthorization! [src.auth_need - src.authorized.len] unauthorizations from others are still needed.")
				return
			if (access_armory in W:access)
				unauthorize()
				playsound(src.loc, 'sound/machines/chime.ogg', 10, 1)
				boutput(user,SPAN_NOTICE(" The armory's equipments have returned to having their default access!"))
				return

			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (H.bioHolder.Uid in src.authorized)
					boutput(user, "You have already unauthorized - fingerprints on file! [src.auth_need - src.authorized.len] unauthorizations from others are still needed.")
					return
				src.authorized += H.bioHolder.Uid
			else
				src.authorized += user
			src.authorized_registered += W:registered

			if (length(src.authorized) < auth_need)
				logTheThing(LOG_STATION, user, "added an approval for revoking armory access using [W]. [length(src.authorized)] total approvals.")
				print_auth_needed(user)
			else
				unauthorize()
				playsound(src.loc, 'sound/machines/chime.ogg', 10, 1)
				boutput(user,SPAN_NOTICE(" The armory's equipments have returned to having their default access!"))

		if("Repeal")

			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				src.authorized -= H.bioHolder.Uid
			else
				src.authorized -= user
			src.authorized_registered -= W:registered
			logTheThing(LOG_STATION, user, "removed an approval for revoking armory access using [W]. [length(src.authorized)] total approvals.")
			print_auth_needed(user)
