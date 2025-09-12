/obj/machinery/power
	name = null
	icon = 'icons/obj/power.dmi'
	anchored = ANCHORED
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
			recheck_powernet()

/obj/machinery/power/set_loc(atom/target)
	. = ..()
	recheck_powernet()

/obj/machinery/power/Move(atom/target)
	. = ..()
	recheck_powernet()

/obj/machinery/power/proc/recheck_powernet()
	src.netnum = 0
	src.powernet = null
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
			deferred_powernet_objs |= src
	. = ..()

// common helper procs for all power machines
/obj/machinery/power/proc/add_avail(var/amount, var/process_loop = PROCESSING_EIGHTH)
	powernet?.newavail += amount / 2**(PROCESSING_EIGHTH - process_loop)

#ifdef MACHINE_PROCESSING_DEBUG
	if(!detailed_power_data) detailed_power_data = new
	detailed_power_data.log_machine(src, amount)
#endif

	if(powernet && src.z == Z_LEVEL_STATION && !istype(src, /obj/machinery/power/smes) && !istype(get_area(src), /area/listeningpost))
		station_power_generation["[round(world.time / ( 1 MINUTE ))]"] += amount


/obj/machinery/power/proc/add_load(var/amount, process_loop = PROCESSING_EIGHTH)
	if(powernet && powernet.newload + amount <= powernet.avail)
		powernet.newload += amount / 2**(PROCESSING_EIGHTH - process_loop)
		. = TRUE

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


var/list/station_power_generation = list()

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
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set desc = "Attempts for fix the powernets."
	set name = "Fix powernets"
	ADMIN_ONLY
	SHOW_VERB_DESC
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

//checks for cables pointing directly into this machine but NOT passing under it
//this fixes the issue of crossed pnets getting linked by dragging a stomper over them
//macro'd because there's two dir vars and I hate copy paste
#define CHECK_DIRECT_CONNECTIONS(dirvar)\
	if(C.dirvar == cdir) {\
		var/through_line = FALSE;\
		for (var/obj/cable/center_cable in center) {\
			if (turn(center_cable.d1, 180) == C.dirvar || turn(center_cable.d2, 180) == C.dirvar) {\
				through_line = TRUE;\
				break;\
			}\
		}\
		if (!through_line) {\
			. += C;\
		}\
	}
/obj/machinery/power/proc/get_connections(unmarked = 0)
	if(!directwired)
		return get_indirect_connections(unmarked)

	. = list()
	var/cdir
	var/turf/center = get_turf(src)
	for(var/turf/T in orange(1, src))
		cdir = get_dir(T, src)
		for(var/obj/cable/C in T)
			if(C.netnum && unmarked)
				continue
			CHECK_DIRECT_CONNECTIONS(d1)
			CHECK_DIRECT_CONNECTIONS(d2)

#undef CHECK_DIRECT_CONNECTIONS

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
	var/non_full_apcs = 0

	if (!nodes)
		nodes = list()

	var/list/our_apcs = list()

	var/apcload = 0

	//index working APCs and perform some initial setup, gathering their load
	for(var/obj/machinery/power/terminal/term in nodes)
		if( istype( term.master, /obj/machinery/power/apc ) )
			var/obj/machinery/power/apc/check_apc = term.master
			if(check_apc.load_cycle())
				apcload += check_apc.cycle_load
				our_apcs += check_apc
				if(check_apc.charging != 2)
					non_full_apcs++

	//determine what proportion of APC load can be supplied by remaining power
	var/charge_percentile = 0
	if(apcload > 0)
		var/end_cycle_draw = avail - newload
		charge_percentile = min(end_cycle_draw/apcload,1)

	//mark down the part of load that isn't from APC load restitution (for power reporting later)
	var/non_restitution_load = newload

	//then tell each APC to supply that proportion of its load
	for(var/obj/machinery/power/apc/netapc in our_apcs)
		netapc.cell_cycle(charge_percentile)

	//mandatory load's done! bring in the outgoing tick's load
	load = newload
	newload = 0

	//check how much of that load depleted the outgoing tick's available power
	netexcess = avail - load

	//then bring in the generation for the next tick
	avail = newavail
	newavail = 0

	apc_charge_share = netexcess / max(1,non_full_apcs)

	for(var/obj/machinery/power/apc/netapc in our_apcs)					// go to each APC in the network
		var/expended = netapc.accept_excess(min(apc_charge_share,netexcess))	// and give them first share of any power not used by mandatory load,
		if(expended)
			netexcess -= expended												// subtracting it from netexcess
			non_restitution_load += expended									// and letting the power computer know it's appreciated
			load += expended

	//then notify other devices they can attempt to reclaim any power that didn't go used, and update their reporting on effective output
	for(var/obj/machinery/power/smes/S in nodes)
		S.restore()
	for(var/obj/machinery/power/sword_engine/SW in nodes)
		SW.restore()

	//report overall consumption, including ALL APC load (even if not fully satisfied) to give a better impression of supply vs demand
	viewload = 0.6 * viewload + 0.4 * (non_restitution_load + apcload)

	viewload = round(viewload)
