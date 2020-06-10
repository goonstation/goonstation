/*
 *	The base machinery object
 *
 *	Machines have a process() proc called approximately once per second while a game round is in progress
 *  Thus they can perform repetative tasks, such as calculating pipe gas flow, power usage, etc.
 *
 *
 */


/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	flags = FPRINT | FLUID_SUBMERGE

	var/status = 0
	var/power_usage = 0
	var/power_channel = EQUIP
	var/power_credit = 0
	var/wire_powered = 0
	var/allow_stunned_dragndrop = 0
	var/processing_bucket = 1
	var/processing_tier = PROCESSING_EIGHTH
	var/current_processing_tier
	var/machine_registry_idx // List index for misc. machines registry, used in loops where machines of a specific type are needed

	// New() and disposing() add and remove machines from the global "machines" list
	// This list is used to call the process() proc for all machines ~1 per second during a round

/obj/machinery/New()
	..()

	if (!isnull(initial(machine_registry_idx))) 	// we can use initial() here to skip a lookup from this instance's vars which we know won't contain this.
		machine_registry[initial(machine_registry_idx)] += src

	var/static/machines_counter = 0
	src.processing_bucket = machines_counter++ & 31 // this is just modulo 32 but faster due to power-of-two memes
	SubscribeToProcess()
	if (current_state > GAME_STATE_WORLD_INIT)
		SPAWN_DBG(5 DECI SECONDS)
			src.power_change()
			var/area/A = get_area(src)
			if (A && src) //fixes a weird runtime wrt qdeling crushers in crusher/New()
				A.machines += src

/obj/machinery/initialize()
	..()
	src.power_change()
	var/area/A = get_area(src)
	A.machines += src

/obj/machinery/disposing()
	if (!isnull(initial(machine_registry_idx)))
		machine_registry[initial(machine_registry_idx)] -= src
	UnsubscribeProcess()

	var/area/A = get_area(src)
	if(A) A.machines -= src
	..()

/obj/machinery/proc/SubscribeToProcess()
	START_PROCESSING(src, src.processing_tier)

/obj/machinery/proc/UnsubscribeProcess()
	STOP_PROCESSING(src)


	/*
	 *	Prototype procs common to all /obj/machinery objects
	 */

/obj/machinery/proc/process()
	// Called for all /obj/machinery in the "machines" list, approximately once per second
	// by /datum/controller/game_controller/process() when a game round is active
	// Any regular action of the machine is executed by this proc.
	// For machines that are part of a pipe network, this routine also calculates the gas flow to/from this machine.
	if (machines_may_use_wired_power && power_usage)
		power_change()
		if (!(status & NOPOWER) && wire_powered)
			use_power(power_usage, power_channel)
			power_credit = power_usage

/obj/machinery/proc/gib(atom/location)
	if (!location) return

	// cause machines should leave debris too
	var/obj/decal/cleanable/machine_debris/gib = null

	// RUH ROH
	var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
	s.set_up(2, 1, location)
	s.start()

	// NORTH
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	if (prob(25))
		gib.icon_state = "gibup1"
	gib.streak(list(NORTH, NORTHEAST, NORTHWEST))
	LAGCHECK(LAG_LOW)

	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	if (prob(25))
		gib.icon_state = "gibdown1"
	gib.streak(list(SOUTH, SOUTHEAST, SOUTHWEST))
	LAGCHECK(LAG_LOW)

	// WEST
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	gib.streak(list(WEST, NORTHWEST, SOUTHWEST))
	LAGCHECK(LAG_LOW)

	// EAST
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	gib.streak(list(EAST, NORTHEAST, SOUTHEAST))
	LAGCHECK(LAG_LOW)

	// RANDOM
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	gib.streak(alldirs)

/obj/machinery/Topic(href, href_list)
	..()
	if(status & (NOPOWER|BROKEN))
		//boutput(usr, "<span class='alert'>That machine is not powered!</span>")
		return 1
	if(usr.restrained() || usr.lying || usr.stat)
		//boutput(usr, "<span class='alert'>You are unable to do that currently!</span>")
		return 1
	if(!hasvar(src,"portable") || !src:portable)
		if ((!in_range(src, usr) || !istype(src.loc, /turf)) && !issilicon(usr) && !isAI(usr))
			if (!usr)
				message_coders("[type]/Topic(): no usr in Topic - [name] at [showCoords(x, y, z)].")
			else if ((x in list(usr.x - 1, usr.x, usr.x + 1)) && (y in list(usr.y - 1, usr.y, usr.y + 1)) && z == usr.z && isturf(loc))
				message_coders("[type]/Topic(): is in range of usr, but in_range failed - [name] at [showCoords(x, y, z) ]")
			//boutput(usr, "<span class='alert'>You must be near the machine to do this!</span>")
			return 1
	else
		if ((!in_range(src.loc, usr) || !istype(src.loc.loc, /turf)) && !issilicon(usr) && !isAI(usr))
			//boutput(usr, "<span class='alert'>You must be near the machine to do this!</span>")
			return 1
	src.add_fingerprint(usr)
	return 0

/obj/machinery/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/attack_hand(mob/user as mob)
	if(status & (NOPOWER|BROKEN))
		return 1
	if(user && (user.lying || user.stat))
		return 1
	if (user && (get_dist(src, user) > 1 || !istype(src.loc, /turf)) && !issilicon(user) && !isAI(usr))
		return 1
	if (user && ishuman(user))
		if(user.get_brain_damage() >= 60 || prob(user.get_brain_damage()))
			boutput(user, "<span class='alert'>You are too dazed to use [src] properly.</span>")
			return 1

	if (user)
		src.add_fingerprint(user)
		interact_particle(user,src)

	return 0

/obj/machinery/ex_act(severity)
	// Called when an object is in an explosion
	// Higher "severity" means the object was further from the centre of the explosion
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				qdel(src)
				return
		else
	return

/obj/machinery/blob_act(var/power)
	// Called when attacked by a blob
	if(prob(25 * power / 20))
		qdel(src)

/obj/machinery/proc/get_power_wire()
	var/obj/cable/C = null
	for (var/obj/cable/candidate in get_turf(src))
		if (!candidate.d1)
			C = candidate
			break
	return C

/obj/machinery/proc/get_direct_powernet()
	var/obj/cable/C = get_power_wire()
	if (C)
		return C.get_powernet()
	return null

/obj/machinery/proc/powered(var/chan = EQUIP)
	// returns true if the area has power on given channel (or doesn't require power).
	// defaults to equipment channel
	if (machines_may_use_wired_power && power_usage)
		var/datum/powernet/net = get_direct_powernet()
		if (net)
			if (net.avail - net.newload > power_usage)
				wire_powered = 1
				return 1
		else
			power_credit = 0
			wire_powered = 0

	var/area/A = get_area(src)		// make sure it's in an area
	if(!A || !isarea(A))
		return 0					// if not, then not powered
	if (machines_may_use_wired_power && power_usage && !A.requires_power)
		return 0
	return A.powered(chan)	// return power status of the area

/obj/machinery/proc/use_power(var/amount, var/chan=EQUIP) // defaults to Equipment channel
	// increment the power usage stats for an area
	if (!src.loc)
		return

	if (machines_may_use_wired_power && wire_powered)
		if (power_credit >= amount)
			power_credit -= amount
			return
		if (power_credit)
			amount -= power_credit
			power_credit = 0
		var/datum/powernet/net = get_direct_powernet()
		if (net)
			// todo: disallow exceeding network power capacity
			net.newload += amount
			return

	var/area/A = get_area(src)		// make sure it's in an area
	if(!A || !isarea(A))
		return

	A.use_power(amount, chan)


/obj/machinery/proc/power_change()		// called whenever the power settings of the containing area change
										// by default, check equipment channel & set flag
										// can override if needed
	if(powered())
		status &= ~NOPOWER
	else

		status |= NOPOWER
	return

/obj/machinery/emp_act()
	src.use_power(7500)

	var/obj/overlay/pulse2 = new/obj/overlay ( src.loc )
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.anchored = 1
	pulse2.dir = pick(cardinal)

	SPAWN_DBG(1 SECOND)
		qdel(pulse2)
	return

/obj/machinery/sec_lock
	name = "Security Pad"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "sec_lock"
	var/obj/item/card/id/scan = null
	var/a_type = 0.0
	var/obj/machinery/door/d1 = null
	var/obj/machinery/door/d2 = null
	anchored = 1.0
	req_access = list(access_armory)

/obj/machinery/driver_button
	name = "Mass Driver Button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a Mass Driver."
	var/id = null
	var/active = 0
	anchored = 1.0

/obj/machinery/ignition_switch
	name = "Ignition Switch"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	var/id = null
	var/active = 0
	anchored = 1.0

/obj/machinery/noise_switch
	name = "Speaker Toggle"
	desc = "Makes things make noise."
	icon = 'icons/obj/noise_makers.dmi'
	icon_state = "switch"
	anchored = 1
	density = 0
	var/ID = 0
	var/noise = 0
	var/broken = 0
	var/sound = 0
	var/rep = 0

/obj/machinery/noise_maker
	name = "Alert Horn"
	desc = "Makes noise when something really bad is happening."
	icon = 'icons/obj/noise_makers.dmi'
	icon_state = "nm n +o"
	anchored = 1
	density = 0
	machine_registry_idx = MACHINES_MISC
	var/ID = 0
	var/sound = 0
	var/broken = 0
	var/containment_fail = 0
	var/last_shot = 0
	var/fire_delay = 4

/obj/machinery/wire
	name = "wire"
	icon = 'icons/obj/power_cond.dmi'

/obj/machinery/transmitter
	name = "transmitter"
	desc = "a big radio transmitter"
	icon = null
	icon_state = null
	anchored = 1
	density = 1

	var/list/signals = list()
	var/list/transmitters = list()

/obj/machinery/set_loc(atom/target)
	var/area/A1 = get_area(src)
	. = ..()
	var/area/A2 = get_area(src)
	if(A1 != A2)
		if(A1) A1.machines -= src
		if(A2) A2.machines += src

/obj/machinery/Move(atom/target)
	var/area/A1 = get_area(src)
	. = ..()
	var/area/A2 = get_area(src)
	if(A1 != A2)
		A1.machines -= src
		A2.machines += src
