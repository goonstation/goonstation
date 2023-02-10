TYPEINFO(/obj/item/device/igniter)
	mats = 2

/obj/item/device/igniter
	name = "igniter"
	desc = "A small electronic device can be paired with other electronics, or used to heat chemicals directly."
	icon_state = "igniter"
	var/status = 1
	flags = FPRINT | TABLEPASS| CONDUCT | USEDELAY
	c_flags = ONBELT
	item_state = "electronic"
	m_amt = 100
	throwforce = 5
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 10
	firesource = FIRESOURCE_IGNITER

	//blcok spamming shit because inventory uncaps click speed and kinda makes this an exploit
	//its still a bit stronger than non-inventory interactions, why not
	var/last_ignite = 0

/obj/item/device/igniter/attack(mob/M, mob/user)
	if (ishuman(M))
		if (M:bleeding || (M:butt_op_stage == 4 && user.zone_sel.selecting == "chest"))
			if (!src.cautery_surgery(M, user, 15))
				return ..()
		else return ..()
	else return ..()

/obj/item/device/igniter/attackby(obj/item/W, mob/user)
	if ((istype(W, /obj/item/device/radio/signaler) && !( src.status )))
		var/obj/item/device/radio/signaler/S = W
		if (!( S.b_stat ))
			return
		var/obj/item/assembly/rad_ignite/R = new /obj/item/assembly/rad_ignite( user )
		S.set_loc(R)
		R.part1 = S
		S.layer = initial(S.layer)
		user.u_equip(S)
		user.put_in_hand_or_drop(R)
		S.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(R)
		R.part2 = src
		src.add_fingerprint(user)

	else if ((istype(W, /obj/item/device/prox_sensor) && !( src.status )))

		var/obj/item/assembly/prox_ignite/R = new /obj/item/assembly/prox_ignite( user )
		W.set_loc(R)
		R.part1 = W
		W.layer = initial(W.layer)
		user.u_equip(W)
		user.put_in_hand_or_drop(R)
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(R)
		R.part2 = src
		src.add_fingerprint(user)

	else if ((istype(W, /obj/item/device/timer) && !( src.status )))

		var/obj/item/assembly/time_ignite/R = new /obj/item/assembly/time_ignite( user )
		W.set_loc(R)
		R.part1 = W
		W.layer = initial(W.layer)
		user.u_equip(W)
		user.put_in_hand_or_drop(R)
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(R)
		R.part2 = src
		src.add_fingerprint(user)
	else if ((istype(W, /obj/item/device/analyzer/healthanalyzer) && !( src.status )))

		var/obj/item/assembly/anal_ignite/R = new /obj/item/assembly/anal_ignite( user ) // Hehehe anal
		W.set_loc(R)
		R.part1 = W
		W.layer = initial(W.layer)
		user.u_equip(W)
		user.put_in_hand_or_drop(R)
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(R)
		R.part2 = src
		src.add_fingerprint(user)
	else if (istype(W, /obj/item/device/multitool)) // check specifically for a multitool

		var/obj/item/assembly/detonator/R = new /obj/item/assembly/detonator(user);
		W.set_loc(R)
		W.master = R
		W.layer = initial(W.layer)
		src.set_loc(R)
		src.master = R
		src.layer = initial(src.layer)
		R.part_mt = W
		R.part_ig = src
		R.set_loc(user)
		user.u_equip(src)
		user.u_equip(W)

		user.put_in_hand_or_drop(R)

		R.setDetState(0)
		src.add_fingerprint(user)
		user.show_message("<span class='notice'>You hook up the igniter to the multitool's panel.</span>")

	if (isscrewingtool(W))
		src.status = !(src.status)
		if (src.status)
			user.show_message("<span class='notice'>The igniter is ready!</span>")
		else
			user.show_message("<span class='notice'>The igniter can now be attached!</span>")
		src.add_fingerprint(user)

	return

/obj/item/device/igniter/attack_self(mob/user as mob)

	src.add_fingerprint(user)
	SPAWN( 5 )
		ignite()
		return
	return

/obj/item/device/igniter/proc/can_ignite()
	return (world.time >= last_ignite + src.combat_click_delay/2)

/obj/item/device/igniter/afterattack(atom/target, mob/user as mob)
	if (!ismob(target) && target.reagents && can_ignite())
		flick("igniter_light", src)
		boutput(user, "<span class='notice'>You heat \the [target.name]</span>")
		target.reagents.temperature_reagents(4000,400)
		last_ignite = world.time

/obj/item/device/igniter/proc/ignite()
	if (src.status && can_ignite())
		var/turf/location = src.loc

		if (src.master)
			location = src.master.loc

		flick("igniter_light", src)
		location = get_turf(location)
		location?.hotspot_expose((isturf(location) ? 3000 : 4000),2000)
		last_ignite = world.time

	return

/obj/item/device/igniter/examine(mob/user)
	. = ..()
	if ((in_interact_range(src, user) || src.loc == user))
		if (src.status)
			. += "The igniter is ready!"
		else
			. += "The igniter can be attached!"
