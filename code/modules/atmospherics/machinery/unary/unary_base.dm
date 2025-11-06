/obj/machinery/atmospherics/unary
	/// Our sweet sweet air.
	var/datum/gas_mixture/air_contents
	/// Our sole connection to other atmospheric devices.
	var/obj/machinery/atmospherics/node
	/// The pipe network we belong to.
	var/datum/pipe_network/network
	exclusionary = TRUE

/obj/machinery/atmospherics/unary/New()
	..()
	initialize_directions = dir
	air_contents = new /datum/gas_mixture

	air_contents.volume = 200

/obj/machinery/atmospherics/unary/disposing()
	node?.disconnect(src)
	node = null
	network?.dispose()
	network = null

	qdel(air_contents)
	air_contents = null
	..()

// Housekeeping and pipe network stuff below
/obj/machinery/atmospherics/unary/network_disposing(datum/pipe_network/reference)
	if (network == reference)
		network = null

/obj/machinery/atmospherics/unary/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node)
		network = new_network

	if(src in new_network.normal_members)
		return FALSE

	new_network.normal_members += src

/obj/machinery/atmospherics/unary/initialize(player_caused_init)
	var/node_connect = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(src.cant_connect(target, get_dir(target,src)) || target.cant_connect(src, get_dir(src,target)))
				continue
			node = target
			break
	if(player_caused_init)
		src.node?.initialize(FALSE)
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
	var/list/results = null

	if(network == reference)
		results = list(air_contents)

	return results

/obj/machinery/atmospherics/unary/return_air(direct = FALSE)
	return air_contents

/obj/machinery/atmospherics/unary/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node)
		network?.dispose()
		network = null
		node = null
	UpdateIcon()
