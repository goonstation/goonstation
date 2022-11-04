// pipeline datum for storing inter-machine links
// create a pipeline

//number of pipelines
var/linenums = 0

/obj/machinery/pipeline/New()
	..()

	gas = new /datum/gas_mixture
	ngas = new /datum/gas_mixture

	gasflowlist += src

/obj/machinery/pipeline/disposing()
	if(gas)
		qdel(gas)
	if(ngas)
		qdel(ngas)
	..()

// find the pipeline that contains the /obj/machine (including pipe)
/proc/findline(var/obj/machinery/M)

	for(var/obj/machinery/pipeline/P in plines)

		for(var/obj/machinery/O in P.nodes)

			if(M==O)
				return P

	return null

// sets the vnode1&2 terminators to the joining machines (or null)
/obj/machinery/pipeline/proc/setterm()

	//first make sure pipes are oriented correctly

	var/obj/machinery/M = null

	for(var/obj/machinery/pipes/P in nodes)
		if(!M)			// special case for 1st pipe
			if(P.node1 && P.node1.ispipe())
				P.flip()		// flip if node1 is a pipe
		else
			if(P.node1 != M)		//other cases, flip if node1 doesn't point to previous node
				P.flip()			// (including if it is null)


		M = P


	// pipes are now ordered so that n1/n2 is in same order as pipeline list

	var/obj/machinery/pipes/P = nodes[1]		// 1st node in list
	vnode1 = P.node1							// n1 points to 1st machine
	P = nodes[nodes.len]						// last node in list
	vnode2 = P.node2							// n2 points to last machine

	vnode1?.buildnodes()
	vnode2?.buildnodes()

	return

/*
/obj/machinery/pipeline/get_gas_moles(from)
	return TOTAL_MOLES(gas)/capmult
*/
/obj/machinery/pipeline/get_gas(from)
	return gas

/obj/machinery/pipeline/gas_flow()
	//if(suffix == "d" && Debug) world.log << "PLF1  TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

	gas.copy_from(ngas)

	//if(suffix == "d" && Debug) world.log << "PLF2  TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

/obj/machinery/pipeline/process()
	/*
	// heat exchange for whole pipeline

	//if(suffix=="dbgp")
	//	world.log << "PLP"
	//	Plasma()

//	var/dbg = (suffix == "d") && Debug

	//if(dbg) world.log << "PLP1 TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

	if(!numnodes)
		return		//dividing by zero is bad okay?

	var/gtemp = ngas.temperature					// cached temperature for heat exch calc
	var/tot_node = TOTAL_MOLES(ngas) / numnodes		// fraction of gas in this node

	//if(dbg) world.log << "PLHE: [gtemp] [tot_node]"

	if(tot_node>0.1)		// no pipe contents, don't heat
		for(var/obj/machinery/pipes/P in src.nodes)		// for each segment of pipe
			P.heat_exchange(ngas, tot_node, numnodes, gtemp) //, dbg)	// exchange heat with its turf
			if(!istype(P, /obj/machinery/pipes/heat_exch) && ((100*tot_node/P.capacity > 15000) || (gtemp > 8000)) )
				P.rupture()
				//Commenting this out because it spams on endlessly
				//for (var/mob/M in viewers(P))
					//M.show_message("<span class='alert'>The pipe has ruptured!</span>", 3)
				//so this is changed to pipe rupturing instead of explosions
			//i.e. it ruptures if the pressure over 15000%
			//and temperature over 8000K
			//it also doesn't work on heat_exchange pipes
	// now do standard gas flow proc


	//if(dbg) world.log << "PLP2 TOTAL_MOLES([ngas)]"

	var/delta_gt

	if(vnode1 && !(vnode1.status & BROKEN))
		delta_gt = FLOWFRAC * ( vnode1.get_gas_val(src) - TOTAL_MOLES(gas) / capmult)
		calc_delta( src, gas, ngas, vnode1, delta_gt)//, dbg)

		//if(dbg) world.log << "PLT1 [delta_gt] >> TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

		flow = delta_gt
	else
		leak_to_turf(1)

	if(vnode2 && !(vnode2.status & BROKEN))
		delta_gt = FLOWFRAC * ( vnode2.get_gas_val(src) - TOTAL_MOLES(gas) / capmult)
		calc_delta( src, gas, ngas, vnode2, delta_gt)//, dbg)

		//if(dbg) world.log << "PLT2 [delta_gt] >> TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

		flow -= delta_gt
	else
		leak_to_turf(2)

	*/ //TODO: FIX

/obj/machinery/pipeline/proc/leak_to_turf(var/port)
	/*
	var/turf/T
	var/obj/machinery/pipes/P
	var/list/ndirs

	switch(port)
		if(1)
			P = nodes[1]		// 1st node in list
			if (P==null)
				T = src.loc
			else
				ndirs = P.get_node_dirs()

				T = get_step(P, ndirs[1])


		if(2)
			P = nodes[nodes.len]	// last node in list
			if (P==null)
				T = src.loc
			else

				ndirs = P.get_node_dirs()
				T = get_step(P, ndirs[2])
	if (T==null)
		return
	if(T.density)
		return

	flow_to_turf(gas, ngas, T)
	*/ //TODO: FIX


// build the pipelines (THIS HAPPENS ONCE!)
/proc/makepipelines()

	for(var/obj/machinery/pipes/P as anything in machine_registry[MACHINES_PIPES])		// look for a pipe

		if(!P.plnum)							// if not already part of a line
			P.buildnodes(++linenums)			// add it, and spread to all connected pipes

			//world.log<<"Line #[linecount] started at [P] ([P.x],[P.y],[P.z])"

	for(var/L = 1 to linenums)					// for count of lines found
		var/obj/machinery/pipeline/PL = new()	// make a pipeline virtual object
		PL.name = "pipeline #[L]"
		plines += PL							// and add it to the list
		PL.linenumber = L



	for(var/obj/machinery/pipes/P as anything in machine_registry[MACHINES_PIPES])		// look for pipes

		if(P.termination)						// true if pipe is terminated (ends in blank or a machine)
			var/obj/machinery/pipeline/PL = plines[P.plnum]		// get the pipeline from the pipe's pl-number

			var/list/pipes = pipelist(null, P)	// get a list of pipes from P until terminated

			PL.nodes = pipes					// pipeline is this list of nodes
			PL.numnodes = pipes.len				// with this many nodes
			PL.capmult = PL.numnodes+1			// with this flow multiplier



	for(var/obj/machinery/pipes/P as anything in machine_registry[MACHINES_PIPES])		// all pipes
		P.setline()								// 	set the pipeline object for this pipe

		if(P.tag == "dbg")		//add debug tag to line containing debug pipe
			P.parent.tag = "dbg"

		if(P.suffix == "dbgpp")		//add debug tag to line containing debug pipe
			P.parent.suffix = "dbgp"

		if(P.suffix == "d")		//add debug tag to line containing debug pipe
			P.parent.suffix = "d"


	for(var/obj/machinery/M in all_processing_machines)		// for all machines
		if(M.p_dir)								// which are pipe-connected
			if(!M.ispipe())						// is not a pipe itself
				M.buildnodes()					// build the nodes, setting the links to the virtual pipelines
												// also sets the vnodes for the pipelines

	for(var/obj/machinery/pipeline/PL in plines)	// for all lines
		PL.setterm()								// orient the pipes and set the pipeline vnodes to the terminating machines

// return a list of pipes (not including terminating machine)

/proc/pipelist(var/obj/machinery/source, var/obj/machinery/startnode)

	var/list/L = list()

	var/obj/machinery/node = startnode
	var/obj/machinery/prev = source
	var/obj/machinery/newnode

	while(node)
		L += node
		newnode = node.next(prev)
		prev = node

		if(newnode?.ispipe())
			node = newnode
		else
			break

	return L

// new pipes system

// flip the nodes of a pipe
/obj/machinery/pipes/proc/flip()
	var/obj/machinery/tempnode = node1
	node1 = node2
	node2 = tempnode
	return


// return the next pipe in the node chain
/obj/machinery/pipes/next(var/obj/machinery/from)

	if(from == null)		// if from null, then return the next actual pipe
		if(node1?.ispipe() )
			return node1
		if(node2?.ispipe() )
			return node2
		return null			// else return null if no real pipe connected

	else if(from == node1)		// otherwise, return the node opposite the incoming one
		return node2
	else
		return node1


// set the pipeline obj from the pl-number and global list of pipelines

/obj/machinery/pipes/setline()
	src.parent = plines[plnum]
	return

// returns the pipeline that this line is in

/obj/machinery/pipes/getline()
	return parent

/obj/machinery/pipes/orient_pipe(P as obj)
	if (!( src.node1 ))
		src.node1 = P
	else
		if (!( src.node2 ))
			src.node2 = P
		else
			return 0
	return 1

// returns a list of dir1, dir2 & p_dir for a pipe

/obj/machinery/pipes/proc/get_dirs()
	var/b1
	var/b2

	for(var/d in cardinal)
		if(p_dir & d)
			if(!b1)
				b1 = d
			else if(!b2)
				b2 = d

	return list(b1, b2, p_dir)

// returns a list of the directions of a pipe, matched to nodes (if present)

/obj/machinery/pipes/proc/get_node_dirs()
	var/list/dirs = get_dirs()


	if(!node1 && !node2)		// no nodes - just return the standard dirs
		return dirs				// note extra p_dir on end of list is unimportant
	else
		if(node1)
			var/d1 = get_dir(src, node1)		// find the direction of node1
			if(d1==dirs[1])						// if it matches
				return dirs						// then dirs list is correct
			else
				return list(dirs[2], dirs[1])	// otherwise return the list swapped

		else		// node2 must be valid
			var/d2 = get_dir(src, node2)		// direction of node2
			if(d2==dirs[2])						// matches
				return dirs						// dirs list is correct
			else
				return list(dirs[2], dirs[1])	// otherwise swap order


/obj/machinery/pipes/proc/update()

	var/turf/T = src.loc

	var/list/dirs = get_dirs()

	var/is = "[dirs[3]]"

	if(status & BROKEN)
		is += "-b"

	if ((src.level == 1 && isturf(src.loc) && T.intact))
		src.invisibility = INVIS_ALWAYS
		is += "-f"

	else
		src.invisibility = INVIS_NONE

	src.icon_state = is

	if(node1 && node2)
		overlays = null
	else if(!node1 && !node2)
		overlays += image('icons/obj/atmospherics/pipes.dmi', "discon", FLY_LAYER, dirs[1])
		overlays += image('icons/obj/atmospherics/pipes.dmi', "discon", FLY_LAYER, dirs[2])
	else if(!node1)
		var/d2 = get_dir(src, node2)
		if(dirs[1] == d2)
			overlays += image('icons/obj/atmospherics/pipes.dmi', "discon", FLY_LAYER, dirs[2])
		else
			overlays += image('icons/obj/atmospherics/pipes.dmi', "discon", FLY_LAYER, dirs[1])
	else if(!node2)
		var/d1 = get_dir(src, node1)
		if(dirs[1] == d1)
			overlays += image('icons/obj/atmospherics/pipes.dmi', "discon", FLY_LAYER, dirs[2])
		else
			overlays += image('icons/obj/atmospherics/pipes.dmi', "discon", FLY_LAYER, dirs[1])


	return

/obj/machinery/pipes/hide(var/i)
	update()

	//its lazy right now but wait until after my exams and I'll redo it.
	//redid it, oh shit

/obj/machinery/pipes/proc/rupture()

	status |= BROKEN
	update()

/obj/machinery/pipes/disposing()
	status |= BROKEN
	update()
	..()


/obj/machinery/pipes/attackby(obj/item/W, mob/user)

	if (isweldingtool(W))
		if(!(status & BROKEN))
			return
		if(!W:try_weld(user,2))
			return
		status &= ~BROKEN
		update()
		for (var/mob/M in viewers(src))
			M.show_message("<span class='alert'>The pipe has been mended by [user.name] with [W].</span>", 3, "<span class='alert'>You hear welding.</span>", 2)
		return

/obj/machinery/pipes/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			status |= BROKEN
			update()
			if (prob(50))
				qdel(src)
				return
		if(3)
			if(prob(75))
				status |= BROKEN
				update()
				if (prob(25))
					qdel(src)
					return
		else
	return
/*
	var/strength = (((plasma + oxygen/2.0) / 1600000.0) * sqrt(temp) ) / 10
	message_admins("CODER: Pipe explosion strength: [strength], Temperature: [temp], Plasma: [plasma], Oxygen: [oxygen]")
	//lets say hypothetically it uses up 9/10 of its energy in bursting the pipe

	if (strength < 773.0)
		var/turf/T = get_turf(src.loc)
		T.poison += plasma
		T.firelevel = T.poison
		T.res_vars()

		//if ((src.gas.temperature > (450+T0C) && src.gas.plasma == 1600000.0))

		if (strength > (450+T0C))
			var/turf/sw = locate(max(T.x - 4, 1), max(T.y - 4, 1), T.z)
			var/turf/ne = locate(min(T.x + 4, world.maxx), min(T.y + 4, world.maxy), T.z)
			defer_powernet_rebuild = 1

			for(var/turf/U in block(sw, ne))
				var/zone = 4
				if ((U.y <= (T.y + 1) && U.y >= (T.y - 1) && U.x <= (T.x + 2) && U.x >= (T.x - 2)) )
					zone = 3
				if ((U.y <= (T.y + 1) && U.y >= (T.y - 1) && U.x <= (T.x + 1) && U.x >= (T.x - 1) ))
					zone = 2
				for(var/atom/A in U)
					A.ex_act(zone)
					//Foreach goto(342)
				U.ex_act(zone)
				U.buildlinks()
				//Foreach goto(170)
			defer_powernet_rebuild = 0
			makepowernets()

		else
			//if ((src.gas.temperature > (300+T0C) && src.gas.plasma == 1600000.0))
			if (strength > (300+T0C))
				var/turf/sw = locate(max(T.x - 4, 1), max(T.y - 4, 1), T.z)
				var/turf/ne = locate(min(T.x + 4, world.maxx), min(T.y + 4, world.maxy), T.z)
				defer_powernet_rebuild = 1

				for(var/turf/U in block(sw, ne))
					var/zone = 4
					if ((U.y <= (T.y + 2) && U.y >= (T.y - 2) && U.x <= (T.x + 2) && U.x >= (T.x - 2)) )
						zone = 3
					for(var/atom/A in U)
						A.ex_act(zone)
						//Foreach goto(598)
					U.ex_act(zone)
					U.buildlinks()
					//Foreach goto(498)
				defer_powernet_rebuild = 0
				makepowernets()

		//src.master = null
		qdel(src)
		return

	var/turf/T = src.loc
	while(!( istype(T, /turf) ))
		T = T.loc

	for(var/mob/M in range(T))
		M.flash(3 SECONDS)
		//Foreach goto(732)
	//var/m_range = 2

	var/m_range = round(strength / 387)
	for(var/obj/machinery/atmoalter/canister/C in range(2, T))
		if (!( C.destroyed ))
			if (C.gas.plasma >= 35000)
				C.destroyed = 1
				m_range++

		//Foreach goto(776)
	var/min = m_range
	var/med = m_range * 2
	var/max = m_range * 3
	var/u_max = m_range * 4

	var/turf/sw = locate(max(T.x - u_max, 1), max(T.y - u_max, 1), T.z)
	var/turf/ne = locate(min(T.x + u_max, world.maxx), min(T.y + u_max, world.maxy), T.z)

	defer_powernet_rebuild = 1

	for(var/turf/U in block(sw, ne))

		var/zone = 4
		if ((U.y <= (T.y + max) && U.y >= (T.y - max) && U.x <= (T.x + max) && U.x >= (T.x - max) ))
			zone = 3
		if ((U.y <= (T.y + med) && U.y >= (T.y - med) && U.x <= (T.x + med) && U.x >= (T.x - med) ))
			zone = 2
		if ((U.y <= (T.y + min) && U.y >= (T.y - min) && U.x <= (T.x + min) && U.x >= (T.x - min) ))
			zone = 1
		for(var/atom/A in U)
			A.ex_act(zone)
			//Foreach goto(1217)
		U.ex_act(zone)
		U.buildlinks()
		//U.mark(zone)

		//Foreach goto(961)
	//src.master = null
	defer_powernet_rebuild = 0
	makepowernets()
	qdel(src)
	return
*/
/*
/obj/machinery/pipes/process()
*/

/obj/machinery/pipes
	machine_registry_idx = MACHINES_PIPES

/obj/machinery/pipes/New()

	..()

	if(istype(src, /obj/machinery/pipes/heat_exch))
		h_dir = text2num(icon_state)
	else
		p_dir = text2num(icon_state)


/obj/machinery/pipes/ispipe()		// return true since this is a pipe
	return 1

/obj/machinery/pipes/buildnodes(var/linenum)

	var/list/dirs = get_dirs()

	node1 = get_machine(level, src.loc, dirs[1])
	node2 = get_machine(level, src.loc, dirs[2])

	if(plnum)
		return

	update()

	plnum = linenum

	termination = 0

	if(node1?.ispipe() )

		node1.buildnodes(linenum)
	else
		termination++

	if(node2?.ispipe() )
		node2.buildnodes(linenum)
	else
		termination++


/obj/machinery/pipes/heat_exch/get_dirs()
	var/b1
	var/b2

	for(var/d in cardinal)
		if(h_dir & d)
			if(!b1)
				b1 = d
			else if(!b2)
				b2 = d

	return list(b1, b2, h_dir)

/obj/machinery/pipes/heat_exch/buildnodes(var/linenum)

	src.level = 2		// h/e pipe cannot be put underfloor

	var/list/dirs = get_dirs()

	node1 = get_he_machine(level, src.loc, dirs[1])
	node2 = get_he_machine(level, src.loc, dirs[2])

	if(plnum)
		return

	update()

	plnum = linenum

	termination = 0

	if(node1?.ispipe() )

		node1.buildnodes(linenum)
	else
		termination++

	if(node2?.ispipe() )
		node2.buildnodes(linenum)
	else
		termination++


/obj/machinery/pipes/proc/heat_exchange(var/datum/gas_mixture/gas, var/tot_node, var/numnodes, var/temp, var/dbg=0)

/*	var/turf/T = src.loc		// turf location of pipe
	if(T.density) return
	if(istype(src, /obj/machinery/pipes/flexipipe)) return

	if( level != 1)				// no heat exchange for under-floor pipes
		if(istype(T,/turf/space))		// heat exchange less efficient in space (no conduction)
			gas.temperature += ( T.temp - temp) / (3.0 * insulation * numnodes)
		else

	//		if(dbg) world.log << "PHE: ([x],[y]) [T.temp]-> \..."
			var/delta_T = (T.temp - temp) / (insulation)	// normal turf

			gas.temperature += delta_T	/ numnodes			// heat the pipe due to turf temperature

			/*
			if(abs(delta_T*tot_node/TOTAL_MOLES(T)) > 1)
				world.log << "Turf [T] at [T.x],[T.y]: gt=[temp] tt=[T.temp]"
				world.log << "dT = [delta_T] tn=[tot_node] TOTAL_MOLES(ttg=[T)] tt-=[delta_T*tot_node/TOTAL_MOLES(T)]"

			*/
			var/tot_turf = max(1, TOTAL_MOLES(T))
			T.temp -= delta_T*min(10,tot_node/tot_turf)			// also heat the turf due to pipe temp
							// clamp max temp change to prevent thermal runaway
							// if low amount of gas in turf
	//		if(dbg) world.log << "[T.temp] [tot_turf] #[delta_T]"
			T.res_vars()	// ensure turf tmp vars are updated

	else								// if level 1 but in space, perform cooling anyway - exposed pipes
		if(istype(T,/turf/space))
			gas.temperature += ( T.temp - temp) / (3.0 * insulation * numnodes)
*/ //TODO FIX
// finds the machine with compatible p_dir in 1 step in dir from S
/proc/get_machine(var/level, var/turf/S, mdir)

	var/flip = turn(mdir, 180)

	var/turf/T = get_step(S, mdir)

	for(var/obj/machinery/M in T.contents)
		if(M.level == level)
			if(M.p_dir & flip)
				return M

	return null

// finds the machine with compatible h_dir in 1 step in dir from S
/proc/get_he_machine(var/level, var/turf/S, mdir)

	var/flip = turn(mdir, 180)

	var/turf/T = get_step(S, mdir)

	for(var/obj/machinery/M in T.contents)
		if(M.level == level)
			if(M.h_dir & flip)
				return M

	return null

// ***** circulator

/obj/machinery/circulator/New()
	..()
	gas1 = new /datum/gas_mixture
	gas2 = new /datum/gas_mixture

	ngas1 = new /datum/gas_mixture
	ngas2 = new /datum/gas_mixture

	gasflowlist += src

	//gas.co2 = capacity

	UpdateIcon()

/obj/machinery/circulator/disposing()
	if(gas1)
		qdel(gas1)
	if(gas2)
		qdel(gas2)
	if(ngas1)
		qdel(ngas1)
	if(ngas2)
		qdel(ngas2)
	..()

/obj/machinery/circulator/buildnodes()

	var/turf/TS = get_step(src, SOUTH)
	var/turf/TN = get_step(src, NORTH)

	for(var/obj/machinery/M in TS)

		if(M && (M.p_dir & 1))
			node1 = M
			break

	for(var/obj/machinery/M in TN)

		if(M && (M.p_dir & 2))
			node2 = M
			break


	if(node1) vnode1 = node1.getline()

	if(node2) vnode2 = node2.getline()


/*
/obj/machinery/circulator/verb/toggle_power()
	set src in view(1)

	if(circ_status == 1)
		circ_status = 2
		SPAWN(3 SECONDS)				// 3 second delay for slow-off
			if(circ_status == 2)
				circ_status = 0
				UpdateIcon()
	else if(circ_status == 0)
		circ_status =1

	UpdateIcon()



/obj/machinery/circulator/verb/set_rate(r as num)
	set src in view(1)
	rate = r/100.0*capacity
*/

/obj/machinery/circulator/proc/control(var/on, var/prate)

	rate = prate/100*capacity

	if(circ_status == 1)
		if(!on)
			circ_status = 2
			SPAWN(3 SECONDS)
				if(circ_status == 2)
					circ_status = 0
					UpdateIcon()
	else if(circ_status == 0)
		if(on)
			circ_status = 1
	else	// circ_status ==2
		if(on)
			circ_status = 1

	UpdateIcon()


/obj/machinery/circulator/UpdateIcon()

	if(status & NOPOWER)
		icon_state = "circ[side]-p"
		return

	var/is
	switch(circ_status)
		if(0)
			is = "off"
		if(1)
			is = "run"
		if(2)
			is = "slow"

	icon_state = "circ[side]-[is]"



/obj/machinery/circulator/power_change()
	..()
	UpdateIcon()

/*
/obj/machinery/circulator/receive_gas(var/obj/substance/gas/t_gas as obj, from as obj, amount)


	if(from != src.node1)
		return

	amount = min(receive_amount(src), amount)


	//src.gas.transfer_from(t_gas, amount)

	return
*/
/obj/machinery/circulator/gas_flow()

	gas1.copy_from(ngas1)
	gas2.copy_from(ngas2)

/obj/machinery/circulator/process()
	/*
	// if operating, pump from resv1 to resv2

	if(! (status & NOPOWER) )				// only do circulator step if powered; still do rest of gas flow at all times
		if(circ_status==1 || circ_status==2)
			gas2.transfer_from(gas1, circ_status==1? rate : rate/2)
			use_power(rate/capacity * 100)
		ngas1.copy_from(gas1)
		ngas2.copy_from(gas2)


	// now do standard process

	var/delta_gt

	if(vnode1)
		delta_gt = FLOWFRAC * ( vnode1.get_gas_val(src) - TOTAL_MOLES(gas1) / capmult)
		calc_delta( src, gas1, ngas1, vnode1, delta_gt)
	else
		leak_to_turf(1)

	if(vnode2)
		delta_gt = FLOWFRAC * ( vnode2.get_gas_val(src) - TOTAL_MOLES(gas2) / capmult)
		calc_delta( src, gas2, ngas2, vnode2, delta_gt)
	else
		leak_to_turf(2)*/ //TODO FIX

/obj/machinery/circulator/proc/leak_to_turf(var/port)
	/*
	var/turf/T

	switch(port)
		if(1)
			T = get_step(src, SOUTH)
		if(2)
			T = get_step(src, NORTH)

	if(T.density)
		T = src.loc
		if(T.density)
			return

	switch(port)
		if(1)
			flow_to_turf(gas1, ngas1, T)
		if(2)
			flow_to_turf(gas2, ngas2, T)


	// do leak
	*/ //TODO: FIX

/*
/obj/machinery/circulator/get_gas_moles(from)
	if(from == vnode1)
		return TOTAL_MOLES(gas1)/capmult
	else
		return TOTAL_MOLES(gas2)/capmult
*/ //TODO: FIX
/obj/machinery/circulator/get_gas(from)
	if(from == vnode1)
		return gas1
	else
		return gas2

/*
/obj/machinery/connector/New()
	..()

	gas = new /datum/gas_mixture()
	ngas = new /datum/gas_mixture()
	//agas = new/obj/substance/gas()

	gasflowlist += src
	SPAWN(0.5 SECONDS)
		var/obj/machinery/atmoalter/A = locate(/obj/machinery/atmoalter, src.loc)

		if(A && A.c_status != 0)
			connected = A
			A.anchored = 1




/obj/machinery/connector/buildnodes()
	var/turf/T = get_step(src.loc, src.dir)
	var/fdir = turn(src.p_dir, 180)

	for(var/obj/machinery/M in T)
		if(M.p_dir & fdir)
			src.node = M
			break

	if(node) vnode = node.getline()


	return



/obj/machinery/connector/examine()
	set src in oview(1)
	set category = "Local"
	..()
	if(connected)
		boutput(usr, "It is connected to \an [connected.name].")
	else
		boutput(usr, "It is unconnected.")



/obj/machinery/connector/get_gas_val(from)
	return TOTAL_MOLES(gas)/capmult

/obj/machinery/connector/get_gas(from)
	return gas


/obj/machinery/connector/gas_flow()

//	var/dbg = (suffix == "d") && Debug
	//if(dbg) world.log << "CF0: TOTAL_MOLES(ngas=[ngas)]"

	//ngas.transfer_from(agas, -1)

	//if(dbg)	world.log << "CF1: TOTAL_MOLES(ngas=[gas)]"
	gas.copy_from(ngas)
	//if(dbg)	world.log << "CF2: TOTAL_MOLES(gas=[gas)]"
	flag = 0

/obj/machinery/connector/process()
	//if(suffix=="dbgp")
	//	world.log << "CP"
	//	Plasma()

	var/delta_gt
//	var/dbg = (suffix == "d") && Debug

	//if(dbg) world.log << "C[tag]P: TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"
	//if(dbg && connected) world.log << "C[tag]PC: TOTAL_MOLES([connected.gas)]"

	if(vnode)

		delta_gt = FLOWFRAC * ( vnode.get_gas_val(src) - TOTAL_MOLES(gas) / capmult)
		//if(dbg) world.log << "C[tag]P0: [delta_gt]"

		//var/obj/substance/gas/vgas = vnode.get_gas(src)

		//if(dbg) world.log << "C[tag]P1: TOTAL_MOLES([gas)], TOTAL_MOLES([ngas)] -> TOTAL_MOLES([vgas)]"
		calc_delta( src, gas, ngas, vnode, delta_gt)//, dbg)
		//if(dbg) world.log << "C[tag]P2: TOTAL_MOLES([gas)], TOTAL_MOLES([ngas)] -> TOTAL_MOLES([vgas)]"

	else
		leak_to_turf()

	if(connected)
		var/amount
		if(connected.c_status == 1)				// canister set to release

			//if(dbg) world.log << "C[tag]PC1: TOTAL_MOLES([gas)], TOTAL_MOLES([ngas)] <- TOTAL_MOLES([connected.gas)]"
			amount = min(connected.c_per, capacity - TOTAL_MOLES(gas) )	// limit to space in connector
			amount = clamp(amount, 0, TOTAL_MOLES(connected.gas) )		// limit to amount in canister, or 0
			//if(dbg) world.log << "C[tag]PC2: a=[amount]"
			//var/ng = TOTAL_MOLES(ngas)
			ngas.transfer_from( connected.gas, amount)
			//if(dbg) world.log TOTAL_MOLES(<<"[ngas)-ng] from siph to connector"
			//if(dbg) world.log << "C[tag]PC3: TOTAL_MOLES([gas)], TOTAL_MOLES([ngas)] <- TOTAL_MOLES([connected.gas)]"
		else if(connected.c_status == 2)		// canister set to accept

			amount = min(connected.c_per, connected.gas.maximum - TOTAL_MOLES(connected.gas))	//limit to space in canister
			amount = clamp(amount, 0, TOTAL_MOLES(gas) )				// limit to amount in connector, or 0

			connected.gas.transfer_from( ngas, amount)

	//flag = 1

	//if(suffix=="dbgp")
	//	world.log << "CP"
	//	Plasma()
*/ //TODO: FIX


/obj/machinery/connector/proc/leak_to_turf()
	/*
	//var/dbg = (tag == "dbg") && Debug

	var/turf/T = get_step(src, dir)
	if(T && !T.density)

		//if(dbg) world.log << "CLT1: [gas.tostring()] ~ [ngas.tostring()]<br>Tg = [T.tostring()]"


		flow_to_turf(gas, ngas, T)

		//if(dbg) world.log << "CLT2: [gas.tostring()] ~ [ngas.tostring()]<br>Tg = [T.tostring()]"
	*/


/obj/machinery/junction/New()
	..()
	gas = new/datum/gas_mixture(src)
	ngas = new/datum/gas_mixture()
	gasflowlist += src

	h_dir = dir					// the h/e pipe is in obj dir
	p_dir = turn(dir, 180)		// the reg pipe is in opposite dir


/obj/machinery/junction/buildnodes()

	var/turf/T = src.loc

	node1 = get_he_machine(level, T, h_dir )		// the h/e pipe

	node2 = get_machine(level, T , p_dir )	// the regular pipe

	if(node1) vnode1 = node1.getline()
	if(node2) vnode2 = node2.getline()

	return


/obj/machinery/junction/gas_flow()

	//var/dbg
	//if(tag == "dbg1")
	//	dbg = 1
	//else if(tag == "dbg2")
	//	dbg = 2

	//if(dbg)	world.log << "J[dbg]F1: [gas.tostring()] ~ [ngas.tostring()]"


	gas.copy_from(ngas)

	//if(dbg)	world.log << "J[dbg]F2: [gas.tostring()] ~ [ngas.tostring()]"

/obj/machinery/junction/process()
/*
	//var/dbg
	//if(tag == "dbg1")
	//	dbg = 1
	//else if(tag == "dbg2")
	//	dbg = 2

	//if(dbg)	world.log << "J[dbg]P: [gas.tostring()] ~ [ngas.tostring()]"

	var/delta_gt

	if(vnode1)
		delta_gt = FLOWFRAC * ( vnode1.get_gas_val(src) - TOTAL_MOLES(gas) / capmult)
		calc_delta( src, gas, ngas, vnode1, delta_gt) //, dbg)

	//	if(dbg)	world.log << "J[dbg]T1: [delta_gt] >> [gas.tostring()] ~ [ngas.tostring()]"
	else
		leak_to_turf(1)

	if(vnode2)
		delta_gt = FLOWFRAC * ( vnode2.get_gas_val(src) - TOTAL_MOLES(gas) / capmult)
		calc_delta( src, gas, ngas, vnode2, delta_gt) //, dbg)

	//	if(dbg)	world.log << "J[dbg]T2: [delta_gt] >> [gas.tostring()] ~ [ngas.tostring()]"
	else
		leak_to_turf(2)
*/ //TODO: FIX

/obj/machinery/junction/get_gas_val(from)
	return TOTAL_MOLES(gas)/capmult

/obj/machinery/junction/get_gas(from)
	return gas

/obj/machinery/junction/proc/leak_to_turf(var/port)

	var/turf/T


	switch(port)
		if(1)
			T = get_step(src, dir)
		if(2)
			T = get_step(src, turn(dir, 180) )

	if(T.density)
		T = src.loc
		if(T.density)
			return

	flow_to_turf(gas, ngas, T)


/obj/machinery/vent/New()

	..()
	p_dir = dir
	gas = new /datum/gas_mixture
	ngas = new /datum/gas_mixture
	gasflowlist += src

/obj/machinery/vent/disposing()
	if(gas)
		qdel(gas)
	if(ngas)
		qdel(ngas)
	..()

/obj/machinery/vent/buildnodes()

	var/turf/T = get_step(src.loc, src.dir)
	var/fdir = turn(src.p_dir, 180)

	for(var/obj/machinery/M in T)
		if(M.p_dir & fdir)
			src.node = M
			break

	if(node) vnode = node.getline()

	return


/obj/machinery/vent/get_gas_val(from)
	return TOTAL_MOLES(gas)/2

/obj/machinery/vent/get_gas(from)
	return gas


/obj/machinery/vent/gas_flow()

//	var/dbg = (suffix=="d") && Debug
	//if(dbg) world.log << "V[tag]F1: TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"
	gas.copy_from(ngas)
	//if(dbg) world.log << "V[tag]F2: TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

/obj/machinery/vent/process()
	/*

//	var/dbg = (suffix=="d") && Debug
	//if(dbg)	world.log << "V[tag]T1: TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

	//if(suffix=="dbgp")
	//	world.log << "VP"
	//	Plasma()

	var/delta_gt

	var/turf/T = src.loc

	delta_gt = FLOWFRAC * (TOTAL_MOLES(gas) / capmult)
	//var/ng = TOTAL_MOLES(ngas)
	ngas.turf_add(T, delta_gt)

	//if(dbg) world.log << "[num2text(ng-TOTAL_MOLES(ngas),10)] from vent to turf"
	//if(dbg)	world.log << "V[tag]T2: TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

	if(vnode)

		//if(dbg)	world.log << "V[tag]N1: TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

		delta_gt = FLOWFRAC * ( vnode.get_gas_val(src) - TOTAL_MOLES(gas) / capmult)

		calc_delta( src, gas, ngas, vnode, delta_gt)//, dbg)

		//if(dbg)	world.log << "V[tag]N2: TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

	else
		leak_to_turf()
	*/ //TODO: FIX


/obj/machinery/vent/proc/leak_to_turf()
// note this is a leak from the node, not the vent itself
// thus acts as a link between the vent turf and the turf in step(dir)

	var/turf/T = get_step(src, dir)
	if(T && !T.density)
		flow_to_turf(gas, ngas, T)


// inlet - equilibrates between pipe contents and turf
// very similar to vent, except that a vent always dumps pipe gas into turf
/obj/machinery/inlet/New()

	..()

	p_dir = dir
	gas = new /datum/gas_mixture
	ngas = new /datum/gas_mixture
	gasflowlist += src

/obj/machinery/inlet/disposing()
	if(gas)
		qdel(gas)
	if(ngas)
		qdel(ngas)
	..()

/obj/machinery/inlet/buildnodes()

	var/turf/T = get_step(src.loc, src.dir)
	var/fdir = turn(src.p_dir, 180)

	for(var/obj/machinery/M in T)
		if(M.p_dir & fdir)
			src.node = M
			break

	if(node) vnode = node.getline()

	return


/obj/machinery/inlet/get_gas_val(from)
	return TOTAL_MOLES(gas)/2

/obj/machinery/inlet/get_gas(from)
	return gas


/obj/machinery/inlet/gas_flow()

	gas.copy_from(ngas)

/obj/machinery/inlet/process()
	/*
	//if(suffix=="dbgp")
	//	world.log << "VP"
	//	Plasma()

	var/delta_gt

	var/turf/T = src.loc

	// this is the difference between vent and inlet

	if(T && !T.density)
		flow_to_turf(gas, ngas, T, dbg)		// act as gas leak

	if(dbg)	world.log << "I[tag]T2: TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

	if(vnode)

		//if(dbg)	world.log << "V[tag]N1: TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

		delta_gt = FLOWFRAC * ( vnode.get_gas_val(src) - TOTAL_MOLES(gas) / capmult)

		calc_delta( src, gas, ngas, vnode, delta_gt)//, dbg)

		//if(dbg)	world.log << "V[tag]N2: TOTAL_MOLES([gas)] ~ TOTAL_MOLES([ngas)]"

	else
		leak_to_turf()
	*/ //TODO: FIX



/obj/machinery/inlet/proc/leak_to_turf()
// note this is a leak from the node, not the inlet itself
// thus acts as a link between the inlet turf and the turf in step(dir)

	var/turf/T = get_step(src, dir)
	if(T && !T.density)
		flow_to_turf(gas, ngas, T)



// standard proc for all machines - passed gas/ngas as arguments
// equilibrate a pipe object and a turf's gas content

/obj/machinery/proc/flow_to_turf(var/datum/gas_mixture/sgas, var/datum/gas_mixture/sngas, var/turf/T, var/dbg = 0)
/*
	if(dbg) world.log << "FTT: G=[sgas.tostring()] ~ N=[sngas.tostring()]"
	if(dbg) world.log << "T=[T.tostring()]"



	var/t_tot = TOTAL_MOLES(T) * 0.2		// partial pressure of turf gas at pipe, for the moment

	var/delta_gt = FLOWFRAC * ( t_tot - TOTAL_MOLES(sgas) / capmult )

	if(dbg) world.log << "FTT: dgt=[delta_gt]"

	var/datum/gas_mixture/ndelta = new()

	if(delta_gt < 0)	// flow from pipe to turf

		//world.log << "FTT<0"
		ndelta.set_frac(sgas, -delta_gt)		// ndelta contains gas to transfer to turf
		//world.log << "ND=[ndelta.tostring()]"
		sngas.sub_delta(ndelta)			// update new gas to remove the amount transfered
		//world.log << "SN=[sngas.tostring()]"
		ndelta.turf_add(T, -1)		// add all of ndelta to turf
		//world.log << "T=[T.tostring()]"

		//world.log << "LTT: [num2text(-delta_gt,10)] from [sgas.loc] to turf"


	else				// flow from turf to pipe
		if(dbg) world.log << "FTT>0"

		sngas.turf_take(T, delta_gt)		// grab gas from turf and direcly add it to the new gas
		if(dbg) world.log << "SN=[sngas.tostring()]"
		if(dbg) world.log << "T=[T.tostring()]"

		if(dbg) world.log << "LTT: [num2text(delta_gt,10)] from turf to [sgas.loc]"

	T.res_vars()	// update turf gas vars for both cases
*/ //TODO: FIX

// on-off valve

/obj/machinery/valve/mvalve/New()
	..()
	gas1 = new/datum/gas_mixture/(src)
	ngas1 = new/datum/gas_mixture/()
	gas2 = new/datum/gas_mixture/(src)
	ngas2 = new/datum/gas_mixture/()

	gasflowlist += src
	switch(dir)
		if(1, 2)
			p_dir = 3
		if(4,8)
			p_dir = 12

	icon_state = "valve[open]"

/obj/machinery/valve/mvalve/examine()
	return list("[desc] It is [ open? "open" : "closed"].")



/obj/machinery/valve/mvalve/buildnodes()
	var/turf/T = src.loc

	node1 = get_machine(level, T, dir )		// the h/e pipe

	node2 = get_machine(level, T , turn(dir, 180) )	// the regular pipe

	if(node1) vnode1 = node1.getline()
	if(node2) vnode2 = node2.getline()

	return


/obj/machinery/valve/mvalve/gas_flow()
	gas1.copy_from(ngas1)
	gas2.copy_from(ngas2)


/obj/machinery/valve/mvalve/process()
/*	var/delta_gt

	if(vnode1)
		delta_gt = FLOWFRAC * ( vnode1.get_gas_val(src) - TOTAL_MOLES(gas1) / capmult)
		calc_delta( src, gas1, ngas1, vnode1, delta_gt)

	else
		leak_to_turf(1)

	if(vnode2)
		delta_gt = FLOWFRAC * ( vnode2.get_gas_val(src) - TOTAL_MOLES(gas2) / capmult)
		calc_delta( src, gas2, ngas2, vnode2, delta_gt)

	else
		leak_to_turf(2)


	if(open)		// valve operating, so transfer btwen resv1 & 2

		delta_gt = FLOWFRAC * (TOTAL_MOLES(gas1) / capmult - TOTAL_MOLES(gas2) / capmult)

		var/datum/gas_mixture//ndelta = new()

		if(delta_gt < 0)		// then flowing from R2 to R1

			ndelta.set_frac(gas2, -delta_gt)

			ngas2.sub_delta(ndelta)
			ngas1.add_delta(ndelta)

		else				// flowing from R1 to R2
			ndelta.set_frac(gas1, delta_gt)
			ngas2.add_delta(ndelta)
			ngas1.sub_delta(ndelta)*/ //TODO: FIX




/obj/machinery/valve/mvalve/get_gas_val(from)
	if(from == vnode2)
		return TOTAL_MOLES(gas2)/capmult
	else
		return TOTAL_MOLES(gas1)/capmult

/obj/machinery/valve/mvalve/get_gas(from)
	if(from == vnode2)
		return gas2
	return gas1

/obj/machinery/valve/mvalve/proc/leak_to_turf(var/port)

	var/turf/T


	switch(port)
		if(1)
			T = get_step(src, dir)
		if(2)
			T = get_step(src, turn(dir, 180) )

	if(T.density)
		T = src.loc
		if(T.density)
			return

	if(port==1)
		flow_to_turf(gas1, ngas1, T)
	else
		flow_to_turf(gas2, ngas2, T)

/obj/machinery/valve/mvalve/attack_ai(mob/user)
	boutput(user, "<span class='alert'>You are unable to use this as it is physically operated.</span>")
	return

/obj/machinery/valve/mvalve/attack_hand(mob/user)
	..()
	add_fingerprint(user)
	if(status & BROKEN)
		return

	if(!open)		// now opening
		flick("valve01", src)
		icon_state = "valve1"
		sleep(1 SECOND)
	else			// now closing
		flick("valve10", src)
		icon_state = "valve0"
		sleep(1 SECOND)
	open = !open

// Digital Valve

/obj/machinery/valve/dvalve/New()
	..()
	gas1 = new/datum/gas_mixture/(src)
	ngas1 = new/datum/gas_mixture/()
	gas2 = new/datum/gas_mixture/(src)
	ngas2 = new/datum/gas_mixture/()

	gasflowlist += src
	switch(dir)
		if(1, 2)
			p_dir = 3
		if(4,8)
			p_dir = 12

	icon_state = "dvalve[open]"

/obj/machinery/valve/dvalve/examine()
	if(NOPOWER)
		return list("[desc] It is unpowered! It is [ open? "open" : "closed"].")
	return list("[desc] It is [ open? "open" : "closed"].")


/obj/machinery/valve/dvalve/buildnodes()
	var/turf/T = src.loc

	node1 = get_machine(level, T, dir )		// the h/e pipe

	node2 = get_machine(level, T , turn(dir, 180) )	// the regular pipe

	if(node1) vnode1 = node1.getline()
	if(node2) vnode2 = node2.getline()

	return


/obj/machinery/valve/dvalve/gas_flow()
	gas1.copy_from(ngas1)
	gas2.copy_from(ngas2)

/obj/machinery/valve/dvalve/power_change()
	..()
	if(status & NOPOWER)
		icon_state = "dvalve[open]nopower"
		return
	icon_state = "dvalve[open]"


/obj/machinery/valve/dvalve/process()
	/*
	var/delta_gt

	if(vnode1)
		delta_gt = FLOWFRAC * ( vnode1.get_gas_val(src) - TOTAL_MOLES(gas1) / capmult)
		calc_delta( src, gas1, ngas1, vnode1, delta_gt)

	else
		leak_to_turf(1)

	if(vnode2)
		delta_gt = FLOWFRAC * ( vnode2.get_gas_val(src) - TOTAL_MOLES(gas2) / capmult)
		calc_delta( src, gas2, ngas2, vnode2, delta_gt)

	else
		leak_to_turf(2)


	if(open)		// valve operating, so transfer btwen resv1 & 2

		delta_gt = FLOWFRAC * (TOTAL_MOLES(gas1) / capmult - TOTAL_MOLES(gas2) / capmult)

		var/datum/gas_mixture/ndelta = new()

		if(delta_gt < 0)		// then flowing from R2 to R1

			ndelta.set_frac(gas2, -delta_gt)

			ngas2.sub_delta(ndelta)
			ngas1.add_delta(ndelta)

		else				// flowing from R1 to R2
			ndelta.set_frac(gas1, delta_gt)
			ngas2.add_delta(ndelta)
			ngas1.sub_delta(ndelta)
	*/ //TODO: FIX



/obj/machinery/valve/dvalve/get_gas_val(from)
	if(from == vnode2)
		return TOTAL_MOLES(gas2)/capmult
	else
		return TOTAL_MOLES(gas1)/capmult

/obj/machinery/valve/dvalve/get_gas(from)
	if(from == vnode2)
		return gas2
	return gas1

/obj/machinery/valve/dvalve/proc/leak_to_turf(var/port)

	var/turf/T


	switch(port)
		if(1)
			T = get_step(src, dir)
		if(2)
			T = get_step(src, turn(dir, 180) )

	if(T.density)
		T = src.loc
		if(T.density)
			return

	if(port==1)
		flow_to_turf(gas1, ngas1, T)
	else
		flow_to_turf(gas2, ngas2, T)

/obj/machinery/valve/dvalve/attack_ai(var/mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/valve/dvalve/attack_hand(mob/user)
	..()
	add_fingerprint(user)
	if(status & (BROKEN|NOPOWER))
		return

	if(!open)		// now opening
		flick("dvalve01", src)
		icon_state = "dvalve1"
		sleep(1 SECOND)
	else			// now closing
		flick("dvalve10", src)
		icon_state = "dvalve0"
		sleep(1 SECOND)
	open = !open

// one way pipe

/obj/machinery/oneway/New()
	..()
	gas1 = new/datum/gas_mixture/(src)
	ngas1 = new/datum/gas_mixture/()
	gas2 = new/datum/gas_mixture/(src)
	ngas2 = new/datum/gas_mixture/()

	gasflowlist += src
	p_dir = dir|turn(dir, 180)

/obj/machinery/oneway/buildnodes()
	var/turf/T = src.loc

	node1 = get_machine(level, T, dir )
	node2 = get_machine(level, T , turn(dir, 180) )

	if(node1) vnode1 = node1.getline()
	if(node2) vnode2 = node2.getline()

	return

/obj/machinery/oneway/gas_flow()
	gas1.copy_from(ngas1)
	gas2.copy_from(ngas2)

/obj/machinery/oneway/process()
/*
	var/delta_gt

	if(vnode1)
		delta_gt = FLOWFRAC * ( vnode1.get_gas_val(src) - TOTAL_MOLES(gas1) / capmult)
		calc_delta( src, gas1, ngas1, vnode1, delta_gt)

	else
		leak_to_turf(1)

	if(vnode2)
		delta_gt = FLOWFRAC * ( vnode2.get_gas_val(src) - TOTAL_MOLES(gas2) / capmult)
		calc_delta( src, gas2, ngas2, vnode2, delta_gt)

	else
		leak_to_turf(2)


	delta_gt = FLOWFRAC * (TOTAL_MOLES(gas1) / capmult - TOTAL_MOLES(gas2) / capmult)
	var/datum/gas_mixture/ndelta = new()

	if(delta_gt < 0)		// then flowing from R2 to R1
		ndelta.set_frac(gas2, -delta_gt)
		ngas2.sub_delta(ndelta)
		ngas1.add_delta(ndelta)*/ //TODO: FIX

/obj/machinery/oneway/get_gas_val(from)
	if(from == vnode2)
		return TOTAL_MOLES(gas2)/capmult
	else
		return TOTAL_MOLES(gas1)/capmult

/obj/machinery/oneway/get_gas(from)
	if(from == vnode2)
		return gas2
	return gas1

/obj/machinery/oneway/proc/leak_to_turf(var/port)
	var/turf/T

	switch(port)
		if(1)
			T = get_step(src, dir)
		if(2)
			T = get_step(src, turn(dir, 180) )

	if(T.density)
		T = src.loc
		if(T.density)
			return

	if(port==1)
		flow_to_turf(gas1, ngas1, T)
	else
		flow_to_turf(gas2, ngas2, T)

/obj/machinery/oneway/pipepump/process()
	/*
	if(! (status & NOPOWER) )  // pump if power
		gas1.transfer_from(gas2, rate)
		use_power(25, ENVIRON)
		ngas1.copy_from(gas1)
		ngas2.copy_from(gas2)

	var/delta_gt

	if(vnode1)
		delta_gt = FLOWFRAC * ( vnode1.get_gas_val(src) - TOTAL_MOLES(gas1) / capmult)
		calc_delta( src, gas1, ngas1, vnode1, delta_gt)

	else
		leak_to_turf(1)

	if(vnode2)
		delta_gt = FLOWFRAC * ( vnode2.get_gas_val(src) - TOTAL_MOLES(gas2) / capmult)
		calc_delta( src, gas2, ngas2, vnode2, delta_gt)

	else
		leak_to_turf(2)
	*/ //TODO: FIX

/obj/machinery/oneway/pipepump/UpdateIcon()
	icon_state = "pipepump-[(status & NOPOWER) ? "stop" : "run"]"

/obj/machinery/oneway/pipepump/power_change()
	if(powered(ENVIRON))
		status &= ~NOPOWER
	else

		status |= NOPOWER
	SPAWN(rand(1,15))	// So they don't all turn off at the same time
		UpdateIcon()

// Filter inlet
// works with filter_control

/obj/machinery/inlet/filter
	machine_registry_idx = MACHINES_INLETS

/obj/machinery/inlet/filter/New()
	..()
	gas = new /datum/gas_mixture
	ngas = new /datum/gas_mixture

/obj/machinery/inlet/filter/disposing()
	if(gas)
		qdel(gas)
	if(ngas)
		qdel(ngas)
	..()

/obj/machinery/inlet/filter/buildnodes()
	var/turf/T = get_step(src.loc, src.dir)
	var/fdir = turn(src.p_dir, 180)

	for(var/obj/machinery/M in T)
		if(M.p_dir & fdir)
			src.node = M
			break

	if(node) vnode = node.getline()
	return

/obj/machinery/inlet/filter/get_gas_val(from)
	return TOTAL_MOLES(gas)/2

/obj/machinery/inlet/filter/get_gas(from)
	return gas

/obj/machinery/inlet/filter/gas_flow()
	gas.copy_from(ngas)

/obj/machinery/inlet/filter/process()
	src.UpdateIcon()
	if(!(status & NOPOWER))
	/*	var/turf/T = src.loc
		if(!T || T.density)	return

		if(!vnode)	return leak_to_turf()
		var/obj/substance/gas/exterior = new()
		exterior.oxygen = T.oxygen
		exterior.n2 = T.n2
		exterior.plasma = T.poison
		exterior.co2 = T.co2
		exterior.sl_gas = T.sl_gas
		exterior.temperature = T.temp
		var/obj/substance/gas/interior = gas
		var/obj/substance/gas/flowing = new()

		var/flow_rate = (TOTAL_MOLES(exterior)-TOTAL_MOLES(interior))*FLOWFRAC
		if(flow_rate <= 0)
			return
		flowing.set_frac(exterior,flow_rate)
		if(!(src.f_mask & GAS_O2))	flowing.oxygen	= 0
		if(!(src.f_mask & GAS_N2))	flowing.n2		= 0
		if(!(src.f_mask & GAS_PL))	flowing.plasma	= 0
		if(!(src.f_mask & GAS_CO2))	flowing.co2		= 0
		if(!(src.f_mask & GAS_N2O))	flowing.sl_gas	= 0
		use_power(5,ENVIRON)
		exterior.sub_delta(flowing)
		interior.add_delta(flowing)*/ //TODO: FIX
	else
		..()
	return

/obj/machinery/inlet/filter/leak_to_turf()
// note this is a leak from the node, not the inlet itself
// thus acts as a link between the inlet turf and the turf in step(dir)
	var/turf/T = get_step(src, dir)
	if(T && !T.density)
		flow_to_turf(gas, ngas, T)

/obj/machinery/inlet/filter/power_change()
	if(powered(ENVIRON))
		status &= ~NOPOWER
	else
		status |= NOPOWER
	SPAWN(rand(1,15))
		UpdateIcon()
	return

/obj/machinery/inlet/filter/UpdateIcon()
	/*
	if(status & NOPOWER)
		icon_state = "inlet_filter-0"
		return
	if(TOTAL_MOLES(src.gas) > src.gas.maximum/2)
		icon_state = "inlet_filter-4"
	else if(TOTAL_MOLES(src.gas) > src.gas.maximum/3)
		icon_state = "inlet_filter-3"
	else if(TOTAL_MOLES(src.gas) > src.gas.maximum/4)
		icon_state = "inlet_filter-2"
	else if(TOTAL_MOLES(src.gas) >= 1 || src.f_mask >= 1)
		icon_state = "inlet_filter-1"
	else
		icon_state = "inlet_filter-0"
	return
	*/ //TODO FIX

// Filter vent
// doesn't do anything yet

/obj/machinery/vent/filter/power_change()
	if(powered(ENVIRON))
		status &= ~NOPOWER
	else
		status |= NOPOWER
	SPAWN(rand(1,15))
		UpdateIcon()
	return

/obj/machinery/vent/filter/UpdateIcon()
	/*
	if(status & NOPOWER)
		icon_state = "vent_filter-0"
		return
	if(TOTAL_MOLES(src.gas) > src.gas.maximum/2)
		icon_state = "vent_filter-4"
	else if(TOTAL_MOLES(src.gas) > src.gas.maximum/3)
		icon_state = "vent_filter-3"
	else if(TOTAL_MOLES(src.gas) > src.gas.maximum/4)
		icon_state = "vent_filter-2"
	else if(TOTAL_MOLES(src.gas) >= 1 || src.f_mask >= 1)
		icon_state = "vent_filter-1"
	else
		icon_state = "vent_filter-0"
	return
	*/ //TODO FIX
