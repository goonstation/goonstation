/**
 * This file contains the stuff you need for using JPS (Jump Point Search) pathing, an alternative to A* that skips
 * over large numbers of uninteresting tiles resulting in much quicker pathfinding solutions. Mind that diagonals
 * cost the same as cardinal moves currently, so paths may look a bit strange, but should still be optimal.
 */

/**
 * This is the proc you use whenever you want to have pathfinding more complex than "try stepping towards the thing".
 * If no path was found, returns an empty list, which is important for bots like medibots who expect an empty list rather than nothing.
 *
 * Arguments:
 * * caller: The movable atom that's trying to find the path
 * * end: What we're trying to path to. It doesn't matter if this is a turf or some other atom, we're gonna just path to the turf it's on anyway
 * * max_distance: The maximum number of steps we can take in a given path to search (default: 30, 0 = infinite)
 * * mintargetdistance: Minimum distance to the target before path returns, could be used to get near a target, but not right to it - for an AI mob with a gun, for example.
 * * id: An ID card representing what access we have and what doors we can open. Its location relative to the pathing atom is irrelevant
 * * simulated_only: Whether we consider turfs without atmos simulation (AKA do we want to ignore space)
 * * exclude: If we want to avoid a specific turf, like if we're a mulebot who already got blocked by some turf
 * * skip_first: Whether or not to delete the first item in the path. This would be done because the first item is the starting tile, which can break movement for some creatures.
 */
/proc/get_path_to(caller, end, max_distance = 30, mintargetdist, id=null, simulated_only=TRUE, turf/exclude=null, skip_first=FALSE, lateral_only=FALSE)
	if(!caller || !get_turf(end))
		return

	var/list/path
	var/datum/pathfind/pathfind_datum = new(caller, end, id, max_distance, mintargetdist, simulated_only, exclude, lateral_only)
	path = pathfind_datum.search()
	qdel(pathfind_datum)

	if(!path)
		path = list()
	if(length(path) > 0 && skip_first)
		path.Cut(1,2)
	return path

/**
 * A helper macro to see if it's possible to step from the first turf into the second one, minding things like door access and directional windows.
 * Note that this can only be used inside the [datum/pathfind][pathfind datum] since it uses variables from said datum.
 * If you really want to optimize things, optimize this, cuz this gets called a lot.
 */
#define CAN_STEP(cur_turf, next) (next && !next.density && jpsTurfPassable(next, source=cur_turf, passer=caller, id=id) && !(simulated_only && !istype(next, /turf/simulated)) && (next != avoid))
/// Another helper macro for JPS, for telling when a node has forced neighbors that need expanding
#define STEP_NOT_HERE_BUT_THERE(cur_turf, dirA, dirB) ((!CAN_STEP(cur_turf, get_step(cur_turf, dirA)) && CAN_STEP(cur_turf, get_step(cur_turf, dirB))))

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
	var/turf/node_goal

/datum/jps_node/New(turf/our_tile, datum/jps_node/incoming_previous_node, jumps_taken, turf/incoming_goal)
	..()
	tile = our_tile
	jumps = jumps_taken
	if(incoming_goal) // if we have the goal argument, this must be the first/starting node
		node_goal = incoming_goal
	else if(incoming_previous_node) // if we have the parent, this is from a direct lateral/diagonal scan, we can fill it all out now
		previous_node = incoming_previous_node
		number_tiles = previous_node.number_tiles + jumps
		node_goal = previous_node.node_goal
		heuristic = get_dist(tile, node_goal)
		f_value = number_tiles + heuristic
	// otherwise, no parent node means this is from a subscan lateral scan, so we just need the tile for now until we call [datum/jps/proc/update_parent] on it

/datum/jps_node/disposing()
	previous_node = null
	..()

/datum/jps_node/proc/update_parent(datum/jps_node/new_parent)
	previous_node = new_parent
	node_goal = previous_node.node_goal
	jumps = get_dist(tile, previous_node.tile)
	number_tiles = previous_node.number_tiles + jumps
	heuristic = get_dist(tile, node_goal)
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
	/// The turf we're trying to path to (note that this won't track a moving target)
	var/turf/end
	/// The open list/stack we pop nodes out from (TODO: make this a normal list and macro-ize the heap operations to reduce proc overhead)
	var/datum/heap/open
	///An assoc list that serves as the closed list & tracks what turfs came from where. Key is the turf, and the value is what turf it came from
	var/list/sources
	/// The list we compile at the end if successful to pass back
	var/list/path

	// general pathfinding vars/args
	/// An ID card representing what access we have and what doors we can open. Its location relative to the pathing atom is irrelevant
	var/obj/item/card/id/id
	/// How far away we have to get to the end target before we can call it quits
	var/mintargetdist = 0
	/// I don't know what this does vs , but they limit how far we can search before giving up on a path
	var/max_distance = 30
	/// Space is big and empty, if this is TRUE then we ignore pathing through unsimulated tiles
	var/simulated_only
	/// A specific turf we're avoiding, like if a mulebot is being blocked by someone t-posing in a doorway we're trying to get through
	var/turf/avoid
	/// Whether we only want lateral steps
	var/lateral_only = FALSE

/datum/pathfind/New(atom/movable/caller, atom/goal, id, max_distance, mintargetdist, simulated_only, avoid, lateral_only=FALSE)
	..()
	src.caller = caller
	end = get_turf(goal)
	open = new /datum/heap(/proc/HeapPathWeightCompare)
	sources = new()
	src.id = id
	src.max_distance = max_distance
	src.mintargetdist = mintargetdist
	src.simulated_only = simulated_only
	src.avoid = avoid
	src.lateral_only = lateral_only

/**
 * search() is the proc you call to kick off and handle the actual pathfinding, and kills the pathfind datum instance when it's done.
 *
 * If a valid path was found, it's returned as a list. If invalid or cross-z-level params are entered, or if there's no valid path found, we
 * return null, which [/proc/get_path_to] translates to an empty list (notable for simple bots, who need empty lists)
 */
/datum/pathfind/proc/search()
	start = get_turf(caller)
	if(!start || !end)
		stack_trace("Invalid A* start or destination")
		return
	if(start.z != end.z || start == end ) //no pathfinding between z levels
		return
	if(max_distance && (max_distance < get_dist(start, end))) //if start turf is farther than max_distance from end turf, no need to do anything
		return

	//initialization
	var/datum/jps_node/current_processed_node = new (start, -1, 0, end)
	open.insert(current_processed_node)
	sources[start] = start // i'm sure this is fine

	//then run the main loop
	while(!open.is_empty() && !path)
		if(!caller)
			return
		current_processed_node = open.pop() //get the lower f_value turf in the open list
		//current_processed_node.tile.maptext = "[current_processed_node.jumps]"
		current_processed_node.tile.color = "#ffaaaa"
		animate(current_processed_node.tile, color=null, time=10 SECONDS)
		if(max_distance && (current_processed_node.number_tiles > max_distance))//if too many steps, don't process that path
			continue

		var/turf/current_turf = current_processed_node.tile
		for(var/scan_direction in list(EAST, WEST, NORTH, SOUTH))
			lateral_scan_spec(current_turf, scan_direction, current_processed_node)

		for(var/scan_direction in list(NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST))
			diag_scan_spec(current_turf, scan_direction, current_processed_node)

		LAGCHECK(LAG_MED)

	//we're done! reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5 * length(path)))
			path.Swap(i, length(path) - i + 1)

	sources = null
	qdel(open)
	return path

/// Called when we've hit the goal with the node that represents the last tile, then sets the path var to that path so it can be returned by [datum/pathfind/proc/search]
/datum/pathfind/proc/unwind_path(datum/jps_node/unwind_node)
	path = new()
	var/turf/iter_turf = unwind_node.tile
	path.Add(iter_turf)

	while(unwind_node.previous_node)
		var/dir_goal = get_dir(iter_turf, unwind_node.previous_node.tile)

		for(var/i = 1 to unwind_node.jumps)
			var/turf/next_turf = get_step(iter_turf,dir_goal)
			if(lateral_only && !is_cardinal(dir_goal))
				var/candidate_dir = dir_goal & (prob(50) ? (NORTH | SOUTH) : (EAST | WEST))
				var/turf/candidate_turf = get_step(iter_turf, candidate_dir)
				if(CAN_STEP(next_turf, candidate_turf) && CAN_STEP(candidate_turf, iter_turf))
					path.Add(candidate_turf)
				else // must be the other one
					path.Add(get_step(iter_turf, dir_goal ^ candidate_dir))
			iter_turf = next_turf
			path.Add(iter_turf)
		unwind_node = unwind_node.previous_node

/**
 * For performing lateral scans from a given starting turf.
 *
 * These scans are called from both the main search loop, as well as subscans for diagonal scans, and they treat finding interesting turfs slightly differently.
 * If we're doing a normal lateral scan, we already have a parent node supplied, so we just create the new node and immediately insert it into the heap, ezpz.
 * If we're part of a subscan, we still need for the diagonal scan to generate a parent node, so we return a node datum with just the turf and let the diag scan
 * proc handle transferring the values and inserting them into the heap.
 *
 * Arguments:
 * * original_turf: What turf did we start this scan at?
 * * heading: What direction are we going in? Obviously, should be cardinal
 * * parent_node: Only given for normal lateral scans, if we don't have one, we're a diagonal subscan.
*/
/datum/pathfind/proc/lateral_scan_spec(turf/original_turf, heading, datum/jps_node/parent_node)
	var/steps_taken = 0

	var/turf/current_turf = original_turf
	var/turf/lag_turf = original_turf

	while(TRUE)
		if(path)
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf, current_turf))
			return

		if(current_turf == end || (mintargetdist && (get_dist(current_turf, end) <= mintargetdist)))
			var/datum/jps_node/final_node = new(current_turf, parent_node, steps_taken)
			sources[current_turf] = original_turf
			if(parent_node) // if this is a direct lateral scan we can wrap up, if it's a subscan from a diag, we need to let the diag make their node first, then finish
				unwind_path(final_node)
			return final_node
		else if(sources[current_turf]) // already visited, essentially in the closed list
			return
		else
			sources[current_turf] = original_turf

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
			return newnode

/**
 * For performing diagonal scans from a given starting turf.
 *
 * Unlike lateral scans, these only are called from the main search loop, so we don't need to worry about returning anything,
 * though we do need to handle the return values of our lateral subscans of course.
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
		if(path)
			return
		lag_turf = current_turf
		current_turf = get_step(current_turf, heading)
		steps_taken++
		if(!CAN_STEP(lag_turf, current_turf))
			return

		if(current_turf == end || (mintargetdist && (get_dist(current_turf, end) <= mintargetdist)))
			var/datum/jps_node/final_node = new(current_turf, parent_node, steps_taken)
			sources[current_turf] = original_turf
			unwind_path(final_node)
			return
		else if(sources[current_turf]) // already visited, essentially in the closed list
			return
		else
			sources[current_turf] = original_turf

		if(parent_node.number_tiles + steps_taken > max_distance)
			return

		var/interesting = FALSE // have we found a forced neighbor that would make us add this turf to the open list?
		var/datum/jps_node/possible_child_node // otherwise, did one of our lateral subscans turn up something?

		switch(heading)
			if(NORTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, NORTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHWEST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, WEST) || lateral_scan_spec(current_turf, NORTH))
			if(NORTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, NORTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, SOUTH, SOUTHEAST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, EAST) || lateral_scan_spec(current_turf, NORTH))
			if(SOUTHWEST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, EAST, SOUTHEAST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHWEST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, SOUTH) || lateral_scan_spec(current_turf, WEST))
			if(SOUTHEAST)
				if(STEP_NOT_HERE_BUT_THERE(current_turf, WEST, SOUTHWEST) || STEP_NOT_HERE_BUT_THERE(current_turf, NORTH, NORTHEAST))
					interesting = TRUE
				else
					possible_child_node = (lateral_scan_spec(current_turf, SOUTH) || lateral_scan_spec(current_turf, EAST))

		if(interesting || possible_child_node)
			var/datum/jps_node/newnode = new(current_turf, parent_node, steps_taken)
			open.insert(newnode)
			if(possible_child_node)
				possible_child_node.update_parent(newnode)
				open.insert(possible_child_node)
				if(possible_child_node.tile == end || (mintargetdist && (get_dist(possible_child_node.tile, end) <= mintargetdist)))
					unwind_path(possible_child_node)
			return

/proc/jpsTurfPassable(turf/T, turf/source=null, atom/passer=null, id=null)
	. = _jpsTurfPassable(T, source, passer, id)
	if(!usr)
		return
	var/obj/ov = new
	ov.icon = 'icons/misc/air_debug.dmi'
	ov.icon_state = "space"
	var/dir = get_dir(source, T)
	ov.dir = dir
	ov.plane = 100
	ov.color = . ? "#00ff00" : "#ff0000"
	ov.alpha = 80
	source.vis_contents += ov

/// this is a slight modification of /proc/checkTurfPassable to avoid indirect proc call overhead
/// Returns false if there is a dense atom on the turf, unless a custom hueristic is passed.
/proc/_jpsTurfPassable(turf/T, turf/source=null, atom/passer=null, id=null)
	. = TRUE
	if(T.density || !T.pathable) // simplest case
		return FALSE
	if(isnull(id) && istype(passer, /obj/machinery/bot))
		var/obj/machinery/bot/bot = passer
		id = bot.botcard
	// if a source turf was included check for directional blocks between the two turfs
	if (source && (T.blocked_dirs || source.blocked_dirs))
		var/direction = get_dir(source, T)

		// do either of these turfs explicitly block entry or exit to the other?
		if (HAS_FLAG(T.blocked_dirs, turn(direction, 180)))
			return FALSE
		else if (source && HAS_FLAG(source.blocked_dirs, direction))
			return FALSE

		if (direction in ordinal) // ordinal? That complicates things...
			if (source.blocked_dirs && T.blocked_dirs)
				// check for "wall" blocks
				// ex. trying to move NE source blocking north exit and destination (T) blocking south entry
				if (HAS_FLAG(source.blocked_dirs, turn(direction, 45)) && HAS_FLAG(T.blocked_dirs, turn(direction, -135)))
					return FALSE
				else if (HAS_FLAG(source.blocked_dirs, turn(direction, -45)) && HAS_FLAG(T.blocked_dirs, turn(direction, 135)))
					return FALSE

			var/turf/corner_1 = get_step(source, turn(direction, 45))
			var/turf/corner_2 = get_step(source, turn(direction, -45))

			// check for potential blocks form the two corners
			if (corner_1.blocked_dirs && corner_2.blocked_dirs)
				if (HAS_FLAG(corner_1.blocked_dirs, turn(direction, -45)))
					if (HAS_FLAG(corner_2.blocked_dirs, turn(direction, 45)))
						return FALSE // entry to dest blocked by corners
					else if (HAS_FLAG(corner_2.blocked_dirs, turn(direction, 135)))
						// check for "wall" blocks
						// ex. trying to move NE with C1 blocking south entry and C2 blocking north exit
						return FALSE
				if (HAS_FLAG(corner_1.blocked_dirs, turn(direction, -135)))
					if (HAS_FLAG(corner_2.blocked_dirs, turn(direction, 135)))
						return FALSE // exit from source blocked by corners
					else if (HAS_FLAG(corner_2.blocked_dirs, turn(direction, 45)))
						return FALSE // "wall" block

			// we got past the combinations of the two corners ok, but what about the corners combined with the source and destination?
			// entry blocked by an object in destination and in one or more of the corners
			if (T.blocked_dirs && (corner_1.blocked_dirs || corner_2.blocked_dirs))
				if (HAS_FLAG(corner_1.blocked_dirs, turn(direction, -45)) && HAS_FLAG(T.blocked_dirs, turn(direction, -135)))
					return FALSE
				else if (HAS_FLAG(corner_2.blocked_dirs, turn(direction, 45)) && HAS_FLAG(T.blocked_dirs, turn(direction, 135)))
					return FALSE
			// entry blocked by an object in source and in one or more of the corners
			if (source.blocked_dirs && (corner_1.blocked_dirs || corner_2.blocked_dirs))
				if (HAS_FLAG(corner_1.blocked_dirs, turn(direction, -135)) && HAS_FLAG(source.blocked_dirs, turn(direction, -45)))
					return FALSE
				else if (HAS_FLAG(corner_2.blocked_dirs, turn(direction, 135)) && HAS_FLAG(source.blocked_dirs, turn(direction, 45)))
					return FALSE
	for(var/atom/A in T.contents)
		if (isobj(A))
			var/obj/O = A
			// only skip if we did the source check, otherwise fall back to normal density checks
			if (source && HAS_FLAG(O.object_flags, HAS_DIRECTIONAL_BLOCKING))
				continue // we already handled these above with the blocked_dirs
			if (istype(A, /obj/overlay) || istype(A, /obj/effects)) continue
			if ((passer || id) && A.density)
				if (O.object_flags & BOTS_DIRBLOCK) //NEW - are we a door-like-openable-thing?
					if (O.has_access_requirements()) //are we a door w/ access?
						if (ismob(passer) && O.allowed(passer) == 2 || id && O.check_access(id)) // do you have explicit access
							continue
						else
							return FALSE
					else //we must be a public door
						continue
				return FALSE
		else if (A.density)
			return FALSE // not a special case, so this is a blocking object

#undef CAN_STEP
#undef STEP_NOT_HERE_BUT_THERE
