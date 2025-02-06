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

	New()
		..() // Set up power usage, subscribe to loop, yada yada yada
		src.icon_state = "[phone_icon]"
		var/area/location = get_area(src)

		// Give the phone an appropriate departmental color. Jesus christ thats fancy.
		if(isnull(stripe_color)) // maps can override it now
			if(istype(location,/area/station/security))
				stripe_color = "#ff0000"
				phone_category = "security"
			else if(istype(location,/area/station/bridge))
				stripe_color = "#00ff00"
				phone_category = "bridge"
			else if(istype(location, /area/station/engine) || istype(location, /area/station/quartermaster) || istype(location, /area/station/mining))
				stripe_color = "#ffff00"
				phone_category = "engineering"
			else if(istype(location, /area/station/science))
				stripe_color = "#8409ff"
				phone_category = "research"
			else if(istype(location, /area/station/medical))
				stripe_color = "#3838ff"
				phone_category = "medical"
			else
				stripe_color = "#b65f08"
				phone_category = "uncategorized"
		else
			phone_category = "uncategorized"
		src.UpdateOverlays(image('icons/obj/machines/phones.dmi',"[dialicon]"), "dial")
		var/image/stripe_image = image('icons/obj/machines/phones.dmi',"[src.icon_state]-stripe")
		stripe_image.color = stripe_color
		stripe_image.appearance_flags = RESET_COLOR | PIXEL_SCALE
		src.UpdateOverlays(stripe_image, "stripe")
		// Generate a name for the phone.

		if(isnull(src.phone_id))
			var/temp_name = src.name
			if(temp_name == initial(src.name) && location)
				temp_name = location.name
			var/name_counter = 1
			for_by_tcl(M, /obj/machinery/phone)
				if(M.phone_id && M.phone_id == temp_name)
					name_counter++
			if(name_counter > 1)
				temp_name = "[temp_name] [name_counter]"
			src.phone_id = temp_name

		src.handset = new /obj/item/phone_handset(src)
		src.AddComponent(/datum/component/cord, src.handset, base_offset_x = -4, base_offset_y = -1)

		RegisterSignal(src, COMSIG_CORD_RETRACT, PROC_REF(hang_up))

		START_TRACKING

	disposing()

		if (linked)
			linked.linked = null
		linked = null

		if (handset)
			handset.parent = null
		handset = null

		STOP_TRACKING
		UnregisterSignal(src, COMSIG_CORD_RETRACT)
		..()

	get_desc()
		if(!isnull(src.phone_id))
			return " There is a small label on the phone that reads \"[src.phone_id]\"."

	attack_ai(mob/user as mob)
		return

	attackby(obj/item/P, mob/living/user)
		if(istype(P, /obj/item/phone_handset))
			var/obj/item/phone_handset/PH = P
			if(PH.parent == src)
				hang_up()
			return
		if(issnippingtool(P))
			if(src.connected)
				if(user)
					boutput(user,"You cut the phone line leading to the phone.")
				src.connected = FALSE
			else
				if(user)
					boutput(user,"You repair the line leading to the phone.")
				src.connected = TRUE
			return
		if(ispulsingtool(P))
			if(src.labelling)
				return
			src.labelling = TRUE
			var/t = tgui_input_text(user, "What do you want to name this phone?", null, null, max_length = 50)
			src.labelling = FALSE
			t = sanitize(html_encode(t))
			if(!t)
				return
			if(!in_interact_range(src, user))
				return
			src.phone_id = t
			boutput(user, SPAN_NOTICE("You rename the phone to \"[src.phone_id]\"."))
			return
		..()
		src._health -= P.force
		attack_particle(user,src)
		user.lastattacked = src
		hit_twitch(src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		if(src._health <= 0)
			if(src.linked)
				hang_up()
			src.gib(src.loc)
			qdel(src)

	// Attempt to pick up the handset
	attack_hand(mob/living/user)
		..(user)
		if (src.answered)
			return

		if (src.emagged)
			src.explode()
			return

		user.put_in_hand_or_drop(src.handset)
		src.answered = TRUE

		src.icon_state = "[answered_icon]"
		UpdateIcon()
		playsound(user, 'sound/machines/phones/pick_up.ogg', 50, FALSE)

		if(!src.ringing) // we are making an outgoing call
			if(src.connected)
				if(user)
					ui_interact(user)
			else
				if(user)
					boutput(user,SPAN_ALERT("As you pick up the phone you notice that the cord has been cut!"))
		else
			src.ringing = FALSE
			src.linked.ringing = FALSE
			if(src.linked.handset.get_holder() && GET_DIST(src.linked.handset,src.linked.handset.get_holder()) < 1)
				src.linked.handset.get_holder().playsound_local(src.linked.handset.get_holder(),'sound/machines/phones/remote_answer.ogg',50,0)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		src.icon_state = "[ringing_icon]"
		UpdateIcon()
		if (!src.emagged)
			if(user)
				boutput(user, SPAN_ALERT("You short out the ringer circuit on the [src]."))
			src.emagged = TRUE
			// pick a random phone
			src.caller_id_message = "<span style='color: #cccccc;'>???</span>"
			var/list/phonebook = list()
			for_by_tcl(P, /obj/machinery/phone)
				if(P.unlisted)
					continue
				phonebook += P
			if (length(phonebook))
				var/obj/machinery/phone/prank = pick(phonebook)
				src.caller_id_message = "<span style='color: [prank.stripe_color];'>[prank.phone_id]</span>"
			return TRUE
		return FALSE

	process()
		if(src.emagged)
			playsound(src.loc,'sound/machines/phones/ring_incoming.ogg' ,100,1)
			if(!src.answered)
				src.obj_speak("Call from [src.caller_id_message].")
				src.icon_state = "[ringing_icon]"
				UpdateIcon()
			return

		if(!src.connected)
			return

		src.last_ring++
		if(..())
			return

		if(src.ringing) // Are we calling someone
			if(src.linked && src.linked.answered == FALSE)
				if(src.last_ring >= 2)
					src.last_ring = 0
					if(src.handset && src.handset.get_holder() && GET_DIST(src.handset,src.handset.get_holder()) < 1)
						src.handset.get_holder().playsound_local(src.handset.get_holder(),'sound/machines/phones/ring_outgoing.ogg' ,40,0)
			else
				if(src.last_ring >= 2)
					playsound(src.loc,'sound/machines/phones/ring_incoming.ogg' ,40,0)
					src.icon_state = "[ringing_icon]"
					UpdateIcon()
					src.last_ring = 0
					src.obj_speak("Call from [src.caller_id_message].")

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Phone")
			ui.open()

	ui_data(mob/user)
		var/list/list/list/phonebook = list()
		for_by_tcl(P, /obj/machinery/phone)
			var/match_found = FALSE
			if(P.unlisted || P == src)
				continue
			if (!(src.can_talk_across_z_levels && P.can_talk_across_z_levels) && (get_z(P) != get_z(src)))
				continue
			if(length(phonebook))
				for(var/i in 1 to length(phonebook))
					if(phonebook[i]["category"] == P.phone_category)
						match_found = TRUE
						phonebook[i]["phones"] += list(list(
							"id" = P.phone_id
						))
						break
			if(!match_found)
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

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch (action)
			if ("call")
				if(src.dialing == TRUE || src.linked)
					return
				. = TRUE
				src.add_fingerprint(usr)
				var/id = params["target"]
				for_by_tcl(P, /obj/machinery/phone)
					if(P.phone_id == id)
						src.call_other(P)
						return
				boutput(usr, SPAN_ALERT("Unable to connect!"))

	update_icon()
		. = ..()
		src.UpdateOverlays(src.SafeGetOverlayImage("stripe", 'icons/obj/machines/phones.dmi',"[src.icon_state]-stripe"), "stripe")

	proc/explode()
		src.blowthefuckup(strength = 2.5, delete = TRUE)

	proc/hang_up()
		src.answered = FALSE
		if(src.linked) // Other phone needs updating
			if(!src.linked.answered) // nobody picked up. Go back to not-ringing state
				src.linked.icon_state = "[src.linked.phone_icon]"
				src.linked.UpdateIcon()
			else if(src.linked.handset && src.linked.handset.get_holder() && GET_DIST(src.linked.handset,src.linked.handset.get_holder()) < 1)
				src.linked.handset.get_holder().playsound_local(src.linked.handset.get_holder(),'sound/machines/phones/remote_hangup.ogg',50,0)
			src.linked.ringing = FALSE
			src.linked.linked = null
			src.linked = null
		src.RemoveComponentsOfType(/datum/component/cord)
		src.ringing = FALSE
		src.handset?.force_drop(sever=TRUE)
		src.handset.loc = src
		src.icon_state = "[phone_icon]"
		tgui_process.close_uis(src)
		UpdateIcon()
		playsound(src.loc,'sound/machines/phones/hang_up.ogg' ,50,0)

	// This makes phones do that thing that phones do
	proc/call_other(var/obj/machinery/phone/target)
		// Dial the number
		if(!src.handset)
			return
		src.dialing = TRUE
		tgui_process?.update_uis(src)
		if(src.handset.get_holder() && GET_DIST(src.handset,src.handset.get_holder()) < 1)
			src.handset.get_holder()?.playsound_local(src.handset.get_holder(),'sound/machines/phones/dial.ogg' ,50,0)
		src.last_called = target.unlisted ? "Undisclosed" : "[target.phone_id]"
		target.caller_id_message = "<span style='color: [src.stripe_color];'>[src.phone_id]</span>"
		SPAWN(4 SECONDS)
			// Is it busy?
			if(target.answered || target.linked || !target.connected || !src.answered)
				playsound(src.loc,'sound/machines/phones/phone_busy.ogg' ,50,0)
				src.dialing = FALSE
				return

			// Start ringing the other phone (handled by process)
			src.linked = target
			target.linked = src
			src.ringing = TRUE
			src.linked.ringing = TRUE
			src.dialing = FALSE
			src.linked.last_called = src.unlisted ? "Undisclosed" : "[src.phone_id]"
			return

/obj/machinery/phone/custom_suicide = TRUE
/obj/machinery/phone/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return FALSE
	if (ishuman(user))
		user.visible_message(SPAN_ALERT("<b>[user] bashes the [src] into [his_or_her(user)] head repeatedly!</b>"))
		user.TakeDamage("head", 150, 0)
		return TRUE

// Item generated when someone picks up a phone // NO ITS THE SAME HANDSET EVERY TIME NOW WHY
/obj/item/phone_handset

	name = "phone handset"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "I wonder if the last crewmember to use this washed their hands before touching it."
	var/obj/machinery/phone/parent = null
	flags = TALK_INTO_HAND
	w_class = W_CLASS_TINY
	var/icon/handset_icon = null

	New(var/obj/machinery/phone/parent_phone)
		if(!parent_phone)
			return
		..()
		icon_state = "handset"
		src.parent = parent_phone
		var/image/stripe_image = image('icons/obj/machines/phones.dmi',"[src.icon_state]-stripe")
		stripe_image.color = parent_phone.stripe_color
		stripe_image.appearance_flags = RESET_COLOR | PIXEL_SCALE
		src.color = parent_phone.color
		src.UpdateOverlays(stripe_image, "stripe")
		src.handset_icon = getFlatIcon(src)
		processing_items.Add(src)

	proc/get_holder()
		RETURN_TYPE(/mob)
		if(ismob(src.loc))
			. = src.loc

	update_icon()
		. = ..()
		src.UpdateOverlays(src.SafeGetOverlayImage("stripe", 'icons/obj/machines/phones.dmi',"[src.icon_state]-stripe"), "stripe")

	disposing()
		parent = null
		processing_items.Remove(src)
		..()

	process()
		if(!src.parent)
			qdel(src)
			return
		if(src.parent.answered && BOUNDS_DIST(src, src.parent) > 0)
			if(src.get_holder())
				boutput(src.get_holder(),SPAN_ALERT("The phone cord reaches it limit and the handset is yanked back to its base!"))
			src.parent.hang_up()
			processing_items.Remove(src)


	talk_into(mob/M as mob, text, secure, real_name, lang_id)
		..()
		if(GET_DIST(src, get_holder()) > 0 || !src.parent.linked || !src.parent.linked.handset) // Guess they dropped it? *shrug
			return

		var/heard_name = M.get_heard_name(just_name_itself=TRUE)
		if(M.mind)
			heard_name = "<span class='name' data-ctx='\ref[M.mind]'>[heard_name]</span>"

		var/obj/item/phone_handset/listener_handset = src.parent.linked.handset

		var/mob/listener = listener_handset.get_holder()
		if(listener?.client)
			var/phone_ident = "\[ <span style=\"color:[src.parent.stripe_color]\">[bicon(src.handset_icon)] [src.parent.phone_id]</span> \]"
			var/said_message = SPAN_SAY("[SPAN_BOLD("[heard_name] [phone_ident]")]  [SPAN_MESSAGE(M.say_quote(text[1]))]")
			if (listener.client.holder && ismob(M) && M.mind)
				said_message = "<span class='adminHearing' data-ctx='[listener.client.chatOutput.getContextFlags()]'>[said_message]</span>"

			// chat feedback to let talker know when they are speaking over the phone
			M.show_message(said_message, 2)

			if(GET_DIST(src.parent.linked.handset,src.parent.linked.handset.get_holder())<1)
				var/heard_voice = M.voice_name
				if(M.mind)
					heard_voice = "<span class='name' data-ctx='\ref[M.mind]'>[heard_voice]</span>"
				if(!listener.say_understands(M, lang_id))
					said_message = SPAN_SAY("[SPAN_BOLD("[heard_voice] [phone_ident]")] [SPAN_MESSAGE(M.voice_message)]")
					if (listener.client.holder && ismob(M) && M.mind)
						said_message = "<span class='adminHearing' data-ctx='[listener.client.chatOutput.getContextFlags()]'>[said_message]</span>"
				listener.show_message(said_message, 2)

			// intercoms overhear phone conversations
			for (var/obj/item/device/radio/intercom/I in range(3, listener))
				I.talk_into(M, text, null, M.get_heard_name(just_name_itself=TRUE), lang_id)

	// attack_hand(mob/user)
	// 	. = ..()
	// 	src.parent?.draw_cord()

	// dropped(mob/user)
	// 	. = ..()
	// 	src.parent?.draw_cord()

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
