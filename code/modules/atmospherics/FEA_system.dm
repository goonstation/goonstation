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

	boutput(world, SPAN_ALERT("Geometry processed in [(world.timeofday-start_time)/10] seconds!"))
	#endif


/// This first processes the air_master update/rebuild lists then processes all groups and tiles for air calculations
/datum/controller/air_system/proc/process()
	src.current_cycle++

	src.is_busy = TRUE

	src.process_high_pressure_delta()

	src.is_busy = FALSE
	return TRUE

/// Process any tiles queued for pressure delta movement.
/// Do not call. Used by [/datum/controller/air_system/proc/process].
/datum/controller/air_system/proc/process_high_pressure_delta()
	PROTECTED_PROC(TRUE)
	for(var/turf/simulated/pressurized as anything in src.high_pressure_delta)
		pressurized.high_pressure_movements()

	high_pressure_delta.len = 0
