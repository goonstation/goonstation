/*
 * This file contains the stuff you need for using JPS (Jump Point Search) pathing, an alternative to A* that skips
 * over large numbers of uninteresting tiles resulting in much quicker pathfinding solutions. Mind that diagonals
 * cost the same as cardinal moves currently, so paths may look a bit strange, but should still be optimal.
 * Ported from TGStation with permission from @Ryll-Ryll, also ryll is cool
 */

/// Pathfind option key; The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
#define POP_MAX_DIST "max_distance"
/// Pathfind option key; Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
#define POP_MIN_DIST "min_distance"
/// Pathfind option key; An ID card representing what access we have and what doors we can open. Its location relative to the pathing atom is irrelevant
#define POP_ID "id"
/// Pathfind option key; Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
#define POP_SIMULATED_ONLY "simulated_only"
/// Pathfind option key; If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
#define POP_EXCLUDE "exclude"
/// Pathfind option key; Whether to find only paths consisting of cardinal steps.
#define POP_CARDINAL_ONLY "cardinal_only"
/// Pathfind option key; Whether or not to check if doors are blocked (welded, out of power, locked, etc...)
#define POP_DOOR_CHECK "do_doorcheck"
/// Pathfind option key; Whether to ignore passability caching (for extremely weird cases; like pods.)
#define POP_IGNORE_CACHE "ignore_cache"

/**
 * This is the proc you use whenever you want to have pathfinding more complex than "try stepping towards the thing".
 *
 * Arguments:
 * * caller: The movable atom that's trying to find the path
 * * ends: What we're trying to path to. It doesn't matter if this is a turf or some other atom, we're gonna just path to the turf it's on anyway
 * * max_distance: The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * * mintargetdistance: Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
 * * id: An ID card representing what access we have and what doors we can open. Its location relative to the pathing atom is irrelevant
 * * simulated_only: Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * * exclude: If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * * skip_first: Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break movement for some creatures.
 * * cardinal_only: Whether to find only paths consisting of cardinal steps.
 * * required_goals: How many goals to find to succeed. Null for all.
 * * do_doorcheck: Whether or not to check if doors are blocked (welded, out of power, locked, etc...)
 *
 * Returns: List of turfs from the caller to the end or a list of lists of the former if multiple ends are specified.
 * If no paths were found, returns an empty list, which is important for bots like medibots who expect an empty list rather than nothing.
 */
/proc/get_path_to(caller, ends, max_distance = 30, mintargetdist, id=null, simulated_only=TRUE, turf/exclude=null, skip_first=FALSE, cardinal_only=TRUE, required_goals=null, do_doorcheck=FALSE)
	if(isnull(ends))
		return
	var/single_end = !islist(ends)
	if(single_end)
		ends = list(ends)
	if(!caller || !length(ends))
		return

	var/list/options = list(
		POP_MAX_DIST=max_distance,
		POP_MIN_DIST=mintargetdist,
		POP_ID=id,
		POP_SIMULATED_ONLY=simulated_only,
		POP_EXCLUDE=exclude,
		POP_CARDINAL_ONLY=cardinal_only,
		POP_DOOR_CHECK=do_doorcheck,
	)
	if(istype(caller, /obj/machinery/bot) && isnull(id)) // Stonepillar: remove this when amy finishes mob-ifying /obj/machinery/bot
		var/obj/machinery/bot/bot = caller
		options[POP_ID] = bot.botcard
	if(istype(caller, /obj/machinery/vehicle))
		options[POP_IGNORE_CACHE] = TRUE

	var/datum/pathfind/pathfind_datum = new(caller, ends, options)
	if(!isnull(required_goals))
		pathfind_datum.n_target_goals = required_goals
	pathfind_datum.search()
	var/list/list/paths = pathfind_datum.paths
	qdel(pathfind_datum)

	if(single_end)
		var/list/path = paths[ends[1]]
		if(isnull(path))
			return null
		if(length(path) && skip_first)
			path.Cut(1,2)
		return path

	if(skip_first)
		for(var/goal in paths)
			if(length(paths[goal]))
				paths[goal].Cut(1,2)
	return paths

/**
 * A helper macro to see if it's possible to step from the first turf into the second one, minding things like door access and directional windows.
 * Note that this can only be used inside the [datum/pathfind][pathfind datum] since it uses variables from said datum.
 * If you really want to optimize things, optimize this, cuz this gets called a lot.
 */
#define CAN_STEP(cur_turf, next) (next && jpsTurfPassable(next, cur_turf, caller, options) && !(simulated_only && !istype(next, /turf/simulated)) && (next != avoid))
/// Another helper macro for JPS, for telling when a node has forced neighbors that need expanding
#define STEP_NOT_HERE_BUT_THERE(cur_turf, dirA, dirB) ((!CAN_STEP(cur_turf, get_step(cur_turf, dirA)) && CAN_STEP(cur_turf, get_step(cur_turf, dirB))))

#define FINISHED_SEARCH (length(paths) == n_target_goals)

/// The JPS Node datum represents a turf that we find interesting enough to add to the open list and possibly search for new tiles from
/datum/jps_node
	/// The turf associated with this node
	var/turf/tile
	/// The node we just came from
	var/datum/jps_node/previous_node
	/// The A* node weight (f_value = number_of_tiles + heuristic)
	var/f_value
	/// The A* node heuristic (a rough estimate of how far we are from the goal)
	var/heuristic
	/// How many steps it's taken to get here from the start (currently pulling double duty as steps taken & cost to get here, since all moves incl diagonals cost 1 rn)
	var/number_tiles
	/// How many steps it took to get here from the last node
	var/jumps
	/// Nodes store the endgoal so they can process their heuristic without a reference to the pathfind datum
	var/list/turf/node_goals

/datum/jps_node/New(turf/our_tile, datum/jps_node/incoming_previous_node, jumps_taken, list/turf/incoming_goals)
	..()
	tile = our_tile
	jumps = jumps_taken
	if(incoming_goals) // if we have the goal argument, this must be the first/starting node
		node_goals = incoming_goals
	else if(incoming_previous_node) // if we have the parent, this is from a direct cardinal/diagonal scan, we can fill it all out now
		previous_node = incoming_previous_node
		number_tiles = previous_node.number_tiles + jumps
		node_goals = previous_node.node_goals
		heuristic = INFINITY
		for(var/turf/goal as anything in node_goals)
			heuristic = min(heuristic, GET_DIST(tile, goal))
		f_value = number_tiles + heuristic
	// otherwise, no parent node means this is from a subscan cardinal scan, so we just need the tile for now until we call [datum/jps/proc/update_parent] on it

/datum/jps_node/disposing()
	previous_node = null
	..()

/datum/jps_node/proc/update_parent(datum/jps_node/new_parent)
	previous_node = new_parent
	node_goals = previous_node.node_goals
	jumps = GET_DIST(tile, previous_node.tile)
	number_tiles = previous_node.number_tiles + jumps
	heuristic = INFINITY
	for(var/turf/goal as anything in node_goals)
		heuristic = min(heuristic, GET_DIST(tile, goal))
	f_value = number_tiles + heuristic

/// TODO: Macro this to reduce proc overhead
/proc/HeapPathWeightCompare(datum/jps_node/a, datum/jps_node/b)
	return b.f_value - a.f_value

/// The datum used to handle the JPS pathfinding, completely self-contained
/datum/pathfind
	/// The thing that we're actually trying to path for
	var/atom/movable/caller
	/// The turf where we started at
	var/turf/start
	/// The number of goals we need to find to succeed
	var/n_target_goals = null
	/// The turf we're trying to path to (note that this won't track a moving target)
	var/list/turf/ends
	/// The open list/stack we pop nodes out from (TODO: make this a normal list and macro-ize the heap operations to reduce proc overhead)
	var/datum/heap/open
	///An assoc list that serves as the closed list & tracks what turfs came from where. Key is the turf, and the value is what turf it came from
	var/list/sources
	/// The list we compile at the end if successful to pass back
	var/list/list/turf/paths

	// general pathfinding vars/args

	/// How far away we have to get to the end target before we can call it quits
	var/mintargetdist = 0
	/// I don't know what this does vs , but they limit how far we can search before giving up on a path
	var/max_distance = 30
	/// Space is big and empty, if this is TRUE then we ignore pathing through unsimulated tiles
	var/simulated_only
	/// A specific turf we're avoiding, like if a mulebot is being blocked by someone t-posing in a doorway we're trying to get through
	var/turf/avoid
	/// Whether we only want cardinal steps
	var/cardinal_only = FALSE
	/// Raw associative list of options passed from get_path_to.
	var/list/options

/datum/pathfind/New(atom/movable/caller, list/atom/goals, list/options)
	..()
	src.caller = caller
	ends = list()
	n_target_goals = length(goals)
	for(var/goal in goals)
		var/turf/T = get_turf(goal)
		if(!istype(T))
			n_target_goals--
			continue
		if(islist(ends[T]))
			ends[T] += goal
		else
			ends[T] = list(goal)
	open = new /datum/heap(/proc/HeapPathWeightCompare)
	sources = new()
	src.options = options
	src.max_distance = options[POP_MAX_DIST]
	src.mintargetdist = options[POP_MIN_DIST]
	src.simulated_only = options[POP_SIMULATED_ONLY]
	src.avoid = options[POP_EXCLUDE]
	src.cardinal_only = options[POP_CARDINAL_ONLY]
	src.paths = list()

/**
 * search() is the proc you call to kick off and handle the actual pathfinding, and kills the pathfind datum instance when it's done.
 *
 * If a valid path was found, it's returned as a list. If invalid or cross-z-level params are entered, or if there's no valid path found, we
 * return null, which [/proc/get_path_to] translates to an empty list (notable for simple bots, who need empty lists)
 */
/datum/pathfind/proc/search()
	start = get_turf(caller)
	if(!start || !length(ends))
		stack_trace("Invalid A* start or destination")
		return
	var/search_z = start.z
	var/possible_goal_count = 0
	for(var/turf/end as anything in ends)
		if(end.z != search_z || max_distance && (max_distance < GET_DIST(start, end)))
			ends -= end
		else
			possible_goal_count += length(ends[end])
	n_target_goals = min(n_target_goals, possible_goal_count)
	if(n_target_goals == 0)
		return

	//initialization
	var/datum/jps_node/current_processed_node = new (start, -1, 0, ends)
	open.insert(current_processed_node)
	sources[start] = start // i'm sure this is fine

	//then run the main loop
	while(!open.is_empty() && !FINISHED_SEARCH)
		if(!caller)
			return
		current_processed_node = open.pop() //get the lower f_value turf in the open list
		if(max_distance && (current_processed_node.number_tiles > max_distance))//if too many steps, don't process that path
			continue

		var/turf/current_turf = current_processed_node.tile
		for(var/scan_direction in list(EAST, WEST, NORTH, SOUTH))
			cardinal_scan_spec(current_turf, scan_direction, current_processed_node)

		for(var/scan_direction in list(NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST))
			diag_scan_spec(current_turf, scan_direction, current_processed_node)

		LAGCHECK(LAG_MED)

	//we're done! reverse the path to get it from start to finish
	for(var/goal in paths)
		var/list/path = paths[goal]
		if(path)
			for(var/i = 1 to round(0.5 * length(path)))
				path.Swap(i, length(path) - i + 1)

	sources = null
	qdel(open)

/// Called when we've hit the goal with the node that represents the last tile, then sets the path var to that path so it can be returned by [datum/pathfind/proc/search]
/datum/pathfind/proc/unwind_path(datum/jps_node/unwind_node)
	. = list()
	var/turf/iter_turf = unwind_node.tile
	. += iter_turf

	while(unwind_node.previous_node)
		var/dir_goal = get_dir(iter_turf, unwind_node.previous_node.tile)

		for(var/i = 1 to unwind_node.jumps)
			var/turf/next_turf = get_step(iter_turf,dir_goal)
			if(cardinal_only && !is_cardinal(dir_goal))
				var/candidate_dir = dir_goal & (prob(50) ? (NORTH | SOUTH) : (EAST | WEST))
				var/turf/candidate_turf = get_step(iter_turf, candidate_dir)
				if(CAN_STEP(next_turf, candidate_turf) && CAN_STEP(candidate_turf, iter_turf))
					. += candidate_turf
				else // must be the other one
					. += get_step(iter_turf, dir_goal ^ candidate_dir)
			iter_turf = next_turf
			. += iter_turf
		unwind_node = unwind_node.previous_node

/**
 * For performing cardinal scans from a given starting turf.
 *
 * These scans are called from both the main search loop, as well as subscans for diagonal scans, and they treat finding interesting turfs slightly differently.
 * If we're doing a normal cardinal scan, we already have a parent node supplied, so we just create the new node and immediately insert it into the heap, ezpz.
 * If we're part of a subscan, we still need for the diagonal scan to generate a parent node, so we return a node datum with just the turf and let the diag scan
 * proc handle transferring the values and inserting them into the heap.
 *
 * Arguments:
 * * original_turf: What turf did we start this scan at?
 * * heading: What direction are we going in? Obviously, should be cardinal
 * * parent_node: Only given for normal cardinal scans, if we don't have one, we're a diagonal subscan.
*/
/datum/pathfind/proc/cardinal_scan_spec(turf/original_turf, heading, datum/jps_node/parent_node)
	var/steps_taken = 0

	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(TRUE)
		if(FINISHED_SEARCH)
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf, current_turf))
			return

		if(sources[current_turf]) // already visited, essentially in the closed list
			return
		sources[current_turf] = original_turf

		var/list/reached_target_goals = null
		if(mintargetdist)
			for(var/turf/T as anything in ends)
				if(GET_DIST(current_turf, T) <= mintargetdist && !istype(current_turf,/turf/simulated/wall) && !is_blocked_turf(current_turf))
					LAZYLISTADD(reached_target_goals, ends[T])
					ends -= T
		else if(current_turf in ends)
			reached_target_goals = ends[current_turf]
			ends -= current_turf

		if(length(reached_target_goals))
			var/datum/jps_node/final_node = new(current_turf, parent_node, steps_taken)
			if(parent_node) // if this is a direct cardinal scan we can wrap up, if it's a subscan from a diag, we need to let the diag make their node first, then finish
				open.insert(final_node)
				var/list/path = unwind_path(final_node)
				for(var/goal in reached_target_goals)
					src.paths[goal] = path.Copy()
			return list(final_node, reached_target_goals)

		if(parent_node && parent_node.number_tiles + steps_taken > max_distance)
			return

		var/interesting = FALSE // have we found a forced neighbor that would make us add this turf to the open list?

		switch(heading)
			if(NORTH)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST))
					interesting = TRUE
			if(SOUTH)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, EAST, SOUTHEAST))
					interesting = TRUE
			if(EAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST))
					interesting = TRUE
			if(WEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST))
					interesting = TRUE

		if(interesting)
			var/datum/jps_node/newnode = new(current_turf, parent_node, steps_taken)
			if(parent_node) // if we're a diagonal subscan, we'll handle adding ourselves to the heap in the diag
				open.insert(newnode)
			return list(newnode, reached_target_goals)

/**
 * For performing diagonal scans from a given starting turf.
 *
 * Unlike cardinal scans, these only are called from the main search loop, so we don't need to worry about returning anything,
 * though we do need to handle the return values of our cardinal subscans of course.
 *
 * Arguments:
 * * original_turf: What turf did we start this scan at?
 * * heading: What direction are we going in? Obviously, should be diagonal
 * * parent_node: We should always have a parent node for diagonals
*/
/datum/pathfind/proc/diag_scan_spec(turf/original_turf, heading, datum/jps_node/parent_node)
	var/steps_taken = 0
	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(TRUE)
		if(FINISHED_SEARCH)
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf, current_turf))
			return

		if(sources[current_turf]) // already visited, essentially in the closed list
			return
		sources[current_turf] = original_turf

		var/datum/jps_node/newnode = null

		var/list/reached_target_goals = null
		if(mintargetdist)
			for(var/turf/T as anything in ends)
				if(GET_DIST(current_turf, T) <= mintargetdist && !istype(current_turf,/turf/simulated/wall) && !is_blocked_turf(current_turf))
					LAZYLISTADD(reached_target_goals, ends[T])
					ends -= T
		else if(current_turf in ends)
			reached_target_goals = ends[current_turf]
			ends -= current_turf

		if(length(reached_target_goals))
			newnode = new(current_turf, parent_node, steps_taken)
			var/list/path = unwind_path(newnode)
			for(var/goal in reached_target_goals)
				src.paths[goal] = path.Copy()
			if(FINISHED_SEARCH)
				return

		if(parent_node.number_tiles + steps_taken > max_distance)
			return

		var/interesting = FALSE // have we found a forced neighbor that would make us add this turf to the open list?
		var/possible_child_node_pair = null

		switch(heading)
			if(NORTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST))
					interesting = TRUE
				else
					possible_child_node_pair = (cardinal_scan_spec(current_turf, WEST) || cardinal_scan_spec(current_turf, NORTH))
			if(NORTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST))
					interesting = TRUE
				else
					possible_child_node_pair = (cardinal_scan_spec(current_turf, EAST) || cardinal_scan_spec(current_turf, NORTH))
			if(SOUTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, SOUTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST))
					interesting = TRUE
				else
					possible_child_node_pair = (cardinal_scan_spec(current_turf, SOUTH) || cardinal_scan_spec(current_turf, WEST))
			if(SOUTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST))
					interesting = TRUE
				else
					possible_child_node_pair = (cardinal_scan_spec(current_turf, SOUTH) || cardinal_scan_spec(current_turf, EAST))

		if(interesting || possible_child_node_pair)
			if(isnull(newnode))
				newnode = new(current_turf, parent_node, steps_taken)
			open.insert(newnode)
			if(possible_child_node_pair)
				var/datum/jps_node/possible_child_node = possible_child_node_pair[1]
				possible_child_node.update_parent(newnode)
				open.insert(possible_child_node)
				var/list/path = unwind_path(possible_child_node)
				for(var/goal in possible_child_node_pair[2])
					src.paths[goal] = path.Copy()

/// this is a slight modification of /proc/checkTurfPassable to avoid indirect proc call overhead
/// Returns false if there is a dense atom on the turf, unless a custom hueristic is passed.
/proc/jpsTurfPassable(turf/T, turf/source, atom/passer, list/options)
	. = TRUE
	if(istype(passer,/mob/living/critter/flock/drone) && istype(T, /turf/simulated/wall/auto/feather))
		var/mob/living/critter/flock/drone/F = passer
		var/turf/simulated/wall/auto/feather/wall = T
		if(!wall.broken && (F.floorrunning || (F.can_floorrun && F.resources >= 10))) //greater than 10 to give some wiggle room, actual cost is 1 per wall tile
			return TRUE // floor running drones can *always* pass through flockwalls

	if(T.jpsPassableCache == null || options[POP_IGNORE_CACHE])
	else
		return T.jpsPassableCache // not anymore
	if(T.density || !T.pathable) // simplest case
		return FALSE
	var/direction = get_dir(source, T)
	if(!direction)
		return FALSE
	if(!is_cardinal(direction))
		var/turf/corner_1 = get_step(source, turn(direction, 45))
		var/turf/corner_2 = get_step(source, turn(direction, -45))
		return jpsTurfPassable(corner_1, source, passer, options) && jpsTurfPassable(T, corner_1, passer, options) || \
				jpsTurfPassable(corner_2, source, passer, options) && jpsTurfPassable(T, corner_2, passer, options)
	// if a source turf was included check for directional blocks between the two turfs
	if (source && (T.blocked_dirs || source.blocked_dirs))
		// do either of these turfs explicitly block entry or exit to the other?
		if (HAS_ALL_FLAGS(T.blocked_dirs, turn(direction, 180)))
			return FALSE
		else if (source && HAS_ALL_FLAGS(source.blocked_dirs, direction))
			return FALSE
	var/id = options[POP_ID]
	for(var/atom/A as anything in T.contents)
		if (isobj(A))
			var/obj/O = A
			// only skip if we did the source check, otherwise fall back to normal density checks
			if (source && HAS_FLAG(O.object_flags, HAS_DIRECTIONAL_BLOCKING))
				continue // we already handled these above with the blocked_dirs
			if (istype(A, /obj/overlay) || istype(A, /obj/effects)) continue
			if ((passer || id) && A.density)
				if (O.object_flags & BOTS_DIRBLOCK) //NEW - are we a door-like-openable-thing?
					if(options[POP_DOOR_CHECK] && istype(O, /obj/machinery/door))
						var/obj/machinery/door/door = O
						if (door.isblocked())
							return FALSE
					if (ismob(passer) && O.allowed(passer) || id && O.check_access(id)) // do you have explicit access
						continue
					else
						return FALSE
		if(!A.Cross(passer))
			if(!T.jpsUnstable)
				T.jpsPassableCache = FALSE
			return FALSE
	if(!T.jpsUnstable) // Only these are cached, the rest are speical cases for unstable interactibles.
		T.jpsPassableCache = .

#undef CAN_STEP
#undef STEP_NOT_HERE_BUT_THERE
#undef FINISHED_SEARCH








// Non-JPS stuff follows, some of it likely deprecated

/proc/getNeighbors(turf/current, list/directions, heuristic, heuristic_args)
	. = list()
	// handle cardinals straightforwardly
	var/list/cardinalTurfs = list()
	for(var/direction in cardinal)
		if(direction in directions)
			var/turf/T = get_step(current, direction)
			cardinalTurfs["[direction]"] = 0 // can't pass
			if(T && checkTurfPassable(T, heuristic, heuristic_args, current))
				. += T
				cardinalTurfs["[direction]"] = 1 // can pass
	 //diagonals need to avoid the leaking problem
	for(var/direction in ordinal)
		if(direction in directions)
			var/turf/T = get_step(current, direction)
			if(T && checkTurfPassable(T, heuristic, heuristic_args, current))
				// check relevant cardinals
				var/clear = 1
				for(var/cardinal in cardinal)
					if(direction & cardinal)
						// this used to check each cardinal turf again but that's completely unnecessary
						if(!cardinalTurfs["[direction]"])
							clear = 0
				if(clear)
					. += T

/// Returns false if there is a dense atom on the turf, unless a custom hueristic is passed.
/proc/checkTurfPassable(turf/T, heuristic = null, heuristic_args = null, turf/source = null)
	. = TRUE
	if(T.density || !T.pathable) // simplest case
		return FALSE
	// if a source turf was included check for directional blocks between the two turfs
	if (source && (T.blocked_dirs || source.blocked_dirs))
		var/direction = get_dir(source, T)

		// do either of these turfs explicitly block entry or exit to the other?
		if (HAS_ALL_FLAGS(T.blocked_dirs, turn(direction, 180)))
			return FALSE
		else if (source && HAS_ALL_FLAGS(source.blocked_dirs, direction))
			return FALSE

		if (direction in ordinal) // ordinal? That complicates things...
			if (source.blocked_dirs && T.blocked_dirs)
				// check for "wall" blocks
				// ex. trying to move NE source blocking north exit and destination (T) blocking south entry
				if (HAS_ALL_FLAGS(source.blocked_dirs, turn(direction, 45)) && HAS_ALL_FLAGS(T.blocked_dirs, turn(direction, -135)))
					return FALSE
				else if (HAS_ALL_FLAGS(source.blocked_dirs, turn(direction, -45)) && HAS_ALL_FLAGS(T.blocked_dirs, turn(direction, 135)))
					return FALSE

			var/turf/corner_1 = get_step(source, turn(direction, 45))
			var/turf/corner_2 = get_step(source, turn(direction, -45))

			// check for potential blocks form the two corners
			if (corner_1.blocked_dirs && corner_2.blocked_dirs)
				if (HAS_ALL_FLAGS(corner_1.blocked_dirs, turn(direction, -45)))
					if (HAS_ALL_FLAGS(corner_2.blocked_dirs, turn(direction, 45)))
						return FALSE // entry to dest blocked by corners
					else if (HAS_ALL_FLAGS(corner_2.blocked_dirs, turn(direction, 135)))
						// check for "wall" blocks
						// ex. trying to move NE with C1 blocking south entry and C2 blocking north exit
						return FALSE
				if (HAS_ALL_FLAGS(corner_1.blocked_dirs, turn(direction, -135)))
					if (HAS_ALL_FLAGS(corner_2.blocked_dirs, turn(direction, 135)))
						return FALSE // exit from source blocked by corners
					else if (HAS_ALL_FLAGS(corner_2.blocked_dirs, turn(direction, 45)))
						return FALSE // "wall" block

			// we got past the combinations of the two corners ok, but what about the corners combined with the source and destination?
			// entry blocked by an object in destination and in one or more of the corners
			if (T.blocked_dirs && (corner_1.blocked_dirs || corner_2.blocked_dirs))
				if (HAS_ALL_FLAGS(corner_1.blocked_dirs, turn(direction, -45)) && HAS_ALL_FLAGS(T.blocked_dirs, turn(direction, -135)))
					return FALSE
				else if (HAS_ALL_FLAGS(corner_2.blocked_dirs, turn(direction, 45)) && HAS_ALL_FLAGS(T.blocked_dirs, turn(direction, 135)))
					return FALSE
			// entry blocked by an object in source and in one or more of the corners
			if (source.blocked_dirs && (corner_1.blocked_dirs || corner_2.blocked_dirs))
				if (HAS_ALL_FLAGS(corner_1.blocked_dirs, turn(direction, -135)) && HAS_ALL_FLAGS(source.blocked_dirs, turn(direction, -45)))
					return FALSE
				else if (HAS_ALL_FLAGS(corner_2.blocked_dirs, turn(direction, 135)) && HAS_ALL_FLAGS(source.blocked_dirs, turn(direction, 45)))
					return FALSE
	for(var/atom/A as anything in T.contents)
		if (isobj(A))
			var/obj/O = A
			// only skip if we did the source check, otherwise fall back to normal density checks
			if (source && HAS_FLAG(O.object_flags, HAS_DIRECTIONAL_BLOCKING))
				continue // we already handled these above with the blocked_dirs
			if (istype(A, /obj/overlay) || istype(A, /obj/effects)) continue
		if (heuristic) // Only use a custom hueristic if we were passed one
			. = min(., call(heuristic)(A, heuristic_args))
			if (!.) // early return if we encountered a failing atom
				return
		else if (A.density)
			return FALSE // not a special case, so this is a blocking object







/******************************************************************/
// Navigation procs
// Used for A-star pathfinding

/// Returns the surrounding cardinal turfs with open links
/// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(obj/item/card/id/ID)
	. = list()

	for(var/d in cardinal)
		var/turf/simulated/T = get_step(src, d)
		if (T?.pathable && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				. += T

/// Returns surrounding card+ord turfs with open links
/turf/proc/AllDirsTurfsWithAccess(obj/item/card/id/ID)
	. = list()

	for(var/d in alldirs)
		var/turf/simulated/T = get_step(src, d)
		//if(istype(T) && !T.density)
		if (T?.pathable && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				. += T

// Fixes floorbots being terrified of space
turf/proc/CardinalTurfsAndSpaceWithAccess(obj/item/card/id/ID)
	. = list()

	for(var/d in cardinal)
		var/turf/T = get_step(src, d)
		if (T && (T.pathable || istype(T, /turf/space)) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				. += T

var/static/obj/item/card/id/ALL_ACCESS_CARD = new /obj/item/card/id/captains_spare()

/turf/proc/AllDirsTurfsWithAllAccess()
	return AllDirsTurfsWithAccess(ALL_ACCESS_CARD)

/turf/proc/CardinalTurfsSpace()
	. = list()

	for (var/d in cardinal)
		var/turf/T = get_step(src, d)
		if (T && (T.pathable || istype(T, /turf/space)) && !T.density)
			if (!LinkBlockedWithAccess(src, T))
				. += T

// Returns true if a link between A and B is blocked
// Movement through doors allowed if ID has access
/proc/LinkBlockedWithAccess(turf/A, turf/B, obj/item/card/id/ID)
	. = FALSE
	if(A == null || B == null)
		return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//	diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlockedWithAccess(A,iStep, ID) && !LinkBlockedWithAccess(iStep,B,ID))
			return 0

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlockedWithAccess(A,pStep,ID) && !LinkBlockedWithAccess(pStep,B,ID))
			return 0
		return 1

	if(!DirWalkableWithAccess(A,adir, ID, exiting_this_tile = 1))
		return 1

	var/DirWalkableB = DirWalkableWithAccess(B,rdir, ID)
	if(!DirWalkableB)
		return 1

	if (DirWalkableB == 2) //we found a door we can open! Let's open the door before we check the whole tile for dense objects below.
		return 0

	for (var/atom/O in B.contents)
		if (O.density)
			if (ismob(O))
				var/mob/M = O
				if (M.anchored)
					return 1
				return 0

			if (O.flags & ON_BORDER)
				if (rdir == O.dir)
					return 1
			else
				return 1

// Returns true if direction is accessible from loc
// If we found a door we could open, return 2 instead of 1.
// Checks doors against access with given ID
/proc/DirWalkableWithAccess(turf/loc,var/dir,var/obj/item/card/id/ID, var/exiting_this_tile = 0)
	. = TRUE
	for (var/obj/O in loc)
		if (O.density)
			if (O.object_flags & BOTS_DIRBLOCK)
				if (O.flags & ON_BORDER && dir == O.dir)//windoors and directional windows
					if (O.has_access_requirements())
						if (O.check_access(ID) == 0)
							return 0
						else
							return 2
					else
						return 2
				else if (!exiting_this_tile)		//other solid objects. dont bother checking if we are EXITING this tile
					if (O.has_access_requirements())
						if (O.check_access(ID) == 0)
							return 0
						else
							return 2
					else
						return 2
			else
				if (O.flags & ON_BORDER)
					if (dir == O.dir)
						return 0
				else if (!exiting_this_tile) //dont bother checking if we are EXITING this tile
					return 0

/turf/proc
	AdjacentTurfs()
		. = list()
		for(var/turf/simulated/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					. += t

	AdjacentTurfsSpace()
		. = list()
		for(var/turf/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					. += t

	Distance(turf/t)
		return sqrt((src.x - t.x) ** 2 + (src.y - t.y) ** 2)

