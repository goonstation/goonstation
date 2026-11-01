// If you add an IMPLANT_STATUS state, you also need to update the related TGUI interface
#define MARIONETTE_IMPLANT_STATUS_IDLE "IDLE"
#define MARIONETTE_IMPLANT_STATUS_ACTIVE "ACTIVE"
#define MARIONETTE_IMPLANT_STATUS_DANGER "DANGER"
#define MARIONETTE_IMPLANT_STATUS_WAITING "WAITING..."
#define MARIONETTE_IMPLANT_STATUS_NO_RESPONSE "NO RESPONSE"
#define MARIONETTE_IMPLANT_STATUS_BURNED_OUT "BURNED OUT"

#define MARIONETTE_IMPLANT_ERROR_NO_TARGET "TARG_NULL"
#define MARIONETTE_IMPLANT_ERROR_DEAD_TARGET "TARG_DEAD"
#define MARIONETTE_IMPLANT_ERROR_BAD_PASSKEY "BADPASS"
#define MARIONETTE_IMPLANT_ERROR_INVALID "INVALID"
#define MARIONETTE_IMPLANT_ERROR_UNABLE "UNABLE"

/obj/item/implant/marionette
	name = "marionette implant"
	desc = "This thing looks really complicated."
	icon_state = "implant-mh"
	impcolor = "r"
	scan_category = IMPLANT_SCAN_CATEGORY_SYNDICATE
	alert_frequency = FREQ_MARIONETTE_IMPLANT

	/// A network address that this implant is linked to. Can be null.
	/// Packets sent by this address skip the passkey requirement, and if the implant burns out,
	/// it will send a signal to this address to alert it.
	var/linked_address = null
	/// A string that's (usually) unique to each implant. Signals must provide the correct passkey to issue commands to the implant.
	var/passkey = null
	/// If TRUE, this implant is burned out and permanently unusable.
	var/burned_out = FALSE
	/// The implant's heat level, increased by various actions. Slowly reduces over time.
	var/heat = 0
	/// The implant's previous heat level, set after it's adjusted.
	/// This is used so that the implant can send an alert signal when it enters the danger zone for the first time.
	var/prev_heat = 0
	/// The implant's heat dissipation. `heat` is reduced by this value every processing tick.
	/// The value slowly ramps up over time, but is reset upon being activated. This makes short-term overuse very punishing,
	/// but allows it to recover decently quickly if given time to rest.
	var/heat_dissipation = 1
	/// If `heat` is above this value, each activation has a chance to break the implant permanently.
	var/const/heat_danger_zone = 100
	/// This is some messy code, but emotes are like that. Anything in this list will not be triggered by the force-emote function.
	var/list/emote_blacklist = list(
		"custom", "customv", "customh", "me", "give", "help", "listbasic", "listtarget", "list", "suicide", "uguu", "juggle", "airquote", "airquotes",
		"faint", "deathgasp", "collapse", "trip", "monologue", "miranda", "birdwell"
	)

	New()
		. = ..()
		var/datum/reagent/R = pick(concrete_typesof(/datum/reagent/fooddrink/alcoholic))
		src.passkey = lowertext(replacetext(replacetext(R.name, " ", "_"), "'", ""))
		if (!src.passkey)
			src.passkey = "IMP-[rand(111, 999)]"
		// The `uses_radio` variable only adds a sender component, not a two-way one. So we have to do that manually!
		if (!src.net_id)
			src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, src.alert_frequency)
		processing_items.Add(src)

	disposing()
		processing_items.Remove(src)
		..()

	deactivate()
		..()
		processing_items.Remove(src)

	process()
		src.adjust_heat(-src.heat_dissipation)
		src.heat_dissipation = min(3, src.heat_dissipation + 0.05)

	can_implant(mob/target, mob/user)
		if (istype(target, /mob/living/critter/wraith/trickster_puppet))
			boutput(user, SPAN_ALERT("The implanter shows an error: \"TARGET IS SECRETLY A GHOST\". Huh. You didn't know it even checked for that!"))
			return
		return ..()

	implanted(mob/M, mob/I)
		. = ..()
		if (!src.burned_out)
			// this is an anti-frustration feature with the goal of both making it easier to reference chat logs to know who is implanted with what,
			// as well as to make sure players can still use packets if they forget to scan it onto their remote and didn't write down the network data
			boutput(I, SPAN_NOTICE("You make a mental note that this implant's network ID is <b>[src.net_id]</b> and its passkey is <b>[src.passkey]</b>."))

	receive_signal(datum/signal/signal)
		// Note the lack of a src.burned_out check here -- this is because burning out removes the implant's radio component,
		// meaning that it can't send or receive signals to begin with
		if (ON_COOLDOWN(src, "activate", 1 SECOND))
			return
		if (!signal || signal.encryption)
			return
		if (signal.data["address_1"] != src.net_id)
			return
		if (signal.data["sender"] == src.net_id)
			return

		var/command = signal.data["command"]
		if (command == "ping")
			src.send_ping(signal.data["sender"])
			return

		if (command == "unlink")
			if (signal.data["sender"] == src.linked_address)
				src.linked_address = null
			return

		if (src.passkey && src.passkey != signal.data["passkey"])
			if (signal.data["sender"] != src.linked_address)
				src.send_activation_reply(signal.data["sender"], MARIONETTE_IMPLANT_ERROR_BAD_PASSKEY)
				return

		src.heat_dissipation = initial(src.heat_dissipation)

		var/fail_reason
		if (!ismob(src.owner))
			fail_reason = MARIONETTE_IMPLANT_ERROR_NO_TARGET
			src.send_activation_reply(signal.data["sender"], fail_reason)
			return

		var/mob/living/carbon/human/H = src.owner
		if (istype(H) && H.decomp_stage != DECOMP_STAGE_NO_ROT)
			fail_reason = MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
			src.send_activation_reply(signal.data["sender"], fail_reason)
			return

		var/data = signal.data["data"]
		switch (command)
			if ("say", "speak")
				if (!isdead(src.owner))
					logTheThing(LOG_COMBAT, src.owner, "was forced by \a [src] to say \"[data]\" at [log_loc(src.owner)] (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
					data = copytext(strip_prefix(data, "*"), 1, 46) // Trim starting asterisks to prevent force-emoting
					src.owner.being_controlled = TRUE
					try
						src.owner.say(data)
					catch (var/exception/e)
						logTheThing(LOG_DEBUG, src, "Exception [e] occurred while processing marionette implant say stack for mob [src.owner]")
					src.owner.being_controlled = FALSE
				else
					fail_reason = MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
				src.adjust_heat(15)
			if ("emote")
				data = lowertext(data)
				if (!isdead(src.owner))
					if (data in src.emote_blacklist)
						fail_reason = MARIONETTE_IMPLANT_ERROR_INVALID
					else
						logTheThing(LOG_COMBAT, src.owner, "was forced by \a [src] to emote \"[data]\" at [log_loc(src.owner)] by (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
						src.owner.emote(data)
				else
					fail_reason = MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
				src.adjust_heat(15)
			if ("move", "step", "bump")
				if (can_act(src.owner, FALSE))
					logTheThing(LOG_COMBAT, src.owner, "was forced by \a [src] to step to the [lowertext(data)] at [log_loc(src.owner)] (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
					var/step_dir = text2dir(uppertext(data))
					if (step_dir && (step_dir in cardinal))
						step(src.owner, step_dir)
					else
						fail_reason = MARIONETTE_IMPLANT_ERROR_INVALID
				else
					fail_reason = MARIONETTE_IMPLANT_ERROR_UNABLE
				src.adjust_heat(5)
			if ("shock", "zap")
				// Note the lack of immunity from the elec_resist mutation here here
				// This is intentional; in this case, it's moreso overstimulating the nervous system than actually causing electrical shocks!
				logTheThing(LOG_COMBAT, src.owner, "was shocked by \a [src] at [log_loc(src.owner)] (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
				boutput(src.owner, SPAN_ALERT("You feel a shock from inside your body!"))
				src.owner.do_disorient(90, knockdown = 7 SECONDS, disorient = 3 SECONDS)
				src.owner.changeStatus("defibbed", 3 SECONDS)
				playsound(src.owner, 'sound/impact_sounds/Energy_Hit_3.ogg', 20, TRUE, -1)
				src.adjust_heat(50)
			if ("drop", "release")
				if (!isdead(src.owner))
					var/obj/item/I = src.owner.equipped()
					if (istype(I))
						logTheThing(LOG_COMBAT, src.owner, "was forced to drop \the [I] by \a [src] at [log_loc(src.owner)] (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
						boutput(src.owner, SPAN_ALERT("Your grip on \the [I] suddenly relaxes!"))
						H.drop_item()
					else
						fail_reason = MARIONETTE_IMPLANT_ERROR_INVALID
					src.adjust_heat(60)
				else
					fail_reason = MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
			if ("use", "activate")
				if (!isdead(src.owner))
					var/obj/item/I = src.owner.equipped()
					if (istype(I))
						logTheThing(LOG_COMBAT, src.owner, "was forced to activate \the [I] by \a [src] at [log_loc(src.owner)] (caused by [constructTarget(signal.author, "combat")] at [log_loc(signal.author)]).")
						boutput(src.owner, SPAN_ALERT("Your hand involuntarily jerks."))
						src.owner.click(I, list())
					else
						fail_reason = MARIONETTE_IMPLANT_ERROR_INVALID
					src.adjust_heat(35)
				else
					fail_reason = MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
			else
				fail_reason = MARIONETTE_IMPLANT_ERROR_INVALID
		src.send_activation_reply(signal.data["sender"], fail_reason)

	/// Sends a ping packet to the provided address, containing information about the implant's status.
	/// If `special` is non-null, it will be provided in the `special` parameter;
	/// this is currently used to indicate when an implant goes above the danger zone when it was previously safe.
	proc/send_ping(sender_address, special = null)
		var/datum/signal/ping_reply = get_free_signal()
		ping_reply.source = src
		ping_reply.data["device"] = "IMP_MARIONETTE"
		ping_reply.data["sender"] = src.net_id
		ping_reply.data["address_1"] = sender_address
		ping_reply.data["command"] = "ping_reply"
		ping_reply.data["status"] = src.burned_out ? MARIONETTE_IMPLANT_STATUS_BURNED_OUT : \
			src.heat > src.heat_danger_zone ? MARIONETTE_IMPLANT_STATUS_DANGER : \
			ismob(src.owner) ? MARIONETTE_IMPLANT_STATUS_ACTIVE : MARIONETTE_IMPLANT_STATUS_IDLE
		if (special)
			ping_reply.data["special"] = special
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, ping_reply)

	/// Sends an activation reply to the provided address. Any activation with a non-null `fail_reason` is considered a fail.
	proc/send_activation_reply(sender_address, fail_reason)
		var/datum/signal/activation_signal = get_free_signal()
		activation_signal.source = src
		activation_signal.data["device"] = "IMP_MARIONETTE"
		activation_signal.data["sender"] = src.net_id
		activation_signal.data["address_1"] = sender_address
		activation_signal.data["command"] = "activate"
		if (fail_reason)
			activation_signal.data["stack"] = fail_reason
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, activation_signal)

	/// Adjusts `heat` by `to_heat`. Also handles potentially burning out when overheating, and alerting a linked address if we enter the danger zone.
	proc/adjust_heat(to_heat)
		if (src.heat > src.heat_danger_zone && prob(20 + src.heat - src.heat_danger_zone) && to_heat > 0)
			SPAWN (0.25 SECONDS) // Give the implant time to send the activation reply
				src.burn_out()
		src.heat = max(0, src.heat + to_heat)
		if (src.heat > src.heat_danger_zone && src.prev_heat <= src.heat_danger_zone && src.linked_address)
			src.send_ping(src.linked_address, TRUE)
		src.prev_heat = src.heat

	/// Burns out the implant and makes it permanently unusable.
	proc/burn_out()
		if (ismob(src.owner))
			logTheThing(LOG_COMBAT, src.owner, "had their [src.name] burn out and become useless.")
			boutput(src.owner, SPAN_ALERT("You feel a painful burning, like there's a something hot inside your body."))
			src.owner.TakeDamage("All", burn = 7, damage_type = DAMAGE_BURN)
		src.name = "melted [src.name]" // Specifically change the name here instead of using prefix, so that it appears in the removed implant item
		src.desc = "Charred and most definitely broken. This thing must have been pushed really hard."
		src.burned_out = TRUE
		src.deactivate()
		if (src.linked_address)
			src.send_ping(src.linked_address)
		// goodbye my sweet son
		src.RemoveComponentsOfType(/datum/component/packet_connected/radio)


/obj/item/remote/marionette_implant
	name = "marionette implant remote"
	desc = "A remote control that allows the sending and receiving of data from linked marionette implants."
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"

	flags = TABLEPASS | TGUI_INTERACTIVE
	object_flags = NO_GHOSTCRITTER
	w_class = W_CLASS_SMALL

	HELP_MESSAGE_OVERRIDE({"Can track and control any number of marionette implants. To link an implant, simply use the remote on an implanter, implant case, \
	or implant. Vice-versa also works."})

	/// The network ID of the remote. Communicated to tracked implants when pinging.
	var/net_id
	/// Data entered by the user. Its contents will be provided as the `data` field in packets sent to implants.
	var/entered_data
	/// The current selected command that implants will be sent.
	var/selected_command = "say"
	/// An associative list of tracked implants, where keys are network IDs of implants and values are the last ping result from those addresses.
	var/list/implant_status = list()

	New()
		. = ..()
		if (!src.net_id)
			src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, FREQ_MARIONETTE_IMPLANT)

	get_desc()
		. = ..()
		. += SPAN_NOTICE("<br>Its network address is [net_id].")

	attack_self(mob/user)
		src.ui_interact(user)

	attackby(obj/item/W, mob/user, params)
		if (src.link_with(W, user))
			return
		return ..()

	afterattack(atom/target, mob/user, reach, params)
		if (istype(target, /obj/item/implanter) || istype(target, /obj/item/implantcase) || istype(target, /obj/item/implant))
			src.link_with(target, user)
		else
			return ..()

	receive_signal(datum/signal/signal, receive_method, receive_param, connection_id)
		if (!signal || signal.encryption)
			return

		if (lowertext(signal.data["address_1"]) != src.net_id)
			return

		var/sender_address = lowertext(signal.data["sender"])
		if (sender_address == src.net_id)
			return

		if (sender_address in src.implant_status)
			if (signal.data["command"] == "ping_reply")
				if (signal.data["status"] == MARIONETTE_IMPLANT_STATUS_BURNED_OUT && src.implant_status[sender_address] != MARIONETTE_IMPLANT_STATUS_BURNED_OUT)
					for (var/mob/M in get_turf(src))
						boutput(M, SPAN_ALERT("Your [src.name] alerts you that a tracked implant has burned out and is no longer usable."))
						M.playsound_local(src, "sound/machines/twobeep.ogg", 50)
				else if (signal.data["status"] == MARIONETTE_IMPLANT_STATUS_DANGER && signal.data["special"])
					for (var/mob/M in get_turf(src))
						boutput(M, SPAN_ALERT("Your [src.name] alerts you that a tracked implant is dangerously hot."))
						M.playsound_local(src, "sound/machines/twobeep.ogg", 50)
				src.implant_status[sender_address] = signal.data["status"]
			if (signal.data["command"] == "activate")
				for (var/mob/M in get_turf(src))
					M.playsound_local(src, !signal.data["stack"] ? "sound/machines/claw_machine_success.ogg" : "sound/machines/claw_machine_fail.ogg", 10, TRUE)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "MarionetteRemote", name)
			ui.open()

	ui_data(mob/user)
		. = ..()
		var/list/implant_entries = list()
		for (var/address in src.implant_status)
			implant_entries += list(list(
				"address" = address,
				"status" = src.implant_status[address]
			))
		.["entered_data"] = src.entered_data
		.["selected_command"] = src.selected_command
		.["implants"] = implant_entries

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return
		if (action == "set_data")
			var/new_data = params["new_data"]
			if (!istext(new_data))
				return
			new_data = copytext(new_data, 1, 46)
			src.entered_data = new_data
			playsound(src.loc, "keyboard", 25, TRUE, -(MAX_SOUND_RANGE - 5))
			. = TRUE
		else if (action == "set_command")
			src.selected_command = params["new_command"]
			playsound(src.loc, 'sound/machines/keypress.ogg', 25, TRUE, -(MAX_SOUND_RANGE - 5))
			. = TRUE
		else if (action == "remove_from_list")
			src.implant_status.Remove(params["address"])
			boutput(usr, SPAN_NOTICE("Implant removed from tracking list."))
			playsound(src.loc, 'sound/machines/keypress.ogg', 25, TRUE, -(MAX_SOUND_RANGE - 5))
			var/datum/signal/unlink_packet = get_free_signal()
			unlink_packet.source = src
			unlink_packet.data["device"] = "IMP_MARIONETTE_REMOTE"
			unlink_packet.data["sender"] = src.net_id
			unlink_packet.data["address_1"] = params["address"]
			unlink_packet.data["command"] = "unlink"
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, unlink_packet)
			. = TRUE
		else
			var/address = params["address"]
			var/command = params["packet_command"]
			var/data = params["packet_data"]
			if (action == "activate")
				var/datum/signal/activation_packet = get_free_signal()
				activation_packet.source = src
				activation_packet.data["device"] = "IMP_MARIONETTE_REMOTE"
				activation_packet.data["sender"] = src.net_id
				activation_packet.data["address_1"] = address
				activation_packet.data["command"] = command
				activation_packet.data["data"] = data
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, activation_packet)
				playsound(src.loc, 'sound/machines/keypress.ogg', 25, TRUE, -(MAX_SOUND_RANGE - 5))
				. = TRUE
			else if ((action == "ping" || action == "ping_all") && !ON_COOLDOWN(src, "do_ping", 2 SECONDS))
				var/list/to_ping = action == "ping" ? list(address) : src.implant_status
				for (var/implant_to_ping in to_ping)
					if (src.implant_status[implant_to_ping] == MARIONETTE_IMPLANT_STATUS_BURNED_OUT)
						continue
					var/datum/signal/ping = get_free_signal()
					ping.source = src
					ping.data["device"] = "IMP_MARIONETTE_REMOTE"
					ping.data["sender"] = src.net_id
					ping.data["address_1"] = implant_to_ping
					ping.data["command"] = "ping"
					src.implant_status[implant_to_ping] = MARIONETTE_IMPLANT_STATUS_WAITING
					// Slightly delay the actual ping, as otherwise the text could be immediately overwritten with unlucky timing
					// This way it's clear to the player that the ping did actually happen!
					SPAWN (0.4 SECONDS)
						SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, ping)
						SPAWN (2 SECONDS)
							if (src.implant_status[implant_to_ping] == MARIONETTE_IMPLANT_STATUS_WAITING)
								src.implant_status[implant_to_ping] = MARIONETTE_IMPLANT_STATUS_NO_RESPONSE
				playsound(src.loc, 'sound/machines/keypress.ogg', 25, TRUE, -(MAX_SOUND_RANGE - 5))
				. = TRUE

	proc/link_with(obj/item/W, mob/living/user)
		var/obj/item/implant/marionette/M
		if (istype(W, /obj/item/implanter))
			var/obj/item/implanter/I = W
			if (!istype(I.imp, /obj/item/implant/marionette))
				boutput(user, SPAN_ALERT("\The [W] doesn't have a compatible implant."))
				return TRUE
			M = I.imp
		else if (istype(W, /obj/item/implantcase))
			var/obj/item/implantcase/IC = W
			if (!istype(IC.imp, /obj/item/implant/marionette))
				boutput(user, SPAN_ALERT("\The [W] doesn't have a compatible implant."))
				return TRUE
			M = IC.imp
		else if (istype(W, /obj/item/implant))
			M = W
		if (istype(M))
			if (M.burned_out)
				boutput(user, SPAN_ALERT("The implant is burned out and permanently unusable."))
			else if (M.net_id in src.implant_status)
				boutput(user, SPAN_NOTICE("This implant is already in the remote's tracking list."))
			else
				boutput(user, SPAN_NOTICE("You scan the implant into \the [src]'s database."))
				src.implant_status[M.net_id] = "UNKNOWN"
				M.linked_address = src.net_id
				user.playsound_local(user, "sound/machines/tone_beep.ogg", 30)
			return TRUE

#undef MARIONETTE_IMPLANT_STATUS_IDLE
#undef MARIONETTE_IMPLANT_STATUS_ACTIVE
#undef MARIONETTE_IMPLANT_STATUS_DANGER
#undef MARIONETTE_IMPLANT_STATUS_WAITING
#undef MARIONETTE_IMPLANT_STATUS_NO_RESPONSE
#undef MARIONETTE_IMPLANT_STATUS_BURNED_OUT

#undef MARIONETTE_IMPLANT_ERROR_NO_TARGET
#undef MARIONETTE_IMPLANT_ERROR_DEAD_TARGET
#undef MARIONETTE_IMPLANT_ERROR_BAD_PASSKEY
#undef MARIONETTE_IMPLANT_ERROR_INVALID
#undef MARIONETTE_IMPLANT_ERROR_UNABLE
