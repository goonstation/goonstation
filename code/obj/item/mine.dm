// Cleaned up the ancient code that used to be here (Convair880).
TYPEINFO(/obj/item/mine)
	mats = 6

/obj/item/mine
	name = "land mine (parent)"
	desc = "You shouldn't be able to see this!"
	w_class = W_CLASS_NORMAL
	density = 0
	layer = OBJ_LAYER
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "mine"
	is_syndicate = TRUE
	event_handler_flags = USE_FLUID_ENTER
	var/suppress_flavourtext = FALSE
	var/armed = FALSE
	var/used_up = FALSE
	var/obj/item/device/timer/our_timer = null

	New()
		..()
		RegisterSignal(src, COMSIG_ITEM_STORAGE_INTERACTION, PROC_REF(on_storage_interaction))
		if (src.armed)
			src.UpdateIcon()

		if (!src.our_timer || !istype(src.our_timer))
			src.our_timer = new /obj/item/device/timer(src)
			src.our_timer.master = src

	disposing()
		UnregisterSignal(src, COMSIG_ITEM_STORAGE_INTERACTION)
		our_timer = null
		..()

	proc/on_storage_interaction(var/affected_mine, var/mob/user)
		if(src.armed)
			src.triggered(user)
			return TRUE

	examine()
		. = ..()
		if (!src.suppress_flavourtext)
			. += "It appears to be [src.armed ? "armed" : "disarmed"]."

	attack_hand(mob/user)
		src.add_fingerprint(user)

		if (prob(50) && src.armed && !src.used_up)
			if (!src.suppress_flavourtext)
				src.visible_message("<font color='red'><b>[user] fumbles with the [src.name], accidentally setting it off!</b></span>")
			src.triggered(user)
			return

		..()

	attackby(obj/item/W, mob/user)
		if (prob(50) && src.armed && !src.used_up)
			if (!src.suppress_flavourtext)
				src.visible_message("<font color='red'><b>[user] fumbles with the [src.name], accidentally setting it off!</b></span>")
			src.triggered(user)
			return

		..()

	pull(mob/user)
		if (..())
			return
		if (src.armed && !src.used_up)
			if (!src.suppress_flavourtext)
				src.visible_message("<font color='red'><b>[user] tries to pull the [src.name], triggering the anti-tamper mechanism!</b></span>")
			src.triggered(user)
			return

	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		if (src.used_up)
			user.show_text("The [src.name] has already been triggered and is no longer functional.", "red")
			return

		if (src.armed)
			src.armed = FALSE
			src.UpdateIcon()
			user.show_text("You disarm the [src.name].", "blue")
			logTheThing(LOG_BOMBING, user, "has disarmed the [src.name] at [log_loc(user)].")

		if (src.our_timer && istype(src.our_timer))
			src.our_timer.AttackSelf(user)


	receive_signal()
		if (src.used_up)
			return

		playsound(src.loc, 'sound/weapons/armbomb.ogg', 100, 1)
		src.armed = TRUE
		src.UpdateIcon()

	// Timer process() expects this to be here. Could be used for dynamic icon_states updates.
	proc/c_state()
		return

	ex_act(severity)
		if (src.used_up || !src.armed)
			return
		if (!src.suppress_flavourtext)
			src.visible_message("<font color='red'><b>The explosion sets off the [src.name]!</b></span>")
		src.triggered()
		return

	emp_act()
		if (src.used_up || !src.armed)
			return
		if (!src.suppress_flavourtext)
			src.visible_message("<font color='red'><b>The electromagnetic pulse sets off the [src.name]!</b></span>")
		src.triggered()
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (src.used_up || !src.armed)
			return FALSE
		if (!src.suppress_flavourtext)
			src.visible_message("<font color='red'><b>The electric charge sets off the [src.name]!</b></span>")
		src.triggered(user)
		return TRUE

	Crossed(atom/movable/AM as mob|obj)
		..()
		if (AM == src || !(istype(AM, /obj/vehicle) || istype(AM, /obj/machinery/bot) || ismob(AM)))
			return
		if (ismob(AM) && (!isliving(AM) || isintangible(AM) || iswraith(AM)))
			return
		if (src.used_up)
			return
		if (!src.armed)
			return

		if (!src.suppress_flavourtext)
			src.visible_message("<font color='red'><b>[AM] triggers the [src.name]!</b></span>")
		src.triggered(AM)
		return

	update_icon()

		if (!src || !istype(src))
			return

		if (src.armed && !findtext(src.icon_state, "_armed"))
			src.icon_state = "[src.icon_state]_armed"
		else
			src.icon_state = replacetext(src.icon_state, "_armed", "")

		return

	// Special effects handled by every type of mine.
	proc/custom_stuff(var/atom/M)
		return

	proc/triggered(var/atom/M)
		if (!src || !istype(src))
			return

		if (src.used_up)
			qdel(src)
			return
		src.used_up = TRUE

		elecflash(src)

		src.custom_stuff(M)
		src.log_me(M)

		qdel(src)

	// For bioeffects or stuns, basically everything that should affect all mobs located on src.loc when triggered.
	proc/get_mobs_on_turf(var/radius = 0)
		var/list/mobs = list()

		if (!src || !istype(src))
			return mobs

		var/turf/T = get_turf(src)

		for (var/mob/living/L in range(radius,T))
			if (isintangible(L) || iswraith(L))
				continue
			mobs += L

		return mobs

	proc/log_me(var/atom/M, var/mob/T)
		if (!src || !istype(src))
			return
		var/logtarget = (T && ismob(T) ? T : null)
		logTheThing(LOG_BOMBING, M && ismob(M) ? M : null, logtarget, "The [src.name] was triggered at [log_loc(src)][T && ismob(T) ? ", affecting [constructTarget(logtarget,"bombing")]." : "."] Last touched by: [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"]")

/obj/item/mine/radiation
	name = "radiation land mine"
	desc = "An anti-personnel mine designed to heavily irradiate its target."
	icon_state = "mine_radiation"

	armed
		armed = TRUE

	custom_stuff(var/atom/M)
		if (!src || !istype(src))
			return

		var/list/mobs = src.get_mobs_on_turf()
		if (length(mobs))
			for (var/mob/living/L in mobs)
				if (istype(L))
					L.take_radiation_dose(2.5 SIEVERTS)
					if (L.bioHolder && ishuman(L))
						L.bioHolder.RandomEffect("bad")
					if (L != M)
						src.log_me(null, L)

		playsound(src.loc, 'sound/weapons/ACgun2.ogg', 50, 1)
		return

/obj/item/mine/incendiary
	name = "incendiary land mine"
	desc = "An anti-personnel mine equipped with an incendiary payload."
	icon_state = "mine_incendiary"

	armed
		armed = TRUE

	custom_stuff(var/atom/M)
		if (!src || !istype(src))
			return

		fireflash_melting(get_turf(src), 3, 3000, 500, chemfire = CHEM_FIRE_RED)
		playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)

/obj/item/mine/stun
	name = "stun land mine"
	desc = "An anti-personnel mine designed to stun its victim nonlethally."
	icon_state = "mine_stun"
	var/effect_mult = 1.5

	armed
		armed = TRUE

	nanotrasen
		name = "NT stun land mine"
		desc = "A Nanotrasen-brand land mine used to stun victims nonlethally."
		icon_state = "mine_stun_nt"
		effect_mult = 1

	custom_stuff(var/atom/M)
		if (!src || !istype(src))
			return

		var/list/mobs = src.get_mobs_on_turf(1)
		if (length(mobs))
			for (var/mob/living/L in mobs)
				if (istype(L))
					L.do_disorient(200, (10 SECONDS * effect_mult))
					L.stuttering += (10 * effect_mult)
					if (L != M)
						src.log_me(null, L)

		playsound(src.loc, 'sound/weapons/flashbang.ogg', 50, 1)

/obj/item/mine/blast
	name = "high explosive land mine"
	desc = "An anti-personnel mine rigged with explosives."

	armed
		armed = TRUE

	custom_stuff(var/atom/M)
		if (!src || !istype(src))
			return

		explosion(src, src.loc, 0, 1, 2, 3)

TYPEINFO(/obj/item/mine/gibs)
	mats = 0

/obj/item/mine/gibs
	name = "pustule"
	desc = "Some kind of weird little meat balloon."
	icon = 'icons/misc/meatland.dmi'
	icon_state = "meatmine"
	suppress_flavourtext = TRUE
	is_syndicate = FALSE

	armed
		armed = TRUE

	update_icon()

		return

	custom_stuff(var/atom/M)
		if (!src || !istype(src))
			return

		src.visible_message(SPAN_ALERT("[src] bursts[pick(" like an overripe melon!", " like an impacted bowel!", " like a balloon filled with blood!", "!", "!")]"))
		gibs(src.loc)
		playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)

		return
