/obj/item/lightbreaker
	name = "compact tape"
	desc = "A casette player loaded with a casette of a vampire's screech."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "recorder"
	var/active = 0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	throwforce = 5
	throw_speed = 2
	throw_range = 10
	w_class = W_CLASS_SMALL
	is_syndicate = 1
	mats = 15
	stamina_cost = 10
	stamina_crit_chance = 15
	var/ammo = 4
	var/ammo_max = 4

	examine()
		. = ..()
		if(src.ammo > 0)
			. += "It has [src.ammo] uses left out of [src.ammo_max]."
		else
			. += "The tape has worn out!"

	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if(ammo > 0)
			src.activate(user)
			ammo--
		else
			playsound(src.loc, 'sound/machines/click.ogg', 100, 1)
			boutput(user, "<span class='alert'>The tape is worn out!</span>")
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

	attackby(obj/item/W, mob/user, params)
		if(isscrewingtool(W))
			if(ammo < ammo_max)
				actions.start(new /datum/action/bar/icon/rewind_tape(src, W, "rewind",round(300*(1-ammo/ammo_max))), user)
			else
				boutput(user, "<span class='alert'>It's already fully rewound!</span>")
			return
		return ..()

	proc/rewind()
		ammo = ammo_max
		playsound(src.loc, 'sound/machines/click.ogg', 100, 1)

/datum/action/bar/icon/rewind_tape
	id = "rewind_tape"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 300
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/item/lightbreaker/the_breaker
	var/obj/item/the_tool
	var/interaction = "rewind"

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
		playsound(the_breaker, 'sound/misc/winding.ogg', 50, 1,3)

	onStart()
		..()
		var/verbing = "rewinding"
		switch (interaction)
			if ("rewind")
				verbing = "rewinding"
		owner.visible_message("<span class='notice'>[owner] begins [verbing] [the_breaker].</span>")

	onEnd()
		..()
		var/verbens = "rewinds"
		switch (interaction)
			if ("rewind")
				verbens = "rewinds"
				the_breaker.rewind()
		owner.visible_message("<span class='notice'>[owner] [verbens] [the_breaker].</span>")
