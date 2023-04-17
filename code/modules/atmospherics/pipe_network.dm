var/global/list/datum/pipe_network/pipe_networks = list()

/datum/pipe_network
	/// All of the gas_mixtures continuously connected in this network
	var/list/datum/gas_mixture/gases = list()
	/// List of non-pipe atmospheric items. Items must add themselves to this list to be processed.
	var/list/obj/machinery/atmospherics/normal_members = list()
	/// List of pipelines to process.
	var/list/datum/pipeline/line_members = list()

	var/update = TRUE
	var/datum/gas_mixture/air_transient = null

/datum/pipe_network/New()
	air_transient = new /datum/gas_mixture

	..()

/datum/pipe_network/disposing()
	update = FALSE
	pipe_networks -= src
	if (gases)
		gases.len = 0
	gases = null
	if (normal_members)
		for(var/obj/machinery/atmospherics/machine as anything in normal_members)
			machine.network_disposing(src)
		normal_members.len = 0
	normal_members = 0
	if (line_members)
		for(var/datum/pipeline/member as anything in line_members)
			member.network = null
		line_members.len = 0
	line_members = null
	if (air_transient)
		qdel(air_transient)
	air_transient = null
	..()

/datum/pipe_network/proc/member_disposing(datum/pipeline/line_member)
	if (gases)
		gases -= line_member.air
	if (line_members)
		line_members -= line_member

/datum/pipe_network/proc/air_disposing_hook()
	for(var/datum/gas_mixture/a as anything in args)
		gases -= a

/datum/pipe_network/proc/process()
	//Equalize gases amongst pipe if called for
	if(update)
		update = FALSE
		reconcile_air()

	//Give pipelines their process call for pressure checking and what not
	for(var/datum/pipeline/line_member as anything in line_members)
		line_member.process()

/// Purpose: Generate membership roster.
/// Notes: Assuming that members will add themselves to appropriate roster in network_expand().
/datum/pipe_network/proc/build_network(obj/machinery/atmospherics/start_normal, obj/machinery/atmospherics/reference)
	if(!start_normal)
		dispose()

	start_normal.network_expand(src, reference)

	update_network_gases()

	if(length(normal_members) || length(line_members))
		pipe_networks += src
	else
		dispose()

/datum/pipe_network/proc/merge(datum/pipe_network/giver)
	if(giver==src) return FALSE

	normal_members |= giver.normal_members

	line_members |= giver.line_members

	for(var/obj/machinery/atmospherics/normal_member as anything in giver.normal_members)
		normal_member.reassign_network(giver, src)

	for(var/datum/pipeline/line_member as anything in giver.line_members)
		line_member.network = src

	giver.dispose()

	update_network_gases()
	return TRUE

/// Go through membership roster and make sure gases is up to date
/datum/pipe_network/proc/update_network_gases()
	gases.len = 0

	for(var/obj/machinery/atmospherics/normal_member as anything in normal_members)
		var/result = normal_member.return_network_air(src)
		if(result) gases += result

	for(var/datum/pipeline/line_member as anything in line_members)
		gases += line_member.air

/// Perfectly equalize all gases members instantly
/datum/pipe_network/proc/reconcile_air()
	//Calculate totals from individual components
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0
	if (!air_transient)
		air_transient = new()
	air_transient.volume = 0
	ZERO_BASE_GASES(air_transient)

	air_transient.clear_trace_gases()

	for(var/datum/gas_mixture/gas as anything in gases)
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
				update = TRUE

		else
			air_transient.temperature = 0

		//Update individual gas_mixtures by volume ratio
		for(var/datum/gas_mixture/gas as anything in gases)
			#define _RECONCILE_AIR_TRANSFER(GAS, ...) gas.GAS = air_transient.GAS * gas.volume / air_transient.volume ;
			APPLY_TO_GASES(_RECONCILE_AIR_TRANSFER)
			#undef _RECONCILE_AIR_TRANSFER

			gas.temperature = air_transient.temperature

			if(length(air_transient.trace_gases))
				for(var/datum/gas/trace_gas as anything in air_transient.trace_gases)
					var/datum/gas/corresponding = gas.get_or_add_trace_gas_by_type(trace_gas.type)
					corresponding.moles = trace_gas.moles*gas.volume/air_transient.volume
	return TRUE

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

	for(var/datum/gas_mixture/gas as anything in gases)
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
		for(var/datum/gas_mixture/gas as anything in gases)
			#define _EQUALIZE_GASES_UPDATE(GAS, ...) gas.GAS = total_ ## GAS * gas.volume / total_volume;
			APPLY_TO_GASES(_EQUALIZE_GASES_UPDATE)
			#undef _EQUALIZE_GASES_UPDATE

			gas.temperature = temperature

			if(length(total_trace_gases))
				for(var/datum/gas/trace_gas as anything in total_trace_gases)
					var/datum/gas/corresponding = gas.get_or_add_trace_gas_by_type(trace_gas.type)
					corresponding.moles = trace_gas.moles*gas.volume/total_volume

	return TRUE
