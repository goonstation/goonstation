/*
	RCD gimmick variants
*/

/// This isnt used anywhere that I can find
/obj/item/rcd_fake
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items/rcd.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = UNANCHORED
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL

/// Broken RCDs.  Attempting to use them is... ill advised.
/obj/item/broken_rcd
	name = "prototype rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items/rcd.dmi'
	icon_state = "bad_rcd0"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "rcd"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	m_amt = 50000
	var/mode = RCD_MODE_FLOORSWALLS
	var/broken = 0 //Fully broken, that is.

	New()
		..()
		src.icon_state = "bad_rcd[rand(0,2)]"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/rcd_ammo))
			boutput(user, "\the [src] slot is not compatible with this cartridge.")
			return

	attack_self(mob/user as mob)
		if (src.broken)
			boutput(user, SPAN_ALERT("It's broken!"))
			return

		playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
		if (mode)
			mode = 0
			boutput(user, "Changed mode to 'Deconstruct'")
			elecflash(src)
			return
		else
			mode = 1
			boutput(user, "Changed mode to 'Floor & Walls'")
			elecflash(src)
			return

	afterattack(atom/A, mob/user as mob)
		if (src.broken > 1)
			boutput(user, SPAN_ALERT("It's broken!"))
			return

		if (!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
			return
		if ((istype(A, /turf/space) || istype(A, /turf/simulated/floor)) && mode)
			if (src.broken)
				boutput(user, SPAN_ALERT("Insufficient charge."))
				return

			boutput(user, "Building [istype(A, /turf/space) ? "Floor (1)" : "Wall (3)"]...")

			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 2 SECONDS))
				if (src.broken)
					return

				src.broken++
				elecflash(src)
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

				for (var/turf/T in orange(1,user))
					T.ReplaceWithWall()


				boutput(user, SPAN_ALERT("\the [src] shorts out!"))
				return

		else if (!mode)
			boutput(user, "Deconstructing ??? ([rand(1,8)])...")

			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user,50))
				if (src.broken)
					return

				src.broken++
				elecflash(src)
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 100, 1)

				boutput(user, SPAN_COMBAT("\the [src] shorts out!"))

				logTheThing(LOG_COMBAT, user, "manages to vaporize \[[log_loc(A)]] (and themselves) with a halloween RCD.")

				new /obj/effects/void_break(A)
				if (user)
					user.gib()

/obj/effects/void_break
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	var/lifespan = 4
	var/rangeout = 0

	New()
		..()
		lifespan = rand(2,4)
		rangeout = lifespan
		SPAWN(0.5 SECONDS)
			void_shatter()
			void_loop()

	proc/void_shatter()
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 80, 1)
		for (var/atom/A in range(lifespan, src))
			if (istype(A, /turf/simulated))
				A.pixel_x = rand(-4,4)
				A.pixel_y = rand(-4,4)
			else if (isliving(A))
				shake_camera(A, 8, 32)
				A.ex_act( BOUNDS_DIST(src, A) > 0 ? 3 : 1 )

			else if (istype(A, /obj) && (A != src))

				if ((GET_DIST(src, A) <= 2) || prob(10))
					A.ex_act(1)
				else if (prob(5))
					A.ex_act(3)

				continue

		elecflash(src,power=3)

	proc/void_loop()
		if (lifespan-- < 0)
			qdel(src)
			return

		for (var/turf/simulated/T in range(src, (rangeout-lifespan)))
			if (prob(5 + lifespan) && limiter.canISpawn(/obj/effects/sparks))
				var/obj/sparks = new /obj/effects/sparks
				sparks.set_loc(T)
				SPAWN(2 SECONDS) if (sparks) qdel(sparks)

			T.ex_act((rangeout-lifespan) < 2 ? 1 : 2)

		SPAWN(1.5 SECONDS)
			void_loop()
		return
