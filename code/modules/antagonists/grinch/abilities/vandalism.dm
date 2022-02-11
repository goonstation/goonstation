/datum/targetable/grinch/vandalism
	name = "Vandalize"
	desc = "Drop Spacemas cheer via graffiti and acts of destruction."
	icon_state = "grinchvandalize"
	targeted = 0
	target_anything = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 100
	start_on_cooldown = 0
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1

		var/objects_fucked_up = 0

		for (var/obj/xmastree/X in oview(1, M))
			boutput(M, __blue("You set the Spacemas tree on fire!"))
			X.change_fire_state(1) // Christmas cheer modifier included.
			objects_fucked_up++

		for (var/obj/stocking/S in oview(1, M))
			if (S.booby_trapped)
				continue
			S.booby_trapped = 1
			boutput(M, __blue("You put a venomous snake in the stocking!"))
			objects_fucked_up++

		for (var/obj/decal/D in oview(1, M))
			if (istype(D, /obj/decal/garland) || istype(D, /obj/decal/tinsel) || istype(D, /obj/decal/xmas_lights) || istype(D, /obj/decal/wreath))
				boutput(M, __blue("You tear down [D] and stomp all over it!"))
				modify_christmas_cheer(-1)
				objects_fucked_up++
				qdel(D)

		for (var/turf/simulated/wall/T in oview(1, M))
			if (locate(/obj/decal/cleanable/grinch_graffiti) in T)
				continue
			boutput(M, __blue("You scrawl graffiti all over the wall!"))
			make_cleanable(/obj/decal/cleanable/grinch_graffiti,T)
			modify_christmas_cheer(-1)
			objects_fucked_up++

		if (objects_fucked_up > 0)
			M.emote("laugh")
			M.visible_message("<span class='alert'>[M] laughs smugly!</span>")
			logTheThing("combat", M, null, "uses the vandalize ability at [log_loc(M)].")
			return 0
		else
			boutput(M, __red("You couldn't find anything to vandalize. You should try again near some walls or Spacemas decorations."))
			return 1
