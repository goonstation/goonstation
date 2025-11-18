/obj/machinery/atmospherics/unary/portables_connector
	icon = 'icons/obj/atmospherics/portables_connector.dmi'
	icon_state = "connector-map"
	name = "Connector Port"
	desc = "For connecting portables devices related to atmospherics control."

	plane = PLANE_NOSHADOW_BELOW
	var/obj/machinery/portable_atmospherics/connected_device
	layer = PIPE_LAYER

/obj/machinery/atmospherics/unary/portables_connector/update_icon()
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/atmospherics/unary/portables_connector/hide(var/intact) //to make the little pipe section invisible, the icon changes.
	var/hide_pipe = CHECKHIDEPIPE(src)
	icon_state = "[hide_pipe ? "h" : "" ]connector"
	update_pipe_underlay(src.node, src.dir, "medium", hide_pipe)

/obj/machinery/atmospherics/unary/portables_connector/process()
	..()
	if(!src.connected_device)
		return

	network?.update = TRUE
	return TRUE

/obj/machinery/atmospherics/unary/portables_connector/disposing()
	connected_device?.disconnect()
	..()

/obj/machinery/atmospherics/unary/portables_connector/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference == src.node)
		return network

	if(reference == src.connected_device)
		return network

/obj/machinery/atmospherics/unary/portables_connector/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(src.connected_device)
		results += connected_device.air_contents

	return results

/obj/machinery/atmospherics/unary/portables_connector/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node)
		if (src.network)
			if(src.connected_device)
				src.network.air_disposing_hook(src.connected_device.air_contents)
			src.network.dispose()
			src.network = null
		src.node = null
