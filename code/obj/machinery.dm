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
	flags = FLUID_SUBMERGE | TGUI_INTERACTIVE
	object_flags = NO_GHOSTCRITTER
	pass_unstable = FALSE // Machines hopefully are stable.
	var/status = 0
	var/power_usage = 0
	var/power_channel = EQUIP
	var/power_credit = 0
	var/wire_powered = 0
	var/allow_stunned_dragndrop = 0
	var/tmp/processing_bucket = 1
	var/tmp/processing_tier = PROCESSING_EIGHTH
	var/tmp/current_processing_tier
	var/tmp/machine_registry_idx // List index for misc. machines registry, used in loops where machines of a specific type are needed
	var/base_tick_spacing = 6 // Machines proc every 1*(2^tier-1) seconds. Or something like that.
	var/cap_base_tick_spacing = 60
	var/tmp/last_process
	var/requires_power = TRUE // machine requires power, used in tgui_broken_state
	// New() and disposing() add and remove machines from the global "machines" list
	// This list is used to call the process() proc for all machines ~1 per second during a round

/obj/machinery/New()
	..()
	START_TRACKING

	if (!isnull(initial(machine_registry_idx))) 	// we can use initial() here to skip a lookup from this instance's vars which we know won't contain this.
		machine_registry[initial(machine_registry_idx)] += src

	var/static/machines_counter = 0
	src.processing_bucket = machines_counter++ & 31 // this is just modulo 32 but faster due to power-of-two memes
	SubscribeToProcess()
	if (current_state > GAME_STATE_WORLD_INIT)
		SPAWN(5 DECI SECONDS)
			src.power_change()
			var/area/A = get_area(src)
			if (A && src) //fixes a weird runtime wrt qdeling crushers in crusher/New()
				A.machines += src

/obj/machinery/initialize()
	..()
	src.power_change()
	var/area/A = get_area(src)
	A?.machines += src

/obj/machinery/disposing()
	STOP_TRACKING
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

/**
* Determines whether or not the user can remote access devices.
* This is typically limited to Borgs and AI things
*/
/obj/machinery/can_access_remotely(mob/user)
	if (src.status & REQ_PHYSICAL_ACCESS)
		. = ..()
	else
		. = can_access_remotely_default(user)
	/*
	 *	Prototype procs common to all /obj/machinery objects
	 */

///wrapper proc for /obj/machinery/process so that signals are always sent. Call this, but do not override it.
/obj/machinery/proc/ProcessMachine(var/mult)
	SHOULD_NOT_OVERRIDE(1)
	if(SEND_SIGNAL(src, COMSIG_MACHINERY_PROCESS, mult))
		return
	src.process(mult)

// Want a mult on your machine process? Put var/mult in its arguments and put mult wherever something could be mangled by lagg
/obj/machinery/proc/process(var/mult) //<- like that, but in your machine's process()
	PROTECTED_PROC(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	// Called for all /obj/machinery in the "machines" list, approximately once per second
	// by /datum/controller/game_controller/process() when a game round is active
	// Any regular action of the machine is executed by this proc.
	// For machines that are part of a pipe network, this routine also calculates the gas flow to/from this machine.
	if (src.power_usage)
		if (machines_may_use_wired_power)
			power_change()
			if (!(status & NOPOWER) && wire_powered)
				use_power(src.power_usage, src.power_channel)
				power_credit = power_usage
				if (zamus_dumb_power_popups)
					new /obj/maptext_junk/power(get_turf(src), change = -src.power_usage * mult, channel = src.power_channel)

				return
		if (!(status & NOPOWER))
			use_power(src.power_usage * mult, src.power_channel)
			if (zamus_dumb_power_popups)
				new /obj/maptext_junk/power(get_turf(src), change = -src.power_usage * mult, channel = src.power_channel)

/obj/machinery/proc/gib(atom/location)
	if (!location) return

	// cause machines should leave debris too
	var/obj/decal/cleanable/machine_debris/gib = null

	// RUH ROH
	elecflash(src, power = 3)

	// NORTH
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	if (prob(25))
		gib.icon_state = "gibup1"
	gib.streak_cleanable(NORTH)
	LAGCHECK(LAG_LOW)

	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	if (prob(25))
		gib.icon_state = "gibdown1"
	gib.streak_cleanable(SOUTH)
	LAGCHECK(LAG_LOW)

	// WEST
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	gib.streak_cleanable(WEST)
	LAGCHECK(LAG_LOW)

	// EAST
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	gib.streak_cleanable(EAST)
	LAGCHECK(LAG_LOW)

	// RANDOM
	gib = make_cleanable( /obj/decal/cleanable/machine_debris,location)
	gib.streak_cleanable(cardinal)

/obj/machinery/Topic(href, href_list)
	..()
	if(status & (NOPOWER|BROKEN))
		//boutput(usr, SPAN_ALERT("That machine is not powered!"))
		return 1
	if(usr.restrained() || usr.lying || usr.stat)
		//boutput(usr, SPAN_ALERT("You are unable to do that currently!"))
		return 1
	if(!hasvar(src,"portable") || !src:portable)
		if ((!in_interact_range(src, usr) || !istype(src.loc, /turf)) && !issilicon(usr) && !isAI(usr))
			if (!usr)
				message_coders("[type]/Topic(): no usr in Topic - [name] at [showCoords(x, y, z)].")
			else if ((x in list(usr.x - 1, usr.x, usr.x + 1)) && (y in list(usr.y - 1, usr.y, usr.y + 1)) && z == usr.z && isturf(loc))
				message_coders("[type]/Topic(): is in range of usr, but in_range failed - [name] at [showCoords(x, y, z) ]")
			//boutput(usr, SPAN_ALERT("You must be near the machine to do this!"))
			return 1
	else
		if ((!in_interact_range(src.loc, usr) || !istype(src.loc.loc, /turf)) && !issilicon(usr) && !isAI(usr))
			//boutput(usr, SPAN_ALERT("You must be near the machine to do this!"))
			return 1
	src.add_fingerprint(usr)
	return 0

/obj/machinery/attack_ai(mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/attack_hand(mob/user)
	. = ..()
	if(status & (NOPOWER|BROKEN))
		return 1
	if(user && (user.lying || user.stat) && !user.client?.holder?.ghost_interaction)
		return 1
	if(!in_interact_range(src, user) || !istype(src.loc, /turf))
		return 1

	if (user)
		if (ishuman(user))
			if(user.get_brain_damage() >= 60 || prob(user.get_brain_damage()))
				boutput(user, SPAN_ALERT("You are too dazed to use [src] properly."))
				return 1

		src.add_fingerprint(user)
		interact_particle(user,src)
	return 0

/obj/machinery/ui_state(mob/user)
	if(src.status & REQ_PHYSICAL_ACCESS)
		. = tgui_physical_state
	else
		. = tgui_default_state

/obj/machinery/ui_status(mob/user, datum/ui_state/state)
	if(src.status & REQ_PHYSICAL_ACCESS)
		. = min(tgui_broken_state.can_use_topic(src, user),
						tgui_physical_state.can_use_topic(src, user),
						tgui_not_incapacitated_state.can_use_topic(src, user)
		)
	else
		. = min(state.can_use_topic(src, user),
						tgui_broken_state.can_use_topic(src, user),
						tgui_not_incapacitated_state.can_use_topic(src, user)
		)

/obj/machinery/ex_act(severity)
	// Called when an object is in an explosion
	// Higher "severity" means the object was further from the centre of the explosion
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(50))
				qdel(src)
				return
		if(3)
			if (prob(25))
				qdel(src)
				return

/obj/machinery/blob_act(var/power)
	// Called when attacked by a blob
	if(prob(25 * power / 20))
		qdel(src)

/obj/machinery/was_deconstructed_to_frame(mob/user)
	. = ..()
	src.power_change()

/obj/machinery/was_built_from_frame(mob/user, newly_built)
	. = ..()
	src.power_change()

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
	if (istype(src.loc, /obj/item/electronics/frame)) //if in a frame, we are never powered
		return 0
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

	if (zamus_dumb_power_popups)
		new /obj/maptext_junk/power(get_turf(src), change = -amount, channel = chan)

	if (machines_may_use_wired_power && wire_powered)
		if (power_credit >= amount)
			power_credit -= amount
			return
		if (power_credit)
			amount -= power_credit
			power_credit = 0
		var/datum/powernet/net = get_direct_powernet()
		if (net.newload + amount <= net.avail) //a fail to wire-power will fall back to area power usage
			net.newload += amount
			return

	var/area/A = get_area(src)		// make sure it's in an area
	if(!A || !isarea(A))
		return

#ifdef MACHINE_PROCESSING_DEBUG
	if(!detailed_power_data) detailed_power_data = new
	detailed_power_data.log_machine(src, -amount)
#endif

	A.use_power(amount, chan)

///Checks the machinery's equipment channel and local power, setting the `NOPOWER` flag as needed.
///
///Called when the power settings of the containing area change.
/obj/machinery/proc/power_change()
	if(powered())
		status &= ~NOPOWER
	else
		status |= NOPOWER
	src.UpdateIcon()

/obj/machinery/emp_act()
	if(src.flags & EMP_SHORT) return
	src.flags |= EMP_SHORT

	src.use_power(7500)

	var/obj/overlay/pulse2 = new/obj/overlay ( src.loc )
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.anchored = ANCHORED
	pulse2.set_dir(pick(cardinal))

	SPAWN(1 SECOND)
		src.flags &= ~EMP_SHORT
		qdel(pulse2)
	return

///Attempt to break a machine. Returns `TRUE` if already broken.
/obj/machinery/proc/set_broken()
	if (src.is_broken())
		return TRUE
	src.status |= BROKEN
	src.power_change()

/obj/machinery/proc/is_broken()
	return (src.status & BROKEN)

/obj/machinery/proc/has_no_power()
	return (src.status & NOPOWER)

/obj/machinery/proc/is_disabled()
	return src.is_broken() || src.has_no_power()

/// Called when contents are added to the machine so it can do any special things it needs to
/obj/machinery/proc/on_add_contents(obj/item/I)
	return

/// Called when machines are overloaded with power.
///
/// Returns TRUE if it did something, or FALSE if it did not.
/obj/machinery/proc/overload_act()
	return FALSE

/obj/machinery/sec_lock
	name = "Security Pad"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "sec_lock"
	var/obj/item/card/id/scan = null
	var/a_type = 0
	var/obj/machinery/door/d1 = null
	var/obj/machinery/door/d2 = null
	anchored = ANCHORED
	req_access = list(access_armory)

/obj/machinery/noise_switch
	name = "Speaker Toggle"
	desc = "Makes things make noise."
	icon = 'icons/obj/noise_makers.dmi'
	icon_state = "switch"
	anchored = ANCHORED
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
	anchored = ANCHORED
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
	anchored = ANCHORED
	density = 1

	var/list/signals = list()
	var/list/transmitters = list()

/obj/machinery/bug_reporter
	name = "bug reporter"
	desc = "Creates bug reports."
	icon = 'icons/obj/objects.dmi'
	icon_state = "moduler-on"
	density = TRUE
	anchored = ANCHORED

/obj/machinery/set_loc(atom/target)
	var/area/A1 = get_area(src)
	. = ..()
	var/area/A2 = get_area(src)
	if(A1 != A2)
		if(A1) A1.machines -= src
		if(A2) A2.machines += src
		// call power_change on machine so it can check if the new area is powered and update it's status flag appropriately
		src.power_change()

/obj/machinery/Move(atom/target)
	var/area/A1 = get_area(src)
	. = ..()
	var/area/A2 = get_area(src)
	if(A1 && A2 && A1 != A2)
		A1.machines -= src
		A2.machines += src
		src.power_change()

/// check if a mob is allowed to eject occupants from various machines
/obj/machinery/proc/can_eject_occupant(mob/user)
	return !(isintangible(user) || isghostcritter(user) || isghostdrone(user) || !can_act(user))

/datum/action/bar/icon/rotate_machinery
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/tools/crowbar.dmi'
	icon_state = "crowbar"
	var/obj/machinery/machine = null

	New(Target)
		src.machine = Target
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, src.machine) > 0 || src.machine == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!src.machine.anchored)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, src.machine) > 0 || src.machine == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		src.machine.visible_message(SPAN_ALERT("<b>[owner]</b> begins to rotate [src.machine]"))

	onEnd()
		..()
		src.machine.set_dir(turn(src.machine.dir, -90))

