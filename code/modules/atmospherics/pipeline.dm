/datum/pipeline
	/// The combined air mixture of all our members.
	var/datum/gas_mixture/air
	/// All the pipes that we own.
	var/list/obj/machinery/atmospherics/pipe/members
	/// List of pipes that border non-pipes. Pipeline extensions start from these.
	var/list/obj/machinery/atmospherics/pipe/edges
	/// The pipe network we belong in.
	var/datum/pipe_network/network
	/// Used for the cooldown system
	var/list/cooldowns
	/// Pressure at which to start checking for ruptures.
	var/alert_pressure = 0

/datum/pipeline/disposing()
	src.network?.member_disposing(src)
	src.network = null

	if(src.air?.volume)
		src.temporarily_store_air()
		qdel(src.air)
	src.air = null

	for(var/obj/machinery/atmospherics/pipe/member as anything in src.members)
		member.parent = null
	src.members = null

	for(var/obj/machinery/atmospherics/pipe/edge as anything in src.edges)
		edge.parent = null
	src.edges = null

	..()

/// Process pipe ruptures.
/datum/pipeline/proc/process()
	if (!src.air) // null air? oh god!
		src.dispose() // kill this network, something is bad
		return
	if(!src.air.volume)
		return

	//Check to see if pressure is within acceptable limits
	var/pressure = MIXTURE_PRESSURE(src.air)
	if(pressure > alert_pressure)
		for(var/obj/machinery/atmospherics/pipe/member as anything in src.members)
			if(!member.check_pressure(pressure))
				break //Only delete 1 pipe per process

/// Temporarily distributes [/datum/pipeline/var/datum/gas_mixture/air] into our members.
/datum/pipeline/proc/temporarily_store_air()
	//Update individual gas_mixtures by volume ratio

	for(var/obj/machinery/atmospherics/pipe/member as anything in src.members)
		if (!member.air_temporary)
			member.air_temporary = new
		member.air_temporary.volume = member.volume

		#define _TEMPORARILY_STORE_GAS(GAS, ...) member.air_temporary.GAS = src.air.GAS * member.volume / src.air.volume;
		APPLY_TO_GASES(_TEMPORARILY_STORE_GAS)
		#undef _TEMPORARILY_STORE_GAS

		member.air_temporary.temperature = src.air.temperature

/// Builds a pipeline out into other pipes.
/datum/pipeline/proc/build_pipeline(obj/machinery/atmospherics/pipe/base)
	var/list/possible_expansions = list(base)
	if (!src.members)
		src.members = list(base)
	else
		src.members.len = 0
		src.members += base

	if (!src.edges)
		src.edges = list()
	else
		src.edges.len = 0

	var/volume = base.volume
	base.parent = src

	if(base.air_temporary)
		if(src.air)
			qdel(src.air)
		src.air = base.air_temporary
		base.air_temporary = null
	else
		src.air = new /datum/gas_mixture

	while(length(possible_expansions))
		for(var/obj/machinery/atmospherics/pipe/borderline as anything in possible_expansions)

			var/list/result = borderline.pipeline_expansion()
			var/edge_check = length(result)

			if(length(result))
				for(var/obj/machinery/atmospherics/pipe/item in result)
					if(!(item in src.members))
						src.members += item
						possible_expansions += item

						volume += item.volume
						item.parent = src

						if(item.air_temporary)
							src.air.merge(item.air_temporary)
							item.air_temporary = null

					edge_check--

			if(edge_check)
				edges += borderline

			possible_expansions -= borderline

	src.air.volume = volume

/// Expands new_network into our pipeline if we are not yet in it.
/datum/pipeline/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(src in new_network.line_members)
		return FALSE

	new_network.line_members += src
	src.network = new_network

	for(var/obj/machinery/atmospherics/pipe/edge as anything in src.edges)
		for(var/obj/machinery/atmospherics/result as anything in edge.pipeline_expansion())
			if(!isnull(result) && !istype(result,/obj/machinery/atmospherics/pipe) && (result!=reference))
				result.network_expand(new_network, edge)

	return TRUE

/// Returns our network, building a new one if we do not yet have one.
/datum/pipeline/proc/return_network(obj/machinery/atmospherics/reference)
	if(!src.network)
		src.network = new /datum/pipe_network()
		src.network.build_network(src, null)
			//technically passing these parameters should not be allowed
			//however pipe_network.build_network(..) and pipeline.network_extend(...)
			//were setup to properly handle this case

	return network

/// Mixes the turf with some volume of our air.
/datum/pipeline/proc/mingle_with_turf(turf/simulated/target, mingle_volume)
	if (!target || !src.air.volume) return
	var/datum/gas_mixture/air_sample = src.air.remove_ratio(mingle_volume/src.air.volume)
	air_sample.volume = mingle_volume

	if(istype(target) && target.parent && target.parent.group_processing)
		//Have to consider preservation of group statuses
		var/datum/gas_mixture/turf_copy = new /datum/gas_mixture

		turf_copy.copy_from(target.parent.air)
		turf_copy.volume = target.parent.air.volume //Copy a good representation of the turf from parent group

		equalize_gases(list(air_sample, turf_copy))
		air.merge(air_sample)

		if(target.parent.air.compare(turf_copy))
			//The new turf would be an acceptable group member so permit the integration

			turf_copy.subtract(target.parent.air)

			target.parent.air.merge(turf_copy)

		else
			//Comparison failure so dissemble group and copy turf

			target.parent.suspend_group_processing()
			target.air.copy_from(turf_copy)
			qdel(turf_copy) // done with this

	else
		var/datum/gas_mixture/turf_air = target.return_air()

		equalize_gases(list(air_sample, turf_air))
		src.air.merge(air_sample)

		//turf_air already modified by equalize_gases()

	if(istype(target) && !target.processing)
		if(target.air)
			if(target.air.check_tile_graphic())
				target.update_visuals(target.air)

	if(!isnull(src.network))
		src.network.update = TRUE

/// Exchanges the heat between the turf and some volume of our air.
/// Thermal_conductivity is used as a factor with 0 meaning no heat transfer and 1 meaning perfect equalisation.
/datum/pipeline/proc/temperature_interact(turf/target, share_volume, thermal_conductivity)
	if(!thermal_conductivity)
		return // noop if no transfer of heat possible

	var/total_heat_capacity = HEAT_CAPACITY(src.air)
	var/partial_heat_capacity = total_heat_capacity*(share_volume/src.air.volume)
	var/heat = 0
	var/delta_temperature = 0

	if(issimulatedturf(target))
		var/turf/simulated/modeled_location = target

		// Turf with walls or without air
		if(modeled_location.gas_impermeable || !modeled_location.air)
			if((modeled_location.heat_capacity>0) && (partial_heat_capacity>0))
				delta_temperature = src.air.temperature - modeled_location.temperature

				heat = thermal_conductivity * delta_temperature * \
					(partial_heat_capacity * modeled_location.heat_capacity/(partial_heat_capacity + modeled_location.heat_capacity))

				src.air.temperature -= heat/total_heat_capacity
				modeled_location.temperature += heat/modeled_location.heat_capacity

		// Normal simulated turfs
		else
			var/sharer_heat_capacity = 0

			if(modeled_location.parent && modeled_location.parent.group_processing)
				delta_temperature = (src.air.temperature - modeled_location.parent.air.temperature)
				sharer_heat_capacity = HEAT_CAPACITY(modeled_location.parent.air)
			else
				delta_temperature = (src.air.temperature - modeled_location.air.temperature)
				sharer_heat_capacity = HEAT_CAPACITY(modeled_location.air)

			var/self_temperature_delta = 0
			var/sharer_temperature_delta = 0

			if((sharer_heat_capacity>0) && (partial_heat_capacity>0))
				heat = thermal_conductivity * delta_temperature * \
					(partial_heat_capacity * sharer_heat_capacity/(partial_heat_capacity + sharer_heat_capacity))

				self_temperature_delta = -heat/total_heat_capacity
				sharer_temperature_delta = heat/sharer_heat_capacity
			else
				return TRUE

			src.air.temperature += self_temperature_delta

			if(modeled_location.parent && modeled_location.parent.group_processing)
				// Check if change sufficient to suspend group processing to limit change to target turf
				if((abs(sharer_temperature_delta) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND) && (abs(sharer_temperature_delta) > MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND*modeled_location.parent.air.temperature))
					modeled_location.parent.suspend_group_processing()
					modeled_location.air.temperature += sharer_temperature_delta

				else
					modeled_location.parent.air.temperature += sharer_temperature_delta/modeled_location.parent.air.group_multiplier
			else
				modeled_location.air.temperature += sharer_temperature_delta

	// Process unsimulated turf
	else
		if((target.heat_capacity>0) && (partial_heat_capacity>0))
			delta_temperature = src.air.temperature - target.temperature

			heat = thermal_conductivity * delta_temperature * \
				(partial_heat_capacity * target.heat_capacity/(partial_heat_capacity + target.heat_capacity))

			src.air.temperature -= heat/total_heat_capacity

	if(!isnull(src.network))
		src.network.update = TRUE
