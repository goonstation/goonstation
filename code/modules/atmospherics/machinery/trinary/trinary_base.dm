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
	switch(src.dir)
		if(NORTH)
			if(src.flipped)
				src.initialize_directions = NORTH|WEST|SOUTH
			else
				src.initialize_directions = NORTH|EAST|SOUTH
		if(EAST)
			if(src.flipped)
				src.initialize_directions = EAST|NORTH|WEST
			else
				src.initialize_directions = EAST|SOUTH|WEST
		if(SOUTH)
			if(src.flipped)
				src.initialize_directions = SOUTH|EAST|NORTH
			else
				src.initialize_directions = SOUTH|WEST|NORTH
		if(WEST)
			if(src.flipped)
				src.initialize_directions = WEST|SOUTH|EAST
			else
				src.initialize_directions = WEST|NORTH|EAST

	src.air1 = new /datum/gas_mixture
	src.air2 = new /datum/gas_mixture
	src.air3 = new /datum/gas_mixture

	src.air1.volume = 200
	src.air2.volume = 200
	src.air3.volume = 200

/obj/machinery/atmospherics/trinary/initialize(player_caused_init)
	var/node1_connect = turn(src.dir, -180)
	var/node2_connect = flipped ? turn(src.dir, 90) : turn(src.dir, -90)
	var/node3_connect = src.dir

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node2 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node3_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			src.node3 = target
			break
	if(player_caused_init)
		src.node1?.initialize(FALSE)
		src.node2?.initialize(FALSE)
		src.node3?.initialize(FALSE)
	UpdateIcon()

/obj/machinery/atmospherics/trinary/disposing()
	src.network1?.air_disposing_hook(src.air1, src.air2, src.air3)
	src.network2?.air_disposing_hook(src.air1, src.air2, src.air3)
	src.network3?.air_disposing_hook(src.air1, src.air2, src.air3)

	src.node1?.disconnect(src)
	src.network1?.dispose()

	src.node2?.disconnect(src)
	src.network2?.dispose()

	src.node3?.disconnect(src)
	src.network3?.dispose()

	src.node1 = null
	src.node2 = null
	src.node3 = null
	src.network1 = null
	src.network2 = null
	src.network3 = null

	if(src.air1)
		qdel(src.air1)
	if(src.air2)
		qdel(src.air2)
	if(src.air3)
		qdel(src.air3)

	src.air1 = null
	src.air2 = null
	src.air3 = null
	..()

/obj/machinery/atmospherics/trinary/build_network()
	if(!src.network1 && src.node1)
		src.network1 = new /datum/pipe_network()
		src.network1.normal_members += src
		src.network1.build_network(src.node1, src)

	if(!src.network2 && src.node2)
		src.network2 = new /datum/pipe_network()
		src.network2.normal_members += src
		src.network2.build_network(src.node2, src)

	if(!src.network3 && src.node3)
		src.network3 = new /datum/pipe_network()
		src.network3.normal_members += src
		src.network3.build_network(src.node3, src)

/obj/machinery/atmospherics/trinary/return_network(obj/machinery/atmospherics/reference)
	src.build_network()

	if(reference==src.node1)
		return src.network1

	if(reference==src.node2)
		return src.network2

	if(reference==src.node3)
		return src.network3

/obj/machinery/atmospherics/trinary/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(src.network1 == old_network)
		src.network1 = new_network

	if(src.network2 == old_network)
		src.network2 = new_network

	if(src.network3 == old_network)
		src.network3 = new_network

	return TRUE

/obj/machinery/atmospherics/trinary/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(src.network1 == reference)
		results += src.air1

	if(src.network2 == reference)
		results += src.air2

	if(src.network3 == reference)
		results += src.air3

	return results

/obj/machinery/atmospherics/trinary/disconnect(obj/machinery/atmospherics/reference)
	if(reference==src.node1)
		if (src.network1)
			src.network1.dispose()
			src.network1 = null
		src.node1 = null

	else if(reference==src.node2)
		if (src.network2)
			src.network2.dispose()
			src.network2 = null
		src.node2 = null

	else if(reference==src.node3)
		if (src.network3)
			src.network3.dispose()
			src.network3 = null
		src.node3 = null
	UpdateIcon()

/obj/machinery/atmospherics/trinary/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == src.node1)
		src.network1 = new_network

	else if(reference == src.node2)
		src.network2 = new_network

	else if(reference == src.node3)
		src.network3 = new_network

	if(src in new_network.normal_members)
		return FALSE

	new_network.normal_members += src

/obj/machinery/atmospherics/trinary/network_disposing(datum/pipe_network/reference)
	if (src.network1 == reference)
		src.network1 = null
	if (src.network2 == reference)
		src.network2 = null
	if (src.network3 == reference)
		src.network3 = null
