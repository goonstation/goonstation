TYPEINFO(/obj/machinery/phone)
	mats = 25

/obj/machinery/phone
	name = "phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A landline phone. In space. Where there is no land. Hmm."
	icon_state = "phone"
	anchored = 1
	density = 0
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS | DECON_MULTITOOL
	_health = 25
	color = null
	var/can_talk_across_z_levels = 0
	var/phone_id = null
	var/obj/machinery/phone/linked = null
	var/ringing = FALSE
	var/answered = FALSE
	var/last_ring = 0
	var/connected = TRUE
	var/emagged = FALSE
	var/dialing = FALSE
	var/labelling = 0
	var/unlisted = FALSE
	var/obj/item/phone_handset/handset = null
	var/phoneicon = "phone"
	var/ringingicon = "phone_ringing"
	var/answeredicon = "phone_answered"
	var/dialicon = "phone_dial"
	var/stripe_color = null
	var/phone_category = null

	New()
		..() // Set up power usage, subscribe to loop, yada yada yada
		src.icon_state = "[phoneicon]"
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

		src.desc += " There is a small label on the phone that reads \"[src.phone_id]\""

		START_TRACKING

	update_icon()
		. = ..()
		src.UpdateOverlays(src.SafeGetOverlayImage("stripe", 'icons/obj/machines/phones.dmi',"[src.icon_state]-stripe"), "stripe")

	disposing()

		if (linked)
			linked.linked = null
		linked = null

		if (handset)
			handset.parent = null
		handset = null

		STOP_TRACKING
		..()

	// Attempt to pick up the handset
	attack_hand(mob/living/user)
		..(user)
		if (src.answered)
			return

		if (src.emagged)
			src.explode()
			return

		src.handset = new /obj/item/phone_handset(src,user)
		user.put_in_hand_or_drop(src.handset)
		src.answered = TRUE

		src.icon_state = "[answeredicon]"
		UpdateIcon()
		playsound(user, 'sound/machines/phones/pick_up.ogg', 50, 0)

		if(src.ringing == FALSE) // we are making an outgoing call
			if(src.connected == TRUE)
				if(user)
					ui_interact(user)
			else
				if(user)
					boutput(user,"<span class='alert'>As you pick up the phone you notice that the cord has been cut!</span>")
		else
			src.ringing = FALSE
			src.linked.ringing = FALSE
			if(src.linked.handset.holder)
				src.linked.handset.holder.playsound_local(src.linked.handset.holder,'sound/machines/phones/remote_answer.ogg',50,0)

	attack_ai(mob/user as mob)
		return

	attackby(obj/item/P, mob/living/user)
		if(istype(P, /obj/item/phone_handset))
			var/obj/item/phone_handset/PH = P
			if(PH.parent == src)
				user.drop_item(PH)
				qdel(PH)
				hang_up()
			return
		if(issnippingtool(P))
			if(src.connected == TRUE)
				if(user)
					boutput(user,"You cut the phone line leading to the phone.")
				src.connected = FALSE
			else
				if(user)
					boutput(user,"You repair the line leading to the phone.")
				src.connected = TRUE
			return
		if(ispulsingtool(P))
			if(src.labelling == TRUE)
				return
			src.labelling = TRUE
			var/t = input(user, "What do you want to name this phone?", null, null) as null|text
			t = sanitize(html_encode(t))
			if(t && length(t) > 50)
				return
			if(t)
				src.phone_id = t
			src.labelling = 0
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
			if (src.emagged)
				src.explode()
			else
				src.gib(src.loc)
			qdel(src)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		src.icon_state = "[ringingicon]"
		UpdateIcon()
		if (!src.emagged)
			if(user)
				boutput(user, "<span class='alert'>You short out the ringer circuit on the [src].</span>")
			src.emagged = TRUE
			return TRUE
		return FALSE

	process()
		if(src.emagged)
			playsound(src.loc,'sound/machines/phones/ring_incoming.ogg' ,100,1)
			if(!src.answered)
				src.icon_state = "[ringingicon]"
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
					if(src.handset && src.handset.holder)
						src.handset.holder.playsound_local(src.handset.holder,'sound/machines/phones/ring_outgoing.ogg' ,40,0)
			else
				if(src.last_ring >= 2)
					playsound(src.loc,'sound/machines/phones/ring_incoming.ogg' ,40,0)
					src.icon_state = "[ringingicon]"
					UpdateIcon()
					src.last_ring = 0

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Phone")
			ui.open()

	ui_data(mob/user)
		var/list/phonebook = list()
		for_by_tcl(P, /obj/machinery/phone)
			if (P.unlisted) continue
			var/list/this_phone_data = list(
				"category" = P.phone_category,
				"id" = P.phone_id
			)
			phonebook += list(this_phone_data)
		sortList(phonebook, /proc/cmp_phone_data)

		. = list(
			"inCall" = src.linked,
			"dialing" = src.dialing,
			"name" = src.name,
			"phonebook" = phonebook,
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch (action)
			if ("call")
				if(src.dialing == TRUE || src.linked)
					return
				var/id = params["target"]
				for_by_tcl(P, /obj/machinery/phone)
					if(P.phone_id == id)
						src.call_other(P)
						. = TRUE
						return
				boutput(usr, "<span class='alert'>Unable to connect!</span>")
		src.add_fingerprint(usr)

	proc/explode()
		src.blowthefuckup(strength = 2.5, delete = TRUE)

	proc/hang_up()
		src.answered = FALSE
		if(src.linked) // Other phone needs updating
			if(!src.linked.answered) // nobody picked up. Go back to not-ringing state
				src.linked.icon_state = "[src.linked.phoneicon]"
				src.linked.UpdateIcon()
			else if(src.linked.handset && src.linked.handset.holder)
				src.linked.handset.holder.playsound_local(src.linked.handset.holder,'sound/machines/phones/remote_hangup.ogg',50,0)
			src.linked.ringing = FALSE
			src.linked.linked = null
			src.linked = null
		src.ringing = FALSE
		src.handset = null
		src.icon_state = "[phoneicon]"
		UpdateIcon()
		playsound(src.loc,'sound/machines/phones/hang_up.ogg' ,50,0)

	// This makes phones do that thing that phones do
	proc/call_other(var/obj/machinery/phone/target)
		// Dial the number
		if(!src.handset)
			return
		src.dialing = TRUE
		src.handset.holder?.playsound_local(src.handset.holder,'sound/machines/phones/dial.ogg' ,50,0)
		SPAWN(4 SECONDS)
			// Is it busy?
			if(target.answered || target.linked || target.connected == FALSE)
				playsound(src.loc,'sound/machines/phones/phone_busy.ogg' ,50,0)
				src.dialing = FALSE
				return

			// Start ringing the other phone (handled by process)
			src.linked = target
			target.linked = src
			src.ringing = TRUE
			src.linked.ringing = TRUE
			src.dialing = FALSE
			return


/obj/machinery/phone/custom_suicide = TRUE
/obj/machinery/phone/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return FALSE
	if (ishuman(user))
		user.visible_message("<span class='alert'><b>[user] bashes the [src] into their head repeatedly!</b></span>")
		user.TakeDamage("head", 150, 0)
		return TRUE

// Item generated when someone picks up a phone
/obj/item/phone_handset

	name = "phone handset"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "I wonder if the last crewmember to use this washed their hands before touching it."
	var/obj/machinery/phone/parent = null
	var/mob/holder = null //GC WOES (just dont use this var, get holder using loc)
	flags = TALK_INTO_HAND
	w_class = W_CLASS_TINY

	New(var/obj/machinery/phone/parent_phone, var/mob/living/picker_upper)
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
		if(picker_upper)
			src.holder = picker_upper
		processing_items.Add(src)

	update_icon()
		. = ..()
		src.UpdateOverlays(src.SafeGetOverlayImage("stripe", 'icons/obj/machines/phones.dmi',"[src.icon_state]-stripe"), "stripe")

	disposing()
		parent = null
		holder = null
		processing_items.Remove(src)
		..()

	process()
		if(!src.parent)
			qdel(src)
			return
		if(src.parent.answered == TRUE && BOUNDS_DIST(src, src.parent) > 0)
			boutput(src.holder,"<span class='alert'>The phone cord reaches it limit and the handset is yanked back to its base!</span>")
			src.holder.drop_item(src)
			src.parent.hang_up()
			processing_items.Remove(src)
			qdel(src)

	talk_into(mob/M as mob, text, secure, real_name, lang_id)
		..()
		if(GET_DIST(src,holder) > 0 || !src.parent.linked || !src.parent.linked.handset) // Guess they dropped it? *shrug
			return
		var/processed = "<span class='game say'><span class='bold'>[M.name] \[<span style=\"color:[src.color]\"> [bicon(src)] [src.parent.phone_id]</span>\] says, </span> <span class='message'>\"[text[1]]\"</span></span>"
		var/mob/T = src.parent.linked.handset.holder
		if(T?.client)
			T.show_message(processed, 2)
			M.show_message(processed, 2)

			for (var/obj/item/device/radio/intercom/I in range(3, T))
				I.talk_into(M, text, null, M.real_name, lang_id)

	// Attempt to pick up the handset
	attack_hand(mob/living/user)
		..(user)
		holder = user

TYPEINFO(/obj/machinery/phone/wall)
	mats = 25

/obj/machinery/phone/wall
	name = "wall phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A landline phone. In space. Where there is no land. Hmm."
	icon_state = "wallphone"
	anchored = TRUE
	density = 0
	_health = 50
	phoneicon = "wallphone"
	ringingicon = "wallphone_ringing"
	answeredicon = "wallphone_answered"
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

//
//		----------------- CELL PHONE STUFF STARTS HERE ---------------------
//


/*
		Radio Antennas. Cell phones require a signal to work!


/var/global/list/radio_antennas = list()

/obj/machinery/radio_antenna
	icon='icons/obj/large/32x64.dmi'
	icon_state = "commstower"
	var/range = 10
	var/active = 0

	process()
		..()

	proc/get_max_range()
		return range * 5

	proc/process_message()

/obj/machinery/radio_antenna/large
	range = 40

TYPEINFO(/obj/item/phone/cellphone)
	mats = 25

/obj/item/phone/cellphone
	icon_state = "cellphone"
	_health = 20
	var/can_talk_across_z_levels = 0
	var/phone_id = null
	var/ringmode = 0 // 0 for silent, 1 for vibrate, 2 for ring
	var/ringing = 0
	var/answered = 0
	var/last_ring = 0
	var/dialing = 0
	var/labelling = 0
	var/chui/window/phonecall/phonebook
	var/phoneicon = "cellphone"
	var/ringingicon = "cellphone_ringing"
	var/answeredicon = "cellphone_answered"
	var/obj/item/ammo/power_cell/cell = new /obj/item/ammo/power_cell/med_power
	var/activated = 0


	New()
		..()

	attackby(obj/item/P, mob/living/user)
		if(istype(P,/obj/item/card/id))
			if(src.activated)
				if(alert("Do you want to un-register this phone?","yes","no") == "yes")
					registered = 0
					phone_id = ""
					phonelist.Remove(src)
			else
				var/obj/item/card/id/new_id = obj
				user.show_text("Activating the phone. Please wait!","blue")
				actions.start(new/datum/action/bar/icon/activate_cell_phone(src.icon_state,src,new_id), user)

		..()
		src._health -= P.force
		if(src._health <= 0)
			if(src.linked)
				hang_up()
			src.gib(src.loc)
			qdel(src)


	proc/ring()

	proc/talk_into()


	proc/find_nearest_radio_tower()
		var/min_distance = inf
		var/nearest_tower = null
		for(var/machinery/radio_tower/tower in radio_antennas)
			if(!tower.active || tower.z != src.z)
				continue
			if(max(abs(tower.x - src.x),abs(tower.y - src.y) < nearest_tower)
				nearest_tower = tower
		return nearest_tower


/obj/item/phone/cellphone/bananaphone
	name = "Banana Phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A cellular, bananular phone."
	icon_state = "bananaphone"
	phoneicon = "bananaphone"
	ringingicon = "bananaphone_ringing"
	answeredicon = "bananaphone_answered"

	ring()

/datum/action/bar/icon/activate_cell_phone
	duration = 50
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "activate_cell_phone"
	icon = 'icons/obj/machines/phones.dmi'
	icon_state = "cellphone"
	var/obj/item/cellphone/phone
	var/registering_name

	New(icon,newphone,newid_name)
		icon_state = icon
		phone = newphone
		registering_name = newid_name
		..()


	onEnd()
		phone.registered = 1
		phone.phone_id = "[id.registered]'s Cell Phone"
		phonelist.Add(phone)
		..()

*/
