/* Overview:
The air_master global variable is the workhorse for the system.

Why are you archiving data before modifying it?
	The general concept with archiving data and having each tile keep track of when they were last updated is to keep everything symmetric
		and totally independent of the order they are read in an update cycle.
	This prevents abnormalities like air/fire spreading rapidly in one direction and super slowly in the other.

Why not just archive everything and then calculate?
	Efficiency. While a for-loop that goes through all tiles and groups to archive their information before doing any calculations seems simple, it is
		slightly less efficient than the archive-before-modify/read method.

Why is there a cycle check for calculating data as well?
	This ensures that every connection between group-tile, tile-tile, and group-group is only evaluated once per loop.
*/

var/global/datum/controller/air_system/air_master
var/global/total_gas_mixtures = 0

/// Checks whether or not gases can pass through. Called by [/turf/gas_cross] for all atoms within the turf.
/// Returns: TRUE for allowed pass and FALSE for denied pass.
/atom/proc/gas_cross(turf/target)
	return !src.gas_impermeable

/datum/controller/air_system
	/// List of air groups to be processed.
	var/list/datum/air_group/air_groups = list()
	/// List of turfs without a group to be processed.
	var/list/turf/simulated/active_singletons = list()

	/// Tiles queued to be processed for superconductivity.
	var/list/turf/simulated/active_super_conductivity = list()
	/// Tiles queued to be processed for pressure delta movement.
	var/list/turf/simulated/high_pressure_delta = list()

	/// Turfs that are in this list have their border data updated before the next air calculations for a cycle.
	///Place turfs in this list rather than call the proc directly to prevent race conditions
	var/list/turf/tiles_to_update = list()

	/** A list of air groups that have had their geometry occluded and thus may need to be split in half.
	 *	A set of adjacent groups put in here will join together if validly connected.
	 *	This is done before air system calculations for a cycle. */
	var/list/datum/air_group/groups_to_rebuild = list()

	/// List of single turfs to rebuild together with [groups_to_rebuild].
	var/list/turf/simulated/tiles_to_rebuild = list()

	/// Turfs to be converted to space on the next cycle in case we're busy right now.
	/// Use [/turf/proc/delay_space_conversion] instead of adding to this list directly.
	var/list/turf/tiles_to_space = list()
	/// Current cycle of air_system.
	var/current_cycle = 0
	/// Don't want to accidentally modify something while still processing. Let's keep track if we're busy.
	var/is_busy = FALSE
	/// Self-reference apparently.
	var/datum/controller/process/air_system/parent_controller = null
	/// Much better idea to cache a tile than to keep calling locate()
	var/turf/space/space_sample

/// Updates cached space sample if need be.
/// Returns: New space sample.
/datum/controller/air_system/proc/update_space_sample()
	if (!istype(space_sample, /turf/space))
		space_sample = locate(/turf/space)
	return space_sample

/// Move every simulated turf into a group, then call [/turf/simulated/proc/update_air_properties] on them.
/datum/controller/air_system/proc/setup(datum/controller/process/air_system/controller)
	parent_controller = controller

	#ifdef SKIP_FEA_SETUP
	return
	#else

	boutput(world, SPAN_ALERT("Processing Geometry..."))

	var/start_time = world.timeofday

	for(var/turf/simulated/S in world)
		if(!S.gas_impermeable && !S.parent)
			assemble_group_turf(S)
		S.update_air_properties()

	boutput(world, SPAN_ALERT("Geometry processed in [(world.timeofday-start_time)/10] seconds!"))
	#endif

/// Collects turfs into groups.
/datum/controller/air_system/proc/assemble_group_turf(turf/simulated/base)
	set waitfor = 0
	var/list/turf/simulated/members = list(base) // Confirmed group members
	var/list/turf/simulated/possible_members = list(base) // Possible places for group expansion
	var/list/turf/simulated/possible_borders = list()
	var/list/turf/simulated/possible_space_borders = list()
	var/possible_space_length = 0

	while(length(possible_members)) //Keep expanding, looking for new members
		for(var/turf/simulated/test as anything in possible_members)
			test.length_space_border = 0
			for(var/direction in cardinal)
				var/turf/T = get_step(test,direction)
				if(!(T in members) && test.gas_cross(T))
					if(issimulatedturf(T))
						if(!T:parent)
							possible_members += T
							members += T
						else
							possible_borders[test] = null
					else if(istype(T, /turf/space) && !istype(T, /turf/space/fluid))
						possible_space_borders[test] = null
						test.length_space_border++

			if(test.length_space_border)
				possible_space_length += test.length_space_border
			possible_members -= test

	if(length(members) > 1)
		var/datum/air_group/group = new
		if(length(possible_borders))
			group.borders = possible_borders
		if(length(possible_space_borders))
			group.space_borders = possible_space_borders
			group.length_space_border = possible_space_length

		// Allow groups to determine if group processing is applicable after FEA setup
		if(current_cycle)
			group.group_processing = FALSE

		group.members = members
		air_groups[group] = null

		group.update_group_from_tiles() //Initialize air group variables
		. = group

		for(var/turf/simulated/test as anything in members)
			test.parent = group
			test.processing = FALSE
			air_master.active_singletons.Remove(test)

			test.dist_to_space = 0
			var/dist
			for(var/turf/simulated/possible as anything in possible_space_borders)
				if (possible == test)
					test.dist_to_space = 1
					break
				dist = get_dist(possible, test) //GET_DIST isn't needed here as air groups never transcend z levels nor can turfs be in an object.
				if (!test.dist_to_space || (dist < test.dist_to_space))
					test.dist_to_space = dist
	else
		base.processing = FALSE //singletons at startup are technically unconnected anyway
		base.parent = null

		if(base.air?.check_tile_graphic())
			base.update_visuals(base.air)

/// This first processes the air_master update/rebuild lists then processes all groups and tiles for air calculations
/datum/controller/air_system/proc/process()
	src.current_cycle++

	src.process_tiles_to_space()
	src.is_busy = TRUE

	if(!explosions.exploding)
		if(length(src.groups_to_rebuild) || length(src.tiles_to_rebuild))
			src.process_rebuild_select_groups()
		LAGCHECK(LAG_REALTIME)

		if(length(src.tiles_to_update))
			src.process_update_tiles()
		LAGCHECK(LAG_REALTIME)

	src.process_groups()
	LAGCHECK(LAG_REALTIME)

	src.process_singletons()
	LAGCHECK(LAG_REALTIME)

	src.process_super_conductivity()

	src.process_high_pressure_delta()

	if(current_cycle % 7 == 0) //Check for groups of tiles to resume group processing every 7 cycles
		for(var/datum/air_group/AG as anything in air_groups)
			AG.check_regroup()
			LAGCHECK(LAG_REALTIME)
	src.is_busy = FALSE
	return TRUE

/// Replaces all queued tiles in [/datum/controller/air_system/var/tiles_to_space] with space.
/// Do not call. Used by [/datum/controller/air_system/proc/process].
/datum/controller/air_system/proc/process_tiles_to_space()
	PROTECTED_PROC(TRUE)
	if(length(tiles_to_space))
		for(var/turf/T as anything in tiles_to_space)
			T.ReplaceWithSpaceForce() // If we made it this far, force is appropriate as we know it NEEDs to be updated
		tiles_to_space.len = 0

/// Updates queued tiles.
/// Do not call. Used by [/datum/controller/air_system/proc/process].
/datum/controller/air_system/proc/process_update_tiles()
	PROTECTED_PROC(TRUE)
	for(var/turf/simulated/T as anything in tiles_to_update) // ZEWAKA-ATMOS SPACE + SPACE FLUID LEAKAGE
		T.update_air_properties()
	tiles_to_update.len = 0

/// Process air groups queued for reconstruction. Deconstructs air groups into tiles, then creates new groups from those tiles.
/// Do not call. Used by [/datum/controller/air_system/proc/process].
/datum/controller/air_system/proc/process_rebuild_select_groups()
	PROTECTED_PROC(TRUE)
	var/list/turf/turf_list = list()

	for(var/datum/air_group/turf_AG as anything in groups_to_rebuild) // Deconstruct groups, gathering their old members
		if(turf_AG.group_processing)	// Ensure correct air is used for reconstruction, otherwise parent is destroyed
			turf_AG.suspend_group_processing()
		for(var/turf/simulated/T as anything in turf_AG.members)
			T.parent = null
			turf_list += T
		air_master.air_groups.Remove(turf_AG)
		turf_AG.members.len = 0
		turf_AG.borders?.len = 0
		qdel(turf_AG)
	LAGCHECK(LAG_REALTIME)

	for(var/turf/simulated/S as anything in turf_list) // Have old members try to form new groups
		if(!S.parent)
			src.assemble_group_turf(S)
	LAGCHECK(LAG_REALTIME)

	for(var/turf/simulated/S as anything in tiles_to_rebuild) // update the singletons
		if(!S.parent)
			src.assemble_group_turf(S)
		turf_list += S
	LAGCHECK(LAG_REALTIME)

	for(var/turf/simulated/S as anything in turf_list)
		S.update_air_properties()

	groups_to_rebuild.len = 0
	tiles_to_rebuild.len = 0

/// Process all air groups.
/// Do not call. Used by [/datum/controller/air_system/proc/process].
/datum/controller/air_system/proc/process_groups()
	PROTECTED_PROC(TRUE)
	for(var/datum/air_group/AG as anything in src.air_groups)
		AG?.process_group(parent_controller)
		LAGCHECK(LAG_REALTIME)

/// Process any singletons queued for processing.
/// Do not call. Used by [/datum/controller/air_system/proc/process].
/datum/controller/air_system/proc/process_singletons()
	PROTECTED_PROC(TRUE)
	for(var/turf/simulated/loner as anything in src.active_singletons)
		loner.process_cell()
		LAGCHECK(LAG_REALTIME)

/// Process any tiles queued for superconduction.
/// Do not call. Used by [/datum/controller/air_system/proc/process].
/datum/controller/air_system/proc/process_super_conductivity()
	PROTECTED_PROC(TRUE)
	for(var/turf/simulated/hot_potato as anything in src.active_super_conductivity)
		hot_potato.super_conduct()

/// Process any tiles queued for pressure delta movement.
/// Do not call. Used by [/datum/controller/air_system/proc/process].
/datum/controller/air_system/proc/process_high_pressure_delta()
	PROTECTED_PROC(TRUE)
	for(var/turf/simulated/pressurized as anything in src.high_pressure_delta)
		pressurized.high_pressure_movements()

	high_pressure_delta.len = 0
