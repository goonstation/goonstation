// converyor belt

// moves items/mobs/movables in set direction every ptick


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
	layer = 2.5
	machine_registry_idx = MACHINES_CONVEYORS
	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
	var/basedir			// this is the default (forward) direction, set by the map dir
						// note dir var can vary when the direction changes

	var/id = ""			// the control ID	- must match controller ID
	// following two only used if a diverter is present
	var/divert = 0 		// if non-zero, direction to divert items
	var/divdir = 0		// if diverting, will be conveyer dir needed to divert (otherwise dense)
	var/move_lag = 4	// The lag at which the movement happens. Lower = faster
	var/obj/machinery/conveyor/next_conveyor = null
	var/obj/machinery/conveyor_switch/owner = null
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER


/obj/machinery/conveyor/north
	dir = NORTH
/obj/machinery/conveyor/south
	dir = SOUTH
/obj/machinery/conveyor/east
	dir = EAST
/obj/machinery/conveyor/west
	dir = WEST

	// create a conveyor

/obj/machinery/conveyor/New()
	..()
	basedir = dir
	setdir()

/obj/machinery/conveyor/disposing()
	for(var/obj/machinery/conveyor/C in range(1,src))
		if (C.next_conveyor == src)
			C.next_conveyor = null
	next_conveyor = null

	if (owner) //conveyor switch could've been exploded
		owner.conveyors -= src
	..()

	// set the dir and target turf depending on the operating direction

/obj/machinery/conveyor/proc/setdir()
	if(operating == -1)
		dir = turn(basedir,180)
	else
		dir = basedir
	next_conveyor = locate(/obj/machinery/conveyor) in get_step(src,dir)
	update()


	// update the icon depending on the operating condition

/obj/machinery/conveyor/proc/update()
	if(status & BROKEN)
		icon_state = "conveyor-b"
		operating = 0

	if(!operable)
		operating = 0
	if(!operating)
		for(var/atom/A in loc.contents)
			walk(A, 0)

	icon_state = "conveyor[(operating != 0) && !(status & NOPOWER)]"


	// machine process
	// move items to the target location
/obj/machinery/conveyor/process()
	if(status & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	if(!loc)
		return

	..()

	for(var/atom/A in loc.contents)
		move_thing(A)

/obj/machinery/conveyor/proc/move_thing(var/atom/movable/A)
	if (A.anchored)
		return
	if(isobserver(A))
		return
	if(istype(A, /obj/machinery/bot) && A:on)	//They drive against the motion of the conveyor, ok.
		return
	if(istype(A, /obj/critter) && A:flying)		//They are flying above it, ok.
		return
	var/movedir = dir	// base movement dir
	if(divert && dir==divdir)	// update if diverter present
		movedir = divert

	/* if (A.l_move_time == world.timeofday)
		continue // already moved by another conveyor
		*/
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

/obj/machinery/conveyor/HasEntered(var/atom/movable/AM, atom/oldloc)
	..()
	if(status & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	if(!loc)
		return
	//DEBUG_MESSAGE("[AM] entered conveyor at [showCoords(src.x, src.y, src.z)] and is being moved.")
	move_thing(AM)

/obj/machinery/conveyor/HasExited(var/atom/movable/AM, var/atom/newloc)
	..()
	if(status & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	if(!loc)
		return

	if(next_conveyor && next_conveyor.loc == newloc)
		//Ok, they will soon walk() according to the new conveyor
		//DEBUG_MESSAGE("[AM] exited conveyor at [showCoords(src.x, src.y, src.z)] onto another conveyor! Wow!.")
		var/mob/M = AM
		if(istype(M) && M.buckled == src) //Transfer the buckle
			M.buckled = next_conveyor
		if(!next_conveyor.operating)
			walk(AM, 0)
			return

	else
		//Stop walking, we left the belt
		//DEBUG_MESSAGE("[AM] exited conveyor at [showCoords(src.x, src.y, src.z)] onto the cold, hard floor.")
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
				src.visible_message("<span class='notice'>[M] ties \himself to the conveyor.</span>")
				// note don't check for lying if self-tying
			else
				if(M.lying)
					user.visible_message("<span class='notice'>[M] has been tied to the conveyor by [user].</span>", "<span class='notice'>You tie [M] to the converyor!</span>")
				else
					boutput(user, "<span class='hint'>[M] must be lying down to be tied to the converyor!</span>")
					return

			M.buckled = src.loc
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
				src.visible_message("<span class='notice'>[M] cuts \himself free from the conveyor.</span>")
			else
				src.visible_message("<span class='notice'>[M] had been cut free from the conveyor by [user].</span>")
			return

// attack with hand, move pulled object onto conveyor

/obj/machinery/conveyor/attack_hand(mob/user as mob)
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.pulling = null
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.pulling = null
	return


// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/machinery/conveyor/proc/broken()
	status |= BROKEN
	update()

	var/obj/machinery/conveyor/C = locate() in get_step(src, basedir)
	if(C)
		C.set_operable(basedir, id, 0)

	C = locate() in get_step(src, turn(basedir,180))
	if(C)
		C.set_operable(turn(basedir,180), id, 0)


//set the operable var if ID matches, propagating in the given direction

/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)

	if(id != match_id)
		return
	operable = op

	update()
	var/obj/machinery/conveyor/C = locate() in get_step(src, stepdir)
	if(C)
		C.set_operable(stepdir, id, op)

/obj/machinery/conveyor/power_change()
	..()
	update()


// converyor diverter
// extendable arm that can be switched so items on the conveyer are diverted sideways
// situate in same turf as conveyor
// only works if belts is running proper direction
//
//
/obj/machinery/diverter
	icon = 'icons/obj/recycling.dmi'
	icon_state = "diverter0"
	name = "diverter"
	desc = "A diverter arm for a conveyor belt."
	anchored = 1
	layer = FLY_LAYER
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT
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
	SPAWN_DBG(0.2 SECONDS)
		// wait for map load then find the conveyor in this turf
		conv = locate() in src.loc
		if(conv)	// divert_from dir must match possible conveyor movement
			if(conv.basedir != divert_from && conv.basedir != turn(divert_from,180) )
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
/obj/machinery/diverter/CanPass(atom/movable/O, var/turf/target)
	var/direct = get_dir(O, target)
	if(direct == divert_to)	// prevent movement through body of diverter
		return 0
	if(!deployed)
		return 1
	return(direct != turn(divert_from,180))

// don't allow movement through the arm if deployed
/obj/machinery/diverter/CheckExit(atom/movable/O, var/turf/target)
	var/direct = get_dir(O, target)
	if(direct == turn(divert_to,180))	// prevent movement through body of diverter
		return 0
	if(!deployed)
		return 1
	return(direct != divert_from)





// the conveyor control switch
//
//

/obj/machinery/conveyor_switch

	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	var/position = 0			// 0 off, -1 reverse, 1 forward
	var/last_pos = -1			// last direction setting
	var/operated = 1			// true if just operated

	var/id = "" 				// must match conveyor IDs to control them

	var/list/conveyors		// the list of converyors that are controlled by this switch
	anchored = 1



/obj/machinery/conveyor_switch/New()
	..()
	START_TRACKING
	update()

	SPAWN_DBG(0.5 SECONDS)		// allow map load
		conveyors = list()
		for(var/obj/machinery/conveyor/C in machine_registry[MACHINES_CONVEYORS])
			if(C.id == id)
				conveyors += C
				C.owner = src

		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"trigger", "trigger")

/obj/machinery/conveyor_switch/disposing()
	STOP_TRACKING
	for(var/obj/machinery/conveyor/C in conveyors)
		C.owner = null
	conveyors = null
	..()


/obj/machinery/conveyor_switch/proc/trigger(var/inp)
	attack_hand(usr) //bit of a hack but hey.
	return

// update the icon depending on the position

/obj/machinery/conveyor_switch/proc/update()
	if(position<0)
		icon_state = "switch-rev"
	else if(position>0)
		icon_state = "switch-fwd"
	else
		icon_state = "switch-off"


// timed process
// if the switch changed, update the linked conveyors

/obj/machinery/conveyor_switch/process()
	if(!operated)
		return
	operated = 0

	for(var/obj/machinery/conveyor/C in conveyors)
		C.operating = position
		C.setdir()

// attack with hand, switch position
/obj/machinery/conveyor_switch/attack_hand(mob/user)
	if(position == 0)
		if(last_pos < 0)
			position = 1
			last_pos = 0
		else
			position = -1
			last_pos = 0
	else
		last_pos = position
		position = 0

	operated = 1
	update()

	// find any switches with same id as this one, and set their positions to match us
	for(var/obj/machinery/conveyor_switch/S in by_type[/obj/machinery/conveyor_switch])
		if(S.id == src.id)
			S.position = position
			S.update()
		LAGCHECK(LAG_MED)

	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"switchTriggered")


//silly proc for corners that can be flippies
/obj/machinery/conveyor/proc/rotateme()
	.= 0


//for ease of mapping
/obj/machinery/conveyor/oshan_carousel
	id = "carousel"
	move_lag = 5.5
	operating = 1


/obj/machinery/conveyor/oshan_carousel/coroner
	var/startdir = NORTH
	var/altdir = NORTH

	New()
		..()
		startdir = src.dir

	setdir()
		if(operating == -1)
			dir = altdir
		else
			dir = startdir
		next_conveyor = locate(/obj/machinery/conveyor) in get_step(src,dir)
		update()

/obj/machinery/conveyor/oshan_carousel/coroner/northeast
	startdir = NORTH
	altdir = EAST

/obj/machinery/conveyor/oshan_carousel/coroner/northwest
	startdir = NORTH
	altdir = WEST

/obj/machinery/conveyor/oshan_carousel/coroner/southeast
	startdir = SOUTH
	altdir = EAST

/obj/machinery/conveyor/oshan_carousel/coroner/southwest
	startdir = SOUTH
	altdir = WEST

/obj/machinery/conveyor/oshan_carousel/coroner/westsouth
	startdir = WEST
	altdir = SOUTH

/obj/machinery/conveyor/oshan_carousel/coroner/westnorth
	startdir = WEST
	altdir = NORTH

/obj/machinery/conveyor/oshan_carousel/coroner/eastsouth
	startdir = EAST
	altdir = SOUTH

/obj/machinery/conveyor/oshan_carousel/coroner/eastnorth
	startdir = EAST
	altdir = NORTH




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
	event_handler_flags = USE_CANPASS | USE_FLUID_ENTER

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
			update_icon()

	proc/update_belts()
		for(var/obj/machinery/conveyor_switch/S in by_type[/obj/machinery/conveyor_switch])
			if(S.id == "carousel")
				for(var/obj/machinery/conveyor/C in S.conveyors)
					C.move_lag = max(initial(C.move_lag) - speedup, 0.1)
				break

	proc/update_icon()
		var/ico = (speedup / speedup_max) * icon_levels
		icon_state = "[icon_base][round(ico)]"
