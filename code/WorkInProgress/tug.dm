//WIP tugs

TYPEINFO(/obj/tug_cart)
	mats = 10

/obj/tug_cart
	name = "cargo cart"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "flatbed"
	var/atom/movable/load = null
	var/obj/tug_cart/next_cart = null
	layer = MOB_LAYER + 1

	MouseDrop_T(var/atom/movable/C, mob/user)
		if (!in_interact_range(user, src) || !in_interact_range(user, C) || user.restrained() || user.getStatusDuration("paralysis") || user.sleeping || user.stat || user.lying)
			return

		if (!istype(C)|| C.anchored || BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(src, C) > 0 )
			return

		if (istype(C, /mob/dead/))
			return

		if (istype(C, /obj/vehicle/tug))
			user.show_text("\The [C] is too heavy for \the [src]!", "red")
			return

		if (istype(C, /obj/tug_cart) && in_interact_range(C, src))
			var/obj/tug_cart/connecting = C
			if (src == connecting) //Wire: Fix for mass recursion runtime (carts connected to themselves)
				return
			else if (!src.next_cart && !connecting.next_cart)
				src.next_cart = connecting
				user.visible_message("[user] connects [connecting] to [src].", "You connect [connecting] to [src].")
				return
			else if (src.next_cart == connecting)
				src.next_cart = null
				user.visible_message("[user] disconnects [connecting] from [src].", "You disconnect [connecting] from [src].")
				return
			else
				user.show_text("\The [src] already has a cart connected to it!", "red")
				return

		if (istype(C, /obj/storage/cart) && in_interact_range(C, src))
			var/obj/storage/cart/connecting = C
			if (src == connecting) //Wire: Fix for mass recursion runtime (carts connected to themselves)
				return
			else if (!src.next_cart && !connecting.next_cart)
				src.next_cart = connecting
				user.visible_message("[user] connects [connecting] to [src].", "You connect [connecting] to [src].")
				return
			else if (src.next_cart == connecting)
				src.next_cart = null
				user.visible_message("[user] disconnects [connecting] from [src].", "You disconnect [connecting] from [src].")
				return
			else
				user.show_text("\The [src] already has a cart connected to it!", "red")
				return

		if (load)
			return

		load(C)
		src.visible_message("<b>[user]</b> loads [C] onto [src].")

	mouse_drop(obj/over_object as obj, src_location, over_location)
		..()
		var/turf/T = get_turf(over_location)
		var/mob/user = usr
		if (!user || !(in_interact_range(user, src) || user.loc == src) || !in_interact_range(src, over_object) || user.restrained() || user.getStatusDuration("paralysis") || user.sleeping || user.stat || user.lying)
			return
		if (!load)
			return
		if (T)
			if (T.density)
				boutput(user, "<span class='alert'>That tile is blocked by [T].</span>")
				return

		for (var/obj/O in T.contents)
			if (O.density)
				boutput(user, "<span class='alert'>That tile is blocked by [O].</span>")
				return
		src.visible_message("<b>[user]</b> unloads [load] from [src].")
		unload(over_object)

	proc/load(var/atom/movable/C)
		/*if ((wires & wire_loadcheck) && !istype(C,/obj/storage/crate))
			src.visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			return		// if not emagged, only allow crates to be loaded // cogwerks - turning this off for now to make the mule more versatile + funny
			*/

		if (istype(C, /atom/movable/screen) || C.anchored)
			return

		if (BOUNDS_DIST(C, src) > 0 || load)
			return

		// if a create, close before loading
		var/obj/storage/crate/crate = C
		if (istype(crate))
			crate.close()
		C.set_loc(src.loc)
		SPAWN(0.2 SECONDS)
			if (C && C.loc == src.loc)
				C.set_loc(src)
				load = C
				C.pixel_y += 6
				if (C.layer < layer)
					C.layer = layer + 0.1
				src.UpdateOverlays(C, "load")

	proc/unload(var/turf/T)//var/dirn = 0)
		if (!load)
			return
		if (!isturf(T))
			T = get_turf(T)

		load.set_loc(src.loc)

		// in case non-load items end up in contents, dump every else too
		// this seems to happen sometimes due to race conditions
		// with items dropping as mobs are loaded

		for (var/atom/movable/AM in src)
			AM.set_loc(src.loc)
			AM.layer = initial(AM.layer)
			AM.pixel_y = initial(AM.pixel_y)

	Exited(atom/movable/Obj, newloc)
		. = ..()
		if(src.load == Obj)
			src.load.pixel_y -= 6
			src.load.layer = initial(src.load.layer)
			src.load = null
			src.UpdateOverlays(null, "load")

	Move()
		var/oldloc = src.loc
		. = ..()
		if (src.loc == oldloc)
			return
		if (next_cart)
			next_cart.Move(oldloc)

	disposing()
		load = null
		next_cart = null
		..()


TYPEINFO(/obj/vehicle/tug)
	mats = 10

/obj/vehicle/tug
	name = "cargo tug"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "tractor"
	//	rider_visible = 1
	layer = MOB_LAYER + 1

	//	sealed_cabin = 0
	health = 80
	health_max = 80
	var/obj/tug_cart/cart = null
	can_eject_items = TRUE
	ability_buttons_to_initialize = list(/obj/ability_button/vehicle_speed)
	var/start_with_cart = 1
	delay = 4

	security
		name = "security wagon"
		icon_state = "tractor-sec"
		var/weeoo_in_progress = 0
		delay = 2
		health = 120
		health_max = 120


		/*
		New()
			..()
			if (!islist(src.ability_buttons))
				ability_buttons = list()
			var/obj/ability_button/weeoo/NB = new
			NB.screen_loc = "NORTH-2,1"
			ability_buttons += NB

		proc/weeoo()

			if (weeoo_in_progress)
				return

			weeoo_in_progress = 10
			SPAWN(0)
				playsound(src.loc, 'sound/machines/siren_police.ogg', 60, 1)
				light.enable()
				src.icon_state = "tractor-sec2"
				while (weeoo_in_progress--)
					light.set_color(0.9, 0.1, 0.1)
					sleep(0.3 SECONDS)
					light.set_color(0.1, 0.1, 0.9)
					sleep(0.3 SECONDS)
				light.disable()
				src.icon_state = "tractor-sec"
				weeoo_in_progress = 0 */

	New()
		..()
		src.add_mdir_light("light", list(255, 255, 255, 150))

	New()
		..()
		if (start_with_cart)
			cart = new/obj/tug_cart/(get_turf(src))

	eject_rider(var/crashed, var/selfdismount, ejectall=TRUE)
		var/mob/living/rider = src.rider
		..()
		if(rider)
			rider.pixel_y = 0
			walk(src, 0)
			if (rider.client)
				for(var/obj/ability_button/B in ability_buttons)
					rider.client.screen -= B
			if (crashed)
				if (crashed == 2)
					playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
				boutput(rider, "<span class='alert'><B>You are flung off of [src]!</B></span>")
				rider.changeStatus("stunned", 8 SECONDS)
				rider.changeStatus("weakened", 5 SECONDS)
				for (var/mob/C in AIviewers(src))
					if (C == rider)
						continue
					C.show_message("<span class='alert'><B>[rider] is flung off of [src]!</B></span>", 1)
				var/turf/target = get_edge_target_turf(src, src.dir)
				rider.throw_at(target, 5, 1)
				rider.buckled = null
				rider = null
				overlays = null
				return
			if (selfdismount)
				boutput(rider, "<span class='notice'>You dismount from [src].</span>")
				for (var/mob/C in AIviewers(src))
					if (C == rider)
						continue
					C.show_message("<B>[rider]</B> dismounts from [src].", 1)
			if (rider)
				rider.buckled = null
			rider = null
			overlays = null
			return

	MouseDrop_T(var/atom/movable/C, mob/user)
		if (!in_interact_range(user, src) || !in_interact_range(user, C) || user.restrained() || user.getStatusDuration("paralysis") || user.sleeping || user.stat || user.lying)
			return

		if (istype(C, /obj/tug_cart) && in_interact_range(C, src))
			if (src == C) //Wire: Fix for mass recursion runtime (carts connected to themselves)
				return
			else if (!src.cart)
				src.cart = C
				user.visible_message("[user] connects [C] to [src].", "You connect [C] to [src].")
				return
			else if (src.cart == C)
				src.cart = null
				user.visible_message("[user] disconnects [C] from [src].", "You disconnect [C] from [src].")
				return
			else
				user.show_text("\The [src] already has a cart connected to it!", "red")
				return

		//if (!ishuman(C))
		if (!isliving(C))
			return
		var/mob/living/target = C
		//var/mob/living/carbon/human/target = C

		if (rider || target.buckled || LinkBlocked(target.loc,src.loc) || isAI(user))
			return

		var/msg

		if (target == user && !user.stat)	// if drop self, then climbed in
			msg = "[user.name] climbs onto [src]."
			boutput(user, "<span class='notice'>You climb onto [src].</span>")
		else if (target != user && !user.restrained())
			msg = "[user.name] helps [target.name] onto [src]!"
			boutput(user, "<span class='notice'>You help [target.name] onto [src]!</span>")
		else
			return

		target.set_loc(src)
		rider = target
		rider.pixel_y = 6
		overlays += rider
		if (rider.restrained() || rider.stat)
			rider.buckled = src

		if (target.client)
			var/x_btt = 1
			for(var/obj/ability_button/B in ability_buttons)
				B.the_mob = target
				B.screen_loc = "NORTH-2,[x_btt]"
				target.client.screen += B
				x_btt++

		for (var/mob/H in AIviewers(src))
			if (H == user)
				continue
			H.show_message(msg, 3)

		return

	Click()
		if (usr != rider)
			..()
			return
		if (!is_incapacitated(usr))
			eject_rider(0, 1)
		return

	attack_hand(mob/living/carbon/human/M)
		if (!M || !rider)
			..()
			return
		switch (M.a_intent)
			if ("harm", "disarm")
				if (prob(60))
					playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
					src.visible_message("<span class='alert'><B>[M] has shoved [rider] off of [src]!</B></span>")
					rider.changeStatus("weakened", 2 SECONDS)
					eject_rider()
				else
					playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, -1)
					src.visible_message("<span class='alert'><B>[M] has attempted to shove [rider] off of [src]!</B></span>")
		return

	disposing()
		if (rider)
			boutput(rider, "<span class='alert'><B>[src] is destroyed!</B></span>")
			eject_rider()
		cart = null
		..()
		return

	Move()
		var/oldloc = src.loc
		. = ..()
		if (src.loc == oldloc)
			return
		if (cart)
			cart.Move(oldloc)

/obj/ability_button/vehicle_speed
	name = "Vehicle Speed"
	icon_state = "lo"

	Click()
		if (!the_mob)
			return
		if (istype(the_mob.loc, /obj/vehicle/tug))
			var/obj/vehicle/tug/T = the_mob.loc
			if (T.delay == 2)
				src.icon_state = "lo"
				T.delay = 4
			else
				T.delay = 2
				src.icon_state = "hi"
			T.relaymove(the_mob, T.dir)

