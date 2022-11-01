// conveyor belt

// moves items/mobs/movables in set direction every ptick
#define OP_REGULAR 1
#define OP_OFF 0
#define OP_REVERSE -1

/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
#ifndef IN_MAP_EDITOR
	icon_state = "conveyor0"
#else
	icon_state = "conveyor0-map"
#endif
	name = "conveyor belt"
	desc = "A conveyor belt."
	anchored = 1
	power_usage = 100
	layer = 2
	machine_registry_idx = MACHINES_CONVEYORS
	var/operating = OP_OFF	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = TRUE	// true if can operate (no broken segments in this belt run)
	var/dir1 = NORTH
	var/dir2 = SOUTH
	var/currentdir = SOUTH

	var/id = ""			// the control ID	- must match controller ID
	// following two only used if a diverter is present
	var/divert = 0 		// if non-zero, direction to divert items
	var/divdir = 0		// if diverting, will be conveyer dir needed to divert (otherwise dense)
	var/move_lag = 4	// The lag at which the movement happens. Lower = faster
	var/obj/machinery/conveyor/next_conveyor = null
	event_handler_flags = USE_FLUID_ENTER
	/// list of conveyor_switches that have us in their conveyors list
	var/list/linked_switches

// for all your mapping needs!
/obj/machinery/conveyor/NE
	dir1 = NORTH
	dir2 = EAST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-NE-map"
#endif
/obj/machinery/conveyor/NS
	dir1 = NORTH
	dir2 = SOUTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-NS-map"
#endif
/obj/machinery/conveyor/NW
	dir1 = NORTH
	dir2 = WEST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-NW-map"
#endif
/obj/machinery/conveyor/ES
	dir1 = EAST
	dir2 = SOUTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-ES-map"
#endif
/obj/machinery/conveyor/EW
	dir1 = EAST
	dir2 = WEST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-EW-map"
#endif
/obj/machinery/conveyor/EN
	dir1 = EAST
	dir2 = NORTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-EN-map"
#endif
/obj/machinery/conveyor/SW
	dir1 = SOUTH
	dir2 = WEST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-SW-map"
#endif
/obj/machinery/conveyor/SN
	dir1 = SOUTH
	dir2 = NORTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-SN-map"
#endif
/obj/machinery/conveyor/SE
	dir1 = SOUTH
	dir2 = EAST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-SE-map"
#endif
/obj/machinery/conveyor/WN
	dir1 = WEST
	dir2 = NORTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-WN-map"
#endif
/obj/machinery/conveyor/WE
	dir1 = WEST
	dir2 = EAST
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-WE-map"
#endif
/obj/machinery/conveyor/WS
	dir1 = WEST
	dir2 = SOUTH
#ifdef IN_MAP_EDITOR
	icon_state = "conveyor-WS-map"
#endif

/obj/machinery/conveyor/NE/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/NS/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/NW/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/ES/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/EW/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/EN/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/SW/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/SN/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/SE/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/WN/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/WE/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1
/obj/machinery/conveyor/WS/carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1

/obj/machinery/conveyor/New()
	src.flags |= UNCRUSHABLE
	..()
	currentdir = dir2
	setdir()

/obj/machinery/conveyor/initialize()
	..()
	setdir()

/obj/machinery/conveyor/process()
	if(status & NOPOWER || !operating)
		return
	use_power(power_usage)

/obj/machinery/conveyor/disposing()
	for(var/obj/machinery/conveyor/C in range(1,src))
		if (C.next_conveyor == src)
			C.next_conveyor = null
	next_conveyor = null

	for (var/obj/machinery/conveyor_switch/S as anything in linked_switches) //conveyor switch could've been exploded
		S.conveyors -= src
	id = null
	..()

/// set the dir and target turf depending on the operating direction
/obj/machinery/conveyor/proc/setdir()
	currentdir = dir1
	if (operating == OP_REGULAR)
		currentdir = dir2
	else if(operating == OP_REVERSE)
		currentdir = dir1

	next_conveyor = locate(/obj/machinery/conveyor) in get_step(src, currentdir)
	update()


/// update the icon depending on the operating condition
/obj/machinery/conveyor/proc/update()
	if(status & BROKEN)
		icon_state = "conveyor-b"
		operating = OP_OFF

	if(!operable)
		operating = OP_OFF
	if(!operating || (status & NOPOWER))
		for(var/atom/movable/A in loc.contents)
			walk(A, 0)
	else
		for(var/atom/movable/A in loc.contents)
			move_thing(A)

	var/new_icon = "conveyor-"

	var/dir1char = "N"
	switch (dir1)
		if (NORTH)
			dir1char = "N"
		if (EAST)
			dir1char = "E"
		if (SOUTH)
			dir1char = "S"
		if (WEST)
			dir1char = "W"

	var/dir2char = "N"
	switch (dir2)
		if (NORTH)
			dir2char = "N"
		if (EAST)
			dir2char = "E"
		if (SOUTH)
			dir2char = "S"
		if (WEST)
			dir2char = "W"


	if (operating == OP_OFF || operating == OP_REGULAR)
		new_icon += dir1char + dir2char
	else if (operating == OP_REVERSE)
		new_icon += dir2char + dir1char

	if (operating == OP_OFF || (status & NOPOWER))
		new_icon += "-still"
	else
		new_icon += "-run"

	if (dir1 == dir2)
		new_icon = "conveyor-fuck"

	icon_state = new_icon


/obj/machinery/conveyor/proc/move_thing(var/atom/movable/A)
	if (A.anchored || A.temp_flags & BEING_CRUSHERED)
		return
	if(istype(A, /obj/machinery/bot) && A:on)	//They drive against the motion of the conveyor, ok.
		return
	if(istype(A, /obj/critter) && A:flying)		//They are flying above it, ok.
		return
	if(HAS_ATOM_PROPERTY(A, PROP_ATOM_FLOATING)) // Don't put new checks here, apply this atom prop instead.
		return
	var/movedir = currentdir	// base movement dir
	if(divert && currentdir == divdir)	// update if diverter present
		movedir = divert

	var/mob/M = A
	if(istype(M) && M.buckled == src)
		M.glide_size = (32 / move_lag) * world.tick_lag
		walk(M, dir, move_lag, (32 / move_lag) * world.tick_lag)
		M.glide_size = (32 / move_lag) * world.tick_lag

		if (src.move_lag <= 1)
			if (prob( (1-src.move_lag) * 1.2) )
				var/turf/T = get_edge_target_turf(src, src.dir)
				M.throw_at(T,rand(0,5),rand(1,3))

	else
		A.glide_size = (32 / move_lag) * world.tick_lag
		walk(A, movedir, move_lag, (32 / move_lag) * world.tick_lag)
		A.glide_size = (32 / move_lag) * world.tick_lag

/obj/machinery/conveyor/Crossed(atom/movable/AM)
	..()
	if(status & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	if(!loc)
		return
	move_thing(AM)

/obj/machinery/conveyor/Uncrossed(var/atom/movable/AM)
	..()
	if(status & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	if(!loc)
		return

	if(src.next_conveyor && src.next_conveyor.loc == AM.loc)
		//Ok, they will soon walk() according to the new conveyor
		var/mob/M = AM
		if(istype(M) && M.buckled == src) //Transfer the buckle
			M.buckled = next_conveyor
		if(!next_conveyor.operating || next_conveyor.status & NOPOWER)
			walk(AM, 0)
			return

	else
		//Stop walking, we left the belt
		var/mob/M = AM
		if(istype(M) && M.buckled == src) //Unbuckle
			M.buckled = null
			new /obj/item/cable_coil/cut(M.loc)
		walk(AM, 0)


/obj/machinery/conveyor/attackby(var/obj/item/I, mob/user)
	if (istype(I, /obj/item/grab))	// special handling if grabbing a mob
		var/obj/item/grab/G = I
		G.affecting.Move(src.loc)
		qdel(G)
		return
	else if (istype(I, /obj/item/cable_coil))	// if cable, see if a mob is present
		var/mob/M = locate() in src.loc
		if(M)
			if (M == user)
				src.visible_message("<span class='notice'>[M] ties [himself_or_herself(M)] to the conveyor.</span>")
				// note don't check for lying if self-tying
			else
				if(M.lying)
					user.visible_message("<span class='notice'>[M] has been tied to the conveyor by [user].</span>", "<span class='notice'>You tie [M] to the converyor!</span>")
				else
					boutput(user, "<span class='hint'>[M] must be lying down to be tied to the converyor!</span>")
					return

			M.buckled = src //behold the most mobile of stools
			src.add_fingerprint(user)
			I:use(1)
			M.lying = 1
			M.set_clothing_icon_dirty()
			return

			// else if no mob in loc, then allow coil to be placed

	else if (issnippingtool(I))
		var/mob/M = locate() in src.loc
		if(M && M.buckled == src)
			M.buckled = null
			src.add_fingerprint(user)
			if (M == user)
				src.visible_message("<span class='notice'>[M] cuts [himself_or_herself(M)] free from the conveyor.</span>")
			else
				src.visible_message("<span class='notice'>[M] had been cut free from the conveyor by [user].</span>")
			return

// attack with hand, move pulled object onto conveyor

/obj/machinery/conveyor/attack_hand(mob/user)
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && BOUNDS_DIST(user, user.pulling) > 0))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		M.remove_pulling()
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.remove_pulling()
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.remove_pulling()
	return


// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/machinery/conveyor/proc/broken()
	status |= BROKEN
	update()

	var/obj/machinery/conveyor/C
	C = locate() in get_step(src, dir1)
	C?.set_operable(OP_REGULAR, id, 0)

	C = locate() in get_step(src, dir2)
	C?.set_operable(OP_REVERSE, id, 0)


/// set the operable var if ID matches, propagating in the given direction
/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)
	if(id != match_id)
		return
	operable = op

	update()
	var/propdir = dir1
	if (stepdir == OP_REGULAR)
		propdir = dir1
	else if(stepdir == OP_REVERSE)
		propdir = dir2
	var/obj/machinery/conveyor/C = locate() in get_step(src, propdir)
	C?.set_operable(stepdir, id, op)

/obj/machinery/conveyor/power_change()
	..()
	update()

/obj/item/debug_conveyor_layer
	name = "conveyor layer"
	icon = 'icons/obj/recycling.dmi'
	icon_state = "debug"
	var/on = FALSE
	var/list/obj/machinery/conveyor/conveyors
	var/list/obj/machinery/conveyor_switch/switches
	var/conv_id

	attack_self(mob/user)
		if (!on)
			switch_on(user)
		else
			switch_off(user)

	proc/switch_on(var/mob/user, var/use_id = null)
		on = TRUE
		icon_state = "debug-on"
		conveyors = list()
		switches = list()
		conv_id = "[world.time]"
		user.AddComponent(/datum/component/conveyorplacer, conveyors, conv_id)

	proc/switch_off(var/mob/user)
		on = FALSE
		icon_state = "debug"
		var/datum/component/conveyorplacer/CP = user.GetComponent(/datum/component/conveyorplacer)
		CP.RemoveComponent()
		for (var/obj/machinery/conveyor/C in src.conveyors)
			C.linked_switches = src.switches
		for (var/obj/machinery/conveyor_switch/S in src.switches)
			S.conveyors = src.conveyors

	afterattack(atom/target, mob/user, reach, params)
		if (on && isturf(target))
			var/obj/machinery/conveyor_switch/sw = new /obj/machinery/conveyor_switch(target)
			sw.id = conv_id
			src.switches |= sw

	dropped(mob/user)
		. = ..()
		switch_off(user)

	disposing()
		. = ..()
		if (on && ismob(src.loc))
			switch_off(src.loc)

// conveyor diverter
// extendable arm that can be switched so items on the conveyer are diverted sideways
// situate in same turf as conveyor
// only works if belts is running proper direction
/obj/machinery/diverter
	icon = 'icons/obj/recycling.dmi'
	icon_state = "diverter0"
	name = "diverter"
	desc = "A diverter arm for a conveyor belt."
	anchored = 1
	layer = FLY_LAYER
	event_handler_flags = USE_FLUID_ENTER
	var/obj/machinery/conveyor/conv // the conveyor this diverter works on
	var/deployed = 0	// true if diverter arm is extended
	var/operating = 0	// true if arm is extending/contracting
	var/divert_to	// the dir that diverted items will be moved
	var/divert_from // the dir items must be moving to divert


// create a diverter
// set up divert_to and divert_from directions depending on dir state
/obj/machinery/diverter/New()
	..()
	switch(dir)
		if(NORTH)
			divert_to = WEST			// stuff will be moved to the west
			divert_from = NORTH			// if entering from the north
		if(SOUTH)
			divert_to = EAST
			divert_from = NORTH
		if(EAST)
			divert_to = EAST
			divert_from = SOUTH
		if(WEST)
			divert_to = WEST
			divert_from = SOUTH
		if(NORTHEAST)
			divert_to = NORTH
			divert_from = EAST
		if(NORTHWEST)
			divert_to = NORTH
			divert_from = WEST
		if(SOUTHEAST)
			divert_to = SOUTH
			divert_from = EAST
		if(SOUTHWEST)
			divert_to = SOUTH
			divert_from = WEST
	SPAWN(0.2 SECONDS)
		// wait for map load then find the conveyor in this turf
		conv = locate() in src.loc
		if(conv)	// divert_from dir must match possible conveyor movement
			if(conv.dir1 != divert_from && conv.dir2 != turn(divert_from,180) )
				qdel(src)	// if no dir match, then delete self
		set_divert()
		update()

// update the icon state depending on whether the diverter is extended
/obj/machinery/diverter/proc/update()
	icon_state = "diverter[deployed]"

// call to set the diversion vars of underlying conveyor
/obj/machinery/diverter/proc/set_divert()
	if(conv)
		if(deployed)
			conv.divert = divert_to
			conv.divdir = divert_from
		else
			conv.divert= 0


// *** TESTING click to toggle
/obj/machinery/diverter/Click()
	toggle()


// toggle between arm deployed and not deployed, showing animation
//
/obj/machinery/diverter/proc/toggle()
	if( status & (NOPOWER|BROKEN))
		return

	if(operating)
		return

	use_power(50)
	operating = 1
	if(deployed)
		flick("diverter10",src)
		icon_state = "diverter0"
		sleep(1 SECOND)
		deployed = 0
	else
		flick("diverter01",src)
		icon_state = "diverter1"
		sleep(1 SECOND)
		deployed = 1
	operating = 0
	update()
	set_divert()

// don't allow movement into the 'backwards' direction if deployed
/obj/machinery/diverter/Cross(atom/movable/O)
	var/direct = get_dir(O, src)
	if(direct == divert_to)	// prevent movement through body of diverter
		return 0
	if(!deployed)
		return 1
	return(direct != turn(divert_from,180))

// don't allow movement through the arm if deployed
/obj/machinery/diverter/Uncross(atom/movable/O, do_bump=TRUE)
	var/direct = get_dir(O, O.movement_newloc)
	if(direct == turn(divert_to,180))	// prevent movement through body of diverter
		. = 0
	else if(!deployed)
		. = 1
	else
		. = direct != divert_from
	UNCROSS_BUMP_CHECK(O)





/// the conveyor control switch
/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	/// current direction setting
	var/position = CONVEYOR_STOPPED
	/// last direction setting
	var/last_pos = CONVEYOR_REVERSE
	// Checked against conveyor ID on link attempt
	var/id = ""
	/// the list of converyors that are controlled by this switch
	var/list/conveyors
	anchored = 1
	/// time last used
	var/last_used = 0

	New()
		. = ..()
		UnsubscribeProcess()
		START_TRACKING
		UpdateIcon()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"trigger", .proc/trigger)
		conveyors = list()
		SPAWN(0.5 SECONDS)
			link_conveyors()
			for (var/obj/machinery/conveyor/C as anything in conveyors)
				if (C.id == src.id)
					C.operating = position
					C.setdir()

	disposing()
		STOP_TRACKING
		for (var/obj/machinery/conveyor/C as anything in conveyors)
			C.linked_switches -= src
		conveyors = null
		. = ..()

	proc/link_conveyors()
		for (var/obj/machinery/conveyor/C as anything in machine_registry[MACHINES_CONVEYORS])
			if (C.id == src.id)
				conveyors |= C
				if (!C.linked_switches)
					C.linked_switches = list()
				C.linked_switches |= src

	proc/trigger(var/inp)
		attack_hand(usr) //bit of a hack but hey.
		return

	/// update the icon depending on the position
	update_icon()
		if(position == CONVEYOR_REVERSE)
			icon_state = "switch-rev"
		else if(position == CONVEYOR_FORWARD)
			icon_state = "switch-fwd"
		else
			icon_state = "switch-off"

	// attack with hand, switch position
	attack_hand(mob/user)
		if (TIME < (last_used + 0.5 SECONDS))
			return
		last_used = TIME
		if(position == CONVEYOR_STOPPED)
			if (last_pos == CONVEYOR_REVERSE)
				position = CONVEYOR_FORWARD
				last_pos = CONVEYOR_STOPPED
			else
				position = CONVEYOR_REVERSE
				last_pos = CONVEYOR_STOPPED
			logTheThing(LOG_STATION, user, "turns the conveyor switch on in [last_pos == CONVEYOR_REVERSE ? "forward" : "reverse"] mode at [log_loc(src)].")
		else
			last_pos = position
			position = CONVEYOR_STOPPED
			logTheThing(LOG_STATION, user, "turns the conveyor switch off at [log_loc(src)].")
		UpdateIcon()

		// find any switches with same id as this one, and set their positions to match us
		for_by_tcl(S, /obj/machinery/conveyor_switch)
			if (S == src) continue
			if(S.id == src.id)
				S.position = position
				S.UpdateIcon()
			LAGCHECK(LAG_MED)

		for (var/obj/machinery/conveyor/C as anything in conveyors)
			if (C.id == src.id)
				C.operating = position
				C.setdir()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"switchTriggered")

//silly proc for corners that can be flippies
/obj/machinery/conveyor/proc/rotateme()
	.= 0

/obj/machinery/carouselpower
	var/maxdrain = 23 MEGA WATTS
	var/bonusdrain = 100 MEGA WATTS

	var/speedup = 0
	var/speedup_max = 3.5
	var/speedup_bonus = 1
	icon = 'icons/obj/fluid.dmi'
	icon_state = "battery-0"
	name = "carousel power unit"
	desc = "All power dumped into this power unit will boost the speed of the station's cargo carousel."
	density = 1
	anchored = 1
	event_handler_flags =  USE_FLUID_ENTER

	var/icon_base = "battery-"
	var/icon_levels = 6 //there are 7 icons of power levels (6 + 1 for unpowered)
	var/obj/cable/attached

	var/search_interval = 1 MINUTES
	var/last_search = 0

	New()
		..()
		attached = locate() in get_turf(src)

	set_loc()
		..()
		attached = locate() in get_turf(src)

	process()
		..()
		var/last_speedup = speedup
		speedup = 0

		if( attached && !(status & (BROKEN | NOPOWER)) )
			var/datum/powernet/PN = attached.get_powernet()
			if(PN)
				var/power_to_use = 0

				power_to_use = min ( maxdrain, PN.avail )
				speedup = (power_to_use/maxdrain) * speedup_max

				if (PN.avail > maxdrain)
					power_to_use = min ( maxdrain+bonusdrain, PN.avail )
					speedup += (power_to_use / bonusdrain ) * speedup_bonus

				PN.newload += power_to_use
				//use_power(power_to_use)

		if (!attached)
			if (world.time + search_interval > last_search)
				last_search = world.time
				attached = locate() in get_turf(src)

		if (speedup != last_speedup)
			update_belts()
			UpdateIcon()

	proc/update_belts()
		for_by_tcl(S, /obj/machinery/conveyor_switch)
			if(S.id == "carousel")
				for(var/obj/machinery/conveyor/C in S.conveyors)
					C.move_lag = max(initial(C.move_lag) - speedup, 0.1)
				break

	update_icon()
		var/ico = clamp(((speedup / speedup_max) * icon_levels), 0, 6)
		icon_state = "[icon_base][round(ico)]"
