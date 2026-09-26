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
	var/answered_icon = "phone_answered"
	var/dialicon = "phone_dial"
	var/phone_icon = "phone"
	var/ringing_icon = "phone_ringing"
	var/answered = FALSE
	var/connected = TRUE
	var/emagged = FALSE
	var/emag_message = null
	var/labelling = FALSE

	var/phone_id = null
	var/phone_category = null
	var/can_talk_across_z_levels = TRUE
	var/unlisted = FALSE
	var/stripe_color = null

/obj/machinery/phone/New()
	. = ..() // Set up power usage, subscribe to loop, yada yada yada
	src.icon_state = "[phone_icon]"
	var/area/location = get_area(src)

	// Give the phone an appropriate departmental color. Jesus christ thats fancy.
	var/area_color = "#b65f08"
	var/area_category = "uncategorized"
	switch(location.station_map_colour)
		if (MAPC_SECURITY, MAPC_ARMOURY, MAPC_BRIG)
			area_color = "#ff0000"
			area_category = "security"
		if (MAPC_COMMAND)
			area_color = "#00ff00"
			area_category = "bridge"
		if (MAPC_ENGINEERING, MAPC_MECHLAB, MAPC_QUARTERMASTER, MAPC_MINING)
			area_color = "#ffff00"
			area_category = "engineering"
		if (MAPC_RESEARCH, MAPC_CHEMISTRY, MAPC_TOXINS, MAPC_TELESCI, MAPC_ARTLAB)
			area_color = "#8409ff"
			area_category = "research"
		if (MAPC_MEDICAL, MAPC_MEDLOBBY, MAPC_ROBOTICS, MAPC_MORGUE, MAPC_MEDRESEARCH, MAPC_PATHOLOGY)
			area_color = "#3838ff"
			area_category = "medical"
	//Allow maps to override either
	if(isnull(src.stripe_color))
		src.stripe_color = area_color
	if(isnull(src.phone_category))
		src.phone_category = area_category

	src.UpdateOverlays(image('icons/obj/machines/phones.dmi',"[src.dialicon]"), "dial")
	var/image/stripe_image = image('icons/obj/machines/phones.dmi',"[src.icon_state]-stripe")
	stripe_image.color = src.stripe_color
	stripe_image.appearance_flags = RESET_COLOR | PIXEL_SCALE
	src.UpdateOverlays(stripe_image, "stripe")
	UpdateIcon()

	src.RegisterSignal(src, COMSIG_CORD_RETRACT, PROC_REF(hang_up))
	src.RegisterSignal(src, COMSIG_PHONE_INBOUND_CONNECTION_CHECK, PROC_REF(inbound_connection_check))
	src.RegisterSignal(src, COMSIG_PHONE_OUTBOUND_CONNECTION_CHECK, PROC_REF(outbound_connection_check))
	src.RegisterSignal(src, COMSIG_PHONE_RING_START, PROC_REF(ring_start))
	src.RegisterSignal(src, COMSIG_PHONE_RING_STOP, PROC_REF(ring_stop))
	src.RegisterSignal(src, COMSIG_PHONE_INFO_UPDATED, PROC_REF(info_updated))
	START_TRACKING
	src.handset = new /obj/item/phone_handset(src)
	src.AddComponent(/datum/component/phone_controller, phone_id, phone_category, can_talk_across_z_levels, unlisted, stripe_color)
	src.AddComponent(/datum/component/phone_ui)
	src.AddComponent(/datum/component/phone_ringer)

/obj/machinery/phone/disposing()
	src.hang_up()
	src.RemoveComponentsOfType(/datum/component/phone_controller)
	src.RemoveComponentsOfType(/datum/component/phone_ui)
	src.RemoveComponentsOfType(/datum/component/phone_ringer)
	qdel(src.handset)
	src.UnregisterSignals(src, list(
		COMSIG_CORD_RETRACT,
		COMSIG_PHONE_RING_START,
		COMSIG_PHONE_RING_STOP,
		COMSIG_PHONE_INFO_UPDATED,
		COMSIG_PHONE_INBOUND_CONNECTION_CHECK,
		COMSIG_PHONE_OUTBOUND_CONNECTION_CHECK
	))
	STOP_TRACKING
	. = ..()

/obj/machinery/phone/proc/info_updated(datum/source, var/phone_name)
	src.phone_id = phone_name
	src.phone_category = PHONE.get_var(src, PHONE_CATEGORY)
	src.stripe_color = PHONE.get_var(src, PHONE_COLOR)

/obj/machinery/phone/proc/connect_wire()
	src.connected = TRUE
	PHONE.set_var(src, PHONE_UNLISTED, FALSE)
	if(src.answered)
		SEND_SIGNAL(src, COMSIG_PHONE_MICROPHONE_ENABLE)
		SEND_SIGNAL(src, COMSIG_PHONE_SPEAKER_ENABLE)

/obj/machinery/phone/proc/disconnect_wire()
	src.connected = FALSE
	PHONE.set_var(src, PHONE_UNLISTED, TRUE)
	SEND_SIGNAL(src, COMSIG_PHONE_MICROPHONE_DISABLE)
	SEND_SIGNAL(src, COMSIG_PHONE_SPEAKER_DISABLE)
	SEND_SIGNAL(src, COMSIG_PHONE_OUTBOUND_DISCONNECTION)

/obj/machinery/phone/was_deconstructed_to_frame(mob/user)
	src.hang_up()
	. = ..()

/obj/machinery/phone/get_desc()
	if (!isnull(src.phone_id))
		return " There is a small label on the phone that reads \"[phone_id]\"."

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
			src.disconnect_wire()
		else
			if (user)
				boutput(user,"You repair the line leading to the phone.")
			src.connect_wire()
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

		PHONE.set_var(src, PHONE_NAME, text)
		boutput(user, SPAN_NOTICE("You rename the phone to \"[src.phone_id]\"."))
		return

	. = ..()
	src._health -= P.force
	attack_particle(user, src)
	user.lastattacked = get_weakref(src)
	hit_twitch(src)
	playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)

	if (src._health <= 0)
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

	if(!src.handset)
		src.handset = new /obj/item/phone_handset(src)
	src.create_cord()
	user.put_in_hand_or_drop(src.handset)
	src.answered = TRUE

	src.icon_state = "[answered_icon]"
	src.UpdateIcon()
	playsound(user, 'sound/machines/phones/pick_up.ogg', 50, FALSE)

	if(!src.emagged)
		SEND_SIGNAL(src, COMSIG_PHONE_RING_STOP)
	if(src.connected)
		SEND_SIGNAL(src, COMSIG_PHONE_MICROPHONE_ENABLE)
		SEND_SIGNAL(src, COMSIG_PHONE_SPEAKER_ENABLE)
		SEND_SIGNAL(src, COMSIG_PHONE_OUTBOUND_SOUND, 'sound/machines/phones/remote_answer.ogg', 50, 0)

	if (user)
		if (src.connected)
			SEND_SIGNAL(src, COMSIG_PHONE_UI_INTERACT, user)
		else
			boutput(user,SPAN_ALERT("As you pick up the phone you notice that the cord has been cut!"))

/obj/machinery/phone/emag_act(mob/user, obj/item/card/emag/E)
	if (src.emagged)
		return FALSE
	if (user)
		boutput(user, SPAN_ALERT("You short out the ringer circuit on the [src]."))
	src.emagged = TRUE
	SEND_SIGNAL(src, COMSIG_PHONE_HANGUP)
	SEND_SIGNAL(src, COMSIG_PHONE_EMAG)
	return TRUE

/obj/machinery/phone/suicide(mob/user)
	if (!src.user_can_suicide(user))
		return FALSE

	if (ishuman(user))
		user.visible_message(SPAN_ALERT("<b>[user] bashes the [src] into [his_or_her(user)] head repeatedly!</b>"))
		user.TakeDamage("head", 150, 0)
		return TRUE

/obj/machinery/phone/proc/create_cord()
	src.AddComponent(/datum/component/cord, src.handset, base_offset_x = -4, base_offset_y = -1, range=48)

/obj/machinery/phone/proc/explode()
	src.blowthefuckup(strength = 2.5, delete = TRUE)

/obj/machinery/phone/proc/hang_up()
	src.answered = FALSE
	SEND_SIGNAL(src, COMSIG_PHONE_OUTBOUND_SOUND, 'sound/machines/phones/remote_hangup.ogg', 50, 0)
	SEND_SIGNAL(src, COMSIG_PHONE_UI_CLOSE)
	SEND_SIGNAL(src, COMSIG_PHONE_HANGUP)
	src.RemoveComponentsOfType(/datum/component/cord)
	src.ClearSpecificOverlays("cord_\ref[src]")
	if(src.handset && !src.handset.disposed)
	// just in case we're being deleted and the handset is already gone
		src.handset.force_drop(sever = TRUE)
		src.handset.set_loc(src)
	if(!src.emagged)
		src.icon_state = "[phone_icon]"
	else
		src.icon_state = "[ringing_icon]"
	src.UpdateIcon()
	playsound(src.loc, 'sound/machines/phones/hang_up.ogg', 50, 0)

/obj/machinery/phone/proc/inbound_connection_check()
	if(!src.connected || src.emagged)
		return PHONE_FAILED
	if(src.answered)
		return PHONE_FAILED

/obj/machinery/phone/proc/outbound_connection_check()
	if(!src.connected || src.emagged)
		return PHONE_FAILED

/obj/machinery/phone/proc/ring_start()
	if(!src.answered) // in case we're emagged while answered
		src.icon_state = "[src.ringing_icon]"
	UpdateIcon()

/obj/machinery/phone/proc/ring_stop()
	if(src.answered)
		src.icon_state = "[answered_icon]"
	else
		src.icon_state = "[phone_icon]"
	UpdateIcon()

/obj/machinery/phone/update_icon()
	. = ..()
	src.UpdateOverlays(src.SafeGetOverlayImage("stripe", 'icons/obj/machines/phones.dmi',"[src.icon_state]-stripe"), "stripe")

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
