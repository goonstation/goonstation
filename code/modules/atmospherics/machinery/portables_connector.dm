/obj/machinery/atmospherics/portables_connector
	icon = 'icons/obj/atmospherics/portables_connector.dmi'
	icon_state = "intact"
	name = "Connector Port"
	desc = "For connecting portables devices related to atmospherics control."
	dir = SOUTH
	initialize_directions = SOUTH
	plane = PLANE_NOSHADOW_BELOW
	var/obj/machinery/portable_atmospherics/connected_device
	var/obj/machinery/atmospherics/node
	var/datum/pipe_network/network
	var/on = 0
	level = 0
	layer = PIPE_LAYER

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	New()
		initialize_directions = dir
		..()

	network_disposing(datum/pipe_network/reference)
		if (network == reference)
			network = null

	update_icon()
		if(node)
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
			set_dir(get_dir(src, node))
		else
			icon_state = "exposed"

		return

	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(node)
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
			set_dir(get_dir(src, node))
		else
			icon_state = "exposed"

	process()
		..()
		if(!on)
			return
		if(!connected_device)
			on = 0
			return
		network?.update = 1
		return 1

// Housekeeping and pipe network stuff below
	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(reference == node)
			network = new_network

		if(new_network.normal_members.Find(src))
			return 0

		new_network.normal_members += src

		return null

	disposing()

		connected_device?.disconnect()

		if(node)
			node.disconnect(src)
			if (network)
				network.dispose()
				network = null

		node = null

		..()

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

		if(reference==connected_device)
			return network

		return null

	reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
		if(network == old_network)
			network = new_network

		return 1

	return_network_air(datum/pipe_network/reference)
		var/list/results = list()

		if(connected_device)
			results += connected_device.air_contents

		return results

	disconnect(obj/machinery/atmospherics/reference)
		if(reference==node)
			if (network)
				if(connected_device)
					network.air_disposing_hook(connected_device.air_contents)
				network.dispose()
				network = null
			node = null

		return null
