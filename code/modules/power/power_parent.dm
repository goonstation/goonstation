/obj/machinery/power
	name = null
	icon = 'icons/obj/power.dmi'
	anchored = 1
	machine_registry_idx = MACHINES_POWER
	var/datum/powernet/powernet = null
	var/tmp/netnum = 0
	/// If set to 1, communicate with other devices over cable network.
	var/use_datanet = 0
	/// by default, power machines are connected by a cable in a neighbouring turf
	/// if set to 0, requires a 0-X cable on this turf
	var/directwired = 1

/obj/machinery/power/New(var/new_loc)
	..()
	if (current_state > GAME_STATE_PREGAME)
		SPAWN(0.1 SECONDS) // aaaaaaaaaaaaaaaa
			src.netnum = 0
			if(makingpowernets)
				return // TODO queue instead
			for(var/obj/cable/C in src.get_connections())
				if(src.netnum == 0 && C.netnum != 0)
					src.netnum = C.netnum
				else if(C.netnum != 0 && C.netnum != src.netnum) // could be a join instead but this won't happen often so screw it
					makepowernets()
					return
			if(src.netnum)
				src.powernet = powernets[src.netnum]
				src.powernet.nodes += src
				if(src.use_datanet)
					src.powernet.data_nodes += src

/obj/machinery/power/disposing()
	if(src.powernet)
		src.powernet.nodes -= src
		src.powernet.data_nodes -= src
	if(src.directwired) // it can bridge gaps in the powernet :/
		if(!defer_powernet_rebuild)
			makepowernets()
		else
			defer_powernet_rebuild = 2
	. = ..()

// common helper procs for all power machines
/obj/machinery/power/proc/add_avail(var/amount)
	powernet?.newavail += amount

#ifdef MACHINE_PROCESSING_DEBUG
	var/area/A = get_area(src)
	var/list/machines = detailed_machine_power[A]
	if(!machines)
		detailed_machine_power[A] = list()
		machines = detailed_machine_power[A]
	var/list/machine = machines[src]
	if(!machine)
		machines[src] = list()
		machine = machines[src]
	machine += amount
#endif

/obj/machinery/power/proc/add_load(var/amount)
	powernet?.newload += amount

/obj/machinery/power/proc/surplus()
	if(powernet)
		return powernet.avail-powernet.load
	else
		return 0

/obj/machinery/power/proc/avail()
	if(powernet)
		return powernet.avail
	else
		return 0


// the powernet datum
// each contiguous network of cables & nodes


// rebuild all power networks from scratch
var/makingpowernets = 0
var/makingpowernetssince = 0
/proc/makepowernets()
	if (makingpowernets)
		logTheThing(LOG_DEBUG, null, "makepowernets was called while it was already running! oh no!")
		DEBUG_MESSAGE("attempt to rebuild powernets while already rebuilding")
		return
	DEBUG_MESSAGE("rebuilding powernets start")

	makingpowernets = 1
	if (ticker)
		makingpowernetssince = ticker.round_elapsed_ticks
	else
		makingpowernetssince = 0

	var/netcount = 0
	powernets = list()

	for_by_tcl(PC, /obj/cable)
		PC.netnum = 0

	for(var/obj/machinery/power/M as anything in machine_registry[MACHINES_POWER])
		if(M.netnum >=0)
			M.netnum = 0

	for_by_tcl(PC, /obj/cable)
		if(!PC.netnum)
			powernet_nextlink(PC, ++netcount)

	for(var/L = 1 to netcount)
		var/datum/powernet/PN = new()
		powernets += PN
		PN.number = L

	for_by_tcl(C, /obj/cable)
		if(!C.netnum) continue
		if (C.netnum <= length(powernets))
			var/datum/powernet/PN = powernets[C.netnum]
			PN.cables += C
		else
			stack_trace("Tried to add cable [identify_object(C)] to the cables of powernet [C.netnum], but that powernet number was larger than the powernets list length of [length(powernets)]")

	for(var/obj/machinery/power/M as anything in machine_registry[MACHINES_POWER])
		if(M.netnum <= 0)		// APCs have netnum=-1 so they don't count as network nodes directly
			continue

		M.powernet = powernets[M.netnum]
		M.powernet.nodes += M
		if(M.use_datanet)
			M.powernet.data_nodes += M

	makingpowernets = 0
	DEBUG_MESSAGE("rebuilding powernets end")

/proc/unfuck_makepowernets()
	makingpowernets = 0

/client/proc/fix_powernets()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set desc = "Attempts for fix the powernets."
	set name = "Fix powernets"
	unfuck_makepowernets()
	makepowernets()

// returns a list of all power-related objects (nodes, cable, junctions) in turf,
// excluding source, that match the direction d
// if unmarked==1, only return those with netnum==0

/proc/power_list(var/turf/T, var/source, var/d, var/unmarked=0, var/cables_only=0)
	. = list()
	var/fdir = (!d)? 0 : turn(d, 180)	// the opposite direction to d (or 0 if d==0)

	if(!cables_only)
		for(var/obj/machinery/power/P in T)
			if(P.netnum < 0)	// exclude APCs
				continue

			if(P.directwired)	// true if this machine covers the whole turf (so can be joined to a cable on neighbour turf)
				if(!unmarked || !P.netnum)
					. += P
			else if(d == 0)		// otherwise, need a 0-X cable on same turf to connect
				if(!unmarked || !P.netnum)
					. += P

	for(var/obj/cable/C in T)
		if(C.d1 == fdir || C.d2 == fdir)
			if(!unmarked || !C.netnum)
				. += C
	. -= source


/obj/cable/proc/get_connections(unmarked = 0)
	. = list()	// this will be a list of all connected power objects
	var/turf/T = get_step(src, d1)
	. += power_list(T, src , d1, unmarked)
	T = get_step(src, d2)
	. += power_list(T, src, d2, unmarked)

	//var/straight = d1 == turn(d2, 180)
	for(var/obj/cable/C in src.loc)
		if(C != src && (C.d1 == d2 || C.d2 == d2 || (d1 && (C.d1 == d1 || C.d2 == d1))) && (!unmarked || !C.netnum)) // my turf, sharing a direction
			/*
			(straight && C.d1 == 0) || // straight line connects to knots
			(!d1 && C.d1 == turn(C.d2, 180))) // knots connect to straight lines
			*/
			. += C

/obj/cable/proc/get_connections_one_dir(is_it_d2, unmarked = 0)
	. = list()	// this will be a list of all connected power objects
	var/d = is_it_d2 ? d2 : d1
	var/turf/T = get_step(src, d)
	. += power_list(T, src , d, unmarked)

	//var/straight = d1 == turn(d2, 180)
	for(var/obj/cable/C in src.loc)
		if(C != src && (d && (C.d1 == d || C.d2 == d)) && (!unmarked || !C.netnum)) // my turf, sharing a direction
			/*
			(straight && C.d1 == 0) || // straight line connects to knots
			(!d1 && C.d1 == turn(C.d2, 180))) // knots connect to straight lines
			*/
			. += C

/obj/machinery/power/proc/get_connections(unmarked = 0)
	if(!directwired)
		return get_indirect_connections(unmarked)

	. = list()
	var/cdir

	for(var/turf/T in orange(1, src))
		cdir = get_dir(T, src)
		for(var/obj/cable/C in T)
			if(C.netnum && unmarked)
				continue
			if(C.d1 == cdir || C.d2 == cdir)
				. += C

/obj/machinery/power/proc/get_indirect_connections(unmarked = 0)
	. = list()

	for(var/obj/cable/C in src.loc)
		if(C.netnum && unmarked)
			continue

		if(C.d1 == 0)
			. += C

//LummoxJR patch:
/proc/powernet_nextlink(var/obj/O, var/num)
	var/list/P
	var/list/more
	//world.log << "start: [O] at [O.x].[O.y]"
	while(1)
		if(istype(O, /obj/cable))
			var/obj/cable/C = O
			if(C.netnum > 0)
				if(!more || !length(more))
					return
				O = more[length(more)]
				more -= O
				continue

			C.netnum = num
			P = C.get_connections(1)

		else if(istype(O, /obj/machinery/power))

			var/obj/machinery/power/M = O
			if(M.netnum > 0)
				if(!more || !length(more))
					return
				O = more[length(more)]
				more -= O
				continue

			M.netnum = num
			P = M.get_connections(1)

		if(length(P) == 0)
			if(length(more))
				O = more[length(more)]
				more -= O
				continue
			return

		O = P[1]

		if(length(P) > 1)
			if(!more)
				more = P.Copy(2)
			else
				for(var/X in P)
					X:netnum = -1
				more += P.Copy(2)
// cut a powernet at this cable object

/datum/powernet/proc/cut_cable(var/obj/cable/C)
	var/turf/T1 = C.loc
	if(C.d1)
		T1 = get_step(C, C.d1)

	var/turf/T2 = get_step(C, C.d2)
	var/list/P1 = power_list(T1, C, C.d1)	// what joins on to cut cable in dir1
	var/list/P2 = power_list(T2, C, C.d2)	// what joins on to cut cable in dir2

	if(length(P1) == 0 || length(P2) ==0)			// if nothing in either list, then the cable was an endpoint
											// no need to rebuild the powernet, just remove cut cable from the list
		cables -= C
		return

	if(makingpowernets)
		return // TODO queue instead

	// zero the netnum of all cables & nodes in this powernet

	for(var/obj/cable/OC as anything in cables)
		OC.netnum = 0
	for(var/obj/machinery/power/OM as anything in nodes)
		OM.netnum = 0

	// remove the cut cable from the network
	C.netnum = -1
	C.set_loc(null)
	cables -= C

	powernet_nextlink(P1[1], number)		// propagate network from 1st side of cable, using current netnum

	// now test to see if propagation reached to the other side
	// if so, then there's a loop in the network

	var/notlooped = 0
	for(var/obj/O in P2)
		if( istype(O, /obj/machinery/power) )
			var/obj/machinery/power/OM = O
			if(OM.netnum != number)
				notlooped = 1
				break
		else if( istype(O, /obj/cable) )
			var/obj/cable/OC = O
			if(OC.netnum != number)
				notlooped = 1
				break

	if(notlooped)
		// not looped, so make a new powernet

		var/datum/powernet/PN = new()
		//PN.tag = "powernet #[L]"
		powernets += PN
		PN.number = length(powernets)

		for(var/obj/cable/OC as anything in cables)
			if(!OC.netnum)		// non-connected cables will have netnum==0, since they weren't reached by propagation
				OC.netnum = PN.number
				cables -= OC
				PN.cables += OC		// remove from old network & add to new one
			LAGCHECK(LAG_MED)

		for(var/obj/machinery/power/OM as anything in nodes)
			if(!OM.netnum)
				OM.netnum = PN.number
				OM.powernet = PN
				nodes -= OM
				PN.nodes += OM		// same for power machines
				if (OM.use_datanet)	//Don't forget data_nodes! (If relevant)
					data_nodes -= OM
					PN.data_nodes += OM
			LAGCHECK(LAG_MED)

	else
		//there is a loop, so nothing to be done
		return

	return

/datum/powernet/proc/join_to(var/datum/powernet/PN) // maybe pool powernets someday
	for(var/obj/cable/C as anything in src.cables)
		C.netnum = PN.number
		PN.cables += C

	for(var/obj/machinery/power/M as anything in src.nodes)
		M.netnum = PN.number
		M.powernet = PN
		PN.nodes += M
		if (M.use_datanet)
			PN.data_nodes += M

/datum/powernet/proc/reset()
	load = newload
	newload = 0
	avail = newavail
	newavail = 0

	viewload = 0.8*viewload + 0.2*load

	viewload = round(viewload)

	var/numapc = 0

	if (!nodes)
		nodes = list()

	for(var/obj/machinery/power/terminal/term in nodes)
		if( istype( term.master, /obj/machinery/power/apc ) )
			numapc++

	if(numapc)
		perapc = avail/numapc

	netexcess = avail - load

	if(netexcess > 100)		// if there was excess power last cycle
		for(var/obj/machinery/power/smes/S in nodes)	// find the SMESes in the network
			S.restore()				// and restore some of the power that was used
		for(var/obj/machinery/power/sword_engine/SW in nodes)	//Finds the SWORD Engines in the network.
			SW.restore()				//Restore some of the power that was used.
