/obj/machinery/atmospherics/unary/portables_connector
	icon = 'icons/obj/atmospherics/portables_connector.dmi'
	icon_state = "intact"
	name = "Connector Port"
	desc = "For connecting portables devices related to atmospherics control."
	plane = PLANE_NOSHADOW_BELOW
	layer = PIPE_LAYER

	var/obj/machinery/portable_atmospherics/connected_device
	var/being_used = FALSE

/obj/machinery/atmospherics/unary/portables_connector/New()
	..()
	src.air_contents = null

/obj/machinery/atmospherics/unary/portables_connector/update_icon()
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/atmospherics/unary/portables_connector/hide(var/intact) //to make the little pipe section invisible, the icon changes.
	if(src.node)
		icon_state = "[src.level == UNDERFLOOR && intact == TRUE && issimulatedturf(loc) ? "h" : "" ]intact"
	else
		icon_state = "exposed"

/obj/machinery/atmospherics/unary/portables_connector/process()
	..()
	if(!src.being_used)
		return
	if(!src.connected_device)
		src.being_used = FALSE
		return
	network?.update = TRUE
	return TRUE

/obj/machinery/atmospherics/unary/portables_connector/disposing()
	connected_device?.disconnect()
	..()

/obj/machinery/atmospherics/unary/portables_connector/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node)
		return network

	if(reference==connected_device)
		return network

/obj/machinery/atmospherics/unary/portables_connector/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(src.connected_device)
		results += src.connected_device.air_contents

	return results

/obj/machinery/atmospherics/unary/portables_connector/disconnect(obj/machinery/atmospherics/reference)
	if(reference == src.node)
		src.network?.air_disposing_hook(src.connected_device.air_contents)
		src.network?.dispose()
		src.network = null
		src.node = null
