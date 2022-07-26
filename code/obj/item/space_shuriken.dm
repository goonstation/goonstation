/obj/item/weapons/space_shuriken
	name = "Kepler Tech-Shuriken"
	desc = "Cyalume powered and disposable, These shuriken can be toggled to redirect stun power to a built in teleportation device."
	w_class = W_CLASS_TINY
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "space_shuriken_harm"
	throw_spin = 1
	throw_speed = 3
	item_function_flags = USE_SPECIALS_ON_ALL_INTENTS
	amount = 1
	var/lethal = true

	New()
		..()
		src.setItemSpecial(/datum/item_special/throwing)
		create_inventory_counter()
		if (!lethal)
			icon_state = "space_shuriken"
			update_icon()


	split_stack(var/toRemove)
		if(toRemove < 1) return 0
		if (toRemove == amount)
			return src
		var/obj/item/weapons/space_shuriken/P = new(src.loc)
		P.lethal = src.lethal
		if (!lethal)
			P.icon_state = "space_shuriken"
		src.change_stack_amount(-toRemove)
		return P

	throw_begin(atom/target, range, speed, list/params, turf/thrown_from, mob/thrown_by, throw_type = 1)
		if (amount > 1)
			var/target_turf = get_turf(target)
			var/cross_throw_dir = turn(get_dir(thrown_from,target), 90)
			var/cross_throw_right = turn(get_dir(thrown_from,target), -90)
			for (var/i=2 to amount)
				var/obj/item/weapons/space_shuriken/P = new(src.loc)
				var/offset_turf = get_step(target_turf,cross_throw_dir)
				P.throw_at(offset_turf, range, speed, params, thrown_from, thrown_by, throw_type)
				cross_throw_dir = cross_throw_right
			src.amount = 1
		src.inventory_counter.hide_count()
		..()


	dropped(mob/user)
		..()
		SPAWN(0)
			if (!src.throwing)
				playsound(src.loc, "sound/weapons/lasersound.ogg", 100, 1)
				elecflash(src.loc,power=2)
				del(src)

	throw_impact(atom/M)
		..()
		playsound(src.loc, "sound/weapons/lasersound.ogg", 100, 1)
		if (!lethal)
			elecflash(src.loc,power=2) //zap puddles before we teleport into them
			if (GET_DIST(src.loc, usr) < 20) //dont tele into the depths of space
				elecflash(usr,power=2)
				playsound(M.loc, "sound/effects/mag_warp.ogg", 25, 1, -1)
				usr.set_loc(get_turf(src.loc))

			// penalise excessive teleporting
			if (usr.get_stamina() > 50)
				usr.do_disorient(50, 0, 0, disorient = 0)
			else
				usr.do_disorient(50, 0, 0, disorient = 20)

			random_brute_damage(M, 8)
			take_bleeding_damage(M, null, 3, DAMAGE_CUT)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				playsound(src.loc, "sound/impact_sounds/Blade_Small.ogg", 100, 1)
				H.changeStatus("weakened", 2 SECONDS)
				H.do_disorient(60, weakened = 0, disorient = 30)
				H.force_laydown_standup()
			del(src)
		else
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				playsound(src.loc, "sound/impact_sounds/Blade_Small.ogg", 100, 1)
				H.changeStatus("weakened", 1 SECONDS)
				H.do_disorient(60, weakened = 0, disorient = 20)
				H.force_laydown_standup()
			else
				elecflash(src.loc,power=2)
			random_brute_damage(M, 20)
			take_bleeding_damage(M, null, 3, DAMAGE_CUT)
			del(src)

	attack_self(mob/user as mob)
		lethal = !lethal
		if (lethal)
			icon_state = "space_shuriken_harm"
			boutput(user, "You switch the shuriken to 'Harm'")
		else
			icon_state = "space_shuriken"
			boutput(user, "You switch the shuriken to 'Teleport")