TYPEINFO(/obj/machinery/phone)
	mats = 25

/obj/machinery/phone
	name = "phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A landline phone. In space. Where there is no land. Hmm."
	icon_state = "phone"
	anchored = ANCHORED
	density = 0
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS | DECON_MULTITOOL
	_health = 25
	color = null
	custom_suicide = TRUE
	var/obj/item/phone_handset/handset = null
	var/obj/machinery/phone/linked = null
	var/answered_icon = "phone_answered"
	var/dialicon = "phone_dial"
	var/phone_icon = "phone"
	var/ringing_icon = "phone_ringing"
	var/last_called = null
	var/caller_id_message = null
	var/phone_category = null
	var/phone_id = null
	var/stripe_color = null
	var/last_ring = 0
	var/answered = FALSE
	var/can_talk_across_z_levels = TRUE
	var/connected = TRUE
	var/dialing = FALSE
	var/emagged = FALSE
	var/labelling = FALSE
	var/ringing = FALSE
	var/unlisted = FALSE
	var/frequency = FREQ_FREE
	var/net_id = null

/obj/machinery/phone/New()
	. = ..() // Set up power usage, subscribe to loop, yada yada yada
	src.icon_state = "[phone_icon]"
	var/area/location = get_area(src)

	// Give the phone an appropriate departmental color. Jesus christ thats fancy.
	if (isnull(src.stripe_color)) // maps can override it now
		if (istype(location,/area/station/security))
			src.stripe_color = "#ff0000"
			src.phone_category = "security"
		else if (istype(location,/area/station/bridge))
			src.stripe_color = "#00ff00"
			src.phone_category = "bridge"
		else if (istype(location, /area/station/engine) || istype(location, /area/station/quartermaster) || istype(location, /area/station/mining))
			src.stripe_color = "#ffff00"
			src.phone_category = "engineering"
		else if (istype(location, /area/station/science))
			src.stripe_color = "#8409ff"
			src.phone_category = "research"
		else if (istype(location, /area/station/medical))
			src.stripe_color = "#3838ff"
			src.phone_category = "medical"
		else
			src.stripe_color = "#b65f08"
			src.phone_category = "uncategorized"
	else
		src.phone_category = "uncategorized"

	src.UpdateOverlays(image('icons/obj/machines/phones.dmi',"[src.dialicon]"), "dial")
	var/image/stripe_image = image('icons/obj/machines/phones.dmi',"[src.icon_state]-stripe")
	stripe_image.color = src.stripe_color
	stripe_image.appearance_flags = RESET_COLOR | PIXEL_SCALE
	src.UpdateOverlays(stripe_image, "stripe")

	// Generate a name for the phone.
	if (isnull(src.phone_id))
		var/temp_name = src.name
		if ((temp_name == src::name) && location)
			temp_name = location.name

		var/name_counter = 1
		for_by_tcl(M, /obj/machinery/phone)
			if (M.phone_id && (M.phone_id == temp_name))
				name_counter++

		if (name_counter > 1)
			temp_name = "[temp_name] [name_counter]"

		src.phone_id = temp_name

	src.net_id = global.format_net_id("\ref[src]")
	MAKE_DEVICE_RADIO_PACKET_COMPONENT(src.net_id, "phone", src.frequency)

	RegisterSignal(src, COMSIG_CORD_RETRACT, PROC_REF(hang_up))
	START_TRACKING

/obj/machinery/phone/disposing()
	if (src.linked)
		src.linked.linked = null
		src.linked = null

	qdel(src.handset)
	UnregisterSignal(src, COMSIG_CORD_RETRACT)
	STOP_TRACKING
	. = ..()

/obj/machinery/phone/get_desc()
	if (!isnull(src.phone_id))
		return " There is a small label on the phone that reads \"[src.phone_id]\"."

/obj/machinery/phone/receive_signal(datum/signal/signal)
	if (!src.linked || !src.handset || !signal.data || !istype(signal.data["message"], /datum/say_message))
		return TRUE

	var/datum/say_message/message = signal.data["message"]
	message = message.Copy()
	message.speaker = src.handset
	message.message_origin = src.handset

	src.handset.ensure_speech_tree().process(message)

/obj/machinery/phone/attack_ai(mob/user)
	return

/obj/machinery/phone/attackby(obj/item/P, mob/living/user)
	if (istype(P, /obj/item/phone_handset))
		var/obj/item/phone_handset/PH = P
		if (PH.parent == src)
			src.hang_up()
		return

	if (issnippingtool(P))
		if (src.connected)
			if (user)
				boutput(user,"You cut the phone line leading to the phone.")
			src.connected = FALSE
		else
			if (user)
				boutput(user,"You repair the line leading to the phone.")
			src.connected = TRUE
		return

	if (ispulsingtool(P))
		if (src.labelling)
			return
		src.labelling = TRUE

		var/text = tgui_input_text(user, "What do you want to name this phone?", null, null, max_length = 50)
		src.labelling = FALSE
		text = sanitize(html_encode(text))
		if (!text || !in_interact_range(src, user))
			return

		src.phone_id = text
		boutput(user, SPAN_NOTICE("You rename the phone to \"[src.phone_id]\"."))
		return

	. = ..()
	src._health -= P.force
	attack_particle(user, src)
	user.lastattacked = get_weakref(src)
	hit_twitch(src)
	playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)

	if (src._health <= 0)
		if (src.linked)
			src.hang_up()
		src.gib(src.loc)
		qdel(src)

/obj/machinery/phone/attack_hand(mob/living/user)
	. = ..(user)

	if (src.answered)
		return

	if (src.emagged)
		src.explode()
		return

	src.handset = new /obj/item/phone_handset(src,user)
	src.AddComponent(/datum/component/cord, src.handset, base_offset_x = -4, base_offset_y = -1)
	user.put_in_hand_or_drop(src.handset)
	src.answered = TRUE

	src.icon_state = "[answered_icon]"
	src.UpdateIcon()
	playsound(user, 'sound/machines/phones/pick_up.ogg', 50, FALSE)

	// A call is being answered.
	if (src.ringing)
		src.ringing = FALSE
		src.linked.ringing = FALSE

		var/mob/linked_holder = src.linked.handset.get_holder()
		if (linked_holder && (GET_DIST(src.linked.handset, linked_holder) < 1))
			linked_holder.playsound_local(linked_holder, 'sound/machines/phones/remote_answer.ogg', 50, 0)

	// An outgoing call is being made.
	else if (user)
		if (src.connected)
			ui_interact(user)
		else
			boutput(user,SPAN_ALERT("As you pick up the phone you notice that the cord has been cut!"))

/obj/machinery/phone/emag_act(mob/user, obj/item/card/emag/E)
	src.icon_state = "[ringing_icon]"
	src.UpdateIcon()

	if (src.emagged)
		return FALSE

	if (user)
		boutput(user, SPAN_ALERT("You short out the ringer circuit on the [src]."))
	src.emagged = TRUE

	// Pick a random phone.
	src.caller_id_message = "<span style=\"color: #cccccc;\">???</span>"
	var/list/phonebook = list()
	for_by_tcl(P, /obj/machinery/phone)
		if (P.unlisted)
			continue
		phonebook += P

	if (length(phonebook))
		var/obj/machinery/phone/prank = pick(phonebook)
		src.caller_id_message = "<span style=\"color: [prank.stripe_color];\">[prank.phone_id]</span>"

	return TRUE

/obj/machinery/phone/process()
	if (src.emagged)
		playsound(src.loc,'sound/machines/phones/ring_incoming.ogg', 100, 1)
		if (!src.answered)
			src.say("Call from [src.caller_id_message].", flags = SAYFLAG_IGNORE_HTML)
			src.icon_state = "[ringing_icon]"
			UpdateIcon()
		return

	if (!src.connected)
		return

	src.last_ring++
	if (..())
		return

	if (!src.ringing)
		return

	if (src.linked && (src.linked.answered == FALSE))
		if (src.last_ring >= 2)
			src.last_ring = 0
			var/mob/holder = src.handset?.get_holder()
			if (holder && (GET_DIST(src.handset, holder) < 1))
				holder.playsound_local(holder, 'sound/machines/phones/ring_outgoing.ogg', 40, 0)

	else if (src.last_ring >= 2)
		playsound(src.loc, 'sound/machines/phones/ring_incoming.ogg', 40, 0)
		src.icon_state = "[src.ringing_icon]"
		src.UpdateIcon()
		src.last_ring = 0
		src.say("Call from [src.caller_id_message].", flags = SAYFLAG_IGNORE_HTML)

/obj/machinery/phone/suicide(mob/user)
	if (!src.user_can_suicide(user))
		return FALSE

	if (ishuman(user))
		user.visible_message(SPAN_ALERT("<b>[user] bashes the [src] into [his_or_her(user)] head repeatedly!</b>"))
		user.TakeDamage("head", 150, 0)
		return TRUE

/obj/machinery/phone/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Phone")
		ui.open()

/obj/machinery/phone/ui_data(mob/user)
	var/list/list/list/phonebook = list()
	for_by_tcl(P, /obj/machinery/phone)
		var/match_found = FALSE
		if (P.unlisted || P == src)
			continue
		if (!(src.can_talk_across_z_levels && P.can_talk_across_z_levels) && (get_z(P) != get_z(src)))
			continue
		if (length(phonebook))
			for (var/i in 1 to length(phonebook))
				if (phonebook[i]["category"] == P.phone_category)
					match_found = TRUE
					phonebook[i]["phones"] += list(list(
						"id" = P.phone_id
					))
					break
		if (!match_found)
			phonebook += list(list(
				"category" = P.phone_category,
				"phones" = list(list(
					"id" = P.phone_id
				))
			))

	. = list(
		"dialing" = src.dialing,
		"inCall" = src.linked,
		"lastCalled" = src.last_called,
		"name" = src.name
	)

	.["phonebook"] = phonebook

/obj/machinery/phone/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch (action)
		if ("call")
			if (src.dialing == TRUE || src.linked)
				return
			. = TRUE
			src.add_fingerprint(usr)
			var/id = params["target"]
			for_by_tcl(P, /obj/machinery/phone)
				if (P.phone_id == id)
					src.call_other(P)
					return
			boutput(usr, SPAN_ALERT("Unable to connect!"))

/obj/machinery/phone/update_icon()
	. = ..()
	src.UpdateOverlays(src.SafeGetOverlayImage("stripe", 'icons/obj/machines/phones.dmi',"[src.icon_state]-stripe"), "stripe")

/obj/machinery/phone/proc/explode()
	src.blowthefuckup(strength = 2.5, delete = TRUE)

/obj/machinery/phone/proc/hang_up()
	src.answered = FALSE
	if (src.linked)
		// If nobody picked up, return to the non-ringing state.
		if (!src.linked.answered)
			src.linked.icon_state = "[src.linked.phone_icon]"
			src.linked.UpdateIcon()

		// If someone did pick up, play the hangup sound.
		else
			var/mob/linked_holder = src.linked.handset?.get_holder()
			if (linked_holder && (GET_DIST(src.linked.handset, linked_holder) < 1))
				linked_holder.playsound_local(linked_holder, 'sound/machines/phones/remote_hangup.ogg', 50, 0)

		src.linked.ringing = FALSE
		src.linked.linked = null
		src.linked = null

	src.RemoveComponentsOfType(/datum/component/cord)
	src.ringing = FALSE
	src.handset?.force_drop(sever = TRUE)
	qdel(src.handset)
	src.handset = null
	src.icon_state = "[phone_icon]"
	tgui_process.close_uis(src)
	src.UpdateIcon()
	playsound(src.loc, 'sound/machines/phones/hang_up.ogg', 50, 0)

/obj/machinery/phone/proc/call_other(obj/machinery/phone/target)
	if (!src.handset)
		return

	src.dialing = TRUE
	tgui_process?.update_uis(src)

	var/mob/holder = src.handset?.get_holder()
	if (holder && (GET_DIST(src.handset, holder) < 1))
		holder.playsound_local(holder, 'sound/machines/phones/dial.ogg', 50, 0)

	src.last_called = target.unlisted ? "Undisclosed" : "[target.phone_id]"
	target.caller_id_message = "<span style=\"color: [src.stripe_color];\">[src.phone_id]</span>"

	SPAWN(4 SECONDS)
		// Return if the line is busy.
		if (target.answered || target.linked || !target.connected || !src.answered)
			playsound(src.loc,'sound/machines/phones/phone_busy.ogg', 50, 0)
			src.dialing = FALSE
			return

		// Start ringing the other phone.
		src.linked = target
		target.linked = src
		src.ringing = TRUE
		src.linked.ringing = TRUE
		src.dialing = FALSE
		src.linked.last_called = src.unlisted ? "Undisclosed" : "[src.phone_id]"


TYPEINFO(/obj/machinery/phone/wall)
	mats = 25

/obj/machinery/phone/wall
	name = "wall phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A landline phone. In space. Where there is no land. Hmm."
	icon_state = "wallphone"
	anchored = ANCHORED
	density = 0
	_health = 50
	phone_icon = "wallphone"
	ringing_icon = "wallphone_ringing"
	answered_icon = "wallphone_answered"
	dialicon = "wallphone_dial"


/obj/machinery/phone/unlisted
	unlisted = TRUE


/obj/item/electronics/frame/phone
	name = "Phone Frame"
	desc = "An undeployed telephone, looks like it could be deployed with a soldering iron. Phones are really that easy!"
	icon_state = "dbox"
	store_type = /obj/machinery/phone
	viewstat = 2
	secured = 2
