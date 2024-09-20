
/obj/machinery/atmospherics/trinary/manifold_valve
	name = "manifold valve"
	desc = "A pipe valve"
	icon = 'icons/obj/atmospherics/manifold_valve.dmi'
	icon_state = "manifold_valve0-map"
	/// Diverts gas flow into the middle node.
	var/divert = FALSE
	/// What frequency we are listening on.
	var/frequency = FREQ_AIR_ALARM_CONTROL
	/// What label is used to contact us on packets?
	var/id = null

/obj/machinery/atmospherics/trinary/manifold_valve/New()
	..()
	qdel(src.air1)
	src.air1 = null
	qdel(src.air2)
	src.air2 = null
	qdel(src.air3)
	src.air3 = null
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, null, src.frequency)

/obj/machinery/atmospherics/trinary/manifold_valve/update_icon(animation)
	if(animation)
		flick("valve[src.divert][!src.divert]",src)
		playsound(src.loc, 'sound/effects/valve_creak.ogg', 50, 1)
	else
		src.icon_state = "manifold_valve[src.divert]"

	SET_PIPE_UNDERLAY(src.node1, turn(src.dir, -180), "medium", issimplepipe(src.node1) ?  src.node1.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node2, src.flipped ? turn(src.dir, 90) : turn(src.dir, -90), "medium", issimplepipe(src.node2) ?  src.node2.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node3, src.dir, "medium", issimplepipe(src.node3) ?  src.node3.color : null, FALSE)

/obj/machinery/atmospherics/trinary/manifold_valve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == src.node1)
		src.network1 = new_network
		if(!src.divert)
			src.network3 = new_network
		else
			src.network2 = new_network
	else if(reference == src.node2)
		src.network2 = new_network
		if(src.divert)
			src.network1 = new_network
	else if(reference == src.node3)
		src.network3 = new_network
		if(!src.divert)
			src.network1 = new_network

	if(src in new_network.normal_members)
		return FALSE

	new_network.normal_members += src

	if(!src.divert)
		if(reference == src.node1)
			if(!isnull(src.node3))
				return src.node3.network_expand(new_network, src)
		else if(reference == src.node3)
			if(!isnull(src.node1))
				return src.node1.network_expand(new_network, src)
	else
		if(reference == src.node1)
			return src.node2.network_expand(new_network, src)
		else if(reference == src.node2)
			return src.node1.network_expand(new_network, src)

/// Divert gas flow from node3 to node2.
/obj/machinery/atmospherics/trinary/manifold_valve/proc/divert()
	if(src.divert)
		return FALSE

	src.divert = TRUE
	UpdateIcon()

	src.network1?.dispose()
	src.network1 = null

	src.build_network()

	if(src.network1&&src.network2)
		src.network1.merge(src.network2)
		src.network2 = src.network1

	if(src.network1)
		src.network1.update = TRUE
	else if(src.network2)
		src.network2.update = TRUE

	return TRUE

/// Divert gas flow from node2 back to node3.
/obj/machinery/atmospherics/trinary/manifold_valve/proc/undivert()
	if(!src.divert)
		return FALSE

	src.divert = FALSE
	UpdateIcon()

	src.network2?.dispose()
	src.network2 = null

	build_network()

	if(src.network1&&src.network3)
		src.network3.merge(src.network1)
		src.network1 = src.network3

	if(src.network1)
		src.network1.update = TRUE
	else if(src.network3)
		src.network3.update = TRUE

	return TRUE

/obj/machinery/atmospherics/trinary/manifold_valve/process()
	..()

	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.data["tag"] = src.id
	signal.data["timestamp"] = air_master.current_cycle
	signal.data["valve_diverting"] = src.divert
	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

/obj/machinery/atmospherics/trinary/manifold_valve/return_network_air(datum/pipe_network/reference)
	return null

/obj/machinery/atmospherics/trinary/manifold_valve/receive_signal(datum/signal/signal)
	if(signal.data["tag"] && (signal.data["tag"] != src.id))
		return FALSE

	switch(signal.data["command"])
		if("valve_divert")
			if(!src.divert)
				src.divert()

		if("valve_undivert")
			if(src.divert)
				src.undivert()

		if("valve_toggle")
			if(divert)
				src.undivert()
			else
				src.divert()

/obj/machinery/atmospherics/trinary/manifold_valve/diverted
	icon_state = "manifold_valve1-map"
	divert = TRUE
