TYPEINFO(/obj/item/device/disguiser)
	mats = 8

/obj/item/device/disguiser
	name = "holographic disguiser"
	icon_state = "enshield0"
	uses_multiple_icon_states = 1
	desc = "Experimental device that projects a hologram of a randomly generated appearance onto the user, hiding their real identity."
	flags = FPRINT | TABLEPASS| CONDUCT | EXTRADELAY
	c_flags = ONBELT
	item_state = "electronic"
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	is_syndicate = 1
	var/datum/appearanceHolder/oldAH = new
	var/anti_spam = 1 // In relation to world time.
	var/active = 0

	var/customization_first_color = 0
	var/customization_second_color = 0
	var/customization_third_color = 0
	var/e_color = 0
	var/s_tone = "#FAD7D0"
	var/cust1 = null
	var/cust2 = null
	var/cust3 = null

	dropped(mob/user)
		..()
		SPAWN(0) // Ported from cloaking device. Spawn call is necessary for some reason (Convair880).
			if (!src) return
			if (ismob(src.loc) && src.loc == user)
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if (H.l_store && H.l_store == src)
						return
					if (H.r_store && H.r_store == src)
						return
					if (H.belt && H.belt == src)
						return
			src.deactivate(user, FALSE)
			return

	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if (!src.active && (src.anti_spam && world.time < src.anti_spam + 100))
			user.show_text("[src] is recharging!", "red")
			return
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (!H.bioHolder || !H.bioHolder.mobAppearance)
				H.show_text("This device is only designed to work on humans!", "red")
				return
		else
			user.show_text("This device is only designed to work on humans!", "red")
			return
		if (src.active)
			src.deactivate(user, TRUE)
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
		for (var/obj/item/device/disguiser/D in user)
			if (D.active)
				number_of_devices += D
		if (number_of_devices.len > 0)
			return 0
		RegisterSignal(user, COMSIG_MOB_DISGUISER_DEACTIVATE, .proc/deactivate)
		src.active = 1
		src.icon_state = "enshield1"
		src.change_appearance(user, 0)
		src.anti_spam = world.time
		var/obj/overlay/T = new/obj/overlay(get_turf(src))
		T.icon = 'icons/effects/effects.dmi'
		flick("emppulse",T)
		SPAWN(0.8 SECONDS)
			if (T) qdel(T)
		return 1

	proc/deactivate(mob/user as mob, var/voluntary)
		UnregisterSignal(user, COMSIG_MOB_DISGUISER_DEACTIVATE)
		if(src.active && istype(user))
			elecflash(src)
			if (!voluntary)
				user.visible_message("<span class='notice'><b>[user]'s disguiser is disrupted!</b></span>")
			else
				user.show_text("You deactivate the [src.name].", "blue")
			src.change_appearance(user, 1)
			src.anti_spam = world.time
			var/obj/overlay/T = new/obj/overlay(get_turf(src))
			T.icon = 'icons/effects/effects.dmi'
			flick("emppulse",T)
			SPAWN(0.8 SECONDS)
				if (T) qdel(T)
		src.active = 0
		src.icon_state = "enshield0"

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if (!H.bioHolder || !H.bioHolder.mobAppearance)
				return
			src.deactivate(H, FALSE)
		return

	// Added to 1) fix a couple bugs and 2) cut down on duplicate code.
	// Also cleaned up the code a bit in general (Convair880).
	proc/change_appearance(var/mob/living/carbon/human/user, var/reset_to_normal = 0)
		if (!src || !user || !ishuman(user))
			return
		var/datum/appearanceHolder/AH = user.bioHolder.mobAppearance
		if (!AH || !istype(AH, /datum/appearanceHolder))
			return

		// Store current appearance and generate new one.
		if (!reset_to_normal)
			oldAH.CopyOther(AH)
			if (AH.mob_appearance_flags & FIX_COLORS)	// mods the special colors so it doesnt mess things up if we stop being special
				AH.customization_first_color = fix_colors(AH.customization_first_color)
				AH.customization_second_color = fix_colors(AH.customization_second_color)
				AH.customization_third_color = fix_colors(AH.customization_third_color)
			src.real_name = user.real_name
			randomize_look(user, 0, 0, 0, 1, 0, 0) // randomize: gender 0, blood type 0, age 0, name 1, underwear 0, remove effects 0
			user.update_colorful_parts()

		// Restore original appearance.
		else
			user.real_name = src.real_name
			AH.CopyOther(oldAH)
			if (user.limbs)
				user.limbs.reset_stone()
			user.set_face_icon_dirty()
			user.set_body_icon_dirty()
			user.update_inhands()
			user.update_clothing()
			user.update_colorful_parts()

		return
