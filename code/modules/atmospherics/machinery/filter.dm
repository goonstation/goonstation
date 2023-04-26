obj/machinery/atmospherics/filter
	name = "Gas filter"
	icon = 'icons/obj/atmospherics/filter.dmi'
	icon_state = "intact_off"
	density = 1
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW

	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST

	var/on = 0

	var/datum/gas_mixture/air_in
	var/datum/gas_mixture/air_out1
	var/datum/gas_mixture/air_out2

	var/obj/machinery/atmospherics/node_in
	var/obj/machinery/atmospherics/node_out1
	var/obj/machinery/atmospherics/node_out2

	var/datum/pipe_network/network_in
	var/datum/pipe_network/network_out1
	var/datum/pipe_network/network_out2

	var/target_pressure = ONE_ATMOSPHERE

	var/filter_type = 0
/*
Filter types:
0: Plasma
1: Oxygen: Oxygen ONLY
2: Nitrogen: Nitrogen
3: Carbon Dioxide: Carbon Dioxide ONLY
4: Other Gases (i.e. Sleeping Agent & Other trace gases)
*/

	New()
		..()
		switch(dir)
			if(NORTH)
				initialize_directions = NORTH|EAST|SOUTH
			if(SOUTH)
				initialize_directions = NORTH|SOUTH|WEST
			if(EAST)
				initialize_directions = EAST|WEST|SOUTH
			if(WEST)
				initialize_directions = NORTH|EAST|WEST
		if(radio_controller)
			initialize()

		air_in = new /datum/gas_mixture
		air_out1 = new /datum/gas_mixture
		air_out2 = new /datum/gas_mixture

		air_in.volume = 200
		air_out1.volume = 200
		air_out2.volume = 200

	disposing()

		if (network_in)
			network_in.air_disposing_hook(air_in, air_out1, air_out2)
		if (network_out1)
			network_out1.air_disposing_hook(air_in, air_out1, air_out2)
		if (network_out2)
			network_out2.air_disposing_hook(air_in, air_out1, air_out2)

		if(node_out1)
			node_out1.disconnect(src)
			if (network_out1)
				network_out1.dispose()

		if(node_out2)
			node_out2.disconnect(src)
			if (network_out2)
				network_out2.dispose()

		if(node_in)
			node_in.disconnect(src)
			if (network_in)
				network_in.dispose()

		node_out1 = null
		node_out2 = null
		node_in = null
		network_out1 = null
		network_out2 = null
		network_in = null

		if(air_in)
			qdel(air_in)
		if(air_out1)
			qdel(air_out1)
		if(air_out2)
			qdel(air_out2)

		air_in = null
		air_out1 = null
		air_out2 = null

		..()

	update_icon()
		if(node_out1&&node_out2&&node_in)
			icon_state = "intact_[on?("on"):("off")]"
		else
			var/node_out1_direction = get_dir(src, node_out1)
			var/node_out2_direction = get_dir(src, node_out2)

			var/node_in_bit = (node_in)?(1):(0)

			icon_state = "exposed_[node_out1_direction|node_out2_direction]_[node_in_bit]_off"

			on = 0

		return

	network_disposing(datum/pipe_network/reference)
		if (network_in == reference)
			network_in = null
		if (network_out1 == reference)
			network_out1 = null
		if (network_out2 == reference)
			network_out2 = null

	process()
		..()
		if(!on)
			return 0

		var/output_starting_pressure = MIXTURE_PRESSURE(air_out2)

		if(output_starting_pressure >= target_pressure)
			//No need to mix if target is already full!
			return 1

		//Calculate necessary moles to transfer using PV=nRT

		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles

		if(air_in.temperature > 0)
			transfer_moles = pressure_delta*air_out2.volume/(air_in.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas

		if(transfer_moles > 0)
			var/datum/gas_mixture/removed = air_in.remove(transfer_moles)

			var/datum/gas_mixture/filtered_out = new /datum/gas_mixture
			//if(filtered_out.temperature)
			if(removed.temperature)
				filtered_out.temperature = removed.temperature

			switch(filter_type)
				if(0) //removing plasma
					if(filtered_out.toxins)
						if(removed.toxins)
							filtered_out.toxins = removed.toxins
							removed.toxins = 0

				if(1) //removing O2
					if(filtered_out.oxygen)
						if(removed.oxygen)
							filtered_out.oxygen = removed.oxygen
							removed.oxygen = 0

				if(2) //removing N2
					if(filtered_out.nitrogen)
						if(removed.nitrogen)
							filtered_out.nitrogen = removed.nitrogen
							removed.nitrogen = 0

				if(3) //removing CO2
					if(filtered_out.carbon_dioxide)
						if(removed.carbon_dioxide)
							filtered_out.carbon_dioxide = removed.carbon_dioxide
							removed.carbon_dioxide = 0

				if(4) //removing trace gases
					if(removed)
						if(length(removed.trace_gases))
							for(var/datum/gas/trace_gas as anything in removed.trace_gases)
								var/datum/gas/filter_gas = filtered_out.get_or_add_trace_gas_by_type(trace_gas.type)
								filter_gas.moles = trace_gas.moles
								removed.remove_trace_gas(trace_gas)

			air_out1.merge(filtered_out)
			air_out2.merge(removed)

		network_out1?.update = 1

		network_out2?.update = 1

		network_in?.update = 1
		return 1

// Housekeeping and pipe network stuff below
	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(reference == node_out1)
			network_out1 = new_network

		else if(reference == node_out2)
			network_out2 = new_network

		else if(reference == node_in)
			network_in = new_network

		if(src in new_network.normal_members)
			return 0

		new_network.normal_members += src

		return null



	initialize()
		if(node_out1 && node_in) return

		var/node_in_connect = turn(dir, -180)
		var/node_out1_connect = turn(dir, -90)
		var/node_out2_connect = dir


		for(var/obj/machinery/atmospherics/target in get_step(src,node_out1_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_out1 = target
				break

		for(var/obj/machinery/atmospherics/target in get_step(src,node_out2_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_out2 = target
				break

		for(var/obj/machinery/atmospherics/target in get_step(src,node_in_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_in = target
				break

		UpdateIcon()

	build_network()
		if(!network_out1 && node_out1)
			network_out1 = new /datum/pipe_network()
			network_out1.normal_members += src
			network_out1.build_network(node_out1, src)

		if(!network_out2 && node_out2)
			network_out2 = new /datum/pipe_network()
			network_out2.normal_members += src
			network_out2.build_network(node_out2, src)

		if(!network_in && node_in)
			network_in = new /datum/pipe_network()
			network_in.normal_members += src
			network_in.build_network(node_in, src)


	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if(reference==node_out1)
			return network_out1

		if(reference==node_out2)
			return network_out2

		if(reference==node_in)
			return network_in

		return null

	reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
		if(network_out1 == old_network)
			network_out1 = new_network

		if(network_out2 == old_network)
			network_out2 = new_network

		if(network_in == old_network)
			network_in = new_network

		return 1

	return_network_air(datum/pipe_network/reference)
		var/list/results = list()

		if(network_out1 == reference)
			results += air_out1

		if(network_out2 == reference)
			results += air_out2

		if(network_in == reference)
			results += air_in

		return results

	disconnect(obj/machinery/atmospherics/reference)
		if(reference==node_out1)
			if (network_out1)
				network_out1.dispose()
				network_out1 = null
			node_out1 = null

		else if(reference==node_out2)
			if (network_out2)
				network_out2.dispose()
				network_out2 = null
			node_out2 = null

		else if(reference==node_in)
			if (network_in)
				network_in.dispose()
				network_in = null
			node_in = null

		return null
