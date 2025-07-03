/obj/machinery/atmospherics/binary
	var/datum/gas_mixture/air1
	var/datum/gas_mixture/air2

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2

	var/datum/pipe_network/network1
	var/datum/pipe_network/network2

/obj/machinery/atmospherics/binary/New()
	..()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

	air1 = new /datum/gas_mixture
	air2 = new /datum/gas_mixture

	air1.volume = 200
	air2.volume = 200

// Housekeeping and pipe network stuff below
/obj/machinery/atmospherics/binary/network_disposing(datum/pipe_network/reference)
	if (network1 == reference)
		network1 = null
	if (network2 == reference)
		network2 = null

/obj/machinery/atmospherics/binary/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network1 = new_network

	else if(reference == node2)
		network2 = new_network

	if(src in new_network.normal_members)
		return FALSE

	new_network.normal_members += src

/obj/machinery/atmospherics/binary/disposing()
	// Signal air disposing...
	if (network1)
		network1.air_disposing_hook(air1,air2)
	if (network2)
		network2.air_disposing_hook(air1,air2)

	if(node1)
		node1.disconnect(src)
		if (network1)
			network1.dispose()
	if(node2)
		node2.disconnect(src)
		if (network2)
			network2.dispose()

	node1 = null
	node2 = null
	network1 = null
	network2 = null

	if(air1)
		qdel(air1)

	if(air2)
		qdel(air2)

	air1 = null
	air2 = null

	..()

/obj/machinery/atmospherics/binary/initialize(player_caused_init)
	if(node1 && node2) return

	var/node2_connect = dir
	var/node1_connect = turn(dir, 180)

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			node2 = target
			break
	if(player_caused_init)
		src.node1?.initialize(FALSE)
		src.node2?.initialize(FALSE)
	UpdateIcon()

/obj/machinery/atmospherics/binary/build_network()
	if(!network1 && node1)
		network1 = new /datum/pipe_network()
		network1.normal_members += src
		network1.build_network(node1, src)

	if(!network2 && node2)
		network2 = new /datum/pipe_network()
		network2.normal_members += src
		network2.build_network(node2, src)

/obj/machinery/atmospherics/binary/return_network(obj/machinery/atmospherics/reference)
	src.build_network()

	if(reference==node1)
		return network1

	if(reference==node2)
		return network2

/obj/machinery/atmospherics/binary/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network1 == old_network)
		network1 = new_network
	if(network2 == old_network)
		network2 = new_network

	return TRUE

/obj/machinery/atmospherics/binary/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(network1 == reference)
		results += air1
	if(network2 == reference)
		results += air2

	return results

/obj/machinery/atmospherics/binary/disconnect(obj/machinery/atmospherics/reference)
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
	UpdateIcon()
