/////////////////////////////////////////////////////////////////
// Defintion for the turbine used by the nuclear reactor
// This is where the power comes from
/////////////////////////////////////////////////////////////////

/obj/machinery/atmospherics/binary/reactor_turbine
	name = "Gas Turbine"
	desc = "A large turbine used for generating power using hot gas."
//	icon = 'icons/obj/atmospherics/pipes.dmi'
//	icon_state = "circ1-off"
	icon = 'icons/obj/large/96x160.dmi'
	icon_state = "turbine_main" //TODO make rotated states of this
	anchored = 1
	density = 1
	bound_width = 96
	bound_height = 160
	pixel_x = -32
	pixel_y = -32
	bound_x = -32
	bound_y = -32
	var/obj/machinery/power/terminal/terminal = null
	var/net_id = null
	dir = EAST

	var/stator_load = 100
	var/RPM = 1
	var/turbine_mass = 1000

	New()
		. = ..()
		terminal = new /obj/machinery/power/terminal/netlink(src.loc)
		src.net_id = generate_net_id(src)
		terminal.set_dir(turn(src.dir,-90))
		terminal.master = src

	//override the atmos/binary connection code, because it doesn't like big icons
	initialize()
		if(node1 && node2) return

		var/node2_connect = dir
		var/node1_connect = turn(dir, 180)

		for(var/obj/machinery/atmospherics/pipe/simple/target in get_steps(src,node1_connect,2))
			if(target.initialize_directions & node2_connect)
				if(target != src)
					node1 = target
					//target.node2 = src
					break

		for(var/obj/machinery/atmospherics/pipe/simple/target in get_steps(src,node2_connect,2))
			if(target.initialize_directions & node1_connect)
				if(target != src)
					node2 = target
					//target.node1 = src
					break

		UpdateIcon()

	process()
		. = ..()

		if(RPM > 1)
			if(src.icon_state == "turbine_main")
				src.icon_state = "turbine_spin"
				UpdateIcon()
		else
			if(src.icon_state == "turbine_spin")
				src.icon_state = "turbine_main"
				UpdateIcon()

		var/output_starting_pressure = MIXTURE_PRESSURE(air2)
		var/input_starting_pressure = MIXTURE_PRESSURE(air1)
		boutput(world,"TURBINE: input=[input_starting_pressure] output=[output_starting_pressure]")

		if(output_starting_pressure >= min(ONE_ATMOSPHERE,input_starting_pressure-10))
			//Need at least 10 KPa difference to overcome friction in the mechanism
			return

		//Calculate necessary moles to transfer using PV = nRT
		if((TOTAL_MOLES(air1) <= 0) || (air1.temperature<=0))
			return

		var/pressure_delta = min(ONE_ATMOSPHERE - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
		//Can not have a pressure delta that would cause output_pressure > input_pressure
		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		//RPM - generate ideal power at 600RPM
		//Stator load - how much are we trying to slow the RPM
		//Energy generated = stator load * RPM
		//RPM = current_RPM + (Energy generated/delta E)*
		var/datum/gas_mixture/current_gas = src.air1.remove(transfer_moles)
		if(current_gas)
			var/input_starting_energy = THERMAL_ENERGY(current_gas)
			current_gas.temperature = max(0.66 * current_gas.temperature,T20C)
			var/output_starting_energy = THERMAL_ENERGY(current_gas)
			var/energy_generated = src.stator_load*src.RPM
			var/delta_E = input_starting_energy - output_starting_energy

			src.RPM += (delta_E/turbine_mass)
			boutput(world,"RPM: [src.RPM]")
			if(src.RPM < 1)
				src.RPM = 1
			src.air2.merge(current_gas)
			src.terminal.add_avail(energy_generated)

			src.network1?.update = TRUE
			src.network2?.update = TRUE

