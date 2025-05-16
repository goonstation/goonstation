#ifdef KEEP_A_LIST_OF_HOTLY_PROCESSED_TURFS
var/global/list/turf/hotly_processed_turfs = list()
/proc/filter_out_hotly_processed_turfs()
	. = list()
	for(var/turf/T as anything in hotly_processed_turfs)
		if(istype(T) && T?.atmos_operations > air_master.current_cycle * KEEP_A_LIST_OF_HOTLY_PROCESSED_TURFS)
			. += T
	global.hotly_processed_turfs = .
#endif

/atom/movable/tile_gas_effect
	name = ""
	density = FALSE
	mouse_opacity = 0
	anchored = ANCHORED_ALWAYS
	pass_unstable = FALSE
	mat_changename = FALSE
	mat_changedesc = FALSE
	event_handler_flags = IMMUNE_OCEAN_PUSH | IMMUNE_TRENCH_WARP

	meteorhit()
		return

	ex_act()
		return

	track_blood()
		src.tracked_blood = null
		return

/turf
	/// Pressure delta between us and some turf.
	var/tmp/pressure_difference = 0
	/// The direction of the pressure delta.
	var/tmp/pressure_direction = 0
	/// Current fire object on us.
	var/tmp/list/atom/movable/hotspot/active_hotspots

#ifdef ATMOS_PROCESS_CELL_STATS_TRACKING
	var/tmp/process_cell_operations = 0
	var/static/max_process_cell_operations = 0
#endif

#ifdef ATMOS_TILE_STATS_TRACKING
	var/tmp/atmos_operations = 0
	var/static/max_atmos_operations = 0
#endif

/turf/New()
	. = ..()
	src.active_hotspots = list()

/// Assumes air into the turf. Use this instead of directly adding to air.
/turf/assume_air(datum/gas_mixture/giver)
	return FALSE

/// Return new gas mixture with the gas variables we start with.
/turf/return_air(direct = FALSE)
	// TODO this is returning a new air object, but object_tile returns the existing air
	//  This is used in a lot of places and thrown away, so it should be pooled,
	//  But there is no way to tell here if it will be retained or discarded, so
	//  we can't pool the object returned by return_air. Bad news, man.
	var/datum/gas_mixture/GM = new /datum/gas_mixture

	#define _TRANSFER_GAS_TO_GM(GAS, ...) GM.GAS = src.GAS;
	APPLY_TO_GASES(_TRANSFER_GAS_TO_GM)
	#undef _TRANSFER_GAS_TO_GM

	GM.temperature = src.temperature

	return GM

/// Return a new gas mixture with a specified amount of moles with the composition of our gas vars.
/turf/remove_air(amount)
	var/datum/gas_mixture/GM = new /datum/gas_mixture
	var/sum = TOTAL_MOLES(src)
	if(sum)
		#define _TRANSFER_AMOUNT_TO_GM(GAS, ...) GM.GAS = (GAS / sum) * amount;
		APPLY_TO_GASES(_TRANSFER_AMOUNT_TO_GM)
		#undef _TRANSFER_AMOUNT_TO_GM

	GM.temperature = src.temperature

	return GM

/// Checks if gas can pass between two turfs. If anything within the turf does not allow passage, the check fails.
/// Returns: TRUE if gas can pass, FALSE if not.
/turf/gas_cross(turf/target)
	if(isnull(target) || target.gas_impermeable || src.gas_impermeable)
		return FALSE
	for(var/atom/movable/AM as anything in src)
		if(!AM.gas_cross(target))
			return FALSE
	for(var/atom/movable/AM as anything in target)
		if(!AM.gas_cross(src))
			return FALSE
	return TRUE

/// Tile that processes things such as air, explosions, and fluids.
/turf/simulated
	pass_unstable = FALSE
	var/static/list/mutable_appearance/gas_overlays = list(
			#ifdef ALPHA_GAS_OVERLAYS
			mutable_appearance('icons/effects/tile_effects.dmi', "plasma-alpha", FLY_LAYER, PLANE_NOSHADOW_ABOVE),
			mutable_appearance('icons/effects/tile_effects.dmi', "sleeping_agent-alpha", FLY_LAYER, PLANE_NOSHADOW_ABOVE),
			mutable_appearance('icons/effects/tile_effects.dmi', "rad_particles-alpha", FLY_LAYER, PLANE_NOSHADOW_ABOVE)
			#else
			mutable_appearance('icons/effects/tile_effects.dmi', "plasma", FLY_LAYER, PLANE_NOSHADOW_ABOVE),
			mutable_appearance('icons/effects/tile_effects.dmi', "sleeping_agent", FLY_LAYER, PLANE_NOSHADOW_ABOVE),
			mutable_appearance('icons/effects/tile_effects.dmi', "rad_particles", FLY_LAYER, PLANE_NOSHADOW_ABOVE)
			#endif
		)

	/// Our distance to the nearest space border.
	var/tmp/dist_to_space = 0
	/// Our gas mixture
	var/tmp/datum/gas_mixture/air
	/// Are we processing atmospherics?
	var/tmp/processing = TRUE
	/// Are we currently radiating heat to other tiles?
	var/tmp/being_superconductive = FALSE
	/// The air group we belong in. Null if we're a singleton.
	var/tmp/datum/air_group/parent
	/// OR of directions in which we border other singletons or groups.
	var/tmp/group_border = 0
	/// The length of our border to space.
	var/tmp/length_space_border = 0
	/// Which directions should we consider for air processing.
	var/tmp/air_check_directions = 0 //Do not modify this, just call air_master.queue_update_tile on this
	/// Which cycle were our archived variables made.
	var/tmp/archived_cycle = 0
	/// What cycle are we on currently.
	var/tmp/current_cycle = 0

#ifdef ATMOS_ARCHIVING
	ARCHIVED(var/tmp/temperature) //USED ONLY FOR SOLIDS
#endif
	/// The overlay used to show gases on us such as plasma.
	var/tmp/atom/movable/tile_gas_effect/gas_icon_overlay
	/// Bitfield representing gas graphics on us.
	var/tmp/visuals_state

/// Process moving movable atoms within us based on the pressure differential.
/turf/simulated/proc/high_pressure_movements()
	for(var/atom/movable/in_tile as anything in src)
		in_tile.experience_pressure_difference(pressure_difference, pressure_direction)

	pressure_difference = 0

/** Sets [/turf/simulated/pressure_difference] and [/turf/simulated/pressure_direction] to connection_difference and connection_direction if
	connection_difference is higher than the value of [/turf/simulated/pressure_difference].
 * 	Flips connection_difference and connection_direction if connection_difference was lower than 0.
 * 	Queues us for pressure delta processing if we previously did not have a pressure difference. */
/turf/simulated/proc/consider_pressure_difference(connection_difference, connection_direction)
	if(loc:sanctuary)
		return //no atmos updates in sanctuaries

	if(connection_difference < 0)
		connection_difference = -connection_difference
		connection_direction = turn(connection_direction, 180)

	if(connection_difference > pressure_difference)
		if(!pressure_difference)
			air_master.high_pressure_delta[src] = null
		pressure_difference = connection_difference
		pressure_direction = connection_direction

/** Check if we have have a valid border to space. If so, sets [/turf/simulated/pressure_difference] and [/turf/simulated/pressure_direction]
	to connection_difference and the direction to space.
 * 	Queues us for pressure delta processing if we previously did not have a pressure difference. */
/turf/simulated/proc/consider_pressure_difference_space(connection_difference)
	for(var/direction in cardinal)
		if(direction & src.group_border)
			if(!istype(get_step(src,direction),/turf/space))
				continue

			if(!src.pressure_difference)
				air_master.high_pressure_delta[src] = null
			src.pressure_direction = direction
			src.pressure_difference = connection_difference

/// Updates, or creates, our overlay if [/datum/gas_mixture/var/graphic] on model is different from [/turf/simulated/var/tmp/visuals_state].
/// If model doesn't have a graphic, delete our overlay.
/turf/simulated/proc/update_visuals(datum/gas_mixture/model)

	if (model.graphic)
		if (model.graphic != visuals_state)
			if(!src.gas_icon_overlay)
				src.gas_icon_overlay = new /atom/movable/tile_gas_effect(src)
			else
				src.gas_icon_overlay.overlays.len = 0

			src.visuals_state = model.graphic
			UPDATE_TILE_GAS_OVERLAY(visuals_state, gas_icon_overlay, GAS_IMG_PLASMA)
			UPDATE_TILE_GAS_OVERLAY(visuals_state, gas_icon_overlay, GAS_IMG_N2O)
			UPDATE_TILE_GAS_OVERLAY(visuals_state, gas_icon_overlay, GAS_IMG_RAD)
			src.gas_icon_overlay.dir = pick(cardinal)
	else
		if (src.gas_icon_overlay)
			qdel(gas_icon_overlay)
			src.gas_icon_overlay = null

/turf/simulated/New()
	. = ..()

	if(!src.gas_impermeable)
		src.air = new /datum/gas_mixture

		#define _TRANSFER_GAS_TO_AIR(GAS, ...) air.GAS = GAS;
		APPLY_TO_GASES(_TRANSFER_GAS_TO_AIR)
		#undef _TRANSFER_GAS_TO_AIR

		src.air.temperature = src.temperature

		if(air_master)
			if(explosions.exploding)
				air_master.tiles_to_rebuild[src] = null
			else
				air_master.tiles_to_update[src] = null
				src.find_group()

	else
		if(!air_master)
			return
		for(var/direction in cardinal)
			var/turf/simulated/floor/target = get_step(src,direction)
			if(issimulatedturf(target))
				air_master.tiles_to_update[target] = null

/turf/simulated/Del()
	if(air_master)
		if(src.being_superconductive)
			air_master.active_super_conductivity.Remove(src)

		if(src.parent)
			air_master.groups_to_rebuild[src.parent] = null
			src.parent.members.Remove(src)
		else
			air_master.active_singletons.Remove(src)

		if(src.gas_impermeable)
			for(var/direction in cardinal)
				var/turf/simulated/tile = get_step(src,direction)
				if(issimulatedturf(tile) && !tile.gas_impermeable)
					air_master.tiles_to_update[tile] = null

	for (var/atom/movable/hotspot/hotspot as anything in src.active_hotspots)
		qdel(hotspot)
	src.active_hotspots.len = 0

	qdel(air)
	src.air = null

	if (src.gas_icon_overlay)
		qdel(gas_icon_overlay)
		src.gas_icon_overlay = null

	src.air = null
	src.parent = null
	..()

/// Merges all air from giver into turf or air group. Deletes giver.
/turf/simulated/assume_air(datum/gas_mixture/giver)
	if(!src.air)
		return ..()

	if(src.parent?.group_processing)
		if(!src.parent.air.check_then_merge(giver))
			src.parent.suspend_group_processing()
			src.air.merge(giver)
	else
		src.air.merge(giver)

		if(!src.processing)
			if(src.air.check_tile_graphic())
				src.update_visuals(air)

	return TRUE


/// Returns air mixture of turf or air group, if we have one. If we don't, return [/turf/return_air].
/turf/simulated/return_air(direct = FALSE)
	if(src.parent?.group_processing)
		return src.parent.air
	else if(src.air)
		return src.air
	else
		return ..()

/// Removes some moles from turf or air group.
/turf/simulated/remove_air(amount)
	if(!src.air)
		return ..()

	var/datum/gas_mixture/removed = null

	if(parent?.group_processing)
		removed = src.parent.air.check_then_remove(amount)
		if(!removed)
			src.parent.suspend_group_processing()
			removed = src.air.remove(amount)
	else
		removed = src.air.remove(amount)

		if(!src.processing)
			if(src.air.check_tile_graphic())
				src.update_visuals(air)

	return removed

/// Updates parent, processing, air checking directions, and space borders.
/turf/simulated/proc/update_air_properties() //OPTIMIZE - yes this proc right here sir
	src.air_check_directions = 0

	for(var/direction in cardinal)
		if(src.gas_cross(get_step(src,direction)))
			src.air_check_directions |= direction

	if(src.parent)
		src.parent.borders?.Remove(src)
		if(src.length_space_border)
			src.parent.length_space_border -= src.length_space_border
			src.length_space_border = 0

		src.group_border = 0
		for(var/direction in cardinal)
			LAGCHECK(LAG_REALTIME)
			if(src.air_check_directions & direction)
				var/turf/simulated/T = get_step(src,direction)

				//See if actually a border
				if(!issimulatedturf(T) || (T.parent != src.parent))
					//See what kind of border it is
					if(istype(T,/turf/space) && !istype(T,/turf/space/fluid))
						if(src.parent.space_borders)
							src.parent.space_borders[src] = null
						else
							src.parent.space_borders = list()
							src.parent.space_borders[src] = null
						src.length_space_border++
						src.group_border |= direction

					else if(issimulatedturf(T))
						if(src.parent.borders)
							src.parent.borders[src] = null
						else
							src.parent.borders = list()
							src.parent.borders[src] = null
						src.group_border |= direction

		src.parent.length_space_border += src.length_space_border

	if(src.air_check_directions || length(src.active_hotspots))
		src.processing = TRUE
		if(!src.parent)
			air_master.active_singletons[src] = null
	else
		src.processing = FALSE

/// Does a fair amount. Shares with neighbors, updates hotspots, update graphics, checks superconductivity, the whole nine yards.
/turf/simulated/proc/process_cell()
	#ifdef ATMOS_PROCESS_CELL_STATS_TRACKING
	src.process_cell_operations++
	max_process_cell_operations = max(max_process_cell_operations, src.process_cell_operations)
	#endif

	ATMOS_TILE_OPERATION_DEBUG(src)
	var/list/turf/simulated/possible_fire_spreads
	if(src.processing && src.air)
		#ifdef ATMOS_ARCHIVING
		if(archived_cycle < air_master.current_cycle) //archive self if not already done
			src.air?.archive()
			src.ARCHIVED(temperature) = src.temperature
			src.archived_cycle = air_master.current_cycle
		#endif
		src.current_cycle = air_master.current_cycle

		for(var/direction in cardinal)
			if(air_check_directions&direction) //Grab all valid bordering tiles
				var/turf/simulated/enemy_tile = get_step(src, direction)
				var/connection_difference = 0

				if (issimulatedturf(enemy_tile))
					#ifdef ATMOS_ARCHIVING
					if(enemy_tile.archived_cycle < archived_cycle) //archive bordering tile information if not already done
						enemy_tile.air?.archive()
						enemy_tile.ARCHIVED(temperature) = enemy_tile.temperature
						enemy_tile.archived_cycle = air_master.current_cycle
					#endif
					var/datum/air_group/sharegroup = enemy_tile.parent //move tile's group to a new variable so we're not referencing multiple layers deep
					if(sharegroup?.group_processing)
						if(sharegroup.current_cycle < src.current_cycle)
							if(sharegroup.air.check_gas_mixture(air))
								connection_difference = src.air.share(sharegroup.air)
							else
								sharegroup.suspend_group_processing()
								connection_difference = src.air.share(enemy_tile.air)
								//group processing failed so interact with individual tile
					else
						if(enemy_tile.current_cycle < current_cycle)
							connection_difference = src.air.share(enemy_tile.air)
					if(length(src.active_hotspots))
						if(!possible_fire_spreads)
							possible_fire_spreads = list()
						possible_fire_spreads += enemy_tile
				else if(!istype(enemy_tile, /turf/space/fluid))
					connection_difference = src.air.mimic(enemy_tile)
						//bordering a tile with fixed air properties

				if(connection_difference)
					src.consider_pressure_difference(connection_difference, direction)
	else
		air_master.active_singletons.Remove(src) //not active if not processing!
		return

	if(src.air.react() & CATALYST_ACTIVE)
		for (var/atom/movable/hotspot/hotspot as anything in src.active_hotspots)
			hotspot.catalyst_active = TRUE
	else
		for (var/atom/movable/hotspot/hotspot as anything in src.active_hotspots)
			hotspot.catalyst_active = FALSE

	for (var/atom/movable/hotspot/hotspot as anything in src.active_hotspots)
		hotspot.process(possible_fire_spreads)

	if(src.air.temperature > MINIMUM_TEMPERATURE_START_SUPERCONDUCTION)
		src.consider_superconductivity(starting = 1)

	if(src.air.check_tile_graphic())
		src.update_visuals(air)

	if(src.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		src.hotspot_expose(air.temperature, CELL_VOLUME)
		for(var/atom/movable/AM as anything in src)
			AM.temperature_expose(src.air, src.air.temperature, CELL_VOLUME)
		src.temperature_expose(src.air, src.air.temperature, CELL_VOLUME)

	if(src.air.radgas >= RADGAS_MINIMUM_CONTAMINATION_MOLES && !ON_COOLDOWN(src, "radgas_contaminate", RADGAS_CONTAMINATION_COOLDOWN)) //if fallout is in the air, contaminate objects on this tile and consume radgas
		for(var/atom/movable/AM as anything in src)
			if(isintangible(AM) || isobserver(AM) || istype(AM, /obj/overlay) || istype(AM, /obj/effects) || istype(AM, /obj/particle))
				continue
			if(AM.invisibility > INVIS_CLOAK) //invisible things don't get to be radioactive. Because space science reasons.
				continue
			var/list/rad_level = list()
			SEND_SIGNAL(AM, COMSIG_ATOM_RADIOACTIVITY, rad_level)
			if(max(rad_level) > RADGAS_MAXIMUM_CONTAMINATION)
				continue
			AM.AddComponent(/datum/component/radioactive,min(src.air.radgas + max(rad_level), max(rad_level) + RADGAS_MAXIMUM_CONTAMINATION_TICK),TRUE,FALSE)
			src.air.radgas -= min(src.air.radgas, RADGAS_MAXIMUM_CONTAMINATION_TICK)/RADGAS_CONTAMINATION_PER_MOLE
			if(src.air.radgas < RADGAS_MINIMUM_CONTAMINATION_MOLES)
				break //no point continuing if we've dropped below threshold

	return TRUE

/// Conducts heat to other tiles through open and closed turfs, also radiates some heat into space.
/turf/simulated/proc/super_conduct()
	var/conductivity_directions = 0
	if(gas_impermeable)
		//Does not participate in air exchange, so will conduct heat across all four borders at this time
		conductivity_directions = NORTH|SOUTH|EAST|WEST

		#ifdef ATMOS_ARCHIVING
		if(archived_cycle < air_master.current_cycle)
			src.air?.archive()
			src.ARCHIVED(temperature) = src.temperature
			src.archived_cycle = air_master.current_cycle
		#endif

	else
		//Does particate in air exchange so only consider directions not considered during process_cell()
		conductivity_directions = ~air_check_directions & (NORTH|SOUTH|EAST|WEST)

	if(conductivity_directions)
		//Conduct with tiles around me
		for(var/direction in cardinal)
			if(conductivity_directions&direction)
				var/turf/neighbor = get_step(src,direction)
				if (!neighbor) continue

				if(issimulatedturf(neighbor)) //blahhh danger
					var/turf/simulated/modeled_neighbor = neighbor

					#ifdef ATMOS_ARCHIVING
					if(modeled_neighbor.archived_cycle < air_master.current_cycle)
						modeled_neighbor.air?.archive()
						modeled_neighbor.ARCHIVED(temperature) = modeled_neighbor.temperature
						modeled_neighbor.archived_cycle = air_master.current_cycle
					#endif

					if(modeled_neighbor.air)
						if(src.air) //Both tiles are open
							if(modeled_neighbor.parent?.group_processing)
								if(src.parent?.group_processing)
									//both are acting as a group
									//modified using construct developed in datum/air_group/share_air_with_group(...)
									var/result = src.parent.air.check_both_then_temperature_share(modeled_neighbor.parent.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
									if(result == SELF_CHECK_FAIL)
										//have to deconstruct parent air group
										src.parent.suspend_group_processing()
										if(!modeled_neighbor.parent.air.check_me_then_temperature_share(air, WINDOW_HEAT_TRANSFER_COEFFICIENT))
											//may have to deconstruct neighbors air group
											modeled_neighbor.parent.suspend_group_processing()
											src.air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)

									else if(result == SHARER_CHECK_FAIL)
										// have to deconstruct neighbors air group but not mine
										modeled_neighbor.parent.suspend_group_processing()
										src.parent.air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)

								else
									src.air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
							else
								if(src.parent?.group_processing)
									if(!src.parent.air.check_me_then_temperature_share(air, WINDOW_HEAT_TRANSFER_COEFFICIENT))
										//may have to deconstruct neighbors air group

										src.parent.suspend_group_processing()
										src.air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)

								else
									src.air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)

						else //Solid but neighbor is open
							if(modeled_neighbor.parent?.group_processing)
								if(!modeled_neighbor.parent.air.check_me_then_temperature_turf_share(src, modeled_neighbor.thermal_conductivity))
									modeled_neighbor.parent.suspend_group_processing()
									modeled_neighbor.air.temperature_turf_share(src, modeled_neighbor.thermal_conductivity)
							else
								modeled_neighbor.air.temperature_turf_share(src, modeled_neighbor.thermal_conductivity)

					else
						if(src.air) //Open but neighbor is solid
							if(src.parent?.group_processing)
								if(!src.parent.air.check_me_then_temperature_turf_share(modeled_neighbor, modeled_neighbor.thermal_conductivity))
									src.parent.suspend_group_processing()
									src.air.temperature_turf_share(modeled_neighbor, modeled_neighbor.thermal_conductivity)
							else
								air.temperature_turf_share(modeled_neighbor, modeled_neighbor.thermal_conductivity)

						else //Both tiles are solid
							src.share_temperature_mutual_solid(modeled_neighbor, modeled_neighbor.thermal_conductivity)

					modeled_neighbor.consider_superconductivity()

				else
					if(src.air) //Open
						if(src.parent?.group_processing)
							if(!src.parent.air.check_me_then_temperature_mimic(neighbor, neighbor.thermal_conductivity))
								src.parent.suspend_group_processing()
								src.air.temperature_mimic(neighbor, neighbor.thermal_conductivity)
						else
							src.air.temperature_mimic(neighbor, neighbor.thermal_conductivity)
					else
						src.mimic_temperature_solid(neighbor, neighbor.thermal_conductivity)

	//Radiate excess tile heat to space
	if(temperature > T0C)
		//Considering 0 degC as te break even point for radiation in and out
		src.mimic_temperature_solid(locate(/turf/space), FLOOR_HEAT_TRANSFER_COEFFICIENT)

	//Conduct with air on my tile if I have it
	if(src.air)
		if(src.parent?.group_processing)
			if(!src.parent.air.check_me_then_temperature_turf_share(src, src.thermal_conductivity))
				src.parent.suspend_group_processing()
				src.air.temperature_turf_share(src, src.thermal_conductivity)
		else
			src.air.temperature_turf_share(src, src.thermal_conductivity)

		if(src.air.temperature < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
			src.being_superconductive = FALSE
			air_master.active_super_conductivity -= src
			return FALSE

	else
		if(temperature < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
			src.being_superconductive = FALSE
			air_master.active_super_conductivity -= src
			return FALSE

/// Similar to share_temperature_mutual_solid(...) but the model is not modified.
/turf/simulated/proc/mimic_temperature_solid(turf/model, conduction_coefficient)
	var/delta_temperature = (src.ARCHIVED(temperature) - model.temperature)
	if((src.heat_capacity > 0) && (model.heat_capacity > 0) && (abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))

		var/heat = conduction_coefficient*delta_temperature* \
			(src.heat_capacity*model.heat_capacity/(src.heat_capacity+model.heat_capacity))
		src.temperature -= heat/src.heat_capacity

/// Share heat between solid turfs with a conduction_coefficient as a factor for efficiency.
/turf/simulated/proc/share_temperature_mutual_solid(turf/simulated/sharer, conduction_coefficient)
	var/delta_temperature = (src.ARCHIVED(temperature) - sharer.ARCHIVED(temperature))
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER && src.heat_capacity)

		var/heat = conduction_coefficient*delta_temperature* \
			(src.heat_capacity*sharer.heat_capacity/(src.heat_capacity+sharer.heat_capacity))

		src.temperature -= heat/src.heat_capacity
		sharer.temperature += sharer.heat_capacity != 0 ? heat/sharer.heat_capacity : 0

/// Checks if we're hot enough to start superconducting heat to other tiles.
/turf/simulated/proc/consider_superconductivity(starting)
	if(src.being_superconductive || !src.thermal_conductivity)
		return FALSE

	if(src.air)
		if(src.air.temperature < (starting ? MINIMUM_TEMPERATURE_START_SUPERCONDUCTION : MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
			return FALSE

		if(HEAT_CAPACITY(air) < MOLES_CELLSTANDARD*0.1*0.05)
			return FALSE
	else
		if(temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
			return FALSE

	src.being_superconductive = TRUE

	air_master.active_super_conductivity[src] = null

/// Tells our neighbors it's time to update.
/turf/proc/update_nearby_tiles(need_rebuild)
	if(!air_master)
		return FALSE

	src.selftilenotify() //used in fluids.dm for displaced fluid
	var/turf/simulated/center = src //this is fine and normal

	if(need_rebuild) // time to make new groups
		if(issimulatedturf(center)) //Rebuild/update nearby group geometry
			if(center.parent)
				air_master.groups_to_rebuild[center.parent] = null
			else
				air_master.tiles_to_update[center] = null

		for(var/direction in cardinal)
			var/turf/simulated/T = get_step(src, direction)
			if(istype(T))
				T.tilenotify(src)
				if(T.parent)
					air_master.groups_to_rebuild[T.parent] = null
				else
					air_master.tiles_to_update[T] = null
	else // or not. just update neigbors.
		if(issimulatedturf(center))
			air_master.tiles_to_update[src] = null

		for(var/direction in cardinal)
			var/turf/simulated/T = get_step(src, direction)
			if(istype(T))
				T.tilenotify(src)
				air_master.tiles_to_update[T] = null

	if (map_currently_underwater)
		for(var/direction in cardinal)
			var/turf/simulated/T = get_step(src, direction)
			if(istype(T))
				T.tilenotify(src)

	return TRUE

/turf/simulated/proc/stabilize()
	ZERO_GASES(src.air)
#ifdef ATMOS_ARCHIVING
	ZERO_ARCHIVED_GASES(src.air)
	src.air.ARCHIVED(temperature) = null
#endif
	src.air.oxygen = MOLES_O2STANDARD
	src.air.nitrogen = MOLES_N2STANDARD
	src.air.fuel_burnt = 0
	src.air.temperature = T20C
	if(src.parent?.group_processing)
		src.parent.suspend_group_processing()
