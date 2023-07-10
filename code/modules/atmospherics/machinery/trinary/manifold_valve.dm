
/obj/machinery/atmospherics/trinary/manifold_valve
	icon = 'icons/obj/atmospherics/manifold_valve.dmi'
	icon_state = "manifold_valve0"

	name = "manifold valve"
	desc = "A pipe valve"

	var/divert = FALSE

	var/frequency = FREQ_AIR_ALARM_CONTROL
	var/id = null

/obj/machinery/atmospherics/trinary/manifold_valve/New()
	..()
	qdel(src.air1)
	src.air1 = null
	qdel(src.air2)
	src.air2 = null
	qdel(src.air3)
	src.air3 = null
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

/obj/machinery/atmospherics/trinary/manifold_valve/update_icon(animation)
	if(animation)
		flick("valve[src.divert][!src.divert]",src)
		playsound(src.loc, 'sound/effects/valve_creak.ogg', 50, 1)
	else
		icon_state = "manifold_valve[divert]"

/obj/machinery/atmospherics/trinary/manifold_valve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network1 = new_network
		if(!divert)
			network3 = new_network
		else
			network2 = new_network
	else if(reference == node2)
		network2 = new_network
		if(divert)
			network1 = new_network
	else if(reference == node3)
		network3 = new_network
		if(!divert)
			network1 = new_network

	if(src in new_network.normal_members)
		return FALSE

	new_network.normal_members += src

	if(!divert)
		if(reference == node1)
			if(!isnull(node3))
				return node3.network_expand(new_network, src)
		else if(reference == node3)
			if(!isnull(node1))
				return node1.network_expand(new_network, src)
	else
		if(reference == node1)
			return node2.network_expand(new_network, src)
		else if(reference == node2)
			return node1.network_expand(new_network, src)
/obj/machinery/atmospherics/trinary/manifold_valve/proc/divert()
	if(divert)
		return FALSE

	divert = TRUE
	UpdateIcon()

	network1?.dispose()
	network1 = null

	build_network()

	if(network1&&network2)
		network1.merge(network2)
		network2 = network1

	if(network1)
		network1.update = TRUE
	else if(network2)
		network2.update = TRUE

	return TRUE

/obj/machinery/atmospherics/trinary/manifold_valve/proc/undivert()
	if(!divert)
		return FALSE

	divert = FALSE
	UpdateIcon()

	network2?.dispose()
	network2 = null

	build_network()

	if(network1&&network3)
		network3.merge(network1)
		network1 = network3

	if(network1)
		network1.update = TRUE
	else if(network3)
		network3.update = TRUE

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
