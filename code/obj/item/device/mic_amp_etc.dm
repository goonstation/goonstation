
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
		tooltip_rebuild = 1
		user.show_text("You switch [src] [src.on ? "on" : "off"].")
		if (src.on && prob(5))
			if (locate(/obj/loudspeaker) in range(2, user))
				for_by_tcl(S, /obj/loudspeaker)
					if(!IN_RANGE(S, user, 7)) continue
					S.visible_message("<span class='alert'>[S] lets out a horrible [pick("shriek", "squeal", "noise", "squawk", "screech", "whine", "squeak")]!</span>")
					playsound(S.loc, 'sound/items/mic_feedback.ogg', 30, 1)

	attack_hand(mob/user)
		if (user.find_in_hand(src) && src.on)
			playsound(user, 'sound/misc/miccheck.ogg', 30, 1)
			user.visible_message("<span class='emote'>[user] taps [src] with [his_or_her(user)] hand.</span>")
		else
			return ..()

	hear_talk(mob/M as mob, msg, real_name, lang_id)
		if (!src.on)
			return
		var/turf/T = get_turf(src)
		if (M in range(1, T))
			src.talk_into(M, msg, null, real_name, lang_id)

	talk_into(mob/M as mob, messages, param, real_name, lang_id)
		if (!src.on)
			return
		var/speakers = 0
		var/turf/T = get_turf(src)
		for_by_tcl(S, /obj/loudspeaker)
			if(!IN_RANGE(S, T, 7)) continue
			speakers ++
		if (!speakers)
			return
		speakers += font_amp // 2 ain't huge so let's give ourselves a little boost
		var/stuff = M.say_quote(messages[1])
		var/stuff_b = M.say_quote(messages[2])
		var/list/mobs_messaged = list()
		for_by_tcl(S, /obj/loudspeaker)
			if(!IN_RANGE(S, T, 7)) continue
			for (var/mob/H in hearers(S, null))
				if (H in mobs_messaged)
					continue
				var/U = H.say_understands(M, lang_id)
				H.show_text("<font size=[clamp(speakers - round(GET_DIST(H, S) / 2), 0, src.max_font)]><b>[M.get_heard_name()]</b> [U ? stuff : stuff_b]</font>")
				mobs_messaged += H
		if (prob(10) && locate(/obj/loudspeaker) in range(2, T))
			for_by_tcl(S, /obj/loudspeaker)
				if(!IN_RANGE(S, T, 7)) continue
				S.visible_message("<span class='alert'>[S] lets out a horrible [pick("shriek", "squeal", "noise", "squawk", "screech", "whine", "squeak")]!</span>")
				playsound(S.loc, 'sound/items/mic_feedback.ogg', 30, 1)

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

	hear_talk(mob/M as mob, msg, real_name)
		if (!myMic || !myMic.on)
			return
		var/turf/T = get_turf(src)
		if (M in range(1, T))
			myMic.talk_into(M, msg)

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
	anchored = 1
	density = 1
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING
