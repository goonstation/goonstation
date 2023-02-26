/obj/machinery/atmospherics/unary
	var/datum/gas_mixture/air_contents
	var/obj/machinery/atmospherics/node
	var/datum/pipe_network/network

/obj/machinery/atmospherics/unary/New()
	..()
	initialize_directions = dir
	air_contents = new /datum/gas_mixture

	air_contents.volume = 200

/obj/machinery/atmospherics/unary/disposing()
	if(node)
		node.disconnect(src)
		if (network)
			network.dispose()

	if(air_contents)
		qdel(air_contents)
		air_contents = null

	node = null
	network = null
	..()

// Housekeeping and pipe network stuff below
/obj/machinery/atmospherics/unary/network_disposing(datum/pipe_network/reference)
	if (network == reference)
		network = null

/obj/machinery/atmospherics/unary/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node)
		network = new_network

	if(new_network.normal_members.Find(src))
		return FALSE

	new_network.normal_members += src

	return null

/obj/machinery/atmospherics/unary/initialize()
	if(node) return

	var/node_connect = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break

	UpdateIcon()

/obj/machinery/atmospherics/unary/build_network()
	if(!network && node)
		network = new /datum/pipe_network()
		network.normal_members += src
		network.build_network(node, src)


/obj/machinery/atmospherics/unary/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node)
		return network

/obj/machinery/atmospherics/unary/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network == old_network)
		network = new_network

	return TRUE

/obj/machinery/atmospherics/unary/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(network == reference)
		results += air_contents

	return results

/obj/machinery/atmospherics/unary/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node)
		if (network)
			network.dispose()
			network = null
		node = null
