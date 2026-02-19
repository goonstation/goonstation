TYPEINFO(/obj/item/cloaking_device)
	mats = 15

/obj/item/cloaking_device
	name = "cloaking device"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "shield0"
	var/base_icon_state = "shield"
	var/active = 0
	flags = TABLEPASS | CONDUCT | NOSHIELD
	item_state = "electronic"
	throwforce = 5
	throw_speed = 2
	throw_range = 10
	w_class = W_CLASS_SMALL
	is_syndicate = 1
	desc = "An illegal device that bends light around the user, rendering them invisible to regular vision."
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 15
	contraband = 6
	var/image/cloak_overlay

	New()
		..()
		src.icon_state = base_icon_state + "0"
		src.cloak_overlay = image('icons/mob/mob.dmi', "icon_state" = "shield")

	attack_self(mob/user)
		src.add_fingerprint(user)
		if (src.active)
			user.show_text("The [src.name] is now inactive.", "blue")
			src.deactivate(user, TRUE)
		else
			if (src.activate(user))
				user.show_text("The [src.name] is now active.", "blue")
			else
				user.show_text("You can't have more than one active [src.name] on your person.", "red")


	update_icon()
		if (src.active)
			src.icon_state = base_icon_state + "1"
		else
			src.icon_state = base_icon_state + "0"


	proc/activate(mob/user)
		// Multiple active devices can lead to weird effects, okay (Convair880).
		var/list/number_of_devices = list()
		for (var/obj/item/cloaking_device/C in user)
			if (C.active)
				number_of_devices += C
		if (length(number_of_devices) > 0)
			return FALSE

		RegisterSignal(user, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE, PROC_REF(deactivate))
		APPLY_ATOM_PROPERTY(user, PROP_MOB_INVISIBILITY, "cloak", INVIS_CLOAK)
		cloak_overlay.loc = user
		user.client?.images += cloak_overlay
		src.active = TRUE
		src.UpdateIcon()
		logTheThing(LOG_COMBAT, user, "Activates a cloaking device at [log_loc(user)]")
		return TRUE

	proc/deactivate(mob/user, deliberate = FALSE)
		UnregisterSignal(user, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
		REMOVE_ATOM_PROPERTY(user, PROP_MOB_INVISIBILITY, "cloak")
		cloak_overlay.loc = null
		user.client?.images -= cloak_overlay
		if(src.active && istype(user))
			user.visible_message(SPAN_NOTICE("<b>[user]'s cloak is disrupted!</b>"))
			user.playsound_local(src, "sparks", 50, 0)
		src.active = FALSE
		src.UpdateIcon()
		if (deliberate)
			logTheThing(LOG_COMBAT, user, "deactivates a cloaking device at [log_loc(user)]")
		else
			logTheThing(LOG_COMBAT, user || src.loc, "has their cloaking device disrupted at [log_loc(user)]")

	// Fix for the backpack exploit. Spawn call is necessary for some reason (Convair880).
	dropped(var/mob/user)
		..()
		SPAWN(0)
			if (!src) return
			if (!user)
				src.deactivate()
				return
			if (ismob(src.loc) && src.loc == user) // Pockets are okay.
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if (H.l_store && H.l_store == src)
						return
					if (H.r_store && H.r_store == src)
						return

			SEND_SIGNAL(user, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
			// Need to update other mob sprite when force-equipping the cloak. Not quite sure how and
			// what even calls update_clothing() (giving the other mob invisibility and overlay) BEFORE
			// we set src.active to 0 here. But yeah, don't comment this out or you'll end up with in-
			// visible dudes equipped with technically inactive cloaking devices.
			SEND_SIGNAL(src.loc, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
			return

	emp_act()
		if (src.active && ismob(src.loc))
			src.deactivate(src.loc)

	disposing()
		if (src.active && ismob(src.loc))
			src.deactivate(src.loc)
		..()

	limited
		name = "limited-use cloaking device"
		desc = "A man-portable cloaking device, miniturization has reduced it's total uses to five."
		var/min_charges = 1
		var/charges = 5

		activate(mob/user as mob)
			if(charges <= min_charges)
				user.show_text("[src] is out of charge!", "red")
				return
			charges -= 1
			..()

	hunter
		name = "Hunter cloaking device"
		desc = "A cloaking device. It doesn't seem to be designed by humans."
		icon_state = "hunter_cloak"
		base_icon_state = "hunter_cloak"
		var/hunter_key = "" // The owner of this cloak.

		New()
			..()
			if(istype(src.loc, /mob/living))
				var/mob/M = src.loc
				src.AddComponent(/datum/component/self_destruct, M)
				src.AddComponent(/datum/component/send_to_target_mob, src)
				src.hunter_key = M.mind.key
				START_TRACKING_CAT(TR_CAT_HUNTER_GEAR)
				FLICK("[src.base_icon_state]-tele", src)

		disposing()
			. = ..()
			if (hunter_key)
				STOP_TRACKING_CAT(TR_CAT_HUNTER_GEAR)
