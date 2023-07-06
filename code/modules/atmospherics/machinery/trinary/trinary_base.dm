/obj/machinery/atmospherics/trinary
	var/datum/gas_mixture/air1
	var/datum/gas_mixture/air2
	var/datum/gas_mixture/air3

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

	var/datum/pipe_network/network1
	var/datum/pipe_network/network2
	var/datum/pipe_network/network3

	/// Are our inputs flipped around?
	var/flipped = FALSE

/obj/machinery/atmospherics/trinary/New()
	..()
	switch(dir)
		if(NORTH)
			if(flipped)
				initialize_directions = NORTH|WEST|SOUTH
			else
				initialize_directions = NORTH|EAST|SOUTH
		if(EAST)
			if(flipped)
				initialize_directions = EAST|NORTH|WEST
			else
				initialize_directions = EAST|SOUTH|WEST
		if(SOUTH)
			if(flipped)
				initialize_directions = SOUTH|EAST|NORTH
			else
				initialize_directions = SOUTH|WEST|NORTH
		if(WEST)
			if(flipped)
				initialize_directions = WEST|SOUTH|EAST
			else
				initialize_directions = WEST|NORTH|EAST

	air1 = new /datum/gas_mixture
	air2 = new /datum/gas_mixture
	air3 = new /datum/gas_mixture

	air1.volume = 200
	air2.volume = 200
	air3.volume = 200

/obj/machinery/atmospherics/trinary/initialize()
	var/node3_connect = dir
	var/node1_connect = flipped ? turn(dir, 90) : turn(dir, -90)
	var/node2_connect = turn(dir, -180)

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			node2 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node3_connect))
		if(target.initialize_directions & get_dir(target,src))
			node3 = target
			break

	UpdateIcon()

/obj/machinery/atmospherics/trinary/disposing()
	if (network1)
		network1.air_disposing_hook(air1, air2, air3)
	if (network2)
		network2.air_disposing_hook(air1, air2, air3)
	if (network3)
		network3.air_disposing_hook(air1, air2, air3)

	if(node1)
		node1.disconnect(src)
		if (network1)
			network1.dispose()

	if(node2)
		node2.disconnect(src)
		if (network2)
			network2.dispose()

	if(node3)
		node3.disconnect(src)
		if (network3)
			network3.dispose()

	node1 = null
	node2 = null
	node3 = null
	network1 = null
	network2 = null
	network3 = null

	if(air1)
		qdel(air1)
	if(air2)
		qdel(air2)
	if(air3)
		qdel(air3)

	air1 = null
	air2 = null
	air3 = null
	..()

/obj/machinery/atmospherics/trinary/build_network()
	if(!network1 && node1)
		network1 = new /datum/pipe_network()
		network1.normal_members += src
		network1.build_network(node1, src)

	if(!network2 && node2)
		network2 = new /datum/pipe_network()
		network2.normal_members += src
		network2.build_network(node2, src)

	if(!network3 && node3)
		network3 = new /datum/pipe_network()
		network3.normal_members += src
		network3.build_network(node3, src)

/obj/machinery/atmospherics/trinary/return_network(obj/machinery/atmospherics/reference)
	src.build_network()

	if(reference==node1)
		return network1

	if(reference==node2)
		return network2

	if(reference==node3)
		return network3

/obj/machinery/atmospherics/trinary/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network1 == old_network)
		network1 = new_network

	if(network2 == old_network)
		network2 = new_network

	if(network3 == old_network)
		network3 = new_network

	return TRUE

/obj/machinery/atmospherics/trinary/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(network1 == reference)
		results += air1

	if(network2 == reference)
		results += air2

	if(network3 == reference)
		results += air3

	return results

/obj/machinery/atmospherics/trinary/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node1)
		if (network1)
			network1.dispose()
			network1 = null
		node1 = null

	else if(reference==node2)
		if (network2)
			network2.dispose()
			network2 = null
		node2 = null

	else if(reference==node3)
		if (network3)
			network3.dispose()
			network3 = null
		node3 = null

/obj/machinery/atmospherics/trinary/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network1 = new_network

	else if(reference == node2)
		network2 = new_network

	else if(reference == node3)
		network3 = new_network

	if(src in new_network.normal_members)
		return FALSE

	new_network.normal_members += src

/obj/machinery/atmospherics/trinary/network_disposing(datum/pipe_network/reference)
	if (network1 == reference)
		network1 = null
	if (network2 == reference)
		network2 = null
	if (network3 == reference)
		network3 = null
