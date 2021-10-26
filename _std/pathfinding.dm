/proc/AStar(start, end, adjacent, heuristic, maxtraverse = 30, adjacent_param = null, exclude = null)
	if(isnull(end) || isnull(start))
		return
	var/list/turf/open = list(start)
	var/list/turf/nodeParent = list()
	var/list/nodeGcost = list()

	var/traverseNum = 0
	while (traverseNum++ < length(open))
		var/turf/current = open[traverseNum]
		var/tentativeGScore = nodeGcost[current]
		if (current == end)
			var/list/reconstructed_path = list()
			while (current)
				reconstructed_path.Insert(1, current)
				current = nodeParent[current]
			return reconstructed_path

		var/list/neighbors = call(current, adjacent)(adjacent_param)
		for (var/neighbor in neighbors)
			if ((neighbor in open) || neighbor == exclude)
				continue
			var/gScore = tentativeGScore + neighbors[neighbor]
			var/fScore = gScore + call(neighbor, heuristic)(end)

			for (var/i = traverseNum; i <= length(open);)
				if (i++ == length(open) || open[open[i]] >= fScore)
					open.Insert(i, neighbor)
					open[neighbor] = fScore
					break
			nodeGcost[neighbor] = gScore
			nodeParent[neighbor] = current

		if (traverseNum > maxtraverse)
			return null // if we reach this part, there's no more nodes left to explore

/proc/AStarmulti(start, list/ends, adjacent, heuristic, maxtraverse = 30, adjacent_param = null, exclude = null)
	. = ends.Copy()
	for(var/x in .)
		.[x] = null
	if(isnull(ends) || isnull(start))
		return
	var/list/turf/open = list(start)
	var/list/turf/nodeParent = list()
	var/list/nodeGcost = list()

	var/nLeft = length(ends)

	var/traverseNum = 0
	while (traverseNum++ < length(open))
		var/turf/current = open[traverseNum]
		var/tentativeGScore = nodeGcost[current]
		if (current in ends)
			var/turf/backtrace = current
			var/list/reconstructed_path = list()
			while (backtrace)
				reconstructed_path.Insert(1, backtrace)
				backtrace = nodeParent[backtrace]
			.[current] = reconstructed_path
			if(--nLeft <= 0)
				return

		var/list/neighbors = call(current, adjacent)(adjacent_param)
		for (var/neighbor in neighbors)
			if ((neighbor in open) || neighbor == exclude)
				continue
			var/gScore = tentativeGScore + neighbors[neighbor]
			var/heur = INFINITY
			for(var/end in ends)
				heur = min(heur, call(neighbor, heuristic)(end))
			var/fScore = gScore + heur

			for (var/i = traverseNum; i <= length(open);)
				if (i++ == length(open) || open[open[i]] >= fScore)
					open.Insert(i, neighbor)
					open[neighbor] = fScore
					break
			nodeGcost[neighbor] = gScore
			nodeParent[neighbor] = current

		if (traverseNum > maxtraverse)
			return // if we reach this part, there's no more nodes left to explore


//#define DEBUG_ASTAR

/proc/cirrAstar(turf/start, atom/goal, min_dist=0, maxtraverse=30, heuristic=null, heuristic_args=null)
	#ifdef DEBUG_ASTAR
	clearAstarViz()
	#endif

	var/list/turf/closedSet = list()
	var/list/turf/openSet = list(start)
	var/list/turf/cameFrom = list()

	var/list/gScore = list()
	var/list/fScore = list()
	gScore[start] = 0
	fScore[start] = GET_MANHATTAN_DIST(start, goal)
	var/traverse = 0

	while(length(openSet))
		var/turf/current = pickLowest(openSet, fScore)
		if(get_dist(current, goal) <= min_dist)
			return reconstructPath(cameFrom, current)

		openSet -= current
		closedSet += current
		var/list/turf/neighbors = getNeighbors(current, alldirs, heuristic, heuristic_args)
		for(var/turf/neighbor as anything in neighbors)
			if(neighbor in closedSet)
				continue // already checked this one
			var/tentativeGScore = gScore[current] + get_dist(current, neighbor)
			if(!(neighbor in openSet))
				openSet += neighbor
			else if(tentativeGScore >= (gScore[neighbor] || 1.#INF))
				continue // this is not a better route to this node

			cameFrom[neighbor] = current
			gScore[neighbor] = tentativeGScore
			fScore[neighbor] = gScore[neighbor] + get_dist(neighbor, goal)
		traverse += 1
		if(traverse > maxtraverse)
			return null // it's taking too long, abandon
		LAGCHECK(LAG_LOW)
	return null // if we reach this part, there's no more nodes left to explore


/proc/pickLowest(list/options, list/values)
	if(!length(options))
		return null // you idiot
	var/lowestScore = 1.#INF
	for(var/option in options)
		if(option in values)
			var/score = values[option]
			if(score < lowestScore)
				lowestScore = score
				. = option

/proc/reconstructPath(list/cameFrom, turf/current)
	var/list/totalPath = list(current)
	while(current in cameFrom)
		current = cameFrom[current]
		totalPath += current
	// reverse the path
	. = list()
	for(var/i = length(totalPath) to 1 step -1)
		. += totalPath[i]
	#ifdef DEBUG_ASTAR
	addAstarViz(.)
	#endif
	return .

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
		if (heuristic) // Only use a custom hueristic if we were passed one
			. = min(., call(heuristic)(A, heuristic_args))
			if (!.) // early return if we encountered a failing atom
				return
		else if (A.density)
			return FALSE // not a special case, so this is a blocking object

/proc/hueristic_IsPassableMob(atom/A, mob/M)
	. = FALSE
	if (!A.density) // Not dense? Don't care!
		return TRUE

	if (isobj(A))
		var/obj/O = A
		. = !O.density //lots of objects are dense and will stop you
		if (O.object_flags & BOTS_DIRBLOCK) //NEW - are we a door-like-openable-thing?
			if (O.has_access_requirements()) //are we a door w/ access?
				if (O.allowed(M) == 2) // do you have explicit access
					return TRUE
				else
					return FALSE
			else //we must be a public door
				return TRUE
	else if (ismob(A)) //We can pass by mobs, who cares if they're dense.
		return TRUE


#ifdef DEBUG_ASTAR
/var/static/list/astarImages = list()
/proc/clearAstarViz()
	for(var/client/C in clients)
		C.images -= astarImages
	astarImages = list()

/proc/addAstarViz(var/list/path)
	astarImages = list()
	for(var/turf/T in path)
		var/image/marker = image('icons/mob/screen1.dmi', T, icon_state="x3")
		marker.color="#0F8"
		astarImages += marker
	for(var/client/C in clients)
		C.images += astarImages
#endif










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

