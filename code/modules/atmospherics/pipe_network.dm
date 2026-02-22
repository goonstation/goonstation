var/global/list/datum/pipe_network/pipe_networks = list()

/datum/pipe_network
	/// All of the gas_mixtures continuously connected in this network
	var/list/datum/gas_mixture/gases
	/// List of non-pipe atmospheric items. Items must add themselves to this list to be processed.
	var/list/obj/machinery/atmospherics/normal_members
	/// List of pipelines to process.
	var/list/datum/pipeline/line_members
	/// Whether to equalise our gases.
	var/update = TRUE
	/// Temporary air datum to distribute out to members during reconcilation.
	var/datum/gas_mixture/air_transient

/datum/pipe_network/New()
	..()
	src.air_transient = new /datum/gas_mixture
	src.gases = list()
	src.normal_members = list()
	src.line_members = list()

/datum/pipe_network/disposing()
	src.update = FALSE
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

/// Remove pipeline from members.
/datum/pipe_network/proc/member_disposing(datum/pipeline/line_member)
	src.gases -= line_member.air
	src.line_members -= line_member

/// Remove gases in args from our gases.
/datum/pipe_network/proc/air_disposing_hook()
	for(var/datum/gas_mixture/a as anything in args)
		src.gases -= a

/// Process reconcilation if [/datum/pipe_network/var/update] is TRUE and processes line members.
/datum/pipe_network/proc/process()
	//Equalize gases amongst pipe if called for
	if(src.update)
		src.update = FALSE
		src.reconcile_air()

	//Give pipelines their process call for pressure checking and what not
	for(var/datum/pipeline/line_member as anything in src.line_members)
		line_member.process()

/// * Generates a roster of pipeline members and normal members.
/// * Notes: Assumes that members will add themselves to appropriate roster in network_expand(). Deletes self if empty roster.
/datum/pipe_network/proc/build_network(obj/machinery/atmospherics/start_normal, obj/machinery/atmospherics/reference)
	if(!start_normal)
		src.dispose()

	start_normal.network_expand(src, reference)

	src.update_network_gases()

	if(length(src.normal_members) || length(src.line_members))
		pipe_networks += src
	else
		src.dispose()

/// Merges giver's normal members and line members into self, deletes giver afterwards.
/datum/pipe_network/proc/merge(datum/pipe_network/giver)
	if(giver == src)
		return FALSE

	src.normal_members |= giver.normal_members

	src.line_members |= giver.line_members

	for(var/obj/machinery/atmospherics/normal_member as anything in giver.normal_members)
		normal_member.reassign_network(giver, src)

	for(var/datum/pipeline/line_member as anything in giver.line_members)
		line_member.network = src

	giver.dispose()

	src.update_network_gases()
	return TRUE

/// Goes through the membership roster and updates all gases to be up to date.
/datum/pipe_network/proc/update_network_gases()
	src.gases.len = 0

	for(var/obj/machinery/atmospherics/normal_member as anything in src.normal_members)
		var/result = normal_member.return_network_air(src)
		if(length(result))
			gases += result

	for(var/datum/pipeline/line_member as anything in src.line_members)
		gases += line_member.air

/// Perfectly equalises all gases in [/datum/pipe_network/var/list/gases]. Fails if volume is negative.
/datum/pipe_network/proc/reconcile_air()
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

	if(src.air_transient.volume <= 0)
		return FALSE

	if(total_heat_capacity > 0)
		src.air_transient.temperature = total_thermal_energy/total_heat_capacity

		//Allow air mixture to react
		if(src.air_transient.react())
			src.update = TRUE

	else
		src.air_transient.temperature = 0 KELVIN

	//Update individual gas_mixtures by volume ratio
	for(var/datum/gas_mixture/gas as anything in src.gases)
		#define _RECONCILE_AIR_TRANSFER(GAS, ...) gas.GAS = src.air_transient.GAS * gas.volume / src.air_transient.volume ;
		APPLY_TO_GASES(_RECONCILE_AIR_TRANSFER)
		#undef _RECONCILE_AIR_TRANSFER

		gas.temperature = src.air_transient.temperature
	return TRUE

//Perfectly equalises all gases given to us in the list. Fails if volume is negative.
proc/equalize_gases(list/datum/gas_mixture/gases)
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

	if(total_volume < 0)
		return FALSE

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

	return TRUE
