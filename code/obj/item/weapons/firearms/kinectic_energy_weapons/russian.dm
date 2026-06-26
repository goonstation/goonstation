/obj/item/gun/russianrevolver
	desc = "Fun for the whole family!"
	name = "\improper Russian revolver"
	icon = 'icons/obj/items/guns/kinetic.dmi'
	icon_state = "revolver"
	w_class = W_CLASS_NORMAL
	throw_speed = 2
	throw_range = 10
	m_amt = 2000
	contraband = 0
	var/shotsLeft = 0
	var/shotsMax = 6
	inventory_counter_enabled = 1

	New()
		src.shotsLeft = rand(1,shotsMax)
		..()
		inventory_counter.update_number(1)
		return

	/*
	examine()
		set src in usr
		src.desc = text("Harmless fun")
		..()
		return
	*/

	attack_self(mob/user as mob)
		reload_gun(user)


	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		fire_gun(user)

	proc/fire_gun(mob/user as mob)
		if(src.shotsLeft > 1)
			src.shotsLeft--
			playsound(user, 'sound/weapons/Gunclick.ogg', 80, TRUE)
			for(var/mob/O in AIviewers(user, null))
				if (O.client)
					O.show_message(SPAN_ALERT("[user] points the gun at [his_or_her(user)] head. Click!"), 1, SPAN_ALERT("Click!"), 2)

			inventory_counter.update_number(1)
			return 0
		else if(src.shotsLeft == 1)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.head_explosion()
			else
				user.TakeDamage("head", 300, 0)
				take_bleeding_damage(user, null, 500, DAMAGE_STAB)
			src.shotsLeft = 0
			playsound(user, 'sound/weapons/Gunshot.ogg', 100, TRUE)
			logTheThing(LOG_COMBAT, user, "shoots themselves with [src] at [log_loc(user)].")
			inventory_counter.update_number(0)
			return 1
		else
			boutput(user, SPAN_NOTICE("You need to reload the gun."))
			inventory_counter.update_number(0)
			return 0

	proc/reload_gun(mob/user as mob)
		if(src.shotsLeft <= 0)
			user.visible_message(SPAN_NOTICE("[user] finds a bullet on the ground and loads it into the gun, spinning the cylinder."), SPAN_NOTICE("You find a bullet on the ground and load it into the gun, spinning the cylinder."))
			src.shotsLeft = rand(1, shotsMax)
		else if(src.shotsLeft >= 1)
			user.visible_message(SPAN_NOTICE("[user] spins the cylinder."), SPAN_NOTICE("You spin the cylinder."))
			src.shotsLeft = rand(1, shotsMax)
		inventory_counter.update_number(1)


/obj/item/gun/russianrevolver/fake357
	name = "\improper Revolver" // Automatically copies the real gun name in New()
	desc = "A slightly shabby looking combat revolver developed by somebody. Uses .357 caliber rounds."
	force = MELEE_DMG_REVOLVER
	shotsMax = 1 //griff
	contraband = 4
	var/fakeshots = 0

	New()
		src.name = /obj/item/gun/kinetic/revolver::name
		fakeshots = rand(2, 7)
		set_current_projectile(new/datum/projectile/bullet/revolver_357)
		..()
		inventory_counter.update_number(fakeshots)

	pixelaction(atom/target, params, mob/user, reach)
		if(target.loc != user)
			if(src.fire_gun(user))
				user.show_text("That gun DID look a bit dodgy, after all!", "red")
				user.playsound_local(user, 'sound/musical_instruments/Trombone_Failiure.ogg', 50, 1)
		inventory_counter.update_number(fakeshots)

	attack_self(mob/user)
		if(!shotsLeft)
			..()

/obj/item/gun/russianrevolver/jk47
	name = "\improper JK-47 rifle"
	desc = "The cold-war classic!  Well, um, a model.  Probably?"
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "ak47"
	item_state = "ak47"
	two_handed = TRUE
