/obj/dummy/chameleon
	name = ""
	desc = ""
	object_flags = NO_GHOSTCRITTER
	density = 0
	anchored = ANCHORED
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
			boutput(M, SPAN_ALERT("Your chameleon-projector deactivates."))
		if (isnull(master))
			return
		master.disrupt()

	attack_hand()
		// drsingh for cannot execute null.disrupt
		if (isnull(master))
			return
		for (var/mob/M in src)
			boutput(M, SPAN_ALERT("Your chameleon-projector deactivates."))
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
			boutput(M, SPAN_ALERT("Your chameleon-projector deactivates."))
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
			boutput(M, SPAN_ALERT("Your chameleon-projector deactivates."))
		if (isnull(master))
			return
		master.disrupt()

	relaymove(var/mob/user, direction)
		if (can_move)
			can_move = 0
			SPAWN(1 SECOND)
				can_move = 1
			step(src,direction)
		return

TYPEINFO(/obj/item/device/chameleon)
	mats = 14

/obj/item/device/chameleon
	name = "chameleon-projector"
	icon_state = "shield0"
	flags = TABLEPASS | CONDUCT | EXTRADELAY | SUPPRESSATTACK
	c_flags = ONBELT
	item_state = "electronic"
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	var/can_use = 0
	var/obj/overlay/anim = null //The toggle animation overlay will also be retained
	var/obj/dummy/chameleon/cham = null //No sense creating / destroying this
	var/disrupt_on_drop = TRUE //TODO: refactor this
	var/active = 0
	tooltip_flags = REBUILD_DIST
	HELP_MESSAGE_OVERRIDE({"Use the chameleon projector on any object to copy it's appearance. Use it in hand to appear as that object indefinitely. The disguise will be removed if you interact with anything else or are hit."})

	is_syndicate = 1

	New()
		..()
		src.anim = new /obj/overlay(src)
		src.anim.icon = 'icons/effects/effects.dmi'
		src.cham = new (src)
		src.cham.master = src

	dropped()
		. = ..()
		if(disrupt_on_drop)
			disrupt()

	attack_self(mob/user)
		toggle(user)

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

		boutput(usr, SPAN_NOTICE("[out]"))
		return null
*/
	afterattack(atom/target, mob/user , flag)
		scan(target, user)

	proc/scan(obj/target, mob/user)
		if (BOUNDS_DIST(src, target) > 0)
			if (user && ismob(user))
				user.show_text("You are too far away to do that.", "red")
			return
		if (isgrab(target)) //don't scan grabs
			return
		if (target.plane == PLANE_HUD && !isitem(target)) //don't grab hud stuff _unless_ it's an item. Grabs are the only exception I know
			return
		//Okay, enough scanning shit without actual icons yo.
		if ((target.icon && target.icon_state || length(target.overlays) || length(target.underlays)) && isobj(target) && target.alpha > 5)
			var/icon/testIcon = getFlatIcon(target)
			if(!testIcon) //weird edgecases
				return

			if (!cham)
				cham = new(src)
				cham.master = src

			playsound(src, 'sound/weapons/flash.ogg', 100, TRUE, 1)
			boutput(user, SPAN_NOTICE("Scanned [target]."))
			cham.name = target.name
			cham.real_name = target.name
			cham.desc = target.desc
			cham.real_desc = target.desc
			cham.icon = testIcon
			cham.set_dir(target.dir)
			can_use = 1
			tooltip_rebuild = 1
		else
			user.show_text("\The [target] is not compatible with the scanner.", "red")

	proc/toggle(mob/user)
		if (!can_use)
			return

		if (!anim)
			anim = new(src)

		if (active) //active_dummy)
			active = 0
			playsound(src, 'sound/effects/pop.ogg', 100, TRUE, 1)
			for (var/atom/movable/A in cham)
				A.set_loc(get_turf(cham))
			cham.set_loc(src)
			boutput(user, SPAN_NOTICE("You deactivate the [src]."))
			anim.set_loc(get_turf(src))
			FLICK("emppulse",anim)
			SPAWN(0.8 SECONDS)
				anim.set_loc(src)
		else
			if (istype(src.loc, /obj/dummy/chameleon)) //No recursive chameleon projectors!!
				boutput(user, SPAN_ALERT("As your finger nears the power button, time seems to slow, and a strange silence falls.  You reconsider turning on a second projector."))
				return

			playsound(src, 'sound/effects/pop.ogg', 100, TRUE, 1)
			cham.master = src
			cham.set_loc(get_turf(src))
			src.active = 1
			user.set_loc(cham)

			boutput(user, SPAN_NOTICE("You activate the [src]."))
			anim.set_loc(get_turf(src))
			FLICK("emppulse",anim)
			SPAWN(0.8 SECONDS)
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
			SPAWN(10 SECONDS)
				can_use = 1
				tooltip_rebuild = 1

/obj/item/device/chameleon/bomb
	name = "chameleon bomb"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "cham_bomb"
	burn_possible = FALSE
	disrupt_on_drop = FALSE
	HELP_MESSAGE_OVERRIDE(null)
	var/strength = 12

	get_help_message(dist, mob/user)
		if (src.name == "chameleon bomb") // We havent been disguised yet, so we can show help messages
			return "Hit the bomb on any object to disguise it as that object. Use the bomb in hand to arm/disarm it. The bomb will explode when anyone tries to pick up the armed bomb."
		else
			return null

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attackby(obj/item/W, mob/user)
		if (src.active)
			if (user)
				message_admins("[key_name(user)] triggers a chameleon bomb ([src]) by hitting it with [W] at [log_loc(user)].")
				logTheThing(LOG_BOMBING, user, "triggers a chameleon bomb ([src]) by hitting it with [W] at [log_loc(user)].")
			src.disrupt()
		else
			return ..()

	attack_hand(var/mob/user)
		if (src.active && isturf(loc))
			message_admins("[key_name(user)] picks up and triggers a chameleon bomb ([src]) at [log_loc(user)].")
			logTheThing(LOG_BOMBING, user, "picks up and triggers a chameleon bomb ([src]) at [log_loc(user)].")
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
		if (BOUNDS_DIST(src, target) > 0)
			if (user && ismob(user))
				user.show_text("You are too far away to do that.", "red")
			return
		if (isgrab(target)) //don't scan grabs
			return
		if (target.plane == PLANE_HUD && !isitem(target)) //don't grab hud stuff _unless_ it's an item. Grabs are the only exception I know
			return
		if ((target.icon && target.icon_state || length(target.overlays) || length(target.underlays)) && (isitem(target) || istype(target, /obj/shrub) || istype(target, /obj/critter) || istype(target, /obj/machinery/bot))) // cogwerks - added more fun
			playsound(src, 'sound/weapons/flash.ogg', 100, TRUE, 1)
			boutput(user, SPAN_NOTICE("Scanned [target]."))
			src.name = target.name
			src.real_name = target.name
			src.desc = target.desc
			src.real_desc = target.desc
			src.icon = getFlatIcon(target)
			src.set_dir(target.dir)
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
			playsound(src, 'sound/effects/pop.ogg', 100, TRUE, 1)
			boutput(usr, SPAN_NOTICE("You disarm the [src]."))
			message_admins("[key_name(usr)] disarms a chameleon bomb ([src]) at [log_loc(usr)].")
			logTheThing(LOG_BOMBING, usr, "disarms a chameleon bomb ([src]) at [log_loc(usr)].")

		else
			playsound(src, 'sound/effects/pop.ogg', 100, TRUE, 1)
			src.active = 1
			boutput(usr, SPAN_NOTICE("You arm the [src]."))
			message_admins("[key_name(usr)] arms a chameleon bomb ([src]) at [log_loc(usr)].")
			logTheThing(LOG_BOMBING, usr, "arms a chameleon bomb ([src]) at [log_loc(usr)].")

	disrupt()
		if (active)
			elecflash(src)
			src.blowthefuckup(src.strength)
