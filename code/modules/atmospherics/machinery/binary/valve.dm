/obj/machinery/atmospherics/binary/valve
	icon = 'icons/obj/atmospherics/valve.dmi'
	icon_state = "valve0-map"
	name = "manual valve"
	desc = "A pipe valve"
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW
	/// Are we letting gas pass through us?
	var/open = FALSE
	/// Does this valve have enough grief potential that the admins should be messaged when this is opened?
	var/high_risk = FALSE

/obj/machinery/atmospherics/binary/valve/New()
	..()
	qdel(src.air1)
	src.air1 = null
	qdel(src.air2)
	src.air2 = null
	UnsubscribeProcess()

/obj/machinery/atmospherics/binary/valve/update_icon(animation)
	if(animation)
		FLICK("valve[src.open][!src.open]",src)
		playsound(src.loc, 'sound/effects/valve_creak.ogg', 50, 1)
	else
		icon_state = "valve[open]"
	SET_PIPE_UNDERLAY(src.node1, turn(src.dir, 180), "medium", issimplepipe(src.node1) ?  src.node1.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node2, src.dir, "medium", issimplepipe(src.node2) ?  src.node2.color : null, FALSE)

/obj/machinery/atmospherics/binary/valve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network1 = new_network
		if(open)
			network2 = new_network
	else if(reference == node2)
		network2 = new_network
		if(open)
			network1 = new_network

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

/// Open us up and connect the networks we are connected to.
/obj/machinery/atmospherics/binary/valve/proc/open()
	if(open)
		return FALSE

	playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
	open = TRUE
	UpdateIcon()

	if(network1&&network2)
		network1.merge(network2)
		network2 = network1

	if(network1)
		network1.update = TRUE
	else if(network2)
		network2.update = TRUE

	return FALSE

/// Close us down and split the network we are connected to.
/obj/machinery/atmospherics/binary/valve/proc/close()
	if(!open)
		return FALSE

	playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
	open = FALSE
	UpdateIcon()

	network1?.dispose()
	network1 = null
	network2?.dispose()
	network2 = null

	build_network()

	return TRUE

/obj/machinery/atmospherics/binary/valve/attack_ai(mob/user as mob)
	boutput(user, "This valve is manually controlled.")

/obj/machinery/atmospherics/binary/valve/attack_hand(mob/user)
	interact_particle(user,src)
	UpdateIcon(1)
	sleep(1 SECOND)
	logTheThing(LOG_STATION, user, "has [src.open ? "closed" : "opened"] the valve: [src] at [log_loc(src)]")
	if (src.open)
		src.close()
	else
		src.open()
		if(high_risk)
			message_admins("[key_name(user)] has opened the valve: [src] at [log_loc(src)]")
	add_fingerprint(user)

/obj/machinery/atmospherics/binary/valve/attackby(var/obj/item/G, var/mob/user)
	if (iswrenchingtool(G))
		UpdateIcon(1)
		sleep(1 SECOND)
		logTheThing(LOG_STATION, user, "has [src.open ? "closed" : "opened"] the valve: [src] at [log_loc(src)]")
		if (src.open)
			src.close()
		else
			src.open()
			if(high_risk)
				message_admins("[key_name(user)] has opened the valve: [src] at [log_loc(src)]")
	..()

/obj/machinery/atmospherics/binary/valve/process()
	..()
	if(open && (!node1 || !node2))
		close()

/obj/machinery/atmospherics/binary/valve/return_network_air(datum/pipe_network/reference)
	return null

/obj/machinery/atmospherics/binary/valve/opened
	icon_state = "valve1-map"
	open = TRUE

/obj/machinery/atmospherics/binary/valve/purge
	name = "purge valve"

/obj/machinery/atmospherics/binary/valve/notify_admins
	high_risk = TRUE

/// Can be controlled by AI
/obj/machinery/atmospherics/binary/valve/digital
	name = "digital valve"
	desc = "A digitally controlled valve."
	icon = 'icons/obj/atmospherics/digital_valve.dmi'

	var/frequency = 0
	var/id = null

/obj/machinery/atmospherics/binary/valve/digital/New()
	..()
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, null, frequency)

/obj/machinery/atmospherics/binary/valve/digital/receive_signal(datum/signal/signal)
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

/obj/machinery/atmospherics/binary/valve/digital/attack_ai(mob/user)
	return src.Attackhand(user)

/obj/machinery/atmospherics/binary/valve/digital/opened
	icon_state = "valve1-map"
	open = TRUE

/obj/machinery/atmospherics/binary/valve/digital/purge
	name = "purge valve"

/obj/machinery/atmospherics/binary/valve/digital/notify_admins
	high_risk = TRUE

