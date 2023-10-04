//TODO: Repath to unary
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
	layer = PIPE_LAYER

/obj/machinery/atmospherics/portables_connector/New()
	..()
	initialize_directions = dir

/obj/machinery/atmospherics/portables_connector/network_disposing(datum/pipe_network/reference)
	if (network == reference)
		network = null

/obj/machinery/atmospherics/portables_connector/update_icon()
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/atmospherics/portables_connector/hide(var/intact) //to make the little pipe section invisible, the icon changes.
	if(src.node)
		icon_state = "[intact && issimulatedturf(src.loc) && src.level == UNDERFLOOR ? "h" : "" ]intact"
	else
		icon_state = "exposed"

/obj/machinery/atmospherics/portables_connector/process()
	..()
	if(!src.on)
		return

	if(!src.connected_device)
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
	node?.disconnect(src)
	network?.dispose()
	network = null
	node = null

	..()

/obj/machinery/atmospherics/portables_connector/initialize()
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

	if(reference == src.node)
		return network

	if(reference == src.connected_device)
		return network

/obj/machinery/atmospherics/portables_connector/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network == old_network)
		network = new_network

	return TRUE

/obj/machinery/atmospherics/portables_connector/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(src.connected_device)
		results += connected_device.air_contents

	return results

/obj/machinery/atmospherics/portables_connector/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node)
		if (src.network)
			if(src.connected_device)
				src.network.air_disposing_hook(src.connected_device.air_contents)
			src.network.dispose()
			src.network = null
		src.node = null
