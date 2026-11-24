// ----------------- abstract sound tape ----------------------------

ABSTRACT_TYPE(/obj/item/sound_tape)

/obj/item/sound_tape
	name = "A tape you shouldn't see!"
	desc = "DONT USE THIS"
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "audiolog_newSmall"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "radio"
	w_class = W_CLASS_SMALL
	var/active = FALSE
	flags = TABLEPASS | CONDUCT
	throwforce = 5
	throw_speed = 2
	throw_range = 10
	stamina_cost = 10
	stamina_crit_chance = 15
	var/ammo = 4
	var/ammo_max = 4
	var/rewind_time = 20 SECONDS
	var/activation_sound = 'sound/effects/light_breaker.ogg'
	HELP_MESSAGE_OVERRIDE({"Use the tape to play a sound. Can be rewound with a <b>screwdriver</b>."})

	examine()
		. = ..()
		if(src.ammo >= 1)
			. += "It has [round(src.ammo)] uses left out of [src.ammo_max]."
		else
			. += "The tape has worn out!"

	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if(src.ammo >= 1)
			if (ON_COOLDOWN(src, "spam_protection", 1 SECOND))
				return
			src.activate(user)
			src.ammo--
		else
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			boutput(user, SPAN_ALERT("The tape is worn out!"))

	proc/activate(mob/user as mob)
		playsound(src.loc, src.activation_sound, 75, 1, 5)
		return TRUE

	attackby(obj/item/W, mob/user, params)
		if(isscrewingtool(W))
			if(src.ammo < ammo_max)
				actions.start(new /datum/action/bar/icon/sound_tape(src, W, "rewind",round(src.rewind_time*(1-ammo/ammo_max))), user)
			else
				boutput(user, SPAN_ALERT("It's already fully rewound!"))
			return
		return ..()

	proc/rewind()
		src.ammo = src.ammo_max


/datum/action/bar/icon/sound_tape
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 300
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/item/sound_tape/the_tape
	var/obj/item/the_tool
	var/interaction = "rewind"
	/// Rough delta-t system so we can gradually increase the tape's "ammo"
	var/last_update = 0

	New(var/obj/item/sound_tape/tape, var/obj/item/tool, var/interact, var/duration_i)
		..()
		if (tape)
			src.the_tape = tape
		if (tool)
			src.the_tool = tool
			icon = src.the_tool.icon
			icon_state = src.the_tool.icon_state
		if (interact)
			src.interaction = interact
		if (duration_i)
			src.duration = duration_i

	onUpdate()
		..()
		if (src.the_tape == null || the_tool == null || owner == null || BOUNDS_DIST(owner, src.the_tape) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return
		var/old_ammo = src.the_tape.ammo
		//ammo per second * delta time
		src.the_tape.ammo += (src.the_tape.ammo_max / src.the_tape.rewind_time) * (TIME - src.last_update)
		src.the_tape.ammo = min(src.the_tape.ammo, src.the_tape.ammo_max)

		if (round(old_ammo) != round(src.the_tape.ammo))
			playsound(get_turf(src.the_tape), 'sound/machines/click.ogg', 50, 1, -3)
			boutput(source, SPAN_NOTICE("You rewind one full track."))

		if (src.the_tape.ammo == src.the_tape.ammo_max)
			src.state = ACTIONSTATE_FINISH
		src.last_update = TIME

	onStart()
		..()
		var/verbing = "rewinding"
		switch (interaction)
			if ("rewind")
				verbing = "rewinding"
		owner.visible_message(SPAN_NOTICE("[owner] begins [verbing] [src.the_tape]."))
		src.last_update = TIME

	onEnd()
		..()
		var/verbens = "rewinds"
		switch (interaction)
			if ("rewind")
				verbens = "rewinds"
				src.the_tape.rewind()
		playsound(get_turf(src.the_tape), 'sound/machines/click.ogg', 50, 1, -3)
		owner.visible_message(SPAN_NOTICE("[owner] [verbens] [src.the_tape]."))

// ----------------- actual sound tapes ----------------------------

TYPEINFO(/obj/item/sound_tape/lightbreaker)
	analyser_flags = parent_type::analyser_flags | ANALYSER_SYNDIE_ONLY
	mats = 15

/obj/item/sound_tape/lightbreaker
	name = "compact tape"
	desc = "A casette player loaded with a casette of a vampire's screech."
	activation_sound = 'sound/effects/light_breaker.ogg'
	HELP_MESSAGE_OVERRIDE({"Use the lightbreaker in hand to shatter all lights around you and deafen/stagger other people without ear protection. Can be rewound with a <b>screwdriver</b>."})

	activate(mob/user as mob)
		..()
		for (var/obj/machinery/light/L in view(7, user))
			if (L.status == 2 || L.status == 1)
				continue
			var/area/A = get_area(L)
			// Protect lights in sanctuary and nukie battlecruiser
			if(A?.sanctuary || istype(A, /area/syndicate_station))
				continue
			L.broken(1)

		for (var/mob/living/HH in hearers(user, null))
			if (HH == user)
				continue
			HH.apply_sonic_stun(0, 0, 30, 0, 5, 4, 6)
		return TRUE


/obj/item/sound_tape/ling_recording
	name = "Human Steve's mixtape"
	desc = "A recording of the merchant \"Human Steve\" singing... Oh dear."
	activation_sound = 'sound/voice/creepyshriek_recording.ogg'
	ammo = 1
	ammo_max = 1

	activate(mob/user as mob)
		..()
		for (var/mob/living/HH in hearers(user, null)) // Works on EVERYONE, bring earmuffs
			HH.apply_sonic_stun(0, 0, 0, 10, 35, rand(0, 2))
		return TRUE

/obj/item/spookbook //Wander Office item, not meant to look like a lightbreaker to the average player
	name = "worn book"
	desc = "A black binded book, it looks like it's seen a lot of use. Something about it fills you with unease."
	icon = 'icons/misc/wander_stuff.dmi'
	icon_state = "spookbook"
	var/ammo = 5
	var/ammo_max = 5

	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if(ammo > 0)
			src.activate(user)
			ammo--
		else
			playsound(src.loc, 'sound/effects/gust.ogg', 100, 1)
			boutput(user, SPAN_ALERT("The spirits are quiet..."))
		return

	proc/activate(mob/user as mob)
		playsound(src.loc, 'sound/effects/light_breaker.ogg', 75, 1, 5)
		for (var/obj/machinery/light/L in view(7, user))
			if (L.status == 2 || L.status == 1)
				continue
			var/area/A = get_area(L)
			// Protect lights in sanctuary and nukie battlecruiser
			if(A?.sanctuary || istype(A, /area/syndicate_station))
				continue
			L.broken(1)

		for (var/mob/living/HH in hearers(user, null))
			if (HH == user)
				continue
			HH.apply_sonic_stun(0, 0, 30, 0, 5, 4, 6)
		return 1
