/obj/item/flash_pistol
	name = "flash pistol"
	desc = "A poorly thought out implement of photography from the early twentieth century, utilising a specialised flash compound to ensure a good picture, regardless of lighting level. Needless to say, this should absolutely never be fired at someone from point-blank range."
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "flash_pistol"
	item_state = "flash_pistol"
	force = MELEE_DMG_PISTOL
	inventory_counter_enabled = TRUE
	w_class = W_CLASS_SMALL

	var/loaded = TRUE
	var/hammer_cocked = FALSE

	var/flash_animation_duration = 60
	var/flash_stamina_damage = 130
	var/flash_weakened = 100
	var/flash_disorient_time = 60

	var/flash_eye_blurry = 4
	var/flash_eye_damage = 10
	var/flash_burning = 5

	New()
		. = ..()
		inventory_counter?.update_number(loaded)

	attack(mob/living/M, mob/user)
		if(isghostcritter(user))
			return

		src.flash_mob(M, user)

	attackby(obj/item/flash_compound_bottle/compound_bottle, mob/user)
		if(istype(compound_bottle, /obj/item/flash_compound_bottle))
			if(ON_COOLDOWN(src, "reload_spam", 2 DECI SECONDS))
				return
			if(compound_bottle.amount_left < 1)
				user.show_text("There's no ammo left in [compound_bottle.name].", "red")
				return
			if(src.loaded)
				user.show_text("[src] is full!", "red")
				return
			else
				user.visible_message("<span class='alert'>[user] refills [src].</span>", "<span class='alert'>You refill [src].</span>")
				src.loaded = TRUE
				src.UpdateIcon()
				compound_bottle.amount_left--
				compound_bottle.UpdateIcon()
		else
			..()

	attack_self(mob/user)
		. = ..()
		if (!src.hammer_cocked)
			boutput(user, "<span class='alert'>You cock the hammer!</span>")
			playsound(user.loc, 'sound/weapons/gun_cocked_colt45.ogg', 70, 1)
			src.hammer_cocked = TRUE
			src.UpdateIcon()
			return

		src.add_fingerprint(user)

		if (!src.loaded)
			user.show_text("*click* *click*", "red")
			playsound(user, 'sound/weapons/Gunclick.ogg', 60, 1)
			return

		// Play animations.
		playsound(src, 'sound/effects/poof.ogg', 100, 1)
		src.loaded = FALSE
		src.hammer_cocked = FALSE
		src.UpdateIcon()

		if (isrobot(user))
			SPAWN(0)
				var/atom/movable/overlay/animation = new(user.loc)
				animation.layer = user.layer + 1
				animation.icon_state = "blank"
				animation.icon = 'icons/mob/mob.dmi'
				animation.master = user
				flick("blspell", animation)
				sleep(0.5 SECONDS)
				qdel(animation)

		// Flash target mobs.
		for (var/atom/A in oviewers(3 , get_turf(src)))
			var/mob/living/M
			if (istype(A, /obj/vehicle))
				var/obj/vehicle/V = A
				if (V.rider && V.rider_visible)
					M = V.rider
			else if (ismob(A))
				M = A
			if (M)
				M.apply_flash(35, 0, 0, 25)


	proc/flash_mob(mob/living/M, mob/user)
		src.add_fingerprint(user)
		if (!src.loaded || !src.hammer_cocked)
			user.show_text("*click* *click*", "red")
			playsound(user, 'sound/weapons/Gunclick.ogg', 60, 1)
			return

		var/turf/T = get_turf(user)
		if (T.loc:sanctuary)
			user.visible_message("<span class='alert'><b>[user]</b> tries to use [src], cannot quite comprehend the forces at play!</span>")
			return

		playsound(src, 'sound/effects/poof.ogg', 100, 1)
		src.hammer_cocked = FALSE
		src.loaded = FALSE
		src.UpdateIcon()

		// We're flashing somebody directly, hence the 100% chance to disrupt cloaking device at the end.
		var/blind_success = M.apply_flash(
			src.flash_animation_duration,
			src.flash_weakened,
			0,
			0,
			src.flash_eye_blurry,
			src.flash_eye_damage,
			0,
			0,
			100,
			stamina_damage = src.flash_stamina_damage,
			disorient_time = src.flash_disorient_time)

		M.update_burning(src.flash_burning)

		// Log entry.
		var/blind_msg_target = "!"
		var/blind_msg_others = "!"
		if (!blind_success)
			blind_msg_target = " but your eyes are protected!"
			blind_msg_others = " but [his_or_her(M)] eyes are protected!"
		M.visible_message("<span class='alert'>[user] blinds [M] with \the [src][blind_msg_others]</span>", "<span class='alert'>[user] blinds you with \the [src][blind_msg_target]</span>")
		logTheThing(LOG_COMBAT, user, "blinds [constructTarget(M,"combat")] with [src] at [log_loc(user)].")

		// Some after attack stuff.
		user.lastattacked = M
		M.lastattacker = user
		M.lastattackertime = world.time


	update_icon()
		if (src.loaded)
			inventory_counter?.update_number(1)
			src.icon_state = replacetext(src.icon_state, "-empty", "")
		else
			inventory_counter?.update_number(0)
			if (!findtext(src.icon_state, "-empty"))
				src.icon_state = "[src.icon_state]-empty"

		if (src.hammer_cocked && !findtext(src.icon_state, "-c"))
			src.icon_state = "[src.icon_state]-c"
		else if (!src.hammer_cocked)
			src.icon_state = replacetext(src.icon_state, "-c", "")


/obj/item/flash_compound_bottle
	name = "Flash Compound Bottle"
	desc = "A small bottle containing a mixture specialised to create a vivid flash when used in a flash pistol."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "flash_compound_bottle"
	inventory_counter_enabled = TRUE
	w_class = W_CLASS_SMALL
	var/amount_left = 10
	var/max_amount = 10

	New()
		. = ..()
		inventory_counter?.update_number(amount_left)

	attackby(obj/O, mob/user)
		if(istype(O, /obj/item/flash_pistol))
			O.Attackby(src, user)

		else if(O.type == src.type)
			var/obj/item/flash_compound_bottle/compound_bottle = O
			if(compound_bottle.amount_left < 1)
				user.show_text("There's no compound left in [compound_bottle.name].", "red")
				return
			if(src.amount_left >= src.max_amount)
				user.show_text("[src] is full!", "red")
				return

			while ((compound_bottle.amount_left > 0) && (src.amount_left < src.max_amount))
				compound_bottle.amount_left--
				src.amount_left++

			if ((compound_bottle.amount_left < 1) && (src.amount_left < src.max_amount))
				compound_bottle.UpdateIcon()
				src.UpdateIcon()
				user.visible_message("<span class='alert'>[user] refills [src].</span>", "<span class='alert'>There wasn't enough compound left in [compound_bottle.name] to fully refill [src]. It only has [src.amount_left] uses remaining.</span>")
				return

			if ((compound_bottle.amount_left >= 0) && (src.amount_left == src.max_amount))
				compound_bottle.UpdateIcon()
				src.UpdateIcon()
				user.visible_message("<span class='alert'>[user] refills [src].</span>", "<span class='alert'>You fully refill [src] with compound from [compound_bottle.name]. There are [compound_bottle.amount_left] uses left in [compound_bottle.name].</span>")
				return
		else return ..()

	update_icon()
		if (src.amount_left < 0)
			src.amount_left = 0

		inventory_counter?.update_number(src.amount_left)
