/obj/item/weapons/space_shuriken
	name = "Kepler Techno-Shuriken"
	desc = ""
	w_class = W_CLASS_TINY
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "space_shuriken_harm"
	throw_spin = 1
	throw_speed = 3
	amount = 1
	var/lethal = true

	New() 
		..()
		src.setItemSpecial(/datum/item_special/throwing)
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
		P.change_stack_amount(toRemove - P.amount)
		src.change_stack_amount(-toRemove)
		src.dropped()
		return P
	
	throw_begin(atom/target, range, speed, list/params, turf/thrown_from, mob/thrown_by, throw_type = 1)
		if (amount > 1)
			var/turf/target_turf = get_turf(target)
			for (var/i=2 to amount)
				var/obj/item/weapons/space_shuriken/P = new(src.loc)
				var/xoffset = pick(-1,1)
				var/yoffset = pick(-1,1)
				var/offset_turf = locate(target_turf.x + xoffset, target_turf.y + yoffset, target_turf.z)
				P.throw_at(offset_turf, range, speed, params, thrown_from, thrown_by, throw_type)
			src.amount = 1
		..()
			
	throw_impact(atom/M)
		..()
		playsound(src.loc, "sound/weapons/lasersound.ogg", 100, 1)
		if (!lethal)
			if (GET_DIST(src.loc, usr) < 20) //dont TP into the depths of space
				elecflash(usr,power=2)
				playsound(M.loc, "sound/effects/mag_warp.ogg", 25, 1, -1)
				usr.set_loc(get_turf(src.loc))
			
			// penalise excessive teleporting
			if (usr.get_stamina() > 100)
				usr.do_disorient(50, 0, 0, disorient = 0) 
			else 
				usr.do_disorient(50, 0, 0, disorient = 20) 
			
			random_brute_damage(M, 8)
			take_bleeding_damage(M, null, 3, DAMAGE_CUT)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				playsound(src.loc, "sound/impact_sounds/Blade_Small.ogg", 100, 1)
				H.changeStatus("weakened", 4 SECONDS)
				H.do_disorient(60, weakened = 0, disorient = 30)
				H.force_laydown_standup()
			else
				elecflash(src.loc,power=2)
			del(src)
		else
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				playsound(src.loc, "sound/impact_sounds/Blade_Small.ogg", 100, 1)
				H.changeStatus("weakened", 2 SECONDS)
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
