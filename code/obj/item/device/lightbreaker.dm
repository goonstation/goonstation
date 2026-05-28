TYPEINFO(/obj/item/lightbreaker)
	mats = 15

/obj/item/lightbreaker
	name = "compact tape"
	desc = "A casette player loaded with a casette of a vampire's screech."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "audiolog_newSmall"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "radio"
	w_class = W_CLASS_SMALL
	var/active = 0
	flags = TABLEPASS | CONDUCT
	throwforce = 5
	throw_speed = 2
	throw_range = 10
	is_syndicate = 1
	stamina_cost = 10
	stamina_crit_chance = 15
	var/ammo = 4
	var/ammo_max = 4
	var/rewind_time = 20 SECONDS
	HELP_MESSAGE_OVERRIDE({"Use the lightbreaker in hand to shatter all lights around you and deafen/stagger other people without ear protection. Can be rewound with a <b>screwdriver</b>."})

	examine()
		. = ..()
		if(src.ammo >= 1)
			. += "It has [round(src.ammo)] uses left out of [src.ammo_max]."
		else
			. += "The tape has worn out!"

	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if(ammo >= 1)
			if (ON_COOLDOWN(src, "spam_protection", 1 SECOND))
				return
			src.activate(user)
			ammo--
		else
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			boutput(user, SPAN_ALERT("The tape is worn out!"))

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

	attackby(obj/item/W, mob/user, params)
		if(isscrewingtool(W))
			if(ammo < ammo_max)
				actions.start(new /datum/action/bar/icon/rewind_tape(src, W, "rewind",round(src.rewind_time*(1-ammo/ammo_max))), user)
			else
				boutput(user, SPAN_ALERT("It's already fully rewound!"))
			return
		return ..()

	proc/rewind()
		ammo = ammo_max


/datum/action/bar/icon/rewind_tape
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 300
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/item/lightbreaker/the_breaker
	var/obj/item/the_tool
	var/interaction = "rewind"
	/// Rough delta-t system so we can gradually increase the tape's "ammo"
	var/last_update = 0

	New(var/obj/item/lightbreaker/brkr, var/obj/item/tool, var/interact, var/duration_i)
		..()
		if (brkr)
			the_breaker = brkr
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (interact)
			interaction = interact
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		if (the_breaker == null || the_tool == null || owner == null || BOUNDS_DIST(owner, the_breaker) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return
		var/old_ammo = the_breaker.ammo
		//ammo per second * delta time
		the_breaker.ammo += (the_breaker.ammo_max / the_breaker.rewind_time) * (TIME - src.last_update)
		the_breaker.ammo = min(the_breaker.ammo, the_breaker.ammo_max)

		if (round(old_ammo) != round(the_breaker.ammo))
			playsound(get_turf(the_breaker), 'sound/machines/click.ogg', 50, 1, -3)
			boutput(source, SPAN_NOTICE("You rewind one full track."))

		if (the_breaker.ammo == the_breaker.ammo_max)
			src.state = ACTIONSTATE_FINISH
		src.last_update = TIME

	onStart()
		..()
		var/verbing = "rewinding"
		switch (interaction)
			if ("rewind")
				verbing = "rewinding"
		owner.visible_message(SPAN_NOTICE("[owner] begins [verbing] [the_breaker]."))
		src.last_update = TIME

	onEnd()
		..()
		var/verbens = "rewinds"
		switch (interaction)
			if ("rewind")
				verbens = "rewinds"
				the_breaker.rewind()
		playsound(get_turf(the_breaker), 'sound/machines/click.ogg', 50, 1, -3)
		owner.visible_message(SPAN_NOTICE("[owner] [verbens] [the_breaker]."))


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
