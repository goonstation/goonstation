#define ARMORY_ACCESS_LEVEL_UNRESTRICTED 2
#define ARMORY_ACCESS_LEVEL_NEEDS_AUTH 1

TYPEINFO(/obj/machinery/computer/riotgear)
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_SUBTLE)

/obj/machinery/computer/riotgear
	name = "Armory Control"
	icon_state = "drawbr"
	density = 0
	glow_in_dark_screen = TRUE
	speech_verb_say = "beeps"
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD

	var/auth_need = 3
	var/list/authorized = list()
	var/list/authorized_registered = list()
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
		command_announcement("<b>[SPAN_ALERT("Armory weapons access has been authorized for all security personnel.")]</b>", "Security Level Increased", 'sound/misc/announcement_1.ogg', alert_origin=ALERT_STATION)
		authed = 1
		src.ClearSpecificOverlays("screen_image")
		src.icon_state = "drawbr-alert"
		src.UpdateIcon()

		ON_COOLDOWN(src, "unauth", 5 MINUTES)

		src.clear_authorizations()

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
		command_announcement("<b>[SPAN_ALERT("Armory weapons access has been revoked from all security personnel. All crew are advised to hand in riot gear to the Head of Security.")]</b>", "Security Level Decreased", "sound/misc/announcement_1.ogg", alert_origin=ALERT_STATION)
		playsound(src.loc, 'sound/machines/chime.ogg', 10, 1)
		authed = 0
		src.ClearSpecificOverlays("screen_image")
		icon_state = "drawbr"
		src.UpdateIcon()

		src.clear_authorizations()

		SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_ARMORY_UNAUTH)

		if (armory_area)
			for(var/obj/O in armory_area)
				if(!(access_armory in O.req_access)) //Did it have armory access in the first place?
					continue
				O.req_access = list(access_armory)
				LAGCHECK(LAG_REALTIME)

	proc/print_auth_needed(mob/author)
		if (author)
			src.say("[author] request accepted. [src.auth_need - src.authorized.len] approvals needed until Armory is [src.authed ? "closed" : "opened"].")
		else
			src.say("[src.auth_need - src.authorized.len] approvals needed until Armory is [src.authed ? "closed" : "opened"].")

	proc/check_access_level(mob/user)
		if(issilicon(user)) //No borgos allowed.
			return 0
		var/obj/item/card/id/id_card = user.get_id()
		if (!id_card || !id_card.access || !islist(id_card.access) || !length(id_card.access))
			return 0
		if(access_armory in id_card?.access)
			return ARMORY_ACCESS_LEVEL_UNRESTRICTED
		else if (access_securitylockers in id_card?.access)
			return ARMORY_ACCESS_LEVEL_NEEDS_AUTH
		return 0

	proc/clear_authorizations()
		src.authorized = list()
		src.authorized_registered = list()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ArmoryAuthorization", src.name)
			ui.open()

	ui_data(mob/user)
		. = list()
		.["disk_authed"] = src.authdisk_authorized
		.["auths_needed"] = src.auth_need
		.["cooldown"] = GET_COOLDOWN(src, "unauth")
		.["authorization_bioholders"] = list()
		for(var/auth in src.authorized)
			if(ismob(auth)) //Nonhumans give refs not bioholder UIDs
				.["authorization_bioholders"] += "Unknown"
			else
				.["authorization_bioholders"] += auth
		.["authorization_names"] = src.authorized_registered
		.["authed"] = src.authed
		.["user_access_level"] = src.check_access_level(user)

#define CAN_STILL_USE_CHECK (in_interact_range(src, user) && !GET_COOLDOWN(src, "unauth"))
	ui_act(action, params, datum/tgui/ui)
		. = ..()
		if (.)
			return
		var/mob/user = ui.user
		if(GET_COOLDOWN(src, "unauth"))
			boutput(user, SPAN_ALERT("The [src] cannot take your commands at the moment! Wait [GET_COOLDOWN(src, "unauth")/10] second\s!"))
			playsound( src.loc, 'sound/machines/airlock_deny.ogg', 10, 0 )
			return
		var/obj/item/card/id/id_card = user.get_id()
		src.add_fingerprint(user)
		if(!id_card && action != "disk_auth")
			boutput(user, SPAN_ALERT("You need an ID card to do that!"))
			return
		switch(action)
			if("disk_auth")
				if(!istype(user.equipped(), /obj/item/disk/data/floppy/read_only/authentication))
					boutput(user, SPAN_ALERT("You need an authentication disk to do that!"))
					return
				if(src.authdisk_authorized)
					boutput(user, SPAN_ALERT("Emergency armory authorizations cannot be cleared or reissued!"))
					return
				if(src.authed)
					var/choice = tgui_alert(user, "Would you like to revoke security's access to riot gear?", src.name, list("Revoke", "Cancel"))
					if(choice == "Revoke" && istype(user.equipped(), /obj/item/disk/data/floppy/read_only/authentication) && CAN_STILL_USE_CHECK)
						unauthorize()
						boutput(user,SPAN_NOTICE("The armory's equipments have returned to having their default access!"))
				else
					var/emergency_auth = tgui_alert(user, "This cannot be undone by Authentication Disk!", "Authentication Warning", list("Emergency Authorization", "Cancel"))
					if(emergency_auth == "Emergency Authorization" && istype(user.equipped(), /obj/item/disk/data/floppy/read_only/authentication) && CAN_STILL_USE_CHECK)
						src.authdisk_authorized = TRUE
						src.authorize()
			if("repeal_all")
				if(src.check_access_level(user) < ARMORY_ACCESS_LEVEL_UNRESTRICTED)
					boutput(user, SPAN_ALERT("You do not have the access to repeal all authorizations!"))
					return
				playsound(src, 'sound/machines/ping.ogg', 50, 0, pitch = 0.5)
				logTheThing(LOG_STATION, user, "repealed all approvals for [src.authed? "un":""]authorizing the armory using [id_card]. [length(src.authorized)] total approvals.")
				src.clear_authorizations()
			if("auth") //Handles both Authorization and Revokation depending on src.authed
				var/auths_left = (src.check_access_level(user) == ARMORY_ACCESS_LEVEL_UNRESTRICTED ? 0 : src.auth_need - length(src.authorized))
				var/auth_or_revoke = src.authed ? "revoke" : "authorize"
				var/choice = tgui_alert(user, "Would you like to [auth_or_revoke] access to riot gear? [auths_left ? "[auths_left] approval\s are still needed." : null]", src.name, list(capitalize(auth_or_revoke), "Cancel"))
				if(choice != capitalize(auth_or_revoke) || !CAN_STILL_USE_CHECK)
					return
				id_card = user.get_id()
				switch(src.check_access_level(user))
					if(ARMORY_ACCESS_LEVEL_UNRESTRICTED)
						if(!src.authed)
							authorize()
						else
							unauthorize()
					if(ARMORY_ACCESS_LEVEL_NEEDS_AUTH)
						var/approvals_needed_text = "[auths_left] approvals from others are still needed."
						if (id_card.registered in src.authorized_registered)
							boutput(user, SPAN_ALERT("This ID has already issued an authorization! [approvals_needed_text]"))
							return
						if (ishuman(user))
							var/mob/living/carbon/human/H = user
							if (H.bioHolder.Uid in src.authorized)
								boutput(user, SPAN_ALERT("You have already [auth_or_revoke]d - fingerprints on file! [approvals_needed_text]"))
								return
							src.authorized += H.bioHolder.Uid
						else
							if (user in src.authorized)
								boutput(user, SPAN_ALERT("You have already authorized! [approvals_needed_text]"))
								return
							src.authorized += user //authorize by USER, not by registered ID. prevent the captain from printing out 3 unique ID cards and getting in by themselves.
						src.authorized_registered += id_card.registered
						playsound(src, 'sound/machines/ping.ogg', 50, 0)

						if (length(src.authorized) < auth_need)
							logTheThing(LOG_STATION, user, "added an approval to [auth_or_revoke] armory access using [id_card]. [length(src.authorized)] total approvals.")
							print_auth_needed(user)
						else
							if(!src.authed)
								authorize()
							else
								unauthorize()
					else
						boutput(user, SPAN_ALERT("You don't have the necessary access or authority for that!"))
			if("repeal")
				var/index = text2num_safe(params["index"])
				switch(src.check_access_level(user))
					if(ARMORY_ACCESS_LEVEL_UNRESTRICTED)
						src.authorized -= src.authorized[index]
						src.authorized_registered -= src.authorized_registered[index]
						playsound(src, 'sound/machines/ping.ogg', 50, 0, pitch = 0.5)
					if(ARMORY_ACCESS_LEVEL_NEEDS_AUTH)
						var/thing_to_check = user
						if(ishuman(user))
							var/mob/living/carbon/human/H = user
							thing_to_check = H.bioHolder.Uid
						if(src.authorized[index] != thing_to_check && src.authorized_registered != id_card.registered)
							boutput(user, SPAN_ALERT("You did not grant that approval!"))
							return
						logTheThing(LOG_STATION, user, "removed [src.authorized_registered[index]]'s approval for armory access. [length(src.authorized) - 1] total approvals.")
						src.authorized -= src.authorized[index]
						src.authorized_registered -= src.authorized_registered[index]
						playsound(src, 'sound/machines/ping.ogg', 50, 0, pitch = 0.5)
						print_auth_needed(user)
					else
						boutput(user, SPAN_ALERT("You don't have the necessary access or authority for that!"))
#undef CAN_STILL_USE_CHECK

/obj/machinery/computer/riotgear/attackby(var/obj/item/W, mob/user)
	. = ..()
	if(istypes(W, list(/obj/item/card/id, /obj/item/device/pda2, /obj/item/disk/data/floppy/read_only/authentication)))
		src.Attackhand(user) //Open the UI


#undef ARMORY_ACCESS_LEVEL_UNRESTRICTED
#undef ARMORY_ACCESS_LEVEL_NEEDS_AUTH
