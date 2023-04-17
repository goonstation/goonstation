/obj/machinery/atmospherics/valve
	icon = 'icons/obj/atmospherics/valve.dmi'
	icon_state = "valve0"
	name = "manual valve"
	desc = "A pipe valve"
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW
	var/open = FALSE
	var/high_risk = FALSE //Does this valve have enough grief potential that the admins should be messaged when this is opened?
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/datum/pipe_network/network_node1
	var/datum/pipe_network/network_node2

/obj/machinery/atmospherics/valve/purge
	name = "purge valve"

/obj/machinery/atmospherics/valve/notify_admins
	high_risk = TRUE

/obj/machinery/atmospherics/valve/digital	// can be controlled by AI
	name = "digital valve"
	desc = "A digitally controlled valve."
	icon = 'icons/obj/atmospherics/digital_valve.dmi'

	var/frequency = 0
	var/id = null

/obj/machinery/atmospherics/valve/digital/New()
	..()
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

/obj/machinery/atmospherics/valve/digital/receive_signal(datum/signal/signal)
	if(signal.data["tag"] && (signal.data["tag"] != id))
		return FALSE

	switch(signal.data["command"])
		if("valve_open")
			if(!open)
				open()

		if("valve_close")
			if(open)
				close()

		if("valve_toggle")
			if(open)
				close()
			else
				open()

/obj/machinery/atmospherics/valve/digital/purge
	name = "purge valve"

/obj/machinery/atmospherics/valve/digital/notify_admins
	high_risk = TRUE

/obj/machinery/atmospherics/valve/digital/attack_ai(mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/atmospherics/valve/network_disposing(datum/pipe_network/reference)
	if (network_node1 == reference)
		network_node1 = null
	if (network_node2 == reference)
		network_node2 = null

/obj/machinery/atmospherics/valve/update_icon(animation)
	if(animation)
		flick("valve[src.open][!src.open]",src)
		playsound(src.loc, 'sound/effects/valve_creak.ogg', 50, 1)
	else
		icon_state = "valve[open]"

/obj/machinery/atmospherics/valve/New()
	..()
	UnsubscribeProcess()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/valve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network_node1 = new_network
		if(open)
			network_node2 = new_network
	else if(reference == node2)
		network_node2 = new_network
		if(open)
			network_node1 = new_network

	if(src in new_network.normal_members)
		return FALSE

	new_network.normal_members += src

	if(open)
		if(reference == node1)
			if(!isnull(node2))
				return node2.network_expand(new_network, src)
		else if(reference == node2)
			if(!isnull(node1))
				return node1.network_expand(new_network, src)

/obj/machinery/atmospherics/valve/disposing()
	if(node1)
		node1.disconnect(src)
		if (network_node1)
			network_node1.dispose()
	if(node2)
		node2.disconnect(src)
		if (network_node2)
			network_node2.dispose()

	node1 = null
	node2 = null
	network_node1 = null
	network_node2 = null

	..()

/obj/machinery/atmospherics/valve/proc/open()
	if(open) return FALSE

	playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
	open = TRUE
	UpdateIcon()

	if(network_node1&&network_node2)
		network_node1.merge(network_node2)
		network_node2 = network_node1

	if(network_node1)
		network_node1.update = TRUE
	else if(network_node2)
		network_node2.update = TRUE

	return TRUE

/obj/machinery/atmospherics/valve/proc/close()
	if(!open)
		return FALSE

	playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
	open = FALSE
	UpdateIcon()

	network_node1?.dispose()
	network_node1 = null
	network_node2?.dispose()
	network_node2 = null

	build_network()

	return TRUE

/obj/machinery/atmospherics/valve/attack_ai(mob/user)
	boutput(user, "This valve is manually controlled.")

/obj/machinery/atmospherics/valve/attack_hand(mob/user)
	interact_particle(user,src)
	UpdateIcon(TRUE)
	sleep(1 SECOND)
	logTheThing(LOG_STATION, user, "has [src.open ? "closed" : "opened"] the valve: [src] at [log_loc(src)]")
	if (src.open)
		src.close()
	else
		src.open()
		if(high_risk) message_admins("[key_name(user)] has opened the valve: [src] at [log_loc(src)]")
	add_fingerprint(user)

/obj/machinery/atmospherics/valve/attackby(var/obj/item/G, var/mob/user)
	if (iswrenchingtool(G))
		UpdateIcon(TRUE)
		sleep(1 SECOND)
		logTheThing(LOG_STATION, user, "has [src.open ? "closed" : "opened"] the valve: [src] at [log_loc(src)]")
		if (src.open)
			src.close()

		else
			src.open()
			if(high_risk) message_admins("[key_name(user)] has opened the valve: [src] at [log_loc(src)]")
	..()

/obj/machinery/atmospherics/valve/process()
	..()
	if(open && (!node1 || !node2))
		close()

/obj/machinery/atmospherics/valve/initialize()
	if(node1 && node2) return

	var/connect_directions

	switch(dir)
		if(NORTH, SOUTH)
			connect_directions = NORTH|SOUTH
		if(EAST, WEST)
			connect_directions = EAST|WEST

	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					connect_directions &= ~direction
					node1 = target
					break
			break

	for(var/direction in cardinal)
		if(direction&connect_directions)
			for(var/obj/machinery/atmospherics/target in get_step(src,direction))
				if(target.initialize_directions & get_dir(target,src))
					node2 = target
					break
			break

/obj/machinery/atmospherics/valve/build_network()
	if(!network_node1 && node1)
		network_node1 = new /datum/pipe_network()
		network_node1.normal_members += src
		network_node1.build_network(node1, src)

	if(!network_node2 && node2)
		network_node2 = new /datum/pipe_network()
		network_node2.normal_members += src
		network_node2.build_network(node2, src)


/obj/machinery/atmospherics/valve/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node1)
		return network_node1

	if(reference==node2)
		return network_node2

/obj/machinery/atmospherics/valve/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network_node1 == old_network)
		network_node1 = new_network
	if(network_node2 == old_network)
		network_node2 = new_network

	return TRUE

/obj/machinery/atmospherics/valve/return_network_air(datum/pipe_network/reference)
	return null

/obj/machinery/atmospherics/valve/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node1)
		if (network_node1)
			network_node1.dispose()
		network_node1 = null
		node1 = null

	else if(reference==node2)
		if (network_node2)
			network_node2.dispose()
		network_node2 = null
		node2 = null

/obj/machinery/atmospherics/manifold_valve
	icon = 'icons/obj/atmospherics/manifold_valve.dmi'
	icon_state = "manifold_valve0"

	name = "manifold valve"
	desc = "A pipe valve"

	var/divert = FALSE

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

	var/datum/pipe_network/network_node1
	var/datum/pipe_network/network_node2
	var/datum/pipe_network/network_node3

	var/frequency = FREQ_AIR_ALARM_CONTROL
	var/id = null

/obj/machinery/atmospherics/manifold_valve/update_icon(animation)
	if(animation)
		flick("valve[src.divert][!src.divert]",src)
		playsound(src.loc, 'sound/effects/valve_creak.ogg', 50, 1)
	else
		icon_state = "manifold_valve[divert]"

/obj/machinery/atmospherics/manifold_valve/New()
	..()
	UnsubscribeProcess()
	switch(dir)
		if(SOUTH)
			initialize_directions = EAST|WEST|NORTH
		if(NORTH)
			initialize_directions = WEST|EAST|SOUTH
		if(EAST)
			initialize_directions = NORTH|SOUTH|WEST
		if(WEST)
			initialize_directions = SOUTH|NORTH|EAST

/obj/machinery/atmospherics/manifold_valve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network_node1 = new_network
		if(!divert)
			network_node2 = new_network
		else
			network_node3 = new_network
	else if(reference == node2)
		network_node2 = new_network
		if(!divert)
			network_node1 = new_network
	else if(reference == node3)
		network_node3 = new_network
		if(divert)
			network_node1 = new_network

	if(src in new_network.normal_members)
		return FALSE

	new_network.normal_members += src

	if(!divert)
		if(reference == node1)
			if(!isnull(node2))
				return node2.network_expand(new_network, src)
		else if(reference == node2)
			if(!isnull(node1))
				return node1.network_expand(new_network, src)
	else
		if(reference == node1)
			return node3.network_expand(new_network, src)
		else if(reference == node3)
			return node1.network_expand(new_network, src)

/obj/machinery/atmospherics/manifold_valve/disposing()
	if(node1)
		node1.disconnect(src)
		if (network_node1)
			network_node1.dispose()
	if(node2)
		node2.disconnect(src)
		if (network_node2)
			network_node2.dispose()
	if(node3)
		node3.disconnect(src)
		if (network_node3)
			network_node3.dispose()

	node1 = null
	node2 = null
	node3 = null
	network_node1 = null
	network_node2 = null
	network_node3 = null

	..()

/obj/machinery/atmospherics/manifold_valve/proc/divert()

	if(divert) return FALSE

	divert = TRUE
	UpdateIcon()

	if(network_node2)
		network_node2.dispose()
		network_node2 = null

	build_network()

	if(network_node1&&network_node3)
		network_node1.merge(network_node3)
		network_node3 = network_node1

	if(network_node1)
		network_node1.update = TRUE
	else if(network_node3)
		network_node3.update = TRUE

	return TRUE

/obj/machinery/atmospherics/manifold_valve/proc/undivert()

	if(!divert)
		return FALSE

	divert = FALSE
	UpdateIcon()

	if(network_node3)
		network_node3.dispose()
		network_node3 = null

	build_network()

	if(network_node1&&network_node2)
		network_node1.merge(network_node2)
		network_node2 = network_node1

	if(network_node1)
		network_node1.update = TRUE
	else if(network_node2)
		network_node2.update = TRUE

	return TRUE

/obj/machinery/atmospherics/manifold_valve/process()
	..()
	if(divert && (!node1 || !node3))
		undivert()
	else if(!divert && (!node1 || !node2))
		divert()

	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.data["tag"] = tag
	signal.data["timestamp"] = air_master.current_cycle
	signal.data["valve_diverting"] = divert
	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

/obj/machinery/atmospherics/manifold_valve/initialize()
	if(node1 && node2 && node3) return

	var/node1_connect = turn(dir, 90)
	var/node2_connect = turn(dir, -90)
	var/node3_connect = turn(dir, 180)


	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			node2 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node3_connect))
		if(target.initialize_directions & get_dir(target,src))
			node3 = target
			break

	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

/obj/machinery/atmospherics/manifold_valve/build_network()
	if(!network_node1 && node1)
		network_node1 = new /datum/pipe_network()
		network_node1.normal_members += src
		network_node1.build_network(node1, src)

	if(!network_node2 && node2)
		network_node2 = new /datum/pipe_network()
		network_node2.normal_members += src
		network_node2.build_network(node2, src)

	if(!network_node3 && node3)
		network_node3 = new /datum/pipe_network()
		network_node3.normal_members += src
		network_node3.build_network(node3, src)

/obj/machinery/atmospherics/manifold_valve/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node1)
		return network_node1

	if(reference==node2)
		return network_node2

	if(reference==node3)
		return network_node3

/obj/machinery/atmospherics/manifold_valve/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network_node1 == old_network)
		network_node1 = new_network
	if(network_node2 == old_network)
		network_node2 = new_network
	if(network_node3 == old_network)
		network_node3 = new_network

	return TRUE

/obj/machinery/atmospherics/manifold_valve/return_network_air(datum/pipe_network/reference)
	return null

/obj/machinery/atmospherics/manifold_valve/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node1)
		network_node1.dispose()
		network_node1 = null
		node1 = null

	else if(reference==node2)
		network_node2.dispose()
		network_node2 = null
		node2 = null

	else if(reference==node3)
		network_node3.dispose()
		network_node3 = null
		node3 = null

/obj/machinery/atmospherics/manifold_valve/receive_signal(datum/signal/signal)
	if(signal.data["tag"] && (signal.data["tag"] != id))
		return FALSE

	switch(signal.data["command"])
		if("valve_divert")
			if(!divert)
				divert()

		if("valve_undivert")
			if(divert)
				undivert()

		if("valve_toggle")
			if(divert)
				undivert()
			else
				divert()
