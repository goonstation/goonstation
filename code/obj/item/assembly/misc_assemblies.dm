/*
Contains:

- Assembly parent
- Timer/igniter
- Proximity/igniter
- Remote signaller/igniter
- Health analyzer/igniter
- Remote signaller/bike horn
- Remote signaller/timer
- Remote signaller/proximity
- Beaker Assembly
- Pipebomb Assembly
- Craftable shotgun shells

*/

//////////////////////////////////////// Assembly parent /////////////////////////////////

/obj/item/assembly
	name = "assembly"
	icon = 'icons/obj/items/assemblies.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "assembly"
	var/status = 0
	throwforce = 10
	w_class = W_CLASS_NORMAL
	throw_speed = 4
	throw_range = 10
	force = 2
	stamina_damage = 10
	stamina_cost = 10
	var/force_dud = 0

/obj/item/assembly/proc/c_state(n, O as obj)
	return

/////////////////////////////////////// Timer/igniter /////////////////////////

/obj/item/assembly/time_ignite
	name = "Timer/Igniter Assembly"
	desc = "A timer-activated igniter assembly."
	icon_state = "timer-igniter0"
	var/obj/item/device/timer/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/reagent_containers/glass/beaker/part3 = null
	var/obj/item/pipebomb/frame/part4 = null
	var/obj/item/pipebomb/bomb/part5 = null
	var/sound_pipebomb = 'sound/weapons/armbomb.ogg'
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT | NOSPLASH

/obj/item/assembly/time_ignite/New()
	..()
	SPAWN(0)
		if(!part1)
			part1 = new(src)
			part1.master = src
		if(!part2)
			part2 = new(src)
			part2.master = src
	return

/obj/item/assembly/time_ignite/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	qdel(part3)
	part3 = null
	qdel(part4)
	part4 = null
	qdel(part5)
	part5 = null
	..()

/obj/item/assembly/time_ignite/attack_self(mob/user as mob)
	src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/time_ignite/receive_signal()
	if(!src.status)
		return
	for(var/mob/O in hearers(1, src.loc))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	src.part2.ignite()
	if(src.part3)
		src.part3.reagents.temperature_reagents(4000, 400)
		src.part3.reagents.temperature_reagents(4000, 400)
	if(src.part5)
		playsound(src.loc, sound_pipebomb, 50, 0)
		SPAWN(3 SECONDS)
			src.part5.do_explode()
			qdel(src)
	return

/obj/item/assembly/time_ignite/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		if (src.part1)
			src.part1.set_loc(T)
			src.part1.master = null
			src.part1 = null
		if (src.part2)
			src.part2.set_loc(T)
			src.part2.master = null
			src.part2 = null
		if (src.part3)
			src.part3.set_loc(T)
			src.part3.master = null
			src.part3 = null
		if (src.part4)
			src.part4.set_loc(T)
			src.part4.master = null
			src.part4 = null
			src.part5.master = null
			src.part5 = null
		if (src.part5 && !src.part4)
			src.part5.set_loc(T)
			src.part5.master = null
			src.part5 = null
		user.u_equip(src)
		qdel(src)
		return

	if((istype(W, /obj/item/reagent_containers/glass/beaker) && !( src.status )))
		if(!src.part3 && !src.part5)
			src.part3 = W
			W.master = src
			W.layer = initial(W.layer)
			user.u_equip(W)
			W.set_loc(src)
			src.c_state(0)

			boutput(user, "You attach the timer/igniter assembly to the beaker.")
		else boutput(user, "You must remove the beaker from the assembly before transferring chemicals to it!")
		return

	if((istype(W, /obj/item/pipebomb/frame) && !( src.status )))
		var/obj/item/pipebomb/frame/F = W
		if(!src.part3 && !src.part5 && F.state < 4)
			boutput(user, "You have to add reagents and wires to the pipebomb before you can add an igniter.")
			return
		if(!src.part3 && !src.part5 && F.state == 4)
			src.part4 = F
			F.master = src
			F.layer = initial(F.layer)
			user.u_equip(F)
			F.set_loc(src)

			src.part5 = new /obj/item/pipebomb/bomb
			src.part5.strength = F.strength
			if (F.material)
				src.part5.setMaterial(F.material)
			user.u_equip(W)
			src.part5 = src.part5
			src.part5.master = src
			src.part5.layer = initial(src.part5.layer)
			src.part5.set_loc(src)
			src.c_state(0)
			boutput(user, "You attach the pipebomb to the timer/igniter assembly.")
			logTheThing(LOG_BOMBING, user, "made Timer/Igniter/Pipebomb Assembly at [log_loc(src)].")
			message_admins("[key_name(user)] made a Timer/Igniter/Pipebomb Assembly at [log_loc(src)].")
		else
			boutput(user, "You can't add more then one pipebomb to the assembly.")

	if((istype(W, /obj/item/pipebomb/bomb)))
		if(!src.part3 && !src.part5)
			src.part5 = W
			W.master = src
			W.layer = initial(W.layer)
			user.u_equip(W)
			W.set_loc(src)
			src.c_state(0)
			boutput(user, "You attach the pipebomb to the timer/igniter assembly.")
			logTheThing(LOG_BOMBING, user, "made Timer/Igniter/Pipebomb Assembly at [log_loc(src)].")
			message_admins("[key_name(user)] made a Timer/Igniter/Pipebomb Assembly at [log_loc(src)].")
		else
			boutput(user, "You can't add more then one pipebomb to the assembly.")

	if (isscrewingtool(W))
		src.status = !(src.status)
		if (src.status)
			user.show_message("<span class='notice'>The timer is now secured!</span>", 1)
		else
			user.show_message("<span class='notice'>The timer is now unsecured!</span>", 1)
		src.part2.status = src.status
		src.add_fingerprint(user)
		return

/obj/item/assembly/time_ignite/c_state(n)
	if(!src.part3 && !src.part5)
		src.icon = 'icons/obj/items/assemblies.dmi'
		src.icon_state = text("timer-igniter[n]")
		src.overlays = null
		src.underlays = null
		src.name = "Timer/Igniter Assembly"
	else if(!src.part3 && src.part5)
		src.icon = part5.icon
		src.icon_state = part5.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "timeignite_overlay[n]", layer = FLOAT_LAYER)
		src.name = "Timer/Igniter/Pipebomb Assembly"
	else
		src.icon = part3.icon
		src.icon_state = part3.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "timeignite_overlay[n]", layer = FLOAT_LAYER)
		src.underlays += part3.underlays
		src.name = "Timer/Igniter/Beaker Assembly"
	return

/obj/item/assembly/time_ignite/verb/removebeaker()
	set src in oview(1)
	set name = "remove beaker"
	set category = "Local"

	if (usr.stat || !isliving(usr) || isintangible(usr))
		return

	if(src.part3)
		src.part3.master = null
		src.part3.Attackhand(usr)
		src.part3 = null
		src.c_state(src.part1.timing)
		boutput(usr, "<span class='notice'>You remove the timer/igniter assembly from the beaker.</span>")
	else boutput(usr, "<span class='alert'>That doesn't have a beaker attached to it!</span>")


/////////////////////////////// Proximity/igniter /////////////////////////////////////

/obj/item/assembly/prox_ignite
	name = "Proximity/Igniter Assembly"
	desc = "A proximity-activated igniter assembly."
	icon_state = "prox-igniter0"
	var/obj/item/device/prox_sensor/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/reagent_containers/glass/beaker/part3 = null
	var/obj/item/pipebomb/frame/part4 = null
	var/obj/item/pipebomb/bomb/part5 = null
	var/sound_pipebomb = 'sound/weapons/armbomb.ogg'
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT | NOSPLASH
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER

/obj/item/assembly/prox_ignite/HasProximity(atom/movable/AM as mob|obj)

	if (isobserver(AM) || iswraith(AM) || isintangible(AM) || istype(AM, /obj/projectile))
		return
	if (AM.move_speed < 12 && src.part1)
		src.part1.sense()
	return

/obj/item/assembly/prox_ignite/dropped()
	SPAWN( 0 )
		if (src.part1)
			src.part1.sense()
		return
	return

/obj/item/assembly/prox_ignite/New()
	..()
	SPAWN(0)
		if(!part1)
			part1 = new(src)
			part1.master = src
		if(!part2)
			part2 = new(src)
			part2.master = src
	return

/obj/item/assembly/prox_ignite/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	qdel(part3)
	part3 = null
	qdel(part4)
	part4 = null
	qdel(part5)
	part5 = null
	..()

/obj/item/assembly/prox_ignite/c_state(n)
	if(!src.part3 && !src.part5)
		src.icon = 'icons/obj/items/assemblies.dmi'
		src.icon_state = text("prox-igniter[n]")
		src.overlays = null
		src.underlays = null
		src.name = "Proximity/Igniter Assembly"
	else if(!src.part3 && src.part5)
		src.icon = part5.icon
		src.icon_state = part5.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "proxignite_overlay[n]", layer = FLOAT_LAYER)
		src.name = "Proximity/Igniter/Pipebomb Assembly"
	else
		src.icon = part3.icon
		src.icon_state = part3.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "proxignite_overlay[n]", layer = FLOAT_LAYER)
		src.underlays += part3.underlays
		src.name = "Proximity/Igniter/Beaker Assembly"
	return

/obj/item/assembly/prox_ignite/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		if (part1)
			src.part1.set_loc(T)
			src.part1.master = null
			src.part1 = null

		if (part2)
			src.part2.set_loc(T)
			src.part2.master = null
			src.part2 = null

		if (part3)
			src.part3.set_loc(T)
			src.part3.master = null
			src.part3 = null

		if (part4)
			src.part4.set_loc(T)
			src.part4.master = null
			src.part4 = null
			src.part5.master = null
			src.part5 = null

		if (part5 && !part4)
			src.part5.set_loc(T)
			src.part5.master = null
			src.part5 = null
		user.u_equip(src)
		qdel(src)
		return
	if((istype(W, /obj/item/reagent_containers/glass/beaker) && !( src.status )))
		if(!src.part3 && !src.part5)
			src.part3 = W
			W.master = src
			W.layer = initial(W.layer)
			user.u_equip(W)
			W.set_loc(src)
			src.c_state(0)

			boutput(user, "You attach the proximity/igniter assembly to the beaker.")
		else boutput(user, "You must remove the beaker from the assembly before transferring chemicals to it!")
		return

	if((istype(W, /obj/item/pipebomb/frame) && !( src.status )))
		var/obj/item/pipebomb/frame/F = W
		if(!src.part3 && !src.part5 && F.state < 4)
			boutput(user, "You have to add reagents and wires to the pipebomb before you can add an igniter.")
			return
		if(!src.part3 && !src.part5 && F.state == 4)
			src.part4 = F
			F.master = src
			F.layer = initial(F.layer)
			user.u_equip(F)
			F.set_loc(src)

			src.part5 = new /obj/item/pipebomb/bomb
			src.part5.strength = F.strength
			if (F.material)
				src.part5.setMaterial(F.material)
			user.u_equip(W)
			src.part5 = src.part5
			src.part5.master = src
			src.part5.layer = initial(src.part5.layer)
			src.part5.set_loc(src)
			src.c_state(0)
			boutput(user, "You attach the sensor/igniter assembly to the pipebomb.")
			logTheThing(LOG_BOMBING, user, "made Proximity/Igniter/Pipebomb Assembly at [log_loc(src)].")
			message_admins("[key_name(user)] made a Proximity/Igniter/Pipebomb Assembly at [log_loc(src)].")
		else
			boutput(user, "You can't add more then one pipebomb to the assembly.")
		return
	if((istype(W, /obj/item/pipebomb/bomb)))
		if(!src.part3 && !src.part5)
			src.part5 = W
			W.master = src
			W.layer = initial(W.layer)
			user.u_equip(W)
			W.set_loc(src)
			src.c_state(0)
			boutput(user, "You attach the sensor/igniter assembly to the pipebomb.")
			logTheThing(LOG_BOMBING, user, "made Proximity/Igniter/Beaker Assembly at [log_loc(src)].")
			message_admins("[key_name(user)] made a Proximity/Igniter/Beaker Assembly at [log_loc(src)].")
		else
			boutput(user, "You can't add more then one pipebomb to the assembly.")

	if (!isscrewingtool(W))
		return
	src.status = !(src.status)
	if (src.status)
		user.show_message("<span class='notice'>The proximity sensor is now secured! The igniter now works!</span>", 1)
	else
		user.show_message("<span class='notice'>The proximity sensor is now unsecured! The igniter will not work.</span>", 1)
	src.part2.status = src.status
	src.add_fingerprint(user)

	return

/obj/item/assembly/prox_ignite/attack_self(mob/user as mob)

	src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/prox_ignite/receive_signal()
	if(!src.status)
		return
	for(var/mob/O in hearers(1, src.loc))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	src.part2.ignite()
	if(src.part3)
		src.part3.reagents.temperature_reagents(4000, 400)
		src.part3.reagents.temperature_reagents(4000, 400)
	if(src.part5)
		playsound(src.loc, sound_pipebomb, 50, 0)
		SPAWN(3 SECONDS)
			src.part5?.do_explode()
			qdel(src)
	return

/obj/item/assembly/prox_ignite/verb/removebeaker()
	set src in oview(1)
	set name = "remove beaker"
	set category = "Local"

	if (usr.stat || !isliving(usr) || isintangible(usr))
		return

	if(src.part3)
		src.part3.master = null
		src.part3.Attackhand(usr)
		src.part3 = null
		src.c_state(src.part1.timing)
		boutput(usr, "<span class='notice'>You remove the Proximity/Igniter assembly from the beaker.</span>")
	else boutput(usr, "<span class='alert'>That doesn't have a beaker attached to it!</span>")

/////////////////////////////////////// Remote signaller/igniter //////////////////////////////////////

/obj/item/assembly/rad_ignite
	name = "Radio/Igniter Assembly"
	desc = "A radio-activated igniter assembly."
	icon_state = "radio-igniter"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/reagent_containers/glass/beaker/part3 = null
	var/obj/item/pipebomb/frame/part4 = null
	var/obj/item/pipebomb/bomb/part5 = null
	var/sound_pipebomb = 'sound/weapons/armbomb.ogg'
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT | NOSPLASH

/obj/item/assembly/rad_ignite/New()
	..()
	SPAWN(0)
		if(!part1)
			part1 = new(src)
			part1.master = src
		if(!part2)
			part2 = new(src)
			part2.master = src

/obj/item/assembly/rad_ignite/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	qdel(part3)
	part3 = null
	qdel(part4)
	part4 = null
	qdel(part5)
	part5 = null
	..()

/obj/item/assembly/rad_ignite/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		if (part1)
			src.part1.set_loc(T)
			src.part1.master = null
			src.part1 = null

		if (part2)
			src.part2.set_loc(T)
			src.part2.master = null
			src.part2 = null

		if (part3)
			src.part3.set_loc(T)
			src.part3.master = null
			src.part3 = null

		if (part4)
			src.part4.set_loc(T)
			src.part4.master = null
			src.part4 = null
			src.part5.master = null
			src.part5 = null

		if (part5 && !part4)
			src.part5.set_loc(T)
			src.part5.master = null
			src.part5 = null

		user.u_equip(src)
		qdel(src)
		return
	if((istype(W, /obj/item/reagent_containers/glass/beaker) && !( src.status )))
		if(!src.part3 && !src.part5)
			src.part3 = W
			W.master = src
			W.layer = initial(W.layer)
			user.u_equip(W)
			W.set_loc(src)
			src.c_state()

			boutput(user, "You attach the radio/igniter assembly to the beaker.")
		else boutput(user, "You must remove the beaker from the assembly before transferring chemicals to it!")
		return

	if((istype(W, /obj/item/pipebomb/frame) && !( src.status )))
		var/obj/item/pipebomb/frame/F = W
		if(!src.part3 && !src.part5 && F.state < 4)
			boutput(user, "You have to add reagents and wires to the pipebomb before you can add an igniter.")
			return
		if(!src.part3 && !src.part5 && F.state == 4)
			src.part4 = F
			F.master = src
			F.layer = initial(F.layer)
			user.u_equip(F)
			F.set_loc(src)

			src.part5 = new /obj/item/pipebomb/bomb
			src.part5.strength = F.strength
			if (F.material)
				src.part5.setMaterial(F.material)
			user.u_equip(W)
			src.part5 = src.part5
			src.part5.master = src
			src.part5.layer = initial(src.part5.layer)
			src.part5.set_loc(src)
			src.c_state()
			boutput(user, "You attach the radio/igniter assembly to the pipebomb.")
			logTheThing(LOG_BOMBING, user, "made Radio/Igniter/Pipebomb Assembly at [log_loc(user)].")
			message_admins("[key_name(user)] made a Radio/Igniter/Pipebomb Assembly at [log_loc(user)].")
		else
			boutput(user, "You can't add more then one pipebomb to the assembly.")
		return
	if((istype(W, /obj/item/pipebomb/bomb)))
		if(!src.part3 && !src.part5)
			src.part5 = W
			W.master = src
			W.layer = initial(W.layer)
			user.u_equip(W)
			W.set_loc(src)
			src.c_state()
			boutput(user, "You attach the radio/igniter assembly to the pipebomb.")
			logTheThing(LOG_BOMBING, user, "made Radio/Igniter/Pipebomb Assembly at [log_loc(user)].")
			message_admins("[key_name(user)] made a Radio/Igniter/Pipebomb Assembly at [log_loc(user)].")
		else
			boutput(user, "You can't add more then one pipebomb to the assembly.")

	if (!isscrewingtool(W))
		return
	src.status = !(src.status)
	if (src.status)
		user.show_message("<span class='notice'>The radio is now secured! The igniter now works!</span>", 1)
	else
		user.show_message("<span class='notice'>The radio is now unsecured! The igniter will not work.</span>", 1)
	src.part2.status = src.status
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_ignite/attack_self(mob/user as mob)

	src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_ignite/receive_signal()
	if(!src.status)
		return
	for(var/mob/O in hearers(1, src.loc))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	if (src.part2)
		src.part2.ignite()
	if(src.part3)
		src.part3.reagents.temperature_reagents(4000, 400)
		src.part3.reagents.temperature_reagents(4000, 400)
	if(src.part5)
		playsound(src.loc, sound_pipebomb, 50, 0)
		SPAWN(3 SECONDS)
			src.part5?.do_explode()
			qdel(src)
	return

/obj/item/assembly/rad_ignite/verb/removebeaker()
	set src in oview(1)
	set name = "remove beaker"
	set category = "Local"

	if (usr.stat || !isliving(usr) || isintangible(usr))
		return

	if(src.part3)
		src.part3.master = null
		src.part3.Attackhand(usr)
		src.part3 = null
		src.c_state()
		boutput(usr, "<span class='notice'>You remove the radio/igniter assembly from the beaker.</span>")
	else boutput(usr, "<span class='alert'>That doesn't have a beaker attached to it!</span>")

/obj/item/assembly/rad_ignite/c_state()
	if(!src.part3 && !src.part5)
		src.icon = 'icons/obj/items/assemblies.dmi'
		src.icon_state = text("radio-igniter")
		src.overlays = null
		src.underlays = null
		src.name = "Radio/Igniter Assembly"
	if(!src.part3 && src.part5)
		src.icon = part5.icon
		src.icon_state = part5.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "radignite_overlay", layer = FLOAT_LAYER)
		src.name = "Radio/Igniter/Pipebomb Assembly"
	else
		src.icon = part3.icon
		src.icon_state = part3.icon_state
		src.overlays = null
		src.underlays = null
		src.overlays += image('icons/obj/items/assemblies.dmi', "radignite_overlay", layer = FLOAT_LAYER)
		src.underlays += part3.underlays
		src.name = "Radio/Igniter/Beaker Assembly"
	return

///////////////////////////////// Health analyzer/igniter /////////////////////////////////////////////

/obj/item/assembly/anal_ignite //lol
	name = "Health-Analyzer/Igniter Assembly"
	desc = "A health-analyzer igniter assembly."
	icon_state = "health-igniter"
	var/obj/item/device/analyzer/healthanalyzer/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"

/obj/item/assembly/anal_ignite/New()
	..()
	SPAWN(0.5 SECONDS)
		if (src && !src.part1)
			src.part1 = new /obj/item/device/analyzer/healthanalyzer(src)
			src.part1.master = src
		if (src && !src.part2)
			src.part2 = new /obj/item/device/igniter(src)
			src.part2.master = src
	return

/obj/item/assembly/anal_ignite/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		src.part1.set_loc(T)
		src.part2.set_loc(T)
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null

		user.u_equip(src)
		qdel(src)
		return
	if (isscrewingtool(W))
		src.status = !(src.status)
		if (src.status)
			user.show_message("<span class='notice'>The analyzer is now secured!</span>", 1)
		else
			user.show_message("<span class='notice'>The analyzer is now unsecured!</span>", 1)
		src.part2.status = src.status
		src.add_fingerprint(user)
	return

///////////////////////////////////////////////////// Remote signaller/bike horn /////////////////////

/obj/item/assembly/radio_horn
	desc = "A bike horn hastily jammed into a signaller."
	name = "Radio/Horn Assembly"
	icon_state = "radio-horn"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/instrument/bikehorn/part2 = null
	status = 0
	flags = FPRINT | TABLEPASS | CONDUCT

/obj/item/assembly/radio_horn/New()
	..()
	SPAWN(0)
		if(!part1)
			part1 = new(src)
			part1.master = src
		if(!part2)
			part2 = new(src)
			part2.master = src
	return

/obj/item/assembly/radio_horn/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	..()
	return

obj/item/assembly/radio_horn/attack_self(mob/user as mob)
	src.part1.attack_self(user)
	src.add_fingerprint(user)
	return

obj/item/assembly/radio_horn/receive_signal()
	part2.play_note(rand(1,part2.sounds_instrument.len), user = null)
	return

/////////////////////////////////////////////////////// Remote signaller/timer /////////////////////////////////////

/obj/item/assembly/rad_time
	name = "Signaller/Timer Assembly"
	desc = "A radio signaller activated by a count-down timer."
	icon_state = "timer-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/timer/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_time/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	..()
	return

/obj/item/assembly/rad_time/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		src.part1.set_loc(T)
		src.part2.set_loc(T)
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		user.u_equip(src)
		qdel(src)
		return
	if (!isscrewingtool(W))
		return
	src.status = !(src.status)
	if (src.status)
		user.show_message("<span class='notice'>The signaler is now secured!</span>", 1)
	else
		user.show_message("<span class='notice'>The signaler is now unsecured!</span>", 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_time/attack_self(mob/user as mob)

	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_time/receive_signal(datum/signal/signal)
	// drsingh for cannot read null.source
	if (signal && signal.source == src.part2)
		src.part1.send_signal("ACTIVATE")
	return

////////////////////////////////////////////// Remote signaller/proximity //////////////////////////////////

/obj/item/assembly/rad_prox
	name = "Signaller/Prox Sensor Assembly"
	desc = "A proximity-activated radio signaller."
	icon_state = "prox-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/prox_sensor/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER

/obj/item/assembly/rad_prox/c_state(n)
	src.icon_state = "prox-radio[n]"
	return

/obj/item/assembly/rad_prox/disposing()
	qdel(part1)
	part1 = null
	qdel(part2)
	part2 = null
	..()
	return

/obj/item/assembly/rad_prox/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/projectile))
		return
	if (AM.move_speed < 12 && src && src.part2)
		src.part2.sense()
	return

/obj/item/assembly/rad_prox/attackby(obj/item/W, mob/user)
	if (!W)
		return
	if (iswrenchingtool(W) && !(src.status))
		var/turf/T = get_turf(src)
		src.part1.set_loc(T)
		src.part2.set_loc(T)
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		user.u_equip(src)
		qdel(src)
		return
	if (!isscrewingtool(W))
		return
	src.status = !(src.status)
	if (src.status)
		user.show_message("<span class='notice'>The proximity sensor is now secured!</span>", 1)
	else
		user.show_message("<span class='notice'>The proximity sensor is now unsecured!</span>", 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_prox/attack_self(mob/user as mob)
	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_prox/receive_signal(datum/signal/signal)
	// drsingh for Cannot read null.source
	if (signal && signal.source == src.part2)
		src.part1.send_signal("ACTIVATE")
	return

/obj/item/assembly/rad_prox/Move()
	. = ..()
	src.part2.sense()
	return

/obj/item/assembly/rad_prox/dropped()
	SPAWN( 0 )
		src.part2.sense()
		return
	return


//////////////////////////////////handmade shotgun shells//////////////////////////////////

ABSTRACT_TYPE(/datum/pipeshotrecipe)
/datum/pipeshotrecipe
	var/thingsneeded = null
	var/obj/item/ammo/bullets/result = null
	var/obj/item/accepteditem = null
	var/craftname = null
	var/success = FALSE
	var/allow_subtypes = TRUE

	proc/check_match(obj/item/craftingitem)
		if(allow_subtypes)
			. = istype(craftingitem, accepteditem)
		else
			. = craftingitem.type == accepteditem

	proc/craftwith(obj/item/craftingitem, obj/item/frame, mob/user)

		if (istype(craftingitem, accepteditem))
			//the checks for if an item is actually allowed are local to the recipie, since they can vary
			var/consumed = min(src.thingsneeded, craftingitem.amount)
			thingsneeded -= consumed //ideally we'd do this later but for sake of working with zeros it's up here

			//consume material- proc handles deleting
			var/obj/item/crafting_piece = craftingitem.split_stack(consumed)
			if(crafting_piece)
				crafting_piece.set_loc(frame)
			else
				user.u_equip(craftingitem)
				craftingitem.set_loc(frame)

			if (thingsneeded > 0)//craft successful, but they'll need more
				boutput(user, "<span class='notice'>You add [consumed] items to the [frame]. You feel like you'll need [thingsneeded] more [craftname]s to fill all the shells. </span>")

			if (thingsneeded <= 0) //check completion and produce shells as needed
				var/obj/item/ammo/bullets/shot = new src.result(get_turf(frame))
				user.put_in_hand_or_drop(shot)
				qdel(frame)

			. = TRUE

/datum/pipeshotrecipe/plasglass
	thingsneeded = 2
	result = /obj/item/ammo/bullets/pipeshot/plasglass
	accepteditem = /obj/item/raw_material/shard
	craftname = "shard"
	var/matid = "plasmaglass"

	check_match(obj/item/craftingitem)
		. = ..()
		if(. && matid != craftingitem.material.mat_id)
			. = FALSE

	craftwith(obj/item/craftingitem, obj/item/frame, mob/user)
		if(matid == craftingitem.material.mat_id)
			. = ..() //call parent, have them run the typecheck

/datum/pipeshotrecipe/scrap
	thingsneeded = 1
	result = /obj/item/ammo/bullets/pipeshot/scrap/
	accepteditem = /obj/item/raw_material/scrap_metal
	craftname = "scrap chunk"

/datum/pipeshotrecipe/glass
	thingsneeded = 2
	result = /obj/item/ammo/bullets/pipeshot/glass/
	accepteditem = /obj/item/raw_material/shard
	craftname = "shard"

/obj/item/assembly/pipehulls
	name = "filled pipe hulls"
	desc = "Four open pipe shells, with propellant in them. You wonder what you could stuff into them."
	icon_state = "Pipeshotrow"
	flags = NOSPLASH
	var/static/list/datum/pipeshotrecipe/recipes_list = list()
	var/datum/pipeshotrecipe/recipe = null

	New()
		..()
		create_reagents(80)
		if(!length(recipes_list))
			for(var/recipe_type in concrete_typesof(/datum/pipeshotrecipe))
				recipes_list += new recipe_type

	attack_self(mob/user as mob)
		if (length(contents) || src.reagents.total_volume)
			if(tgui_alert(user, "Pour out the [src]?", "Empty hulls", list("Yes", "No")) != "Yes")
				return
			boutput(user, "<span class='notice'>The contents inside spill out!</span>")
			for(var/obj/item in contents)
				item.set_loc(get_turf(user))
			if(src.reagents.total_volume)
				src.reagents.reaction(get_turf(user), TOUCH, src.reagents.total_volume)
			recipe = null

	attackby(obj/item/W, mob/user)
		if (!recipe) //no recipie? assign one
			for(var/datum/pipeshotrecipe/R in recipes_list)
				if(R.check_match(W))
					recipe = new R.type()
					break
		if(recipe?.craftwith(W, src, user))
			return //don't bang objects together unless they are wrong...
		..()

