/obj/item/lightbreaker
	name = "compact tape"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "recorder"
	var/active = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	throwforce = 10.0
	throw_speed = 2
	throw_range = 10
	w_class = 2.0
	is_syndicate = 1
	mats = 15
	stamina_cost = 10
	stamina_crit_chance = 15
	var/ammo = 4

	examine()
		if(src.ammo > 0)
			src.desc = "A casette player loaded with a casette of a vampire's screech. It has [src.ammo] uses left out of 4."
		else
			src.desc = "A casette player loaded with a casette of a vampire's screech. The tape has worn out!"
		..()
		return

	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if(ammo > 0)
			src.activate(user)
			ammo--
		else
			playsound(src.loc, "sound/machines/click.ogg", 100, 1)
			boutput(usr, "<span style=\"color:red\">The tape is worn out!</span>")
		return

	proc/activate(mob/user as mob)
		playsound(src.loc, "sound/effects/light_breaker.ogg", 50, 1)
		for (var/obj/machinery/light/L in view(7, user))
			if (L.status == 2 || L.status == 1)
				continue
			L.broken(1)

		for (var/mob/living/HH in hearers(user, null))
			if (HH == user)
				continue
			HH.apply_sonic_stun(0, 0, 40, 0, 15, 8, 12)
		return 1
