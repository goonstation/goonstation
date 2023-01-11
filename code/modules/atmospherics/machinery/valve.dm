obj/machinery/atmospherics/valve
	icon = 'icons/obj/atmospherics/valve.dmi'
	icon_state = "valve0"
	name = "manual valve"
	desc = "A pipe valve"
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW
	var/open = 0
	var/high_risk = 0 //Does this valve have enough grief potential that the admins should be messaged when this is opened?
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/datum/pipe_network/network_node1
	var/datum/pipe_network/network_node2

	vertical
		dir = NORTH
	horizontal
		dir = EAST

	purge
		name = "purge valve"

		vertical
			dir = NORTH
		horizontal
			dir = EAST

	notify_admins
		high_risk = 1

		vertical
			dir = NORTH
		horizontal
			dir = EAST

	digital		// can be controlled by AI
		name = "digital valve"
		desc = "A digitally controlled valve."
		icon = 'icons/obj/atmospherics/digital_valve.dmi'

		vertical
			dir = NORTH
		horizontal
			dir = EAST

		purge
			name = "purge valve"

			vertical
				dir = NORTH
			horizontal
				dir = EAST

		notify_admins
			high_risk = 1

			vertical
				dir = NORTH
			horizontal
				dir = EAST

		attack_ai(mob/user as mob)
			return src.Attackhand(user)


		var/frequency = 0
		var/id = null

		New()
			..()
			MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

		receive_signal(datum/signal/signal)
			if(signal.data["tag"] && (signal.data["tag"] != id))
				return 0

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

	network_disposing(datum/pipe_network/reference)
		if (network_node1 == reference)
			network_node1 = null
		if (network_node2 == reference)
			network_node2 = null

	update_icon(animation)
		if(animation)
			flick("valve[src.open][!src.open]",src)
			playsound(src.loc, 'sound/effects/valve_creak.ogg', 50, 1)
		else
			icon_state = "valve[open]"

	New()
		..()
		UnsubscribeProcess()
		switch(dir)
			if(NORTH, SOUTH)
				initialize_directions = NORTH|SOUTH
			if(EAST, WEST)
				initialize_directions = EAST|WEST

	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)

		if(reference == node1)
			network_node1 = new_network
			if(open)
				network_node2 = new_network
		else if(reference == node2)
			network_node2 = new_network
			if(open)
				network_node1 = new_network

		if(src in new_network.normal_members)
			return 0

		new_network.normal_members += src

		if(open)
			if(reference == node1)
				if(!isnull(node2))
					return node2.network_expand(new_network, src)
			else if(reference == node2)
				if(!isnull(node1))
					return node1.network_expand(new_network, src)

		return null

	disposing()
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

	proc/open()

		if(open) return 0

		playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
		open = 1
		UpdateIcon()

		if(network_node1&&network_node2)
			network_node1.merge(network_node2)
			network_node2 = network_node1

		if(network_node1)
			network_node1.update = 1
		else if(network_node2)
			network_node2.update = 1

		return 1

	proc/close()

		if(!open)
			return 0

		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		open = 0
		UpdateIcon()

		network_node1?.dispose()
		network_node1 = null
		network_node2?.dispose()
		network_node2 = null

		build_network()

		return 1

	attack_ai(mob/user as mob)
		boutput(user, "This valve is manually controlled.")
		return

	attack_hand(mob/user)
		interact_particle(user,src)
		UpdateIcon(1)
		sleep(1 SECOND)
		logTheThing(LOG_STATION, user, "has [src.open ? "closed" : "opened"] the valve: [src] at [log_loc(src)]")
		if (src.open)
			src.close()
		else
			src.open()
			if(high_risk) message_admins("[key_name(user)] has opened the valve: [src] at [log_loc(src)]")
		add_fingerprint(user)

	attackby(var/obj/item/G, var/mob/user)
		if (iswrenchingtool(G))
			UpdateIcon(1)
			sleep(1 SECOND)
			logTheThing(LOG_STATION, user, "has [src.open ? "closed" : "opened"] the valve: [src] at [log_loc(src)]")
			if (src.open)
				src.close()

			else
				src.open()
				if(high_risk) message_admins("[key_name(user)] has opened the valve: [src] at [log_loc(src)]")
		..()
		return

	process()
		..()
		if(open && (!node1 || !node2))
			close()

		return

	initialize()
		if(node1 && node2) return

		var/connect_directions

		switch(dir)
			if(NORTH)
				connect_directions = NORTH|SOUTH
			if(SOUTH)
				connect_directions = NORTH|SOUTH
			if(EAST)
				connect_directions = EAST|WEST
			if(WEST)
				connect_directions = EAST|WEST
			else
				connect_directions = dir

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

	build_network()
		if(!network_node1 && node1)
			network_node1 = new /datum/pipe_network()
			network_node1.normal_members += src
			network_node1.build_network(node1, src)

		if(!network_node2 && node2)
			network_node2 = new /datum/pipe_network()
			network_node2.normal_members += src
			network_node2.build_network(node2, src)


	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if(reference==node1)
			return network_node1

		if(reference==node2)
			return network_node2

		return null

	reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
		if(network_node1 == old_network)
			network_node1 = new_network
		if(network_node2 == old_network)
			network_node2 = new_network

		return 1

	return_network_air(datum/pipe_network/reference)
		return null

	disconnect(obj/machinery/atmospherics/reference)
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

		return null

obj/machinery/atmospherics/manifold_valve
	icon = 'icons/obj/atmospherics/manifold_valve.dmi'
	icon_state = "manifold_valve0"

	name = "manifold valve"
	desc = "A pipe valve"

	dir = SOUTH
	initialize_directions = EAST|WEST|NORTH

	var/divert = 0

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

	var/datum/pipe_network/network_node1
	var/datum/pipe_network/network_node2
	var/datum/pipe_network/network_node3

	var/frequency = "1439"
	var/id = null

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	update_icon(animation)
		if(animation)
			flick("valve[src.divert][!src.divert]",src)
			playsound(src.loc, 'sound/effects/valve_creak.ogg', 50, 1)
		else
			icon_state = "manifold_valve[divert]"

	New()
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

	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
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

		if(new_network.normal_members.Find(src))
			return 0

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

		return null

	disposing()
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

	proc/divert()

		if(divert) return 0

		divert = 1
		UpdateIcon()

		if(network_node2)
			network_node2.dispose()
			network_node2 = null

		build_network()

		if(network_node1&&network_node3)
			network_node1.merge(network_node3)
			network_node3 = network_node1

		if(network_node1)
			network_node1.update = 1
		else if(network_node3)
			network_node3.update = 1

		return 1

	proc/undivert()

		if(!divert)
			return 0

		divert = 0
		UpdateIcon()

		if(network_node3)
			network_node3.dispose()
			network_node3 = null

		build_network()

		if(network_node1&&network_node2)
			network_node1.merge(network_node2)
			network_node2 = network_node1

		if(network_node1)
			network_node1.update = 1
		else if(network_node2)
			network_node2.update = 1

		return 1

	attack_hand(mob/user)
		..()


	process()
		..()
		if(divert && (!node1 || !node3))
			undivert()
		else if(!divert && (!node1 || !node2))
			divert()

		var/datum/signal/signal = get_free_signal()
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = tag
		signal.data["timestamp"] = air_master.current_cycle
		signal.data["valve_diverting"] = divert
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	initialize()
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

	build_network()
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

	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if(reference==node1)
			return network_node1

		if(reference==node2)
			return network_node2

		if(reference==node3)
			return network_node3

		return null

	reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
		if(network_node1 == old_network)
			network_node1 = new_network
		if(network_node2 == old_network)
			network_node2 = new_network
		if(network_node3 == old_network)
			network_node3 = new_network

		return 1

	return_network_air(datum/pipe_network/reference)
		return null

	disconnect(obj/machinery/atmospherics/reference)
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

		return null

	receive_signal(datum/signal/signal)
		if(signal.data["tag"] && (signal.data["tag"] != id))
			return 0

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
