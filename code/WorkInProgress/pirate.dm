// These are needed because Load Area seems to have issues with ordinary var-edited landmarks.
/obj/landmark/pirate
	name = "Pirate-Spawn"

	first_mate
		name = "Pirate-First-Mate-Spawn"

	captain
		name = "Pirate-Captain-Spawn"

/obj/gold_bee
	name = "\improper Gold Bee Statue"
	desc = "Is it a trophy? A mascot? A treasure? Or all of the above?"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "gold_bee"
	flags = FPRINT | FLUID_SUBMERGE | TGUI_INTERACTIVE
	object_flags = NO_GHOSTCRITTER
	density = 1
	anchored = 0
	var/list/gibs = list()

	New()
		..()
		src.setMaterial(getMaterial("gold"), appearance = 0, setname = 0)
		for(var/i in 1 to 7)
			gibs.Add(new /obj/item/stamped_bullion)
			gibs.Add(new /obj/item/raw_material/gold)

	attack_hand(mob/user)
		src.add_fingerprint(user)

		if (user.a_intent != INTENT_HARM)
			src.visible_message("<span class='notice'><b>[user]</b> pets [src]!</span>")

	attackby(obj/item/W, mob/user)
		src.add_fingerprint(user)
		user.lastattacked = src

		src.visible_message("<span class='combat'><b>[user]</b> hits [src] with [W]!</span>")
		src.take_damage(W.force / 3)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
		attack_particle(user, src)

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round(((P.power/6)*P.proj_data.ks_ratio), 1.0)

		src.visible_message("<span class='combat'><b>[src]</b> is hit by [P]!</span>")
		if (damage <= 0)
			return
		if(P.proj_data.damage_type == D_KINETIC || (P.proj_data.damage_type == D_ENERGY && damage))
			src.take_damage(damage / 3)
		else if (P.proj_data.damage_type == D_PIERCING)
			src.take_damage(damage)

	proc/take_damage(var/amount)
		if (!isnum(amount) || amount < 1)
			return
		src._health = max(0,src._health - amount)

		if (src._health < 1)
			src.visible_message("<span class='alert'><b>[src]</b> breaks and shatters into many peices!</span>")
			playsound(src.loc, 'sound/impact_sounds/plate_break.ogg', 50, 0.1, 0, 0.5)
			if (length(gibs))
				for (var/atom/movable/I in gibs)
					I.set_loc(get_turf(src))
					ThrowRandom(I, 3, 1)
			qdel(src)
