
#define _SET_SIGNAL_GAS(GAS, _, _, ID, ...) signal.data[#ID + #GAS] = round(100*air_##ID.GAS/ID##_total_moles);
#define _RESET_SIGNAL_GAS(GAS, _, _, ID, ...) signal.data[#ID + #GAS] = 0;
#define SET_SIGNAL_MIXTURE(ID) APPLY_TO_GASES(_SET_SIGNAL_GAS, ID)
#define RESET_SIGNAL_MIXTURE(ID) APPLY_TO_GASES(_RESET_SIGNAL_GAS, ID)

/obj/machinery/atmospherics/mixer
	name = "Gas mixer"
	icon = 'icons/obj/atmospherics/mixer.dmi'
	icon_state = "intact_off"
	density = 0
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW


	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST

	var/flipped = 0

	var/id_tag
	var/master_id
	var/on = 0

	var/datum/gas_mixture/air_in1
	var/datum/gas_mixture/air_in2
	var/datum/gas_mixture/air_out

	var/obj/machinery/atmospherics/node_in1
	var/obj/machinery/atmospherics/node_in2
	var/obj/machinery/atmospherics/node_out

	var/datum/pipe_network/network_in1
	var/datum/pipe_network/network_in2
	var/datum/pipe_network/network_out

	var/target_pressure = ONE_ATMOSPHERE
	var/node1_concentration = 0.5
	var/node2_concentration = 0.5

	var/frequency

	update_icon()
		if(node_in1&&node_in2&&node_out)
			icon_state = "intact[flipped?"_flipped":""]_[on?"on":"off"]"
		else
			var/node_in1_direction = get_dir(src, node_in1)
			var/node_in2_direction = get_dir(src, node_in2)

			var/node_out_bit = (node_out)?(1):(0)

			icon_state = "exposed_[node_in1_direction|node_in2_direction]_[node_out_bit]_off"

			on = 0

		return

	network_disposing(datum/pipe_network/reference)
		if (network_in1 == reference)
			network_in1 = null
		if (network_in2 == reference)
			network_in2 = null
		if (network_out == reference)
			network_out = null

	New()
		..()
		switch(dir)
			if(NORTH)
				if(flipped)
					initialize_directions = NORTH|WEST|SOUTH
				else
					initialize_directions = NORTH|EAST|SOUTH
			if(EAST)
				if(flipped)
					initialize_directions = EAST|NORTH|WEST
				else
					initialize_directions = EAST|SOUTH|WEST
			if(SOUTH)
				if(flipped)
					initialize_directions = SOUTH|EAST|NORTH
				else
					initialize_directions = SOUTH|WEST|NORTH
			if(WEST)
				if(flipped)
					initialize_directions = WEST|SOUTH|EAST
				else
					initialize_directions = WEST|NORTH|EAST

		air_in1 = new /datum/gas_mixture
		air_in2 = new /datum/gas_mixture
		air_out = new /datum/gas_mixture

		air_in1.volume = 200
		air_in2.volume = 200
		air_out.volume = 300

	disposing()

		// Signal air disposing...
		if (network_in1)
			network_in1.air_disposing_hook(air_in1, air_in2, air_out)
		if (network_in2)
			network_in2.air_disposing_hook(air_in1, air_in2, air_out)
		if (network_out)
			network_out.air_disposing_hook(air_in1, air_in2, air_out)

		if(node_in1)
			node_in1.disconnect(src)
			if (network_in1)
				network_in1.dispose()

		if(node_in2)
			node_in2.disconnect(src)
			if (network_in2)
				network_in2.dispose()

		if(node_out)
			node_out.disconnect(src)
			if (network_out)
				network_out.dispose()

		node_in1 = null
		node_in2 = null
		node_out = null
		network_in1 = null
		network_in2 = null
		network_out = null

		if(air_in1)
			qdel(air_in1)
		if(air_in2)
			qdel(air_in2)
		if(air_out)
			qdel(air_out)

		air_in1 = null
		air_in2 = null
		air_out = null
		..()

	proc/report_status() // Report the status of this mixer over the radio.
		if (!(status & (NOPOWER | BROKEN)))
			var/datum/signal/signal = get_free_signal()
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = air_master.current_cycle
			signal.data["target_pressure"] = src.target_pressure
			if (src.on == 0)
				signal.data["pump_status"] = "Offline"
			else
				signal.data["pump_status"] = "Online"

			//Report gas concentration of in1
			var/in1_total_moles = TOTAL_MOLES(air_in1)
			if(in1_total_moles > 0)
				SET_SIGNAL_MIXTURE(in1)
				var/tgmoles = 0
				if(length(air_in1.trace_gases))
					for(var/datum/gas/trace_gas as anything in air_in1.trace_gases)
						tgmoles += trace_gas.moles
				signal.data["in1tg"] = round(100*tgmoles/in1_total_moles)
				signal.data["in1kpa"] = round(MIXTURE_PRESSURE(air_in1), 0.1)
				signal.data["in1temp"] = round(TO_CELSIUS(air_in1.temperature))
			else
				RESET_SIGNAL_MIXTURE(in1)
				signal.data["in1tg"] = 0

			//Report gas concentration of in2
			var/in2_total_moles = TOTAL_MOLES(air_in2)
			if(in2_total_moles > 0)
				SET_SIGNAL_MIXTURE(in2)
				var/tgmoles = 0
				if(length(air_in2.trace_gases))
					for(var/datum/gas/trace_gas as anything in air_in2.trace_gases)
						tgmoles += trace_gas.moles
				signal.data["in2tg"] = round(100*tgmoles/in2_total_moles)
				signal.data["in2kpa"] = round(MIXTURE_PRESSURE(air_in2), 0.1)
				signal.data["in2temp"] = round(TO_CELSIUS(air_in2.temperature))
			else
				RESET_SIGNAL_MIXTURE(in2)
				signal.data["in2tg"] = 0

			//Report transferred concentrations
			signal.data["i1trans"] = node1_concentration*100
			signal.data["i2trans"] = node2_concentration*100

			//Report gas concentration of out
			var/out_total_moles = TOTAL_MOLES(air_out)
			if(out_total_moles > 0)
				SET_SIGNAL_MIXTURE(out)
				var/tgmoles = 0
				if(length(air_out.trace_gases))
					for(var/datum/gas/trace_gas as anything in air_out.trace_gases)
						tgmoles += trace_gas.moles
				signal.data["outtg"] = round(100*tgmoles/out_total_moles)
				signal.data["outkpa"] = round(MIXTURE_PRESSURE(air_out), 0.1)
				signal.data["outtemp"] = round(TO_CELSIUS(air_out.temperature))
			else
				RESET_SIGNAL_MIXTURE(out)
				signal.data["outtg"] = 0

			signal.data["address_tag"] = "mixercontrol"

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	process()
		..()

		src.report_status()

		if(!on)
			return 0

		var/output_starting_pressure = MIXTURE_PRESSURE(air_out)

		if(output_starting_pressure >= target_pressure)
			//No need to mix if target is already full!
			return 1

		//Calculate necessary moles to transfer using PV=nRT

		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles1 = 0
		var/transfer_moles2 = 0

		if(air_in1.temperature > 0)
			transfer_moles1 = (node1_concentration*pressure_delta)*air_out.volume/(air_in1.temperature * R_IDEAL_GAS_EQUATION)

		if(air_in2.temperature > 0)
			transfer_moles2 = (node2_concentration*pressure_delta)*air_out.volume/(air_in2.temperature * R_IDEAL_GAS_EQUATION)

		var/air_in1_moles = TOTAL_MOLES(air_in1)
		var/air_in2_moles = TOTAL_MOLES(air_in2)

		if((air_in1_moles < transfer_moles1) || (air_in2_moles < transfer_moles2))
			if(transfer_moles1 != 0 && transfer_moles2 !=0)
				var/ratio = min(air_in1_moles/transfer_moles1, air_in2_moles/transfer_moles2)

				transfer_moles1 *= ratio
				transfer_moles2 *= ratio
			/*else
				if(transfer_moles1 != 0)
					transfer_moles2 = air_in2_moles
				else if (transfer_moles2 != 0)
					transfer_moles1 = air_in1_moles*/


		//Actually transfer the gas

		if(transfer_moles1 > 0)
			var/datum/gas_mixture/removed1 = air_in1.remove(transfer_moles1)
			air_out.merge(removed1)

		if(transfer_moles2 > 0)
			var/datum/gas_mixture/removed2 = air_in2.remove(transfer_moles2)
			air_out.merge(removed2)

		if(network_in1 && transfer_moles1)
			network_in1.update = 1

		if(network_in2 && transfer_moles2)
			network_in2.update = 1

		network_out?.update = 1

		return 1

	receive_signal(datum/signal/signal)
		if (signal.data["tag"] && (signal.data["tag"] != master_id))
			return 0

		switch (signal.data["command"])
			if ("toggle_pump")
				if (signal.data["parameter"] == "power_on")
					src.on = 1
				else if (signal.data["parameter"] == "power_off")
					src.on = 0

			if ("set_ratio")
				var/number = text2num(signal.data["parameter"])
				if (number && isnum(number))
					number = clamp(number, 0, 100)
					node1_concentration = number/100
					node2_concentration = (100-number)/100

			if ("set_pressure")
				var/number2 = text2num(signal.data["parameter"])
				if (number2 && isnum(number2))
					target_pressure = max(0, number2)
				else
					target_pressure = 0

		if (signal.data["tag"])
			SPAWN(0.5 SECONDS)
				if (src) src.report_status()

		src.UpdateIcon()
		return

// Housekeeping and pipe network stuff below
	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(reference == node_in1)
			network_in1 = new_network

		else if(reference == node_in2)
			network_in2 = new_network

		else if(reference == node_out)
			network_out = new_network

		if(new_network.normal_members.Find(src))
			return 0

		new_network.normal_members += src

		return null



	initialize()
		if(node_in1 && node_out) return

		var/node_out_connect = dir
		var/node_in1_connect = flipped ? turn(dir, 90) : turn(dir, -90)
		var/node_in2_connect = turn(dir, -180)

		for(var/obj/machinery/atmospherics/target in get_step(src,node_in1_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_in1 = target
				break

		for(var/obj/machinery/atmospherics/target in get_step(src,node_in2_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_in2 = target
				break

		for(var/obj/machinery/atmospherics/target in get_step(src,node_out_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_out = target
				break

		UpdateIcon()
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

	build_network()
		if(!network_in1 && node_in1)
			network_in1 = new /datum/pipe_network()
			network_in1.normal_members += src
			network_in1.build_network(node_in1, src)

		if(!network_in2 && node_in2)
			network_in2 = new /datum/pipe_network()
			network_in2.normal_members += src
			network_in2.build_network(node_in2, src)

		if(!network_out && node_out)
			network_out = new /datum/pipe_network()
			network_out.normal_members += src
			network_out.build_network(node_out, src)


	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if(reference==node_in1)
			return network_in1

		if(reference==node_in2)
			return network_in2

		if(reference==node_out)
			return network_out

		return null

	reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
		if(network_in1 == old_network)
			network_in1 = new_network

		if(network_in2 == old_network)
			network_in2 = new_network

		if(network_out == old_network)
			network_out = new_network

		return 1

	return_network_air(datum/pipe_network/reference)
		var/list/results = list()

		if(network_in1 == reference)
			results += air_in1

		if(network_in2 == reference)
			results += air_in2

		if(network_out == reference)
			results += air_out

		return results

	disconnect(obj/machinery/atmospherics/reference)
		if(reference==node_in1)
			if (network_in1)
				network_in1.dispose()
				network_in1 = null
			node_in1 = null

		else if(reference==node_in2)
			if (network_in2)
				network_in2.dispose()
				network_in2 = null
			node_in2 = null

		else if(reference==node_out)
			if (network_out)
				network_out.dispose()
				network_out = null
			node_out = null

		return null

/obj/machinery/atmospherics/mixer/flipped
	icon_state = "intact_flipped_off"
	flipped = 1


#undef _SET_SIGNAL_GAS
#undef _RESET_SIGNAL_GAS
#undef SET_SIGNAL_MIXTURE
#undef RESET_SIGNAL_MIXTURE
