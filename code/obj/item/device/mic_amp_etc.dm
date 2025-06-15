TYPEINFO(/obj/item/device/microphone)
	start_listen_effects = list(LISTEN_EFFECT_MICROPHONE)
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD_RANGE_1)
	start_listen_languages = list(LANGUAGE_ALL)

/obj/item/device/microphone
	name = "microphone"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "mic"
	item_state = "mic"

	HELP_MESSAGE_OVERRIDE("Use in-hand to turn on or off. If on, speech will play through any nearby loudspeakers.")

	var/max_font = 8
	var/font_amp = 4
	var/on = 0

	get_desc()
		..()
		. += "It's currently [src.on ? "on" : "off"]."

	attack_self(mob/user as mob)
		src.on = !(src.on)
		tooltip_rebuild = 1
		user.show_text("You switch [src] [src.on ? "on" : "off"].")
		if (src.on && prob(5))
			if (locate(/obj/loudspeaker) in range(2, user))
				for_by_tcl(S, /obj/loudspeaker)
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

TYPEINFO(/obj/loudspeaker)
	mats = 15

/obj/loudspeaker
	name = "loudspeaker"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "loudspeaker"
	anchored = ANCHORED
	density = 1
	object_flags = NO_BLOCK_TABLE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL

	HELP_MESSAGE_OVERRIDE("Speech into nearby microphones will be played over this loudspeaker.<br>If damaged, use a <b>screwdriver</b> to repair.")

/obj/loudspeaker/New()
	. = ..()
	START_TRACKING
	src.AddComponent(/datum/component/obj_projectile_damage)

/obj/loudspeaker/disposing()
	. = ..()
	STOP_TRACKING

/obj/loudspeaker/updateHealth(prevHealth)
	if (src._health > 0)
		var/health_pct = src._health / src._max_health
		var/prev_pct = prevHealth / src._max_health
		if (health_pct <= 0.25 && prev_pct > 0.25)
			src.visible_message("[src] [pick("crackles", "buzzes")] woefully!!")
			playsound(src, pick('sound/machines/glitch1.ogg', 'sound/machines/glitch2.ogg', 'sound/machines/glitch3.ogg', 'sound/machines/glitch4.ogg', 'sound/machines/glitch5.ogg'), 30, TRUE)
			animate_shake(src,5,rand(3,8),rand(3,8))
		else if (health_pct <= 0.5 && prev_pct > 0.5)
			src.visible_message("[src] [pick("warbles", "fizzes")] weakly!")
			playsound(src, 'sound/machines/romhack3.ogg', 60, TRUE)
			animate_shake(src,3,rand(2,4),rand(2,4))
	. = ..()

/obj/loudspeaker/onDestroy()
	var/obj/decal/cleanable/gib = make_cleanable(/obj/decal/cleanable/machine_debris, src.loc)
	gib.streak_cleanable()
	playsound(src, 'sound/impact_sounds/locker_break.ogg', 80, TRUE)
	. = ..()

/obj/loudspeaker/attackby(obj/item/I, mob/user)
	if (isscrewingtool(I))
		if (src._health < src._max_health)
			src.visible_message(SPAN_NOTICE("[user] begins repairing [src]."))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, PROC_REF(repair), list(user), I.icon, I.icon_state, null,\
					INTERRUPT_MOVE | INTERRUPT_ACTION | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACT)
		else
			boutput(user, SPAN_NOTICE("[src] seems fully repaired!"))
		return
	. = ..()
	user.lastattacked = get_weakref(src)
	attack_particle(user,src)
	hit_twitch(src)
	if (I.hitsound)
		playsound(src.loc, I.hitsound, 50, 1)
	if (I.force)
		var/damage = I.force
		damage /= 3
		if (user.is_hulk())
			damage *= 4
		if (iscarbon(user))
			var/mob/living/carbon/C = user
			if (C.bioHolder && C.bioHolder.HasEffect("strong"))
				damage *= 2
		if (damage >= 1)
			src.changeHealth(-damage)


/obj/loudspeaker/proc/repair(user)
		src.visible_message(SPAN_NOTICE("[user] repairs some of the damage on [src]!"))
		src.changeHealth(15)
