datum/pipeline
	var/datum/gas_mixture/air
//
	var/list/obj/machinery/atmospherics/pipe/members
	var/list/obj/machinery/atmospherics/pipe/edges //Used for building networks

	var/datum/pipe_network/network
	var/list/cooldowns

	var/alert_pressure = 0

	disposing()
		if (network)
			network.member_disposing(src)
		network = null

		if(air?.volume)
			temporarily_store_air()
			qdel(air)
		air = null

		if (members)
			for(var/obj/machinery/atmospherics/pipe/member in members)
				member.parent = null
			members.len = 0

		if (edges)
			for(var/obj/machinery/atmospherics/pipe/edge in edges)
				edge.parent = null
			edges.len = 0

		..()

	proc/process()
		if (!air) // null air? oh god!
			/*
			var/obj/machinery/atmospherics/member = null
			if (length(members))
				member = members[0]
			else if (length(edges))
				member = edges[0]
			*/
			//logTheThing(LOG_DEBUG, null, "null air in pipeline([member ? "([log_loc(member)])" : "detached" ])")
			dispose() // kill this network, something is bad
			return
		if(!air.volume)
			return

		//Check to see if pressure is within acceptable limits
		var/pressure = MIXTURE_PRESSURE(air)
		if(pressure > alert_pressure)
			for(var/obj/machinery/atmospherics/pipe/member in members)
				if(!member.check_pressure(pressure))
					break //Only delete 1 pipe per process

		//Allow for reactions
		//air.react() //Should be handled by pipe_network now

	proc/temporarily_store_air()
		//Update individual gas_mixtures by volume ratio

		for(var/obj/machinery/atmospherics/pipe/member in members)
			if (!member.air_temporary)
				member.air_temporary = new
			else
				member.air_temporary.clear_trace_gases()
			member.air_temporary.volume = member.volume

			#define _TEMPORARILY_STORE_GAS(GAS, ...) member.air_temporary.GAS = air.GAS * member.volume / air.volume;
			APPLY_TO_GASES(_TEMPORARILY_STORE_GAS)
			#undef _TEMPORARILY_STORE_GAS

			member.air_temporary.temperature = air.temperature

			if(length(air.trace_gases))
				for(var/datum/gas/trace_gas as anything in air.trace_gases)
					var/datum/gas/corresponding = member.air_temporary.get_or_add_trace_gas_by_type(trace_gas.type)
					corresponding.moles = trace_gas.moles*member.volume/air.volume

	proc/build_pipeline(obj/machinery/atmospherics/pipe/base)
		var/list/possible_expansions = list(base)
		if (!members)
			members = list(base)
		else
			members.len = 0
			members += base

		if (!edges)
			edges = list()
		else
			edges.len = 0

		var/volume = base.volume
		base.parent = src

		if(base.air_temporary)
			if(air)
				qdel(air)
			air = base.air_temporary
			base.air_temporary = null
		else
			air = new /datum/gas_mixture

		while(possible_expansions.len>0)
			for(var/obj/machinery/atmospherics/pipe/borderline in possible_expansions)

				var/list/result = borderline.pipeline_expansion()
				var/edge_check = length(result)

				if(result.len>0)
					for(var/obj/machinery/atmospherics/pipe/item in result)
						if(!(item in members))
							members += item
							possible_expansions += item

							volume += item.volume
							item.parent = src

							if(item.air_temporary)
								air.merge(item.air_temporary)
								item.air_temporary = null

						edge_check--

				if(edge_check>0)
					edges += borderline

				possible_expansions -= borderline

		air.volume = volume

	proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(src in new_network.line_members)
			return 0

		new_network.line_members += src
		network = new_network

		for(var/obj/machinery/atmospherics/pipe/edge in edges)
			for(var/obj/machinery/atmospherics/result in edge.pipeline_expansion())
				if(!istype(result,/obj/machinery/atmospherics/pipe) && (result!=reference))
					result.network_expand(new_network, edge)

		return 1

	proc/return_network(obj/machinery/atmospherics/reference)
		if(!network)
			network = new /datum/pipe_network()
			network.build_network(src, null)
				//technically passing these parameters should not be allowed
				//however pipe_network.build_network(..) and pipeline.network_extend(...)
				//		were setup to properly handle this case

		return network

	proc/mingle_with_turf(turf/simulated/target, mingle_volume)
		if (!target || !air.volume) return
		var/datum/gas_mixture/air_sample = air.remove_ratio(mingle_volume/air.volume)
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
			air.merge(air_sample)

			//turf_air already modified by equalize_gases()

		if(istype(target) && !target.processing)
			if(target.air)
				if(target.air.check_tile_graphic())
					target.update_visuals(target.air)

		if(!isnull(network))
			network.update = 1

	proc/temperature_interact(turf/target, share_volume, thermal_conductivity)
		if(!thermal_conductivity) return // noop if no transfer of heat possible

		var/total_heat_capacity = HEAT_CAPACITY(src.air)
		var/partial_heat_capacity = total_heat_capacity*(share_volume/src.air.volume)
		var/heat = 0
		var/delta_temperature = 0

		if(istype(target, /turf/simulated))
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
					return 1

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

				air.temperature -= heat/total_heat_capacity

		if(!isnull(network))
			network.update = 1
