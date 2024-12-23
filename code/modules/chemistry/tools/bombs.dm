
/* =============================================== */
/* -------------------- Bombs -------------------- */
/* =============================================== */

/obj/item/assembly/chem_bomb
	var/obj/item/device/triggering_device = null
	var/obj/item/device/igniter/igniter = null
	var/obj/item/chem_grenade/payload = null
	status = 0
	flags = TABLEPASS | CONDUCT
	var/mob/attacher = "Unknown"

/obj/item/assembly/chem_bomb/c_state(n)
	switch(src.triggering_device.type)
		if (/obj/item/device/timer)
			src.icon_state = text("timer-igniter-chem[]", n)
		if (/obj/item/device/prox_sensor)
			src.icon_state = text("prox-igniter-chem[]", n)
		if (/obj/item/device/radio/signaler)
			src.icon_state = "radio-igniter-chem"
	return

/obj/item/assembly/chem_bomb/bump(atom/O)
	if (!istype(src.triggering_device, /obj/item/device/prox_sensor))
		return
	SPAWN(0)
		//boutput(world, "miptank bumped into [O]")
		if (src.triggering_device:state)
			//boutput(world, "sending signal")
			receive_signal()
		//else
			//boutput(world, "not active")
	..()

/obj/item/assembly/chem_bomb/dropped()
	. = ..()
	if (!istype(src.triggering_device, /obj/item/device/prox_sensor))
		return
	SPAWN( 0 )
		src.triggering_device:sense()
		return
	return

/obj/item/assembly/chem_bomb/get_desc(dist, user)
	return src.payload.get_desc(dist, user)

/obj/item/assembly/chem_bomb/disposing()
	qdel(src.triggering_device)
	src.triggering_device = null
	qdel(src.igniter)
	src.igniter = null
	qdel(src.payload)
	src.payload = null
	..()

/obj/item/assembly/chem_bomb/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		var/obj/item/assembly/R = null
		switch(src.triggering_device.type)
			if (/obj/item/device/timer)
				R = new /obj/item/assembly/time_ignite()
			if (/obj/item/device/prox_sensor)
				R = new /obj/item/assembly/prox_ignite()
			if (/obj/item/device/radio/signaler)
				R = new /obj/item/assembly/rad_ignite()
		if (!R)
			return
		R:part1 = src.triggering_device
		R:part2 = src.igniter
		user.put_in_hand_or_drop(R)
		src.triggering_device.set_loc(R)
		src.igniter.set_loc(R)
		src.triggering_device.master = R
		src.igniter.master = R
		var/turf/T = src.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		src.payload.set_loc(T)
		src.triggering_device = null
		src.igniter = null
		src.payload = null
		qdel(src)
		return

	src.add_fingerprint(user)
	return

/obj/item/assembly/chem_bomb/attack_self(mob/user as mob)
	playsound(src.loc, 'sound/weapons/armbomb.ogg', 100, 1)
	// drsingh for Cannot execute null.attack self()
	if (isnull(src) || isnull(src.triggering_device))
		return

	src.triggering_device.AttackSelf(user, 1)
	src.add_fingerprint(user)
	return

/obj/item/assembly/chem_bomb/receive_signal()
	//boutput(world, "miptank [src] got signal")
	for (var/mob/O in hearers(1, null))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)

	var/turf/bombturf = get_turf(src)
	var/bombarea = bombturf.loc.name

	logTheThing(LOG_BOMBING, null, "Chemical ([src]) Bomb triggered in [bombarea] with device attacher: [attacher]. Last touched by: [src.fingerprintslast]")
	message_admins("Chemical Bomb ([src]) triggered in [bombarea] with device attacher: [attacher]. Last touched by: [key_name(src.fingerprintslast)]")

	//boutput(world, "sent explode() to [src.payload]")
	src.payload.explode()
	return
