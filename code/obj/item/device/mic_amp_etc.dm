TYPEINFO(/obj/item/device/microphone)
	start_listen_effects = list(LISTEN_EFFECT_MICROPHONE)
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD_RANGE_1)
	start_listen_languages = list(LANGUAGE_ALL)

/obj/item/device/microphone
	name = "microphone"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "mic"
	item_state = "mic"

	var/max_font = 8
	var/font_amp = 4
	var/on = 0

	get_desc()
		..()
		. += "It's currently [src.on ? "on" : "off"]."

	attack_self(mob/user as mob)
		src.on = !(src.on)
		tooltip_rebuild = TRUE
		user.show_text("You switch [src] [src.on ? "on" : "off"].")
		if (src.on && prob(5))
			if (locate(/obj/machinery/loudspeaker) in range(2, user))
				for_by_tcl(S, /obj/machinery/loudspeaker)
					if(!IN_RANGE(S, user, 7)) continue
					S.visible_message(SPAN_ALERT("[S] lets out a horrible [pick("shriek", "squeal", "noise", "squawk", "screech", "whine", "squeak")]!"))
					playsound(S.loc, 'sound/items/mic_feedback.ogg', 30, 1)

	attack_hand(mob/user)
		if (user.find_in_hand(src) && src.on)
			playsound(user, 'sound/misc/miccheck.ogg', 30, TRUE)
			user.visible_message(SPAN_EMOTE("[user] taps [src] with [his_or_her(user)] hand."))
		else
			return ..()


TYPEINFO(/obj/mic_stand)
	mats = 10

/obj/mic_stand
	name = "microphone stand"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "micstand"
	layer = FLY_LAYER
	var/obj/item/device/microphone/myMic = null

	New()
		SPAWN(1 DECI SECOND)
			if (!myMic)
				myMic = new(src)
		return ..()

	attack_hand(mob/user)
		if (!myMic)
			return ..()
		user.put_in_hand_or_drop(myMic)
		myMic = null
		src.UpdateIcon()
		return ..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/microphone))
			if (myMic)
				user.show_text("There's already a microphone on [src]!", "red")
				return
			user.show_text("You place [W] on [src].", "blue")
			myMic = W
			user.u_equip(W)
			W.set_loc(src)
			src.UpdateIcon()
		else
			return ..()

	update_icon()
		if (myMic)
			switch (myMic.icon_state)
				if ("radio_mic1")
					src.icon_state = "micstand-b"
				if ("radio_mic2")
					src.icon_state = "micstand-r"
				else
					src.icon_state = "micstand"
		else
			src.icon_state = "micstand-empty"

TYPEINFO(/obj/machinery/loudspeaker)
	mats = 15

/obj/machinery/loudspeaker
	name = "loudspeaker"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "loudspeaker"
	anchored = ANCHORED
	density = 1
	object_flags = NO_BLOCK_TABLE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL

	HELP_MESSAGE_OVERRIDE("Speech into nearby microphones will be played over this loudspeaker.")

/obj/machinery/loudspeaker/New()
	. = ..()
	START_TRACKING
	src.AddComponent(/datum/component/obj_projectile_damage)
	src.UnsubscribeProcess()

/obj/machinery/loudspeaker/disposing()
	. = ..()
	STOP_TRACKING

/obj/machinery/loudspeaker/set_broken()
	. = ..()
	if(.) return
	src.SubscribeToProcess()
	AddComponent(/datum/component/equipment_fault/elecflash, tool_flags = TOOL_SCREWING | TOOL_WIRING | TOOL_SNIPPING)
	src.visible_message(SPAN_ALERT("[src] sparks and pops, shorting out!"))
	playsound(src, 'sound/effects/screech_tone.ogg', 70, 2, pitch=0.5)
	for (var/mob/living/M in hearers(5, src))
		M.do_disorient(50, target_type = DISORIENT_EAR, remove_stamina_below_zero = TRUE)

/obj/machinery/loudspeaker/ex_act(severity)
	. = ..()
	if(QDELETED(src))
		return
	switch(severity)
		if (2)
			changeHealth(rand(-25, -35))
		if (3)
			changeHealth(rand(-5, -15))

/obj/machinery/loudspeaker/process(mult)
	. = ..()
	if (!(src.status & BROKEN))
		src.UnsubscribeProcess()

/obj/machinery/loudspeaker/changeHealth(change)
	. = ..()
	if(prob(100*(src._health/src._max_health)))
		src.set_broken()
