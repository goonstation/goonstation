/obj/item/cloaking_device
	name = "cloaking device"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "shield0"
	uses_multiple_icon_states = 1
	var/active = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT | NOSHIELD
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 2
	throw_range = 10
	w_class = W_CLASS_SMALL
	is_syndicate = 1
	mats = 15
	desc = "An illegal device that bends light around the user, rendering them invisible to regular vision."
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 15
	contraband = 6

	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if (src.active)
			user.show_text("The [src.name] is now inactive.", "blue")
			src.deactivate(user)
		else
			switch (src.activate(user))
				if (0)
					user.show_text("You can't have more than one active [src.name] on your person.", "red")
				if (1)
					user.show_text("The [src.name] is now active.", "blue")
		return

	proc/activate(mob/user as mob)
		// Multiple active devices can lead to weird effects, okay (Convair880).
		var/list/number_of_devices = list()
		for (var/obj/item/cloaking_device/C in user)
			if (C.active)
				number_of_devices += C
		if (number_of_devices.len > 0)
			return 0
		RegisterSignal(user, COMSIG_CLOAKING_DEVICE_DEACTIVATE, .proc/deactivate)
		src.active = 1
		src.icon_state = "shield1"
		if (user && ismob(user))
			user.update_inhands()
			user.update_clothing()
		return 1

	proc/deactivate(mob/user as mob)
		UnregisterSignal(user, COMSIG_CLOAKING_DEVICE_DEACTIVATE)
		if(src.active && istype(user))
			user.visible_message("<span class='notice'><b>[user]'s cloak is disrupted!</b></span>")
		src.active = 0
		src.icon_state = "shield0"
		if (user && ismob(user))
			user.update_inhands()
			user.update_clothing()

	// Fix for the backpack exploit. Spawn call is necessary for some reason (Convair880).
	dropped(var/mob/user)
		..()
		SPAWN_DBG(0)
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

			SEND_SIGNAL(user, COMSIG_CLOAKING_DEVICE_DEACTIVATE)
			// Need to update other mob sprite when force-equipping the cloak. Not quite sure how and
			// what even calls update_clothing() (giving the other mob invisibility and overlay) BEFORE
			// we set src.active to 0 here. But yeah, don't comment this out or you'll end up with in-
			// visible dudes equipped with technically inactive cloaking devices.
			SEND_SIGNAL(src.loc, COMSIG_CLOAKING_DEVICE_DEACTIVATE)
			return

	emp_act()
		usr.visible_message("<span class='notice'><b>[usr]'s cloak is disrupted!</b></span>")
		src.deactivate(usr)
		return

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
