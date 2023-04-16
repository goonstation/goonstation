/* Contains:
- Single tank bomb logs
- Single tank bomb (proximity)
- Single tank bomb (timer)
- Single tank bomb (remote signaller)
*/

// Just a little helper. These three bombs are very similar (Convair880).
/obj/item/assembly/proc/bomb_logs(var/mob/user, var/obj/item/bomb, var/type = "", var/welded_or_unwelded = 0, var/is_dud = 0)
	if (!bomb || !type)
		return

	if (is_dud == 1)
		message_admins("A [type] single tank bomb would have opened at [log_loc(bomb)] but was forced to dud! Last touched by: [key_name(bomb.fingerprintslast)]")
		logTheThing(LOG_BOMBING, null, "A [type] single tank bomb would have opened at [log_loc(bomb)] but was forced to dud! Last touched by: [bomb.fingerprintslast ? "[bomb.fingerprintslast]" : "*null*"]")
		return

	var/obj/item/tank/T = null

	if (istype(bomb, /obj/item/assembly/proximity_bomb/))
		var/obj/item/assembly/proximity_bomb/PB = bomb
		if (PB.part3)
			T = PB.part3
	if (istype(bomb, /obj/item/assembly/time_bomb/))
		var/obj/item/assembly/time_bomb/TB = bomb
		if (TB.part3)
			T = TB.part3
	if (istype(bomb, /obj/item/assembly/radio_bomb/))
		var/obj/item/assembly/radio_bomb/RB = bomb
		if (RB.part3)
			T = RB.part3

	if (!T || !istype(T, /obj/item/tank))
		return

	logTheThing(LOG_BOMBING, user, "[welded_or_unwelded == 0 ? "welded" : "unwelded"] a [type] single tank bomb [log_atmos(T)] at [log_loc(user)].")
	if (welded_or_unwelded == 0)
		message_admins("[key_name(user)] welded a [type] single tank bomb [alert_atmos(T)] at [log_loc(user)].")

	return

/////////////////////////////////////////////////// Single tank bomb (proximity) ////////////////////////////////////

/obj/item/assembly/proximity_bomb
	desc = "A very intricate igniter and proximity sensor electrical assembly mounted onto top of a plasma tank."
	name = "Proximity/Igniter/Plasma Tank Assembly"
	icon_state = "prox-igniter-tank0"
	var/obj/item/device/prox_sensor/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/tank/plasma/part3 = null
	status = 0
	flags = FPRINT | TABLEPASS| CONDUCT
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER

/obj/item/assembly/proximity_bomb/dropped()

	SPAWN( 0 )
		src.part1.sense()
		return
	return

/obj/item/assembly/proximity_bomb/examine()
	. = ..()
	. += src.part3.examine()

/obj/item/assembly/proximity_bomb/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	qdel(part3)
	part3 = null
	..()
	return

/obj/item/assembly/proximity_bomb/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W) && !(src.status))
		var/obj/item/assembly/prox_ignite/R = new /obj/item/assembly/prox_ignite(  )
		R.part1 = src.part1
		R.part2 = src.part2
		user.put_in_hand_or_drop(R)
		src.part1.set_loc(R)
		src.part2.set_loc(R)
		src.part1.master = R
		src.part2.master = R
		var/turf/T = src.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		src.part3.set_loc(T)
		src.part1 = null
		src.part2 = null
		src.part3 = null
		qdel(src)
		return
	if (!(isweldingtool(W) && W:try_weld(user,0,-1,1,0)))
		return
	if (!( src.status ))
		src.status = 1
		user.show_message("<span class='notice'>A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.</span>", 1)
	else
		src.status = 0
		boutput(user, "<span class='notice'>The hole has been closed.</span>")

	src.bomb_logs(user, src, "proximity", src.status == 1 ? 0 : 1, 0)
	src.part2.status = src.status
	src.add_fingerprint(user)
	return

/obj/item/assembly/proximity_bomb/attack_self(mob/user as mob)

	playsound(src.loc, 'sound/weapons/armbomb.ogg', 100, 1)
	src.part1.attack_self(user, 1)
	src.add_fingerprint(user)
	return

/obj/item/assembly/proximity_bomb/receive_signal()
	//boutput(world, "miptank [src] got signal")
	for(var/mob/O in hearers(1, null))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
		//Foreach goto(19)

	if (src.status)
		src.part1.armed = FALSE
		src.c_state(0)
		if (src.force_dud == 1)
			src.bomb_logs(usr, src, "proximity", 0, 1)
			return
		src.part3.ignite()
	else
		if (!src.status && src.force_dud == 0)
			src.part1.armed = FALSE
			src.c_state(0)
			src.part3.release()

	return

/obj/item/assembly/proximity_bomb/c_state(n)

	src.icon_state = text("prox-igniter-tank[]", n)
	return

/obj/item/assembly/proximity_bomb/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/projectile))
		return
	if (AM.move_speed < 12 && src.part1)
		src.part1.sense()
	return

/obj/item/assembly/proximity_bomb/bump(atom/O)
	SPAWN(0)
		//boutput(world, "miptank bumped into [O]")
		if(src.part1.armed)
			//boutput(world, "sending signal")
			receive_signal()
		else
			//boutput(world, "not active")
	..()

/obj/item/assembly/proximity_bomb/proc/prox_check()
	if(!part1 || !part1.armed)
		return
	for(var/atom/A in view(1, src.loc))
		if(A!=src && !istype(A, /turf/space) && !isarea(A))
			//boutput(world, "[A]:[A.type] was sensed")
			src.part1.sense()
			break

	SPAWN(1 SECOND)
		prox_check()

/////////////////////////////////////////////////// Single tank bomb (timer) ////////////////////////////////////

/obj/item/assembly/time_bomb
	desc = "A very intricate igniter and timer assembly mounted onto top of a plasma tank."
	name = "Timer/Igniter/Plasma Tank Assembly"
	icon_state = "timer-igniter-tank0"
	var/obj/item/device/timer/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/tank/plasma/part3 = null
	status = 0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/time_bomb/c_state(n)

	src.icon_state = text("timer-igniter-tank[]", n)
	return

/obj/item/assembly/time_bomb/examine()
	. = ..()
	. += src.part3.examine()

/obj/item/assembly/time_bomb/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	qdel(part3)
	part3 = null
	..()
	return

/obj/item/assembly/time_bomb/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W) && !(src.status))
		var/obj/item/assembly/time_ignite/R = new /obj/item/assembly/time_ignite(  )
		R.part1 = src.part1
		R.part2 = src.part2
		user.put_in_hand_or_drop(R)
		src.part1.set_loc(R)
		src.part2.set_loc(R)
		src.part1.master = R
		src.part2.master = R
		var/turf/T = src.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		src.part3.set_loc(T)
		src.part1 = null
		src.part2 = null
		src.part3 = null
		qdel(src)
		return
	if (!(isweldingtool(W) && W:try_weld(user,0,-1,1,0)))
		return
	if (!( src.status ))
		src.status = 1
		user.show_message("<span class='notice'>A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.</span>", 1)
	else
		src.status = 0
		boutput(user, "<span class='notice'>The hole has been closed.</span>")

	src.part2.status = src.status
	src.bomb_logs(user, src, "timer", src.status == 1 ? 0 : 1, 0)
	src.add_fingerprint(user)
	return

/obj/item/assembly/time_bomb/attack_self(mob/user as mob)

	if (src.part1)
		src.part1.attack_self(user, 1)
		playsound(src.loc, 'sound/weapons/armbomb.ogg', 100, 1)
	src.add_fingerprint(user)
	return

/obj/item/assembly/time_bomb/receive_signal()
	//boutput(world, "tiptank [src] got signal")
	for(var/mob/O in hearers(1, null))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	if (src.status)
		if (src.force_dud == 1)
			src.bomb_logs(usr, src, "timer", 0, 1)
			return
		src.part3.ignite()
	else
		if (!src.status && src.force_dud == 0)
			src.part3.release()
	return

/////////////////////////////////////////////////// Single tank bomb (remote signaller) ////////////////////////////////////

/obj/item/assembly/radio_bomb
	desc = "A very intricate igniter and signaller electrical assembly mounted onto top of a plasma tank."
	name = "Radio/Igniter/Plasma Tank Assembly"
	icon_state = "radio-igniter-tank"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/tank/plasma/part3 = null
	status = 0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/radio_bomb/examine()
	. = ..()
	. += src.part3.examine()

/obj/item/assembly/radio_bomb/disposing()

	qdel(src.part1)
	src.part1 = null
	qdel(src.part2)
	src.part2 = null
	qdel(src.part3)
	src.part3 = null
	..()
	return

/obj/item/assembly/radio_bomb/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W) && !(src.status))
		var/obj/item/assembly/rad_ignite/R = new /obj/item/assembly/rad_ignite(  )
		R.part1 = src.part1
		R.part2 = src.part2
		user.put_in_hand_or_drop(R)
		src.part1.set_loc(R)
		src.part2.set_loc(R)
		src.part1.master = R
		src.part2.master = R
		var/turf/T = src.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		if (!( istype(T, /turf) ))
			T = T.loc
		src.part3.set_loc(T)
		src.part1 = null
		src.part2 = null
		src.part3 = null
		qdel(src)
		return
	if (!(isweldingtool(W) && W:try_weld(user,0,-1,1,0)))
		return
	if (!( src.status ))
		src.status = 1
		user.show_message("<span class='notice'>A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.</span>", 1)
	else
		src.status = 0
		boutput(user, "<span class='notice'>The hole has been closed.</span>")

	src.bomb_logs(user, src, "radio", src.status == 1 ? 0 : 1, 0)
	src.part2.status = src.status
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/radio_bomb/attack_self(mob/user as mob)

	if (src.part1)
		playsound(src.loc, 'sound/weapons/armbomb.ogg', 100, 1)
		src.part1.attack_self(user, 1)
	src.add_fingerprint(user)
	return

/obj/item/assembly/radio_bomb/receive_signal()
	//boutput(world, "riptank [src] got signal")
	for(var/mob/O in hearers(1, null))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	if (src.status)
		if (src.force_dud == 1)
			src.bomb_logs(usr, src, "radio", 0, 1)
			return
		src.part3.ignite()
	else
		if (!src.status && src.force_dud == 0)
			src.part3.release()
	return
