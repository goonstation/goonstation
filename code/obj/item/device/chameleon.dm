/obj/dummy/chameleon
	name = ""
	desc = ""
	density = 0
	anchored = 1
	soundproofing = -1
	var/can_move = 1
	var/obj/item/device/chameleon/master = null

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attackby()
	    // drsingh for cannot execute null.disrupt
		if (isnull(master))
			return
		for (var/mob/M in src)
			boutput(M, "<span class='alert'>Your chameleon-projector deactivates.</span>")
		if (isnull(master))
			return
		master.disrupt()

	attack_hand()
		// drsingh for cannot execute null.disrupt
		if (isnull(master))
			return
		for (var/mob/M in src)
			boutput(M, "<span class='alert'>Your chameleon-projector deactivates.</span>")
		if (isnull(master))
			return
		master.disrupt()

	ex_act(var/severity)
		// drsingh for cannot execute null.disrupt
		if (isnull(master))
			return
		if (isnull(master))
			return

		for (var/mob/M in src)
			boutput(M, "<span class='alert'>Your chameleon-projector deactivates.</span>")
			M.ex_act(severity) //Fuck you and your TTBs.

		if(master)
			master.disrupt()
		else
			qdel(src)

	bullet_act()
		// drsingh for cannot execute null.disrupt
		if (isnull(master))
			return
		for (var/mob/M in src)
			boutput(M, "<span class='alert'>Your chameleon-projector deactivates.</span>")
		if (isnull(master))
			return
		master.disrupt()

	relaymove(var/mob/user, direction)
		if (can_move)
			can_move = 0
			SPAWN_DBG (10)
				can_move = 1
			step(src,direction)
		return

/obj/item/device/chameleon
	name = "chameleon-projector"
	icon_state = "shield0"
	flags = FPRINT | TABLEPASS| CONDUCT | EXTRADELAY | ONBELT | SUPPRESSATTACK
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	var/can_use = 0
	var/obj/overlay/anim = null //The toggle animation overlay will also be retained
	var/obj/dummy/chameleon/cham = null //No sense creating / destroying this
	var/active = 0
	tooltip_flags = REBUILD_DIST

	is_syndicate = 1
	mats = 14

	New()
		..()
		src.anim = new /obj/overlay(src)
		src.anim.icon = 'icons/effects/effects.dmi'
		src.cham = new (src)
		src.cham.master = src

	dropped()
		disrupt()

	attack_self()
		toggle()

	get_desc(dist)
		if (dist < 1 && !istype(src, /obj/item/device/chameleon/bomb))
			if (can_use && cham)
				. += "There is a small picture of \a [cham] on its screen."
			else
				. += "The screen on it is blank."
/*
	examine()
		..()
		var/out = ""
		if (can_use && cham)
			out = "There is a small picture of \a [cham] on its screen."
		else
			out = "The screen on it is blank."

		boutput(usr, "<span class='notice'>[out]</span>")
		return null
*/
	afterattack(atom/target, mob/user , flag)
		scan(target, user)

	proc/scan(obj/target, mob/user)
		if (get_dist(src, target) > 1)
			if (user && ismob(user))
				user.show_text("You are too far away to do that.", "red")
			return
		//Okay, enough scanning shit without actual icons yo.
		if (!isnull(initial(target.icon)) && !isnull(initial(target.icon_state)) && target.icon && target.icon_state && (isitem(target) || istype(target, /obj/shrub) || istype(target, /obj/critter) || istype(target, /obj/machinery/bot))) // cogwerks - added more fun
			if (!cham)
				cham = new(src)
				cham.master = src

			playsound(src, "sound/weapons/flash.ogg", 100, 1, 1)
			boutput(user, "<span class='notice'>Scanned [target].</span>")
			cham.name = target.name
			cham.real_name = target.name
			cham.desc = target.desc
			cham.real_desc = target.desc
			cham.icon = target.icon
			cham.icon_state = target.icon_state
			cham.dir = target.dir
			can_use = 1
			tooltip_rebuild = 1
		else
			user.show_text("\The [target] is not compatible with the scanner.", "red")

	proc/toggle()
		if (!can_use)
			return

		if (!anim)
			anim = new(src)

		if (active) //active_dummy)
			active = 0
			playsound(src, "sound/effects/pop.ogg", 100, 1, 1)
			for (var/atom/movable/A in cham)
				A.set_loc(get_turf(cham))
			cham.set_loc(src)
			boutput(usr, "<span class='notice'>You deactivate the [src].</span>")
			anim.set_loc(get_turf(src))
			flick("emppulse",anim)
			SPAWN_DBG (8)
				anim.set_loc(src)
		else
			if (istype(src.loc, /obj/dummy/chameleon)) //No recursive chameleon projectors!!
				boutput(usr, "<span class='alert'>As your finger nears the power button, time seems to slow, and a strange silence falls.  You reconsider turning on a second projector.</span>")
				return

			playsound(src, "sound/effects/pop.ogg", 100, 1, 1)
			cham.master = src
			cham.set_loc(get_turf(src))
			usr.set_loc(cham)
			src.active = 1

			boutput(usr, "<span class='notice'>You activate the [src].</span>")
			anim.set_loc(get_turf(src))
			flick("emppulse",anim)
			SPAWN_DBG (8)
				anim.set_loc(src)

	proc/disrupt()
		if (active)
			active = 0
			elecflash(src)
			for (var/atom/movable/A in cham)
				A.set_loc(get_turf(cham))
			cham.set_loc(src)
			can_use = 0
			tooltip_rebuild = 1
			SPAWN_DBG (100)
				can_use = 1
				tooltip_rebuild = 1

/obj/item/device/chameleon/bomb
	name = "chameleon bomb"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "cham_bomb"
	burn_possible = 0
	var/strength = 32 // same as syndie pipebombs, calls the same proc

	dropped()
		return

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.active)
			if (user)
				message_admins("[key_name(user)] triggers a chameleon bomb ([src]) by hitting it with [W] at [log_loc(user)].")
				logTheThing("bombing", user, null, "triggers a chameleon bomb ([src]) by hitting it with [W] at [log_loc(user)].")
			src.disrupt()
		else
			return ..()

	attack_hand(var/mob/user)
		if (src.active && isturf(loc))
			message_admins("[key_name(user)] picks up and triggers a chameleon bomb ([src]) at [log_loc(user)].")
			logTheThing("bombing", user, null, "picks up and triggers a chameleon bomb ([src]) at [log_loc(user)].")
			src.disrupt()
		else
			return ..()

	ex_act()
		if (src.active)
			src.disrupt()
		else
			return ..()

	bullet_act()
		if (src.active)
			src.disrupt()
		else
			return ..()

	scan(obj/target, mob/user)
		if (get_dist(src, target) > 1)
			if (user && ismob(user))
				user.show_text("You are too far away to do that.", "red")
			return
		if (!isnull(initial(target.icon)) && !isnull(initial(target.icon_state)) && target.icon && target.icon_state && (isitem(target) || istype(target, /obj/shrub) || istype(target, /obj/critter) || istype(target, /obj/machinery/bot))) // cogwerks - added more fun
			playsound(src, "sound/weapons/flash.ogg", 100, 1, 1)
			boutput(user, "<span class='notice'>Scanned [target].</span>")
			src.name = target.name
			src.real_name = target.name
			src.desc = target.desc
			src.real_desc = target.desc
			src.icon = target.icon
			src.icon_state = target.icon_state
			src.dir = target.dir
			can_use = 1
		else
			user.show_text("\The [target] is not compatible with the scanner.", "red")

	toggle()
		if (!can_use)
			return

		if (!anim)
			anim = new(src)

		if (active)
			active = 0
			playsound(src, "sound/effects/pop.ogg", 100, 1, 1)
			boutput(usr, "<span class='notice'>You disarm the [src].</span>")
			message_admins("[key_name(usr)] disarms a chameleon bomb ([src]) at [log_loc(usr)].")
			logTheThing("bombing", usr, null, "disarms a chameleon bomb ([src]) at [log_loc(usr)].")

		else
			playsound(src, "sound/effects/pop.ogg", 100, 1, 1)
			src.active = 1
			boutput(usr, "<span class='notice'>You arm the [src].</span>")
			message_admins("[key_name(usr)] arms a chameleon bomb ([src]) at [log_loc(usr)].")
			logTheThing("bombing", usr, null, "arms a chameleon bomb ([src]) at [log_loc(usr)].")

	disrupt()
		if (active)
			elecflash(src)
			src.blowthefuckup(src.strength)
