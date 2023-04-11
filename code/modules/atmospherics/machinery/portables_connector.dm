/obj/machinery/atmospherics/portables_connector
	icon = 'icons/obj/atmospherics/portables_connector.dmi'
	icon_state = "intact"
	name = "Connector Port"
	desc = "For connecting portables devices related to atmospherics control."
	plane = PLANE_NOSHADOW_BELOW
	var/obj/machinery/portable_atmospherics/connected_device
	var/obj/machinery/atmospherics/node
	var/datum/pipe_network/network
	var/on = FALSE
	level = 0
	layer = PIPE_LAYER

/obj/machinery/atmospherics/portables_connector/New()
	initialize_directions = dir
	..()

/obj/machinery/atmospherics/portables_connector/network_disposing(datum/pipe_network/reference)
	if (network == reference)
		network = null

/obj/machinery/atmospherics/portables_connector/update_icon()
	if(node)
		icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
		set_dir(get_dir(src, node))
	else
		icon_state = "exposed"

/obj/machinery/atmospherics/portables_connector/hide(var/i) //to make the little pipe section invisible, the icon changes.
	if(node)
		icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
		set_dir(get_dir(src, node))
	else
		icon_state = "exposed"

/obj/machinery/atmospherics/portables_connector/process()
	..()
	if(!on)
		return
	if(!connected_device)
		on = FALSE
		return
	network?.update = TRUE
	return TRUE

// Housekeeping and pipe network stuff below
/obj/machinery/atmospherics/portables_connector/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node)
		network = new_network

	if(src in new_network.normal_members)
		return FALSE

	new_network.normal_members += src

/obj/machinery/atmospherics/portables_connector/disposing()
	connected_device?.disconnect()

	if(node)
		node.disconnect(src)
		if (network)
			network.dispose()
			network = null

	node = null

	..()

/obj/machinery/atmospherics/portables_connector/initialize()
	if(node) return

	var/node_connect = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break

	UpdateIcon()

/obj/machinery/atmospherics/portables_connector/build_network()
	if(!network && node)
		network = new /datum/pipe_network()
		network.normal_members += src
		network.build_network(node, src)


/obj/machinery/atmospherics/portables_connector/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node)
		return network

	if(reference==connected_device)
		return network

/obj/machinery/atmospherics/portables_connector/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network == old_network)
		network = new_network

	return TRUE

/obj/machinery/atmospherics/portables_connector/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(connected_device)
		results += connected_device.air_contents

	return results

/obj/machinery/atmospherics/portables_connector/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node)
		if (network)
			if(connected_device)
				network.air_disposing_hook(connected_device.air_contents)
			network.dispose()
			network = null
		node = null
