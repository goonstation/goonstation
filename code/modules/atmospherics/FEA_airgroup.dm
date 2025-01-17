
/**
 * Air groups are collections of tiles that let us save processing time by treating a bunch of similar tiles as a single tile.
 * This is quite useful because atmospherics processing is quite the time hog and processing one tile is much faster.
 * Whenever our tiles become too different, we can break up and create new smaller groups. */
/datum/air_group
	/// Processing all tiles as one large tile if TRUE.
	var/tmp/group_processing = TRUE

	/// The gas mixture we use for the air group.
	var/tmp/datum/gas_mixture/air = null

	/// Current cycle of the atmospherics master.
	var/tmp/current_cycle = 0

	/// Cycle that our archived vars were made.
	/// The use of archived cycle saves processing power by permitting the archiving step of FET to be rolled into the updating step.
	var/tmp/archived_cycle = 0

	/// Our tiles that border this group to other groups/singletons.
	var/list/turf/simulated/borders

	/// All tiles in this group
	var/list/turf/simulated/members

	/// Tiles that border space
	var/list/turf/simulated/space_borders

	/// Length of our border with space
	var/length_space_border = 0

	// drsingh - lets try caching these lists from process_group, see if we can't reduce the garbage collection
	/// Tiles that border us that either have no group, aka singletons, or are not in group processing mode.
	var/list/turf/simulated/border_individual
	/// Groups that border us and are in group processing mode.
	var/list/datum/air_group/border_group

	//used to send the appropriate border tile of a group to the group proc
	/// Tiles that border us and are in another group that is currently processing.
	var/list/turf/simulated/enemies
	/// Our tiles that border groups that are processing.
	var/list/turf/simulated/self_group_borders
	/// Our tiles that border singletons.
	var/list/turf/simulated/self_tile_borders
	/// If true, will drain the gasses of the airgroup.
	var/spaced = FALSE

// overrides
/datum/air_group/disposing()
	src.air = null
	..()

/datum/air_group/New()
	..()
	src.air = new /datum/gas_mixture

// Group procs

/// Distribute air from the group out to members
/datum/air_group/proc/suspend_group_processing()
	ASSERT(group_processing == TRUE)
	update_tiles_from_group()
	group_processing = FALSE

/// Collect air from the members to the group.
/datum/air_group/proc/resume_group_processing()
	ASSERT(group_processing == FALSE)
	update_group_from_tiles()
	group_processing = TRUE

/// Copy group air information to individual tile air. Used right before turning on group processing.
/datum/air_group/proc/update_group_from_tiles()
	// Single sample? Seems like not very many...
	// Local var, direct access to gas_mixture, no need to pool
	if(!length(members)) //I guess all the areas were BADSPACE!!! OH NO! (Spyguy fix for pick() from empty list)
		qdel(src)
		return FALSE

	var/turf/simulated/sample_member = pick(members)
	if (sample_member.air)
		var/datum/gas_mixture/sample_air = sample_member.air

		src.air.copy_from(sample_air)
		src.air.group_multiplier = length(members)

	return TRUE

/// Copy group air information to individual tile air. Used right before turning off group processing.
/datum/air_group/proc/update_tiles_from_group()
	for(var/turf/simulated/member as anything in members)
		member.air?.copy_from(src.air)

/** If individually processing tiles, checks all member tiles to see if they are close enough that the group may resume group processing.
 *  Returns: False if group should not continue processing, TRUE if it should.
 * Warning: Do not call, called by air_master.process() */
/datum/air_group/proc/check_regroup()
	if(group_processing) return TRUE

	if(!length(members)) //I guess all the areas were BADSPACE!!! OH NO! (Spyguy fix for pick() from empty list)
		qdel(src)
		return FALSE

	var/turf/simulated/sample = pick(members)
	for(var/turf/simulated/member as anything in members)
		if(length(member.active_hotspots))
			return FALSE
		if(member.air?.compare(sample.air))
			continue
		else
			return FALSE

	src.resume_group_processing()
	return TRUE

/// Process the various air groups.
/datum/air_group/proc/process_group(var/datum/controller/process/parent_controller)
	var/abort_group = FALSE
	src.current_cycle = air_master.current_cycle

	if (spaced)
		if (!length_space_border)
			src.unspace_group()
			src.check_regroup()
		else if(!group_processing)
			src.check_regroup()

	if(group_processing) //See if processing this group as a group
		border_individual = null
		border_group = null

		enemies = null //used to send the appropriate border tile of a group to the group proc
		self_group_borders = null
		self_tile_borders = null

#ifdef ATMOS_ARCHIVING
		if(archived_cycle < air_master.current_cycle)
			src.air?.archive()
			src.archived_cycle = air_master.current_cycle
				//Archive air data for use in calculations
				//But only if another group didn't store it for us
#endif

		for(var/turf/simulated/border_tile as anything in src.borders)
			ATMOS_TILE_OPERATION_DEBUG(border_tile)
			for(var/direction in cardinal) //Go through all border tiles and get bordering groups and individuals
				if(border_tile.group_border&direction)
					var/turf/simulated/enemy_tile = get_step(border_tile, direction) //Add found tile to appropriate category
					if(!istype(enemy_tile))
						continue
					ATMOS_TILE_OPERATION_DEBUG(enemy_tile)
					// Tiles can get added to these lists more than once, but that is OK,
					// because groups sharing more than one edge should transfer more air.

					if(enemy_tile.parent?.group_processing) //blahh danger
						// Tile is a border with another group, and the other group is in group processing mode.
						// Build border groups list
						if(isnull(border_group))
							border_group = list(enemy_tile.parent)
							enemies = list(enemy_tile)
							self_group_borders = list(border_tile)
						else
							border_group += enemy_tile.parent
							enemies += enemy_tile
							self_group_borders += border_tile
					else
						// Tile is a border with a singleton, not a group in group processing mode.
						if(isnull(border_individual))
							border_individual = list(enemy_tile = null)
							self_tile_borders = list(border_tile)
						else
							border_individual[enemy_tile] = null
							self_tile_borders += border_tile

		// Process connections to adjacent groups
		var/border_index = 1
		if(border_group)
			for(var/datum/air_group/AG as anything in border_group)
#ifdef ATMOS_ARCHIVING
				if(AG.archived_cycle < archived_cycle)
					//archive other groups information if it has not been archived yet this cycle
					AG.air?.archive()
					AG.archived_cycle = air_master.current_cycle
#endif
				if(AG.current_cycle < src.current_cycle)
					//This if statement makes sure two groups only process their individual connections once!
					//Without it, each connection would be processed a second time as the second group is evaluated

					var/connection_difference = 0
					var/turf/simulated/floor/self_border = self_group_borders[border_index]
					var/turf/simulated/floor/enemy_border = enemies[border_index]
					ATMOS_TILE_OPERATION_DEBUG(self_border)
					ATMOS_TILE_OPERATION_DEBUG(enemy_border)

					var/result = src.air.check_gas_mixture(AG.air)
					if(result == GROUP_CHECK_PASS)
						connection_difference = src.air.share(AG.air)
					else if(result == SHARER_CHECK_FAIL)
						AG.suspend_group_processing()
						connection_difference = src.air.share(enemy_border.air)
					else
						abort_group = TRUE
						break

					if(connection_difference)
						self_border.consider_pressure_difference(connection_difference, get_dir(self_border,enemy_border))

					border_index++

				LAGCHECK(LAG_REALTIME)

		// Process connections to adjacent tiles
		border_index = 1
		if(!abort_group && border_individual)
			for(var/turf/simulated/enemy_tile as anything in border_individual)
				ATMOS_TILE_OPERATION_DEBUG(enemy_tile)

				var/connection_difference = 0
				var/turf/simulated/floor/self_border = self_tile_borders[border_index]

				ATMOS_TILE_OPERATION_DEBUG(self_border)

				if(issimulatedturf(enemy_tile)) //blahhh danger
#ifdef ATMOS_ARCHIVING
					if(enemy_tile.archived_cycle < src.archived_cycle) //archive tile information if not already done
						enemy_tile.air?.archive()
						enemy_tile.ARCHIVED(temperature) = enemy_tile.temperature
						enemy_tile.archived_cycle = air_master.current_cycle
#endif
					if(enemy_tile.current_cycle < src.current_cycle)
						if(src.air.check_gas_mixture(enemy_tile.air))
							connection_difference = src.air.share(enemy_tile.air)
						else
							abort_group = TRUE
							break
				else if(isturf(enemy_tile) && !enemy_tile.density) // optimization, if you ever need unsimmed walls to affect temperature change this
					if(src.air.check_turf(enemy_tile))
						connection_difference = src.air.mimic(enemy_tile)
					else
						abort_group = TRUE
						break

				if(connection_difference)
					self_border.consider_pressure_difference(connection_difference, get_dir(self_border,enemy_tile))

				LAGCHECK(LAG_REALTIME)

		// Process connections to space
		border_index = 1
		if(!abort_group)
			if(length_space_border > 0)
				var/connection_difference = 0
				if(map_currently_underwater)
					var/turf/space/sample = air_master.update_space_sample()

					if(src.air?.check_turf(sample))
						connection_difference = src.air.mimic(sample, length_space_border)
					else
						abort_group = TRUE
				else // faster check for actual space (modified check_turf)
					var/moles = TOTAL_MOLES(src.air)
					if(moles <= MINIMUM_AIR_TO_SUSPEND)
						var/turf/space/sample = air_master.update_space_sample()
						connection_difference = air.mimic(sample, length_space_border)
					else
						abort_group = TRUE

				if(connection_difference)
					for(var/turf/simulated/self_border as anything in space_borders)
						self_border.consider_pressure_difference_space(connection_difference)

		if(abort_group)
			src.suspend_group_processing()
		else
			if(air?.check_tile_graphic())
				for(var/turf/simulated/member as anything in members)
					ATMOS_TILE_OPERATION_DEBUG(member)
					member.update_visuals(air)

					LAGCHECK(LAG_REALTIME)


	// This logic is not inverted because group processing may have been
	// suspended in the above block.
	if(!group_processing) //Revert to individual processing
		// space fastpath if we didn't revert (avoid regrouping tiles prior to processing individual cells)
		if (!abort_group && length(members) && length_space_border)
			if (space_fastpath(parent_controller))
				// If the fastpath resulted in the group being zeroed, return early.
				return

		var/totalPressure = 0
		var/maxTemperature = 0
		for(var/turf/simulated/member as anything in members)
			ATMOS_TILE_OPERATION_DEBUG(member)
			member.process_cell()
			if(member.air)
				ADD_MIXTURE_PRESSURE(member.air, totalPressure)
				maxTemperature = max(maxTemperature, member.air.temperature)
			else
				air_master.groups_to_rebuild[src] = null
			LAGCHECK(LAG_REALTIME)

		if(totalPressure / max(length(members), 1) < 5 && maxTemperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			src.resume_group_processing()
			return
	else
		if(src.air?.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			for(var/turf/simulated/member as anything in members)
				ATMOS_TILE_OPERATION_DEBUG(member)
				member.hotspot_expose(air.temperature, CELL_VOLUME)
				member.consider_superconductivity(starting=1)

				LAGCHECK(LAG_REALTIME)

		src.air?.react()


/** If group processing is off, and the air group is bordered by a space tile, execute a fast evacuation of the air in the group.
 * If the average pressure in the group is < 5kpa, the group will be zeroed.
 * Returns: TRUE if the group is zeroed, FALSE if not. */
/datum/air_group/proc/space_fastpath(var/datum/controller/process/parent_controller)
	var/minDist
	var/turf/space/sample
	. = FALSE
	sample = air_master.update_space_sample()

	var/totalPressure = 0

	for(var/turf/simulated/member as anything in members)
		ATMOS_TILE_OPERATION_DEBUG(member)
/* // commented out temporarily, it will probably have to be reenabled later
		minDist = null
		// find nearest space border tile
		for(var/turf/simulated/b in space_borders)
			if (b == member)
				continue

			var/dist = GET_DIST(b, member)
			if (minDist == null || dist < minDist)
				minDist = dist
*/
		minDist = member.dist_to_space

		// Don't space hotspots, it breaks them
		if(length(member.active_hotspots))
			return FALSE

		if (member.air && minDist)
			var/datum/gas_mixture/member_air = member.air
			// Todo - retain nearest space tile border and apply force proportional to amount
			// of air leaving through it
			member_air.mimic(sample, clamp(length_space_border / (2 * max(1, minDist)), 0.1, 1))
			ADD_MIXTURE_PRESSURE(member_air, totalPressure) // Build your own atmos disaster

		LAGCHECK(LAG_REALTIME)

	if(!members || !length(members))  //bail to resolve div 0
		qdel(src) // die theres no one with you
		return FALSE

	//mbc : bringing this silly fix back in for now
	if (map_currently_underwater)
		if (totalPressure / length(members) < 65)
			space_group()
			return TRUE
	else
		if (totalPressure / length(members) < 5)
			space_group()
			return TRUE

/// Zeroes and spaces the air of the group and resumes group processing.
/datum/air_group/proc/space_group()
	for(var/turf/simulated/member as anything in members)
		member.air?.reset_to_space_gas()
	if (length_space_border)
		spaced = TRUE
		if(!group_processing)
			resume_group_processing()

/// Unspaces the group and stops group processing.
/datum/air_group/proc/unspace_group()
	if(group_processing)
		suspend_group_processing()
	spaced = FALSE
