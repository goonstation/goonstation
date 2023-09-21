/*
Contains:

- Laser tripwire
- Infrared sensor
- Remote signaller/tripwire assembly
*/

//////////////////////////////////////// Laser tripwire //////////////////////////////

TYPEINFO(/obj/item/device/infra)
	mats = 3

/obj/item/device/infra
	name = "Laser Tripwire"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared0"
	var/state = 0
	var/visible = 0
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	m_amt = 150

///////////////////////////////////////// Infrared sensor ///////////////////////////////////////////

TYPEINFO(/obj/item/device/infra_sensor)
	mats = 4

/obj/item/device/infra_sensor
	name = "Infrared Sensor"
	desc = "Scans for infrared beams in the vicinity."
	icon_state = "infra_sensor"
	var/passive = 1
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	m_amt = 150

/* When/if someone ever gets around to fixing these uncomment this
/obj/item/device/infra_sensor/process()
	if (src.passive)
		for(var/obj/beam/i_beam/I in range(2, src.loc))
			I.left = 2
		return 1

	else
		processing_items.Remove(src)
		return null

/obj/item/device/infra_sensor/proc/burst()
	for(var/obj/beam/i_beam/I in range(src.loc))
		I.left = 10
	for(var/obj/item/device/infra/I in range(src.loc))
		I.visible = 1
		SPAWN( 0 )
			if (I?.first)
				I.first.vis_spread(1)
			return
	for(var/obj/item/assembly/rad_infra/I in range(src.loc))
		I.part2.visible = 1
		SPAWN( 0 )
			if ((I.part2 && I.part2.first))
				I.part2.first.vis_spread(1)
			return
	return

/obj/item/device/infra_sensor/attack_self(mob/user as mob)
	src.add_dialog(user)
	var/dat = text("<TT><B>Infrared Sensor</B><BR><br><B>Passive Emitter</B>: []<BR><br><B>Active Emitter</B>: <A href='?src=\ref[];active=0'>Burst Fire</A><br></TT>", (src.passive ? text("<A href='?src=\ref[];passive=0'>On</A>", src) : text("<A href='?src=\ref[];passive=1'>Off</A>", src)), src)
	user.Browse(dat, "window=infra_sensor")
	onclose(user, "infra_sensor")
	return

/obj/item/device/infra_sensor/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if ((usr.contents.Find(src) || (usr.contents.Find(src.master) || ((BOUNDS_DIST(src, usr) == 0) && istype(src.loc, /turf)))))
		src.add_dialog(usr)
		if (href_list["passive"])
			src.passive = !( src.passive )
			if(passive) processing_items |= src
		if (href_list["active"])
			SPAWN( 0 )
				src.burst()
				return
		if (!( src.master ))
			if (ismob(src.loc))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client)
						src.attack_self(M)
		else
			if (ismob(src.master.loc))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client)
						src.attack_self(M)
		src.add_fingerprint(usr)
	else
		usr.Browse(null, "window=infra_sensor")
		onclose(usr, "infra_sensor")
		return
	return

/obj/item/device/infra/proc/hit()
	if (src.master)
		SPAWN(0)
			var/datum/signal/signal = new
			signal.data["message"] = "ACTIVATE"
			src.master.receive_signal(signal)
			qdel(signal)
			return
	else
		for(var/mob/O in hearers(null, null))
			O.show_message(text("[bicon()] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	return

/obj/item/device/infra/process()
	if(!state)
		processing_items.Remove(src)
		return null

	if ((!( src.first ) && (src.state && (istype(src.loc, /turf) || (src.master && istype(src.master.loc, /turf))))))
		var/obj/beam/i_beam/I = new /obj/beam/i_beam( (src.master ? src.master.loc : src.loc) )
		//boutput(world, "infra spawning beam : \ref[I]")
		I.master = src
		I.set_density(1)
		I.set_dir(src.dir)
		step(I, I.dir)
		if (I)
			//boutput(world, "infra: beam at [I.x] [I.y] [I.z]")
			I.set_density(0)
			src.first = I
			//boutput(world, "infra : vis_spread")
			I.vis_spread(src.visible)
			SPAWN( 0 )
				if (I)
					//boutput(world, "infra: setting limit")
					I.limit = 20
					//boutput(world, "infra: processing beam \ref[I]")
					I.process()
				return
	if (!( src.state ))
		qdel(src.first)
		//src.first = null
	return

/obj/item/device/infra/attackby(obj/item/device/radio/signaler/S, mob/user)
	if ((!( istype(S, /obj/item/device/radio/signaler) ) || !( S.b_stat )))
		return
	var/obj/item/assembly/rad_infra/R = new /obj/item/assembly/rad_infra( user )
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
	R.set_dir(src.dir)
	src.add_fingerprint(user)
	return

/obj/item/device/infra/attack_self(mob/user as mob)
	src.add_dialog(user)
	var/dat = text("<TT><B>Infrared Laser</B><br><B>Status</B>: []<BR><br><B>Visibility</B>: []<BR><br></TT>", (src.state ? text("<A href='?src=\ref[];state=0'>On</A>", src) : text("<A href='?src=\ref[];state=1'>Off</A>", src)), (src.visible ? text("<A href='?src=\ref[];visible=0'>Visible</A>", src) : text("<A href='?src=\ref[];visible=1'>Invisible</A>", src)))
	user.Browse(dat, "window=infra")
	onclose(user, "infra")
	return

/obj/item/device/infra/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if ((usr.contents.Find(src) || usr.contents.Find(src.master) || in_interact_range(src, usr) && istype(src.loc, /turf)))
		src.add_dialog(usr)
		if (href_list["state"])
			src.state = !( src.state )
			src.icon_state = text("infrared[]", src.state)
			if (src.master)
				src.master:c_state(src.state, src)
			if(state) processing_items |= src
		if (href_list["visible"])
			src.visible = !( src.visible )
			SPAWN( 0 )
				if (src.first)
					src.first.vis_spread(src.visible)
				return
		if (!( src.master ))
			if (ismob(src.loc))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client)
						src.attack_self(M)
					//Foreach goto(211)
		else
			if (ismob(src.master.loc))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client)
						src.attack_self(M)
					//Foreach goto(287)
	else
		usr.Browse(null, "window=infra")
		onclose(usr, "infra")
		return
	return

/obj/item/device/infra/attack_hand()
	qdel(src.first)
	//src.first = null
	..()
	return

/obj/item/device/infra/Move()
	var/t = src.dir
	..()
	src.set_dir(t)
	qdel(src.first)
	//src.first = null
	return

/obj/item/device/infra/verb/rotate()
	set src in usr

	src.set_dir(turn(src.dir, 90))
	return

*/

/////////////////////////////////////// Remote signaller/tripwire assembly /////////////////////////////////

/obj/item/assembly/rad_infra
	name = "Signaller/Infrared Assembly"
	desc = "An infrared-activated radio signaller"
	icon_state = "infrared-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/infra/part2 = null
	status = null
	flags = FPRINT | TABLEPASS | CONDUCT

/obj/item/assembly/rad_infra/c_state(n)
	src.icon_state = text("infrared-radio[]", n)
	return
/*
/obj/item/assembly/rad_infra/disposing()
	qdel(src.part1)
	qdel(src.part2)
	..()
	return

/obj/item/assembly/rad_infra/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.set_loc(T)
		src.part2.set_loc(T)
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		qdel(src)
		return
	if (!isscrewingtool(W))
		return
	src.status = !(src.status)
	if (src.status)
		user.show_message("<span class='notice'>The infrared laser is now secured!</span>", 1)
	else
		user.show_message("<span class='notice'>The infrared laser is now unsecured!</span>", 1)
	src.part1.b_stat = !(src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_infra/attack_self(mob/user as mob)

	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_infra/receive_signal(datum/signal/signal)

	if (signal.source == src.part2)
		src.part1.send_signal("ACTIVATE")
	return

/obj/item/assembly/rad_infra/verb/rotate()
	set src in usr

	src.set_dir(turn(src.dir, 90))
	src.part2.set_dir(src.dir)
	src.add_fingerprint(usr)
	return

/obj/item/assembly/rad_infra/Move()

	var/t = src.dir
	..()
	src.set_dir(t)
	qdel(src.part2.first)
	//src.part2.first = null
	return

/obj/item/assembly/rad_infra/attack_hand(M)
	qdel(src.part2.first)
	..()
	return
*/
