/datum/air_group
	//Processing all tiles as one large tile if 1
	var/tmp/group_processing = 1

	var/tmp/datum/gas_mixture/air = null

	//cycle that oxygen value represents
	var/tmp/current_cycle = 0

	//cycle that oxygen_archived value represents
	//The use of archived cycle saves processing power by permitting the archiving step of FET
	//	to be rolled into the updating step
	var/tmp/archived_cycle = 0

	//Tiles that connect this group to other groups/individual tiles
	var/list/borders

	//All tiles in this group
	var/list/members

	// Space tiles that border this group
	var/list/space_borders

	// Length of space border
	var/length_space_border = 0

	// drsingh - lets try caching these lists from process_group, see if we can't reduce the garbage collection
	var/list/turf/simulated/border_individual
	var/list/datum/air_group/border_group

	//used to send the appropriate border tile of a group to the group proc
	var/list/turf/simulated/enemies
	var/list/turf/simulated/self_group_borders
	var/list/turf/simulated/self_tile_borders

	var/spaced = 0
	var/spaced_via_group = 0
	var/gencolor = null

// overrides
/datum/air_group/disposing()
	air = null
	..()

/datum/air_group/New()
	..()
	air = new /datum/gas_mixture

// Group procs
/datum/air_group/proc/suspend_group_processing()
	// Distribute air from the group out to members
	update_tiles_from_group()
	group_processing = 0

/datum/air_group/proc/resume_group_processing()
	update_group_from_tiles()
	group_processing = 1

//Copy group air information to individual tile air
//Used right before turning on group processing
/datum/air_group/proc/update_group_from_tiles()
	// Single sample? Seems like not very many...
	// Local var, direct access to gas_mixture, no need to pool
	var/sample_member
	for (var/turf/S in members)
		if (istype(S, /turf/space))
			members -= S
	if(!members || !members.len ) //I guess all the areas were BADSPACE!!! OH NO! (Spyguy fix for pick() from empty list)
		qdel(src)
		return 0
	sample_member = pick(members)
	if (sample_member:air)
		var/datum/gas_mixture/sample_air = sample_member:air

		air.copy_from(sample_air)
		air.group_multiplier = members.len

	return 1

//Copy group air information to individual tile air
//Used right before turning off group processing
/datum/air_group/proc/update_tiles_from_group()
	for(var/turf/simulated/member in members)
		if (member.air) member.air.copy_from(air)

/datum/air_group/proc/archive()
	if (air)
		air.archive()
	archived_cycle = air_master.current_cycle

//If individually processing tiles, checks all member tiles to see if they are close enough
//	that the group may resume group processing
//Warning: Do not call, called by air_master.process()
/datum/air_group/proc/check_regroup()
	//Purpose: Checks to see if group processing should be turned back on
	//Returns: group_processing
	if(group_processing) return 1

	// I don't know why the fuck space tiles are even getting into
	// airgroups, but this should sort of fix it. This is a bad
	// hack and I'm sorry. This should eliminate the runtime
	// "undefined variable: /turf/space/var/air"
	for(var/turf/space/BADSPACE in members)
		if(istype(BADSPACE))
			members -= BADSPACE

	if(!members || !members.len ) //I guess all the areas were BADSPACE!!! OH NO! (Spyguy fix for pick() from empty list)
		qdel(src)
		return 0

	var/turf/simulated/sample = pick(members)
	for(var/turf/simulated/member in members)
		if(member.active_hotspot)
			return 0
		if(member.air && member.air.compare(sample.air)) continue
		else
			return 0

	resume_group_processing()
	return 1


/datum/air_group/proc/process_group(var/datum/controller/process/parent_controller)
	current_cycle = air_master.current_cycle

	if (spaced)
		if (!length_space_border)
			unspace_group()
			check_regroup()
		else if(!group_processing)
			check_regroup()

	if(group_processing) //See if processing this group as a group
		border_individual = null
		border_group = null

		enemies = null //used to send the appropriate border tile of a group to the group proc
		self_group_borders = null
		self_tile_borders = null

		if(archived_cycle < air_master.current_cycle)
			archive()
				//Archive air data for use in calculations
				//But only if another group didn't store it for us

		for(var/turf/simulated/border_tile in src.borders)
			//var/obj/movable/floor/movable_on_me = locate(/obj/movable/floor) in border_tile
			for(var/direction in cardinal) //Go through all border tiles and get bordering groups and individuals
				if(border_tile.group_border&direction)
					var/turf/simulated/enemy_tile = get_step(border_tile, direction) //Add found tile to appropriate category

					// Tiles can get added to these lists more than once, but that is OK,
					// because groups sharing more than one edge should transfer more air.

					//if(istype(enemy_tile) && enemy_tile.parent && enemy_tile.parent.group_processing) //trying the other one
					if(enemy_tile.turf_flags & IS_TYPE_SIMULATED && enemy_tile.parent && enemy_tile.parent.group_processing) //blahh danger

						// Tile is a border with another group, and the other group is in group processing mode.
						// Build border groups list
						if(!border_group)
							border_group = list()
						border_group += enemy_tile.parent

						// Build enemies list
						if(!enemies)
							enemies = list()
						enemies += enemy_tile

						// Build self-group border list
						if(!self_group_borders)
							self_group_borders = list()
						self_group_borders += border_tile
					else
						// Tile is a border with a singleton, not a group in group processing mode.
						// Build individual border list
						if(!border_individual)
							border_individual = list()
						border_individual += enemy_tile

						// Build self-tile-border list
						if(!self_tile_borders)
							self_tile_borders = list()
						self_tile_borders += border_tile

			LAGCHECK(LAG_REALTIME)

		var/abort_group = 0

		// Process connections to adjacent groups
		var/border_index = 1
		if(border_group)
			for(var/datum/air_group/AG in border_group)
				if(AG.archived_cycle < archived_cycle)
					//archive other groups information if it has not been archived yet this cycle
					AG.archive()
				if(AG.current_cycle < current_cycle)
					//This if statement makes sure two groups only process their individual connections once!
					//Without it, each connection would be processed a second time as the second group is evaluated

					var/connection_difference = 0
					var/turf/simulated/floor/self_border
					var/turf/simulated/floor/enemy_border
					if(self_group_borders && self_group_borders.len)
						self_border = self_group_borders[border_index]
					if(enemy_border)
						enemy_border = enemies[border_index]

					var/result = air.check_gas_mixture(AG.air)
					if(result == 1)
						connection_difference = air.share(AG.air)
					else if(result == -1)
						AG.suspend_group_processing()
						connection_difference = air.share(enemy_border.air)
					else
						abort_group = 1
						break

					if(connection_difference && !isnull(enemy_border) && !isnull(self_border))
						if(connection_difference > 0)
							self_border.consider_pressure_difference(connection_difference, get_dir(self_border,enemy_border))
						else
							var/turf/enemy_turf = enemy_border
							if(!isturf(enemy_turf))
								enemy_turf = enemy_border.loc
							enemy_turf.consider_pressure_difference(-connection_difference, get_dir(enemy_turf,self_border))

					border_index++

				LAGCHECK(LAG_REALTIME)

		// Process connections to adjacent tiles
		border_index = 1
		if(!abort_group && border_individual)
			for(var/border_tile in border_individual)
				var/turf/enemy_tile = border_tile

				var/connection_difference = 0
				var/turf/simulated/floor/self_border
				if(self_tile_borders)
					self_border = self_tile_borders[border_index]

				//if(istype(enemy_tile, /turf/simulated)) //trying the other one
				if(enemy_tile.turf_flags & IS_TYPE_SIMULATED) //blahhh danger
					if(enemy_tile:archived_cycle < archived_cycle) //archive tile information if not already done
						enemy_tile:archive()
					if(enemy_tile:current_cycle < current_cycle)
						if(air.check_gas_mixture(enemy_tile:air))
							connection_difference = air.share(enemy_tile:air)
						else
							abort_group = 1
							break
				else if(isturf(enemy_tile))
					if(air.check_turf(enemy_tile))
						connection_difference = air.mimic(enemy_tile)
					else
						abort_group = 1
						break

				if(connection_difference)
					if(connection_difference > 0 && !isnull(self_border))
						self_border.consider_pressure_difference(connection_difference, get_dir(self_border,enemy_tile))
					else
						var/turf/enemy_turf = enemy_tile
						if(!isturf(enemy_turf))
							enemy_turf = enemy_tile.loc
						enemy_turf.consider_pressure_difference(-connection_difference, get_dir(enemy_tile,enemy_turf))

				LAGCHECK(LAG_REALTIME)

		// Process connections to space
		border_index = 1
		if(!abort_group)
			if(length_space_border > 0)
				//var/turf/space/sample = locate()
				var/turf/space/sample = air_master.get_space_sample()
				var/connection_difference = 0

				if(air && sample && air.check_turf(sample))
					connection_difference = air.mimic(sample, length_space_border)
				else
					abort_group = 1

				if(connection_difference)
					for(var/turf/simulated/self_border in space_borders)
						self_border.consider_pressure_difference_space(connection_difference)

		if(abort_group)
			suspend_group_processing()
		else
			if(air && air.check_tile_graphic())
				for(var/turf/simulated/member in members)
					member.update_visuals(air)

					LAGCHECK(LAG_REALTIME)


	// This logic is not inverted because group processing may have been
	// suspended in the above block.
	if(!group_processing) //Revert to individual processing
		// space fastpath
		if (members.len && length_space_border) {
			if (space_fastpath(parent_controller))
				// If the fastpath resulted in the group being zeroed, return early.
				return
		}
		for(var/turf/simulated/member in members)
			member.process_cell()

			LAGCHECK(LAG_REALTIME)
	else
		if(air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			for(var/turf/simulated/member in members)
				member.hotspot_expose(air.temperature, CELL_VOLUME)
				member.consider_superconductivity(starting=1)

				LAGCHECK(LAG_REALTIME)

		air.react()

// If group processing is off, and the air group is bordered by a space tile,
// execute a fast evacuation of the air in the group.
// If the average pressure in the group is < 5kpa, the group will be zeroed
// returns: 1 if the group is zeroed, 0 if not
/datum/air_group/proc/space_fastpath(var/datum/controller/process/parent_controller)
	var/minDist
	var/dist
	var/turf/space/sample
	if (map_currently_underwater)
		//sample = locate(/turf/space/fluid)
		sample = air_master.get_space_sample()
	else
		//sample = locate()
		sample = air_master.get_space_sample()
	if (!sample)
		return 0
	var/totalPressure = 0

	for(var/turf/simulated/member in members)
		minDist = null
		// find nearest space border tile
		for(var/turf/simulated/b in space_borders)
			if (b == member)
				continue

			dist = get_dist(b, member)
			if (minDist == null || dist < minDist)
				minDist = dist

		if (member.air && !isnull(minDist))
			// Todo - retain nearest space tile border and apply force proportional to amount
			// of air leaving through it
			member.air.mimic(sample, CLAMP(length_space_border / (2 * max(1, minDist)), 0.1, 1))
		if (member && member.air)
			totalPressure += member.air.return_pressure()

		LAGCHECK(LAG_REALTIME)

	//mbc : bringing this silly fix back in for now
	if (map_currently_underwater)
		if (totalPressure / members.len < 65)
			space_group()
			return 1
	else
		if (totalPressure / members.len < 5)
			space_group()
			return 1



	return 0

/datum/air_group/proc/space_group()
	for(var/turf/simulated/member in members)
		if (member.air)
			member.air.zero()
	if (length_space_border)
		spaced = 1
		resume_group_processing()

/datum/air_group/proc/unspace_group()
	suspend_group_processing()
	spaced = 0
