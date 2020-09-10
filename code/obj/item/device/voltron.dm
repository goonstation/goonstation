/obj/dummy/voltron
	icon = null
	name = "Sparks"
	desc = "Dangerous looking sparks."
	anchored = 1
	density = 0
	opacity = 0
	var/can_move = 1
	var/speed = 1
	var/image/img = null
	var/list/cableimgs = new/list()
	var/vision_radius = 3
	var/mob/the_user = null
	//Prolonged use causes damage.
	New(mob/target, atom/location)
		..()
		src.set_loc(location)
		the_user = target
		target.set_loc(src)
		img = image('icons/effects/effects.dmi',src ,"energyorb")
		target << img

		//SPAWN_DBG(0) check() but why

	remove_air(amount as num)
		var/datum/gas_mixture/Air = unpool(/datum/gas_mixture)
		Air.oxygen = amount
		Air.temperature = 310
		return Air

	proc/spawn_sparks()
		SPAWN_DBG(0)
			// Check spawn limits
			if(limiter.canISpawn(/obj/effects/sparks))
				var/obj/effects/sparks/O = unpool(/obj/effects/sparks)
				O.set_loc(src.loc)
				SPAWN_DBG(2 SECONDS) if (O) pool(O)

	relaymove(mob/user, direction)

		var/turf/new_loc = get_step(src, direction)

		if(can_move)
			var/list/allowed = new/list()

			for(var/obj/cable/C in src.loc)
				allowed += C.d1
				allowed += C.d2

			if(direction in allowed)

				if(!locate(/obj/cable) in new_loc) return

				if (prob(10)) spawn_sparks()

				src.set_loc(new_loc)
				can_move = 0
				SPAWN_DBG(speed) can_move = 1
		return

	disposing()
		the_user.client.images -= cableimgs
		the_user = null
		return ..()

	proc/check()
		/*if(1) return
		while (!disposed)

			for(var/obj/item/I in src)
				I.set_loc(src.loc)

			the_user.client.images -= cableimgs

			cableimgs.Cut()
			for(var/obj/cable/C in range(3, src.loc))
				cableimgs += C//.cableimg

			the_user.client.images += cableimgs

			sleep(1 SECOND)*/

/obj/item/device/voltron
	name = "Voltron"
	desc = "Converts matter into energy and back. Needs to be used while standing on a cable."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "voltron"
	item_state = "electronic"
	var/active = 0
	var/mob/target = null
	var/obj/dummy/voltron/D = null
	var/activating = 0
	var/on_cooldown = 0
	var/power = 100
	var/power_icon = ""
	module_research = list("devices" = 5, "energy" = 20, "miniaturization" = 20)
	var/list/cableimgs = list()
	var/vision_radius = 2
	New()
		handle_overlay()
		SPAWN_DBG(0)
			check()//ohly fucke pls rewrite me
		cableimgs = new/list((vision_radius*2+1)**2)
		var/obj/cable/ctype = /obj/cable
		var/cicon = initial(ctype.icon)
		for(var/i = 1, i <= cableimgs.len, i++)
			var/image/cimg = image(cicon)
			cimg.layer = 100
			cimg.plane = 100
			cableimgs[i] = cimg//@MBC this is how you'd do phasing
		return ..()

	pickup()
		power_icon = ""
		handle_overlay()
		return ..()
	disposing()
		if(prev_user)
			prev_user.images -= cableimgs
			prev_user = null
		return ..()
	dropped()
		power_icon = ""
		handle_overlay()
		if(active)
			src.set_loc(get_turf(target))
			if(prev_user)
				prev_user.images -= cableimgs
				prev_user = null
			deactivate()
		return ..()

	proc/handle_overlay()
		var/rebuild_overlay = 0
		switch(power)
			if(0 to 20)
				if(power_icon != "volt1")
					power_icon = "volt1"
					rebuild_overlay = 1
			if(21 to 40)
				if(power_icon != "volt2")
					power_icon = "volt2"
					rebuild_overlay = 1
			if(41 to 60)
				if(power_icon != "volt3")
					power_icon = "volt3"
					rebuild_overlay = 1
			if(61 to 80)
				if(power_icon != "volt4")
					power_icon = "volt4"
					rebuild_overlay = 1
			if(81 to 100)
				if(power_icon != "volt5")
					power_icon = "volt5"
					rebuild_overlay = 1

		if(rebuild_overlay)
			overlays.Cut()
			overlays += image('icons/obj/items/device.dmi',src,power_icon)
	var/overlay_state = 0//0: nothing visible; 1: there's some visible
	var/client/prev_user
	proc/check()


		while (!disposed)
			if(prev_user && (!active || (((!target || !target.client) || prev_user != target.client))))
				prev_user.images -= cableimgs
				prev_user = null
			else if(target && (!prev_user || prev_user != target.client) && active)
				prev_user = target.client
				prev_user.images += cableimgs
			if(!active)
				if(power < 100) power += 0.35
				handle_overlay()
				if(overlay_state)
					for(var/image/img in cableimgs)
						img.loc = null
						img.alpha = 0
					overlay_state = 0
				sleep(1 SECOND)
			else
				overlay_state = 1
				for(var/image/img in cableimgs)
					img.loc = null
					img.alpha = 0
				var/turf/us = get_turf(D)
				var/turf/start = locate(us.x - src.vision_radius, us.y - src.vision_radius, us.z)
				var/turf/end = locate(us.x + src.vision_radius, us.y + src.vision_radius, us.z)

				for(var/turf/t in block(start, end))
					for(var/obj/cable/C in t.contents)//because why would you want to include invisible objects in range(), byond?
						var/idx = ((C.y - us.y + src.vision_radius) * src.vision_radius*2) + (C.x - us.x + src.vision_radius*2) + 1
						if(idx < 0 || idx > cableimgs.len)
							boutput(world, "[idx], [cableimgs.len]")
							continue
						var/image/img = cableimgs[idx]
						img.appearance = C.appearance
						img.invisibility = 0
						img.alpha = 255
						img.layer = 100
						img.plane = 100
						img.loc = locate(C.x, C.y, C.z)
				power = round(power)
				power--
				handle_overlay()
				if(power == 20)
					boutput(target, "<span class='alert'>The [src] is dangerously low on power. Your energy pattern is destabilizing.</span>")
				if(power < 20)
					random_brute_damage(target, 4)
				if(power <= 0)
					boutput(target, "<span class='alert'>The [src] is out of energy.</span>")
					var/mob/old_trg = target
					deactivate()
					old_trg.changeStatus("stunned", 200)
				sleep(1 SECOND)

	proc/deactivate()
		if(activating) return

		activating = 1

		on_cooldown = 1
		SPAWN_DBG(3 SECONDS) on_cooldown = 0

		var/atom/dummy = D
		if(D)
			dummy.invisibility = 101

		playsound(src, "sound/effects/shielddown2.ogg", 40, 1)
		var/obj/overlay/O = new/obj/overlay(get_turf(target))
		O.name = "Energy"
		O.anchored = 1
		O.layer = MOB_EFFECT_LAYER
		target.transforming = 1
		O.icon = 'icons/effects/effects.dmi'
		O.icon_state = "energytwirlout"
		sleep(0.5 SECONDS)
		target.transforming = 0
		qdel(O)

		target.set_loc(get_turf(target))
		qdel(D)
		D = null
		active = 0
		target = null
		activating = 0

	proc/activate()
		if(activating) return
		if(locate(/obj/cable) in get_turf(src))

			if(on_cooldown)
				boutput(usr, "<span class='alert'>The [src] is still recharging.</span>")
				return

			activating = 1

			playsound(get_turf(src), "sound/effects/singsuck.ogg", 40, 1)
			var/obj/overlay/O = new/obj/overlay(get_turf(usr))
			O.name = "Energy"
			O.anchored = 1
			O.layer = MOB_EFFECT_LAYER
			usr:transforming = 1
			O.icon = 'icons/effects/effects.dmi'
			O.icon_state = "energytwirlin"
			sleep(0.5 SECONDS)
			usr:transforming = 0
			qdel(O)

			D = new/obj/dummy/voltron(usr, get_turf(src))

			target = usr
			active = 1
			activating = 0
		else
			boutput(usr, "<span class='alert'>This needs to be used while standing on a cable.</span>")

	attack_self(mob/user as mob)
		if(activating) return

		if(active)
			boutput(target, "<span class='notice'>You deactivate the [src].</span>")
			deactivate()
		else
			if(istype(user.l_hand,/obj/item/phone_handset) || istype(user.r_hand,/obj/item/phone_handset)) // travel through space line
				var/obj/item/phone_handset/PH = null
				var/obj/item/phone_handset/EXIT = null
				var/turf/target_loc = null
				if(istype(user.l_hand,/obj/item/phone_handset))
					PH = user.l_hand
				else
					PH = user.r_hand
				if(PH.parent.linked && PH.parent.linked.handset)
					if(isturf(PH.parent.linked.handset.loc))
						target_loc = PH.parent.linked.handset.loc
					else if(ismob(PH.parent.linked.handset.loc))
						target_loc = PH.parent.linked.handset.loc.loc
					else
						boutput(user, "You can't seem to enter the phone for some reason!")
						return
				else
					boutput(user, "You can't seem to enter the phone for some reason!")
					return
				if(isrestrictedz(user.loc.z) || isrestrictedz(target_loc.z))
					boutput(user, "You can't seem to enter the phone for some reason!")
					return
				EXIT = PH.parent.linked.handset
				user.visible_message("[user] enters the phone line using their [src].", "You enter the phone line using your [src].", "You hear a strange sucking noise.")
				playsound(user.loc, "sound/effects/singsuck.ogg", 40, 1)
				user.drop_item(PH)
				user.set_loc(target_loc)
				playsound(user.loc, "sound/effects/singsuck.ogg", 40, 1)
				user.visible_message("[user] suddenly emerges from the [EXIT]. [pick("","What the fuck?")]", "You emerge from the [EXIT].", "You hear a strange sucking noise.")
			else
				boutput(user, "<span class='notice'>You activate the [src].</span>")
				activate()
			power -= 5
			handle_overlay()
		return
