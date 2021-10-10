var/global/list/datum/pipe_network/pipe_networks = list()
//
datum/pipe_network
	var/list/datum/gas_mixture/gases = list() //All of the gas_mixtures continuously connected in this network

	var/list/obj/machinery/atmospherics/normal_members = list()
	var/list/datum/pipeline/line_members = list()
		//membership roster to go through for updates and what not

	var/update = 1
	var/datum/gas_mixture/air_transient = null

	New()
		air_transient = new /datum/gas_mixture

		..()

	disposing()
		update = 0
		pipe_networks -= src
		if (gases)
			gases.len = 0
		gases = null
		if (normal_members)
			for(var/obj/machinery/atmospherics/machine in normal_members)
				machine.network_disposing(src)
			normal_members.len = 0
		normal_members = 0
		if (line_members)
			for(var/datum/pipeline/member in line_members)
				member.network = null
			line_members.len = 0
		line_members = null
		if (air_transient)
			qdel(air_transient)
		air_transient = null
		..()

	proc/member_disposing(datum/pipeline/line_member)
		if (gases)
			gases -= line_member.air
		if (line_members)
			line_members -= line_member

	proc/air_disposing_hook()
		for(var/datum/gas_mixture/a in args)
			gases -= a

	proc/process()
		//Equalize gases amongst pipe if called for
		if(update)
			update = 0
			reconcile_air() //equalize_gases(gases)

		//Give pipelines their process call for pressure checking and what not
		for(var/datum/pipeline/line_member in line_members)
			line_member.process()

	proc/build_network(obj/machinery/atmospherics/start_normal, obj/machinery/atmospherics/reference)
		//Purpose: Generate membership roster
		//Notes: Assuming that members will add themselves to appropriate roster in network_expand()

		if(!start_normal)
			dispose()

		start_normal.network_expand(src, reference)

		update_network_gases()

		if((normal_members.len>0)||(line_members.len>0))
			pipe_networks += src
		else
			dispose()

	proc/merge(datum/pipe_network/giver)
		if(giver==src) return 0

		normal_members |= giver.normal_members

		line_members |= giver.line_members

		for(var/obj/machinery/atmospherics/normal_member in giver.normal_members)
			normal_member.reassign_network(giver, src)

		for(var/datum/pipeline/line_member in giver.line_members)
			line_member.network = src

		giver.dispose()

		update_network_gases()
		return 1

	proc/update_network_gases()
		//Go through membership roster and make sure gases is up to date

		gases.len = 0

		for(var/obj/machinery/atmospherics/normal_member in normal_members)
			var/result = normal_member.return_network_air(src)
			if(result) gases += result

		for(var/datum/pipeline/line_member in line_members)
			gases += line_member.air

	proc/reconcile_air()
		//Perfectly equalize all gases members instantly

		//Calculate totals from individual components
		var/total_thermal_energy = 0
		var/total_heat_capacity = 0
		if (!air_transient)
			air_transient = new()
		air_transient.volume = 0
		ZERO_BASE_GASES(air_transient)

		air_transient.clear_trace_gases()

		for(var/datum/gas_mixture/gas in gases)
			air_transient.volume += gas.volume
			total_thermal_energy += THERMAL_ENERGY(gas)
			total_heat_capacity += HEAT_CAPACITY(gas)

			#define _RECONCILE_AIR(GAS, ...) air_transient.GAS += gas.GAS;
			APPLY_TO_GASES(_RECONCILE_AIR)
			#undef _RECONCILE_AIR

			if(length(gas.trace_gases))
				for(var/datum/gas/trace_gas as anything in gas.trace_gases)
					var/datum/gas/corresponding = air_transient.get_or_add_trace_gas_by_type(trace_gas.type)
					corresponding.moles += trace_gas.moles

		if(air_transient.volume > 0)

			if(total_heat_capacity > 0)
				air_transient.temperature = total_thermal_energy/total_heat_capacity

				//Allow air mixture to react
				if(air_transient.react())
					update = 1

			else
				air_transient.temperature = 0

			//Update individual gas_mixtures by volume ratio
			for(var/datum/gas_mixture/gas in gases)
				#define _RECONCILE_AIR_TRANSFER(GAS, ...) gas.GAS = air_transient.GAS * gas.volume / air_transient.volume ;
				APPLY_TO_GASES(_RECONCILE_AIR_TRANSFER)
				#undef _RECONCILE_AIR_TRANSFER

				gas.temperature = air_transient.temperature

				if(length(air_transient.trace_gases))
					for(var/datum/gas/trace_gas in air_transient.trace_gases)
						var/datum/gas/corresponding = gas.get_or_add_trace_gas_by_type(trace_gas.type)
						corresponding.moles = trace_gas.moles*gas.volume/air_transient.volume
		return 1

proc/equalize_gases(list/datum/gas_mixture/gases)
	//Perfectly equalize all gases members instantly

	//Calculate totals from individual components
	var/total_volume = 0
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0

	#define _EQUALIZE_GASES_TOTAL_DEF(GAS, ...) var/total_ ## GAS = 0;
	APPLY_TO_GASES(_EQUALIZE_GASES_TOTAL_DEF)
	#undef _EQUALIZE_GASES_TOTAL_DEF

	var/list/total_trace_gases

	for(var/datum/gas_mixture/gas in gases)
		total_volume += gas.volume
		total_thermal_energy += THERMAL_ENERGY(gas)
		total_heat_capacity += HEAT_CAPACITY(gas)

		#define _EQUALIZE_GASES_ADD_TO_TOTAL(GAS, ...) total_ ## GAS += gas.GAS;
		APPLY_TO_GASES(_EQUALIZE_GASES_ADD_TO_TOTAL)
		#undef _EQUALIZE_GASES_ADD_TO_TOTAL

		if(length(gas.trace_gases))
			for(var/datum/gas/trace_gas as anything in gas.trace_gases)
				var/datum/gas/corresponding
				if(length(total_trace_gases))
					corresponding = locate(trace_gas.type) in total_trace_gases
				if(!corresponding)
					corresponding = new trace_gas.type()
					if(!total_trace_gases)
						total_trace_gases = list()
					total_trace_gases += corresponding

				corresponding.moles += trace_gas.moles

	if(total_volume > 0)

		//Calculate temperature
		var/temperature = 0

		if(total_heat_capacity > 0)
			temperature = total_thermal_energy/total_heat_capacity

		//Update individual gas_mixtures by volume ratio
		for(var/datum/gas_mixture/gas in gases)
			#define _EQUALIZE_GASES_UPDATE(GAS, ...) gas.GAS = total_ ## GAS * gas.volume / total_volume;
			APPLY_TO_GASES(_EQUALIZE_GASES_UPDATE)
			#undef _EQUALIZE_GASES_UPDATE

			gas.temperature = temperature

			if(length(total_trace_gases))
				for(var/datum/gas/trace_gas in total_trace_gases)
					var/datum/gas/corresponding = gas.get_or_add_trace_gas_by_type(trace_gas.type)
					corresponding.moles = trace_gas.moles*gas.volume/total_volume

	return 1
