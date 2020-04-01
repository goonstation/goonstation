/proc/AStar(start, end, adjacent, heuristic, maxtraverse = 30, adjacent_param = null, exclude = null)
	var/list/open = list(start), list/nodeG = list(), list/nodeParent = list(), P = 0
	while (P++ < open.len)
		var/T = open[P], TG = nodeG[T]
		if (T == end)
			var/list/R = list()
			while (T)
				R.Insert(1, T)
				T = nodeParent[T]
			return R
		var/list/other = call(T, adjacent)(adjacent_param)
		for (var/next in other)
			if (open.Find(next) || next == exclude) continue
			var/G = TG + other[next], F = G + call(next, heuristic)(end)
			for (var/i = P; i <= open.len;)
				if (i++ == open.len || open[open[i]] >= F)
					open.Insert(i, next)
					open[next] = F
					break
			nodeG[next] = G
			nodeParent[next] = T

		if (P > maxtraverse)
			return


//#define DEBUG_ASTAR

/proc/cirrAstar(turf/start, turf/goal, var/min_dist=0, proc/adjacent, proc/heuristic, maxtraverse = 30, adjacent_param = null, exclude = null)
	#ifdef DEBUG_ASTAR
	clearAstarViz()
	#endif

	var/list/closedSet = list()
	var/list/openSet = list(start)
	var/list/cameFrom = list()

	var/list/gScore = list()
	var/list/fScore = list()
	gScore[start] = 0
	fScore[start] = heuristic(start, goal)
	var/traverse = 0

	while(openSet.len > 0)
		var/current = pickLowest(openSet, fScore)
		if(distance(current, goal) <= min_dist)
			return reconstructPath(cameFrom, current)

		openSet -= current
		closedSet += current
		var/list/neighbors = getNeighbors(current, alldirs)
		for(var/neighbor in neighbors)
			if(neighbor in closedSet)
				continue // already checked this one
			var/tentativeGScore = gScore[current] + distance(current, neighbor)
			if(!(neighbor in openSet))
				openSet += neighbor
			else if(tentativeGScore >= (gScore[neighbor] || 1.#INF))
				continue // this is not a better route to this node

			cameFrom[neighbor] = current
			gScore[neighbor] = tentativeGScore
			fScore[neighbor] = gScore[neighbor] + heuristic(neighbor, goal)
		traverse += 1
		if(traverse > maxtraverse)
			return null // it's taking too long, abandon
		LAGCHECK(LAG_LOW)
	return null // if we reach this part, there's no more nodes left to explore



/proc/heuristic(turf/start, turf/goal)
	if(!start || !goal)
		return null // yes, null, not a number, i need to track down why nulls are being passed in as turfs so i'm throwing this up the stack
	// let's just do manhattan for now
	return abs(start.x - goal.x) + abs(start.y - goal.y)

/proc/distance(turf/start, turf/goal)
	if(!start || !goal)
		return null
	var/dx = goal.x - start.x
	var/dy = goal.y - start.y
	return sqrt(dx*dx + dy*dy)

/proc/pickLowest(list/options, list/values)
	if(options.len == 0)
		return null // you idiot
	var/lowestScore = 1.#INF
	for(var/option in options)
		if(option in values)
			var/score = values[option]
			if(score < lowestScore)
				lowestScore = score
				. = option
		else
			continue // if we have no score for an option, ignore it

/proc/reconstructPath(list/cameFrom, turf/current)
	var/list/totalPath = list(current)
	while(current in cameFrom)
		current = cameFrom[current]
		totalPath += current
	// reverse the path
	. = list()
	for(var/i = totalPath.len to 1 step -1)
		. += totalPath[i]
	#ifdef DEBUG_ASTAR
	addAstarViz(.)
	#endif
	return .

/proc/getNeighbors(turf/current, list/directions)
	. = list()
	// handle cardinals straightforwardly
	var/list/cardinalTurfs = list()
	for(var/direction in cardinal)
		if(direction in directions)
			var/turf/T = get_step(current, direction)
			cardinalTurfs["[direction]"] = 0 // can't pass
			if(T && checkTurfPassable(T))
				. += T
				cardinalTurfs["[direction]"] = 1 // can pass
	 //diagonals need to avoid the leaking problem
	for(var/direction in ordinal)
		if(direction in directions)
			var/turf/T = get_step(current, direction)
			if(T && checkTurfPassable(T))
				// check relevant cardinals
				var/clear = 1
				for(var/cardinal in cardinal)
					if(direction & cardinal)
						// this used to check each cardinal turf again but that's completely unnecessary
						if(!cardinalTurfs["[direction]"])
							clear = 0
				if(clear)
					. += T

// shamelessly stolen from further down and modified
/proc/checkTurfPassable(turf/T)
	if(!T)
		return 0 // can't go on a turf that doesn't exist!!
	if(T.density) // simplest case
		return 0
	for(var/atom/O in T.contents)
		if (O.density) // && !(O.flags & ON_BORDER)) -- fuck you, windows, you're dead to me
			if (istype(O, /obj/machinery/door))
				var/obj/machinery/door/D = O
				if (D.isblocked())
					return 0 // a blocked door is a blocking door
			if (ismob(O))
				var/mob/M = O
				if (M.anchored)
					return 0 // an anchored mob is a blocking mob
				else
			return 0 // not a special case, so this is a blocking object
	return 1



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

// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(var/obj/item/card/id/ID)
	var/L[] = new()

	//	for(var/turf/simulated/t in oview(src,1))

	for(var/d in cardinal)
		var/turf/simulated/T = get_step(src, d)
		//if(istype(T) && !T.density)
		if (T && T.pathable && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L
/turf/proc/AllDirsTurfsWithAccess(var/obj/item/card/id/ID)
	var/L[] = new()

	//	for(var/turf/simulated/t in oview(src,1))

	for(var/d in alldirs)
		var/turf/simulated/T = get_step(src, d)
		//if(istype(T) && !T.density)
		if (T && T.pathable && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L


/turf/proc/CardinalTurfsSpace()
	var/L[] = new()

	for (var/d in cardinal)
		var/turf/T = get_step(src, d)
		if (T && (T.pathable || istype(T, /turf/space)) && !T.density)
			if (!LinkBlockedWithAccess(src, T))
				L.Add(T)

	return L

// Returns true if a link between A and B is blocked
// Movement through doors allowed if ID has access
/proc/LinkBlockedWithAccess(turf/A, turf/B, obj/item/card/id/ID)

	if(A == null || B == null) return 1
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

	return 0

// Returns true if direction is accessible from loc
// If we found a door we could open, return 2 instead of 1.
// Checks doors against access with given ID
/proc/DirWalkableWithAccess(turf/loc,var/dir,var/obj/item/card/id/ID, var/exiting_this_tile = 0)
	.= 1

	for (var/atom in loc)
		if (!isobj(atom)) continue
		var/obj/D = atom

		if (D.density)
			if (D.object_flags & BOTS_DIRBLOCK)
				if (D.flags & ON_BORDER && dir == D.dir)//windoors and directional windows
					if (D.has_access_requirements())
						if (D.check_access(ID) == 0)
							return 0
						else
							return 2
					else
						return 2
				else if (!exiting_this_tile)		//other solid objects. dont bother checking if we are EXITING this tile
					if (D.has_access_requirements())
						if (D.check_access(ID) == 0)
							return 0
						else
							return 2
					else
						return 2
			else
				if (D.flags & ON_BORDER)
					if (dir == D.dir)
						return 0
				else if (!exiting_this_tile) //dont bother checking if we are EXITING this tile
					return 0





















/turf/proc
	AdjacentTurfs()
		var/L[] = new()
		for(var/turf/simulated/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					L.Add(t)
		return L
	Distance(turf/t)
		if(get_dist(src,t) == 1)
			var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
			cost *= (pathweight+t.pathweight)/2
			return cost
		else
			return get_dist(src,t)
	AdjacentTurfsSpace()
		var/L[] = new()
		for(var/turf/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					L.Add(t)
		return L


