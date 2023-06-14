var/global/list/datum/pipe_network/pipe_networks = list()

/datum/pipe_network
	var/list/datum/gas_mixture/gases //All of the gas_mixtures continuously connected in this network

	var/list/obj/machinery/atmospherics/normal_members
	var/list/datum/pipeline/line_members
	//membership roster to go through for updates and what not

	var/update = 1
	var/datum/gas_mixture/air_transient

/datum/pipe_network/New()
	..()
	src.air_transient = new /datum/gas_mixture
	src.gases = list()
	src.normal_members = list()
	src.line_members = list()

/datum/pipe_network/disposing()
	src.update = 0
	pipe_networks -= src

	src.gases = null

	for(var/obj/machinery/atmospherics/machine as anything in src.normal_members)
		machine.network_disposing(src)
	src.normal_members = null

	for(var/datum/pipeline/member as anything in src.line_members)
		member.network = null
	src.line_members = null

	if (src.air_transient)
		qdel(src.air_transient)
	src.air_transient = null

	..()

/datum/pipe_network/proc/member_disposing(datum/pipeline/line_member)
	src.gases -= line_member.air
	src.line_members -= line_member

/datum/pipe_network/proc/air_disposing_hook()
	for(var/datum/gas_mixture/a as anything in args)
		gases -= a

/datum/pipe_network/proc/process()
	//Equalize gases amongst pipe if called for
	if(src.update)
		src.update = 0
		src.reconcile_air()

	//Give pipelines their process call for pressure checking and what not
	for(var/datum/pipeline/line_member as anything in src.line_members)
		line_member.process()

/datum/pipe_network/proc/build_network(obj/machinery/atmospherics/start_normal, obj/machinery/atmospherics/reference)
	//Purpose: Generate membership roster
	//Notes: Assuming that members will add themselves to appropriate roster in network_expand()

	if(!start_normal)
		src.dispose()

	start_normal.network_expand(src, reference)

	src.update_network_gases()

	if(length(src.normal_members) || length(src.line_members))
		pipe_networks += src
	else
		src.dispose()

/datum/pipe_network/proc/merge(datum/pipe_network/giver)
	if(giver == src)
		return 0

	src.normal_members |= giver.normal_members

	src.line_members |= giver.line_members

	for(var/obj/machinery/atmospherics/normal_member as anything in giver.normal_members)
		normal_member.reassign_network(giver, src)

	for(var/datum/pipeline/line_member as anything in giver.line_members)
		line_member.network = src

	giver.dispose()

	src.update_network_gases()
	return 1

/datum/pipe_network/proc/update_network_gases()
	//Go through membership roster and make sure gases is up to date

	src.gases.len = 0

	for(var/obj/machinery/atmospherics/normal_member as anything in src.normal_members)
		var/result = normal_member.return_network_air(src)
		if(result)
			gases += result

	for(var/datum/pipeline/line_member as anything in src.line_members)
		gases += line_member.air

/datum/pipe_network/proc/reconcile_air()
	//Perfectly equalize all gases members instantly

	//Calculate totals from individual components
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0
	if (!src.air_transient)
		src.air_transient = new()
	src.air_transient.volume = 0
	ZERO_GASES(src.air_transient)

	for(var/datum/gas_mixture/gas as anything in src.gases)
		src.air_transient.volume += gas.volume
		total_thermal_energy += THERMAL_ENERGY(gas)
		total_heat_capacity += HEAT_CAPACITY(gas)

		#define _RECONCILE_AIR(GAS, ...) air_transient.GAS += gas.GAS;
		APPLY_TO_GASES(_RECONCILE_AIR)
		#undef _RECONCILE_AIR

	if(src.air_transient.volume > 0)

		if(total_heat_capacity > 0)
			src.air_transient.temperature = total_thermal_energy/total_heat_capacity

			//Allow air mixture to react
			if(src.air_transient.react())
				src.update = 1

		else
			src.air_transient.temperature = 0

		//Update individual gas_mixtures by volume ratio
		for(var/datum/gas_mixture/gas as anything in src.gases)
			#define _RECONCILE_AIR_TRANSFER(GAS, ...) gas.GAS = src.air_transient.GAS * gas.volume / src.air_transient.volume ;
			APPLY_TO_GASES(_RECONCILE_AIR_TRANSFER)
			#undef _RECONCILE_AIR_TRANSFER

			gas.temperature = src.air_transient.temperature
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

	for(var/datum/gas_mixture/gas as anything in gases)
		total_volume += gas.volume
		total_thermal_energy += THERMAL_ENERGY(gas)
		total_heat_capacity += HEAT_CAPACITY(gas)

		#define _EQUALIZE_GASES_ADD_TO_TOTAL(GAS, ...) total_ ## GAS += gas.GAS;
		APPLY_TO_GASES(_EQUALIZE_GASES_ADD_TO_TOTAL)
		#undef _EQUALIZE_GASES_ADD_TO_TOTAL

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

	return 1
