#ifdef KEEP_A_LIST_OF_HOTLY_PROCESSED_TURFS
var/global/list/turf/hotly_processed_turfs = list()
/proc/filter_out_hotly_processed_turfs()
	. = list()
	for(var/turf/T as anything in hotly_processed_turfs)
		if(istype(T) && T?.atmos_operations > air_master.current_cycle * KEEP_A_LIST_OF_HOTLY_PROCESSED_TURFS)
			. += T
	global.hotly_processed_turfs = .
#endif

/turf
	var/tmp/pressure_difference = 0
	var/tmp/pressure_direction = 0

	var/tmp/obj/hotspot/active_hotspot

#ifdef ATMOS_PROCESS_CELL_STATS_TRACKING
	var/tmp/process_cell_operations = 0
	var/static/max_process_cell_operations = 0
#endif

#ifdef ATMOS_TILE_STATS_TRACKING
	var/tmp/atmos_operations = 0
	var/static/max_atmos_operations = 0
#endif

/turf/assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
	return FALSE

/turf/return_air()
	//Create gas mixture to hold data for passing
	// TODO this is returning a new air object, but object_tile returns the existing air
	//  This is used in a lot of places and thrown away, so it should be pooled,
	//  But there is no way to tell here if it will be retained or discarded, so
	//  we can't pool the object returned by return_air. Bad news, man.
	var/datum/gas_mixture/GM = new /datum/gas_mixture

	#define _TRANSFER_GAS_TO_GM(GAS, ...) GM.GAS = GAS;
	APPLY_TO_GASES(_TRANSFER_GAS_TO_GM)
	#undef _TRANSFER_GAS_TO_GM

	GM.temperature = temperature

	return GM

/turf/remove_air(amount as num)//, remove_water = 0)
	var/datum/gas_mixture/GM = new /datum/gas_mixture
	var/sum = BASE_GASES_TOTAL_MOLES(src)
	if(sum>0)
		#define _TRANSFER_AMOUNT_TO_GM(GAS, ...) GM.GAS = (GAS / sum) * amount;
		APPLY_TO_GASES(_TRANSFER_AMOUNT_TO_GM)
		#undef _TRANSFER_AMOUNT_TO_GM

	GM.temperature = temperature

	return GM

/turf/proc/high_pressure_movements()
	if(!loc:sanctuary)
		for(var/atom/movable/in_tile as anything in src)
			in_tile.experience_pressure_difference(pressure_difference, pressure_direction)

	pressure_difference = 0

/turf/proc/consider_pressure_difference(connection_difference, connection_direction)
	if(loc:sanctuary)
		return //no atmos updates in sanctuaries

	if(connection_difference < 0)
		connection_difference = -connection_difference
		connection_direction = turn(connection_direction, 180)

	if(connection_difference > pressure_difference)
		if(!pressure_difference)
			air_master.high_pressure_delta += src
		pressure_difference = connection_difference
		pressure_direction = connection_direction

/turf/simulated/proc/consider_pressure_difference_space(connection_difference)
	for(var/direction in cardinal)
		if(direction & group_border)
			if(!istype(get_step(src,direction),/turf/space))
				continue

			if(!pressure_difference)
				air_master.high_pressure_delta += src
			pressure_direction = direction
			pressure_difference = connection_difference
			return TRUE

/turf/simulated
	jpsUnstable = FALSE
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


	var/tmp/dist_to_space = null

	var/tmp/datum/gas_mixture/air

	var/tmp/processing = TRUE
	var/tmp/being_superconductive = FALSE
	var/tmp/datum/air_group/parent
	var/tmp/group_border = 0
	var/tmp/length_space_border = 0

	var/tmp/air_check_directions = 0 //Do not modify this, just call air_master.queue_update_tile on this

	var/tmp/archived_cycle = 0
	var/tmp/current_cycle = 0

#ifdef ATMOS_ARCHIVING
	ARCHIVED(var/tmp/temperature) //USED ONLY FOR SOLIDS
#endif

	var/tmp/obj/overlay/tile_gas_effect/gas_icon_overlay
	var/tmp/visuals_state

/turf/simulated/proc/update_visuals(datum/gas_mixture/model)
	if (disposed)
		return

	if (model.graphic)
		if (model.graphic != visuals_state)
			if(!gas_icon_overlay)
				gas_icon_overlay = new /obj/overlay/tile_gas_effect
				gas_icon_overlay.set_loc(src)
			else
				gas_icon_overlay.overlays.len = 0

			visuals_state = model.graphic
			UPDATE_TILE_GAS_OVERLAY(visuals_state, gas_icon_overlay, GAS_IMG_PLASMA)
			UPDATE_TILE_GAS_OVERLAY(visuals_state, gas_icon_overlay, GAS_IMG_N2O)
			UPDATE_TILE_GAS_OVERLAY(visuals_state, gas_icon_overlay, GAS_IMG_RAD)
			gas_icon_overlay.dir = pick(cardinal)
	else
		if (gas_icon_overlay)
			qdel(gas_icon_overlay)
			gas_icon_overlay = null

/turf/simulated/New()
	. = ..()

	if(!gas_impermeable)
		air = new /datum/gas_mixture

		#define _TRANSFER_GAS_TO_AIR(GAS, ...) air.GAS = GAS;
		APPLY_TO_GASES(_TRANSFER_GAS_TO_AIR)
		#undef _TRANSFER_GAS_TO_AIR

		air.temperature = temperature

		if(air_master)
			air_master.tiles_to_update |= src
			find_group()

	else
		if(!air_master)
			return
		for(var/direction in cardinal)
			var/turf/simulated/floor/target = get_step(src,direction)
			if(istype(target))
				air_master.tiles_to_update |= target

/turf/simulated/Del()
	if(air_master)
		if(parent)
			air_master.groups_to_rebuild |= parent
			parent.members.Remove(src)
		else
			air_master.active_singletons.Remove(src)

	if(active_hotspot)
		active_hotspot.dispose() // have to call this now to force the lighting cleanup
		if (active_hotspot)
			qdel(active_hotspot)
			active_hotspot = null

	if(being_superconductive)
		air_master.active_super_conductivity.Remove(src)

	if(gas_impermeable)
		for(var/direction in cardinal)
			var/turf/simulated/tile = get_step(src,direction)
			if(air_master && istype(tile) && !tile.gas_impermeable)
				air_master.tiles_to_update |= tile

	qdel(air)
	air = null

	if (gas_icon_overlay)
		qdel(gas_icon_overlay)
		gas_icon_overlay = null

	air = null
	parent = null
	..()

/turf/simulated/assume_air(datum/gas_mixture/giver)
	if(!air)
		return ..()

	if(parent?.group_processing)
		if(!parent.air.check_then_merge(giver))
			parent.suspend_group_processing()
			air.merge(giver)
	else
		air.merge(giver)

		if(!processing)
			if(air.check_tile_graphic())
				update_visuals(air)

	return TRUE

#ifdef ATMOS_ARCHIVING
/turf/simulated/proc/archive()
	if(air) //For open space like floors
		air.archive()

	ARCHIVED(temperature) = temperature
	archived_cycle = air_master.current_cycle
#endif

/turf/simulated/proc/share_air_with_tile(turf/simulated/T)
	return air.share(T.air)

/turf/simulated/proc/mimic_air_with_tile(turf/T)
	return air.mimic(T)

/turf/simulated/return_air()
	if(air)
		if(parent?.group_processing)
			return parent.air
		else
			return air

	else
		return ..()

/turf/simulated/remove_air(amount as num)//, remove_water = 0)
	if(!air)
		return ..()

	var/datum/gas_mixture/removed = null

	if(parent?.group_processing)
		removed = parent.air.check_then_remove(amount)//, remove_water)
		if(!removed)
			parent.suspend_group_processing()
			removed = air.remove(amount)//, remove_water)
	else
		removed = air.remove(amount)//, remove_water)

		if(!processing)
			if(air.check_tile_graphic())
				update_visuals(air)

	return removed


/turf/simulated/proc/update_air_properties() //OPTIMIZE - yes this proc right here sir
	air_check_directions = 0

	for(var/direction in cardinal)
		LAGCHECK(LAG_REALTIME)
		if(gas_cross(get_step(src,direction)))
			air_check_directions |= direction

	if(parent)
		if(parent.borders)
			parent.borders -= src
		if(length_space_border > 0)
			parent.length_space_border -= length_space_border
			length_space_border = 0

		group_border = 0
		for(var/direction in cardinal)
			LAGCHECK(LAG_REALTIME)
			if(air_check_directions & direction)
				var/turf/simulated/T = get_step(src,direction)

				//See if actually a border
				if(!istype(T) || (T.parent!=parent))

					//See what kind of border it is
					if(istype(T,/turf/space) && !istype(T,/turf/space/fluid))
						if(parent.space_borders)
							parent.space_borders |= src
						else
							parent.space_borders = list(src)
						length_space_border++
						group_border |= direction

					else if(issimulatedturf(T))
						if(parent.borders)
							parent.borders |= src
						else
							parent.borders = list(src)
						group_border |= direction


		parent.length_space_border += length_space_border

	if(air_check_directions)
		processing = TRUE
		if(!parent)
			air_master.active_singletons |= src
	else
		processing = FALSE

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
			archive()
		#endif
		current_cycle = air_master.current_cycle

		for(var/direction in cardinal)
			if(air_check_directions&direction) //Grab all valid bordering tiles
				var/turf/simulated/enemy_tile = get_step(src, direction)
				var/connection_difference = 0

				//if(istype(enemy_tile))
				if (enemy_tile.turf_flags & IS_TYPE_SIMULATED)
					#ifdef ATMOS_ARCHIVING
					if(enemy_tile.archived_cycle < archived_cycle) //archive bordering tile information if not already done
						enemy_tile.archive()
					#endif
					var/datum/air_group/sharegroup = enemy_tile.parent //move tile's group to a new variable so we're not referencing multiple layers deep
					if(sharegroup?.group_processing)
						if(sharegroup.current_cycle < current_cycle)
							if(sharegroup.air.check_gas_mixture(air))
								connection_difference = src.air.share(sharegroup.air)
							else
								sharegroup.suspend_group_processing()
								connection_difference = src.air.share(enemy_tile.air)
								//group processing failed so interact with individual tile
					else
						if(enemy_tile.current_cycle < current_cycle)
							connection_difference = src.air.share(enemy_tile.air)
					if(active_hotspot)
						if(!possible_fire_spreads)
							possible_fire_spreads = list()
						possible_fire_spreads += enemy_tile
				else if(!istype(enemy_tile, /turf/space/fluid))
					connection_difference = mimic_air_with_tile(enemy_tile)
						//bordering a tile with fixed air properties

				if(connection_difference)
					if(connection_difference > 0)
						consider_pressure_difference(connection_difference, direction)
					else
						enemy_tile.consider_pressure_difference(connection_difference, direction)
	else
		air_master.active_singletons -= src //not active if not processing!
		return


	if(src.air.react() & CATALYST_ACTIVE)
		src.active_hotspot?.catalyst_active = TRUE
	else
		src.active_hotspot?.catalyst_active = FALSE

	if(src.active_hotspot && possible_fire_spreads)
		src.active_hotspot.process(possible_fire_spreads)

	if(src.air.temperature > MINIMUM_TEMPERATURE_START_SUPERCONDUCTION)
		consider_superconductivity(starting = 1)

	if(src.air.check_tile_graphic())
		update_visuals(air)

	if(src.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		hotspot_expose(air.temperature, CELL_VOLUME)
		for(var/atom/movable/item as anything in src)
			item.temperature_expose(src.air, src.air.temperature, CELL_VOLUME)
		temperature_expose(src.air, src.air.temperature, CELL_VOLUME)

	if(src.air.radgas >= RADGAS_MINIMUM_CONTAMINATION_MOLES && !ON_COOLDOWN(src, "radgas_contaminate", RADGAS_CONTAMINATION_COOLDOWN)) //if fallout is in the air, contaminate objects on this tile and consume radgas
		for(var/atom/movable/AM in src)
			if(isintangible(AM) || isobserver(AM) || istype(AM, /obj/overlay) || istype(AM, /obj/effects) || istype(AM, /obj/particle))
				continue
			if(AM.invisibility > INVIS_CLOAK) //invisible things don't get to be radioactive. Because space science reasons.
				continue
			var/list/rad_level = list()
			SEND_SIGNAL(AM, COMSIG_ATOM_RADIOACTIVITY, rad_level)
			if(max(rad_level) > RADGAS_MAXIMUM_CONTAMINATION)
				continue
			AM.AddComponent(/datum/component/radioactive,min(src.air.radgas, RADGAS_MAXIMUM_CONTAMINATION_TICK),TRUE,FALSE)
			src.air.radgas -= min(src.air.radgas, RADGAS_MAXIMUM_CONTAMINATION_TICK)/RADGAS_CONTAMINATION_PER_MOLE
			if(src.air.radgas < RADGAS_MINIMUM_CONTAMINATION_MOLES)
				break //no point continuing if we've dropped below threshold

	return 1

/turf/simulated/proc/super_conduct()
	var/conductivity_directions = 0
	if(gas_impermeable)
		//Does not participate in air exchange, so will conduct heat across all four borders at this time
		conductivity_directions = NORTH|SOUTH|EAST|WEST

		#ifdef ATMOS_ARCHIVING
		if(archived_cycle < air_master.current_cycle)
			archive()
		#endif

	else
		//Does particate in air exchange so only consider directions not considered during process_cell()
		conductivity_directions = ~air_check_directions & (NORTH|SOUTH|EAST|WEST)

	if(conductivity_directions > 0)
		//Conduct with tiles around me
		for(var/direction in cardinal)
			if(conductivity_directions&direction)
				var/turf/neighbor = get_step(src,direction)
				if (!neighbor) continue

				//if(istype(neighbor, /turf/simulated)) //anything under this subtype will share in the exchange
				if(neighbor.turf_flags & IS_TYPE_SIMULATED) //blahhh danger
					var/turf/simulated/modeled_neighbor = neighbor

					#ifdef ATMOS_ARCHIVING
					if(modeled_neighbor.archived_cycle < air_master.current_cycle)
						modeled_neighbor.archive()
					#endif

					if(modeled_neighbor.air)
						if(air) //Both tiles are open

							if(modeled_neighbor.parent && modeled_neighbor.parent.group_processing)
								if(parent?.group_processing)
									//both are acting as a group
									//modified using construct developed in datum/air_group/share_air_with_group(...)

									var/result = parent.air.check_both_then_temperature_share(modeled_neighbor.parent.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
									if(result==0)
										//have to deconstruct parent air group

										parent.suspend_group_processing()
										if(!modeled_neighbor.parent.air.check_me_then_temperature_share(air, WINDOW_HEAT_TRANSFER_COEFFICIENT))
											//may have to deconstruct neighbors air group

											modeled_neighbor.parent.suspend_group_processing()
											air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
									else if(result==-1)
										// have to deconstruct neighbors air group but not mine

										modeled_neighbor.parent.suspend_group_processing()
										parent.air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
								else
									air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
							else
								if(parent?.group_processing)
									if(!parent.air.check_me_then_temperature_share(air, WINDOW_HEAT_TRANSFER_COEFFICIENT))
										//may have to deconstruct neighbors air group

										parent.suspend_group_processing()
										air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)

								else
									air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
				//			boutput(world, "OPEN, OPEN")

						else //Solid but neighbor is open
							if(modeled_neighbor.parent && modeled_neighbor.parent.group_processing)
								if(!modeled_neighbor.parent.air.check_me_then_temperature_turf_share(src, modeled_neighbor.thermal_conductivity))

									modeled_neighbor.parent.suspend_group_processing()
									modeled_neighbor.air.temperature_turf_share(src, modeled_neighbor.thermal_conductivity)
							else
								modeled_neighbor.air.temperature_turf_share(src, modeled_neighbor.thermal_conductivity)
				//			boutput(world, "SOLID, OPEN")

					else
						if(air) //Open but neighbor is solid
							if(parent?.group_processing)
								if(!parent.air.check_me_then_temperature_turf_share(modeled_neighbor, modeled_neighbor.thermal_conductivity))
									parent.suspend_group_processing()
									air.temperature_turf_share(modeled_neighbor, modeled_neighbor.thermal_conductivity)
							else
								air.temperature_turf_share(modeled_neighbor, modeled_neighbor.thermal_conductivity)
				//			boutput(world, "OPEN, SOLID")

						else //Both tiles are solid
							share_temperature_mutual_solid(modeled_neighbor, modeled_neighbor.thermal_conductivity)
				//			boutput(world, "SOLID, SOLID")

					modeled_neighbor.consider_superconductivity()

				else
					if(air) //Open
						if(parent?.group_processing)
							if(!parent.air.check_me_then_temperature_mimic(neighbor, neighbor.thermal_conductivity))
								parent.suspend_group_processing()
								air.temperature_mimic(neighbor, neighbor.thermal_conductivity)
						else
							air.temperature_mimic(neighbor, neighbor.thermal_conductivity)
					else
						mimic_temperature_solid(neighbor, neighbor.thermal_conductivity)

	//Radiate excess tile heat to space
	var/turf/space/sample_space = locate(/turf/space)
	if(sample_space && (temperature > T0C))
	//Considering 0 degC as te break even point for radiation in and out
		mimic_temperature_solid(sample_space, FLOOR_HEAT_TRANSFER_COEFFICIENT)

	//Conduct with air on my tile if I have it
	if(air)
		if(parent?.group_processing)
			if(!parent.air.check_me_then_temperature_turf_share(src, src.thermal_conductivity))
				parent.suspend_group_processing()
				air.temperature_turf_share(src, src.thermal_conductivity)
		else
			air.temperature_turf_share(src, src.thermal_conductivity)


	//Make sure still hot enough to continue conducting heat
	if(air)
		if(air.temperature < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
			being_superconductive = FALSE
			air_master.active_super_conductivity -= src
			return FALSE

	else
		if(temperature < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
			being_superconductive = FALSE
			air_master.active_super_conductivity -= src
			return FALSE

/turf/simulated/proc/mimic_temperature_solid(turf/model, conduction_coefficient)
	var/delta_temperature = (ARCHIVED(temperature) - model.temperature)
	if((src.heat_capacity > 0) && (model.heat_capacity > 0) && (abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))

		var/heat = conduction_coefficient*delta_temperature* \
			(src.heat_capacity*model.heat_capacity/(src.heat_capacity+model.heat_capacity))
		temperature -= heat/src.heat_capacity

/turf/simulated/proc/share_temperature_mutual_solid(turf/simulated/sharer, conduction_coefficient)
	var/delta_temperature = (ARCHIVED(temperature) - sharer.ARCHIVED(temperature))
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER && src.heat_capacity)

		var/heat = conduction_coefficient*delta_temperature* \
			(src.heat_capacity*sharer.heat_capacity/(src.heat_capacity+sharer.heat_capacity))

		temperature -= heat/src.heat_capacity
		sharer.temperature += sharer.heat_capacity != 0 ? heat/sharer.heat_capacity : 0

/turf/simulated/proc/consider_superconductivity(starting)
	if(being_superconductive || !src.thermal_conductivity)
		return FALSE

	if(air)
		if(air.temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
			return FALSE

		if(HEAT_CAPACITY(air) < MOLES_CELLSTANDARD*0.1*0.05)
			return FALSE
	else
		if(temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
			return FALSE

	being_superconductive = TRUE

	air_master.active_super_conductivity += src

/turf/simulated/proc/update_nearby_tiles(need_rebuild)
	if(!air_master)
		return FALSE

	src.selftilenotify() //used in fluids.dm for displaced fluid

	var/turf/simulated/north = get_step(src,NORTH)
	var/turf/simulated/south = get_step(src,SOUTH)
	var/turf/simulated/east = get_step(src,EAST)
	var/turf/simulated/west = get_step(src,WEST)

	if(need_rebuild)
		if(istype(src)) //Rebuild/update nearby group geometry
			if(src.parent)
				air_master.groups_to_rebuild |= src.parent
			else
				air_master.tiles_to_update |= src

		if(istype(north))
			north.tilenotify(src)
			if(north.parent)
				air_master.groups_to_rebuild |= north.parent
			else
				air_master.tiles_to_update |= north
		if(istype(south))
			south.tilenotify(src)
			if(south.parent)
				air_master.groups_to_rebuild |= south.parent
			else
				air_master.tiles_to_update |= south
		if(istype(east))
			east.tilenotify(src)
			if(east.parent)
				air_master.groups_to_rebuild |= east.parent
			else
				air_master.tiles_to_update |= east
		if(istype(west))
			west.tilenotify(src)
			if(west.parent)
				air_master.groups_to_rebuild |= west.parent
			else
				air_master.tiles_to_update |= west
	else
		if(istype(src)) air_master.tiles_to_update |= src
		if(istype(north))
			north.tilenotify(src)
			air_master.tiles_to_update |= north
		if(istype(south))
			south.tilenotify(src)
			air_master.tiles_to_update |= south
		if(istype(east))
			east.tilenotify(src)
			air_master.tiles_to_update |= east
		if(istype(west))
			west.tilenotify(src)
			air_master.tiles_to_update |= west

	if (map_currently_underwater)
		var/turf/space/fluid/n = get_step(src,NORTH)
		var/turf/space/fluid/s = get_step(src,SOUTH)
		var/turf/space/fluid/e = get_step(src,EAST)
		var/turf/space/fluid/w = get_step(src,WEST)
		if(istype(n))
			n.tilenotify(src)
		if(istype(s))
			s.tilenotify(src)
		if(istype(e))
			e.tilenotify(src)
		if(istype(w))
			w.tilenotify(src)

	return TRUE
