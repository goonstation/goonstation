/obj/machinery/atmospherics/unary

	var/datum/gas_mixture/air_contents

	var/obj/machinery/atmospherics/node

	var/datum/pipe_network/network

	New()
		..()
		initialize_directions = dir
		air_contents = new /datum/gas_mixture

		air_contents.volume = 200

	disposing()
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
//
// Housekeeping and pipe network stuff below
	network_disposing(datum/pipe_network/reference)
		if (network == reference)
			network = null

	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(reference == node)
			network = new_network

		if(new_network.normal_members.Find(src))
			return 0

		new_network.normal_members += src

		return null

	initialize()
		if(node) return

		var/node_connect = dir

		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break

		UpdateIcon()

	build_network()
		if(!network && node)
			network = new /datum/pipe_network()
			network.normal_members += src
			network.build_network(node, src)


	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if(reference==node)
			return network

		return null

	reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
		if(network == old_network)
			network = new_network

		return 1

	return_network_air(datum/pipe_network/reference)
		var/list/results = list()

		if(network == reference)
			results += air_contents

		return results

	disconnect(obj/machinery/atmospherics/reference)
		if(reference==node)
			if (network)
				network.dispose()
				network = null
			node = null

		return null

/obj/machinery/atmospherics/unary/pipeline_expansion()
	return list(node)
