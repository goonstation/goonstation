/obj/item/gun/russianrevolver
	desc = "Fun for the whole family!"
	name = "\improper Russian revolver"
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


	attack(mob/M, mob/user)
		fire_gun(user)

	proc/fire_gun(mob/user as mob)
		if(src.shotsLeft > 1)
			src.shotsLeft--
			playsound(user, 'sound/weapons/Gunclick.ogg', 80, 1)
			for(var/mob/O in AIviewers(user, null))
				if (O.client)
					O.show_message("<span class='alert'>[user] points the gun at [his_or_her(user)] head. Click!</span>", 1, "<span class='alert'>Click!</span>", 2)

			inventory_counter.update_number(1)
			return 0
		else if(src.shotsLeft == 1)
			if(ishuman(user))
				var/list/nearby_turfs = list()
				for(var/turf/T in view(5, user))
					nearby_turfs += T
				var/mob/living/carbon/human/H = user
				var/obj/brain = H.organHolder.drop_organ("brain")
				var/obj/l_eye = H.organHolder.drop_organ("left_eye")
				var/obj/r_eye = H.organHolder.drop_organ("right_eye")
				var/obj/head = H.organHolder.drop_organ("head")
				brain.throw_at(pick(nearby_turfs), pick(1,2), 10)
				l_eye.throw_at(pick(nearby_turfs), pick(1,2), 10)
				r_eye.throw_at(pick(nearby_turfs), pick(1,2), 10)
				qdel(head)
			else
				user.TakeDamage("head", 300, 0)
			take_bleeding_damage(user, null, 500, DAMAGE_STAB)
			src.shotsLeft = 0
			playsound(user, 'sound/weapons/Gunshot.ogg', 100, 1)
			user.visible_message("<span class='alert'><B>BOOM!</B> [user]'s head explodes.</span>",\
				"<span class='alert'><B>BOOM!</B></span>",\
				"<span class='alert'>You hear someone's head explode.</span>")
			logTheThing(LOG_COMBAT, user, "shoots themselves with [src] at [log_loc(user)].")
			inventory_counter.update_number(0)
			return 1
		else
			boutput(user, "<span class='notice'>You need to reload the gun.</span>")
			inventory_counter.update_number(0)
			return 0

	proc/reload_gun(mob/user as mob)
		if(src.shotsLeft <= 0)
			user.visible_message("<span class='notice'>[user] finds a bullet on the ground and loads it into the gun, spinning the cylinder.</span>", "<span class='notice'>You find a bullet on the ground and load it into the gun, spinning the cylinder.</span>")
			src.shotsLeft = rand(1, shotsMax)
		else if(src.shotsLeft >= 1)
			user.visible_message("<span class='notice'>[user] spins the cylinder.</span>", "<span class='notice'>You spin the cylinder.</span>")
			src.shotsLeft = rand(1, shotsMax)
		inventory_counter.update_number(1)


/obj/item/gun/russianrevolver/fake357
	name = "revolver"
	shotsMax = 1 //griff
	var/fakeshots = 0
	New()
		fakeshots = rand(2, 7)
		desc = "There are [fakeshots] bullets left! Each shot will currently use 1 bullets!"
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
	icon = 'icons/obj/large/48x32.dmi'
	icon_state = "ak47"
	item_state = "ak47"
	two_handed = TRUE
