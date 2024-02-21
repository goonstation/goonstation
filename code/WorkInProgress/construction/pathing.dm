/proc/findPath_H(var/turf/A, var/turf/target)
	var/dx = target.x - A.x
	var/dy = target.y - A.y
	if (dx < 0)
		dx = -dx
	if (dy < 0)
		dy = -dy
	return max(dx, dy)

/proc/findPath_isValid(var/turf/A)
	if (A.density)
		return 0
	for (var/obj/O in A)
		if (O.density)
			return 0
	return 1

/proc/findPath_heapInsert(var/list/heap, var/turf/add, var/value)
	heap += add
	heap[add] = value
	var/i = length(heap)
	while (i > 1)
		var/p = round(i / 2)
		var/key1 = heap[i]
		var/key2 = heap[p]
		if (heap[key1] < heap[key2])
			heap.Swap(p, i)
			i = p
		else
			break

/proc/findPath_heapify(var/list/heap, var/entry)
	var/i = entry
	while (i < heap.len)
		if (i * 2 + 1 <= heap.len)
			var/c1 = i * 2
			var/c2 = i * 2 + 1
			var/keyi = heap[i]
			var/key1 = heap[c1]
			var/key2 = heap[c2]
			var/lesser = c1
			var/lesskey = key1
			if (heap[key2] < heap[key1])
				lesser = c2
				lesskey = key2
			if (heap[lesskey] < heap[keyi])
				heap.Swap(i, lesser)
				i = lesser
			else
				break
		else if (i * 2 <= heap.len)
			var/lesser = i * 2
			var/keyi = heap[i]
			var/lesskey = heap[lesser]
			if (heap[lesskey] < heap[keyi])
				heap.Swap(i, lesser)
				i = lesser
			else
				break
		else
			break

/proc/findPath_heapRemove(var/list/heap)
	var/turf/get = heap[1]
	var/value = heap[get]
	heap.Swap(1, heap.len)
	heap -= get
	findPath_heapify(heap, 1)
	return list(get, value)

/proc/findPath_heapModify(var/list/heap, var/turf/key, var/value)
	if (!(key in heap))
		return
	var/i = heap.Find(key)
	heap[key] = value
	findPath_heapify(heap, i)

/proc/findPath_weigh(var/turf/which, var/turf/parent, var/turf/target)
	var/moveDir = get_dir(parent, which)
	var/opposite = get_dir(which, parent)
	var/targetDir = get_dir(which, target)
	if (targetDir == moveDir)
		return 1
	if (targetDir == opposite)
		return 3
	if (moveDir in list(1,2,4,8))
		if (moveDir & targetDir)
			return 1.5
		if (opposite & targetDir)
			return 2.5
		return 2
	else
		if (targetDir in list(1,2,4,8))
			if (moveDir & targetDir)
				return 1.5
			if (opposite & targetDir)
				return 2.5
	return 2

/proc/findPath(var/turf/source, var/turf/target, var/maxIterations = 2500, var/stopRange = 5, var/stopOverflow = 50)
	var/list/open = list()
	open += source
	open[source] = findPath_H(source, target)
	var/list/parent = list()
	var/list/G = list()
	var/list/ignore = list()
	var/list/ret = list()
	var/iterations = 0
	var/turf/closest = source
	var/closest_H = maxIterations
	var/stop_counter = 0
	while (open.len)
		var/list/data = findPath_heapRemove(open)
		var/turf/check = data[1]
		var/H = findPath_H(check, target)
		var/dist = data[2] - H
		if (check == target)
			while (check != source)
				ret.Insert(1, check)
				check = parent[check]
			return ret
		if (stop_counter)
			stop_counter++
		if (H < closest_H)
			closest = check
			closest_H = H
			if (closest_H <= stopRange && !stop_counter)
				stop_counter++
		iterations++
		if (iterations >= maxIterations || stop_counter > stopOverflow)
			check = closest
			while (check != source)
				ret.Insert(1, check)
				check = parent[check]
			return ret
		for (var/turf/Q in orange(1, check))
			if (Q in ignore)
				continue
			if (!findPath_isValid(Q))
				ignore += Q
				continue
			if (!(Q in G))
				G += Q
				var/cG = dist + findPath_weigh(Q, check, target)
				G[Q] = cG
				parent += Q
				parent[Q] = check
				findPath_heapInsert(open, Q, dist + 1 + findPath_H(Q, target))
			else
				var/cG = dist + findPath_weigh(Q, check, target)
				if (cG < G[Q])
					G[Q] = cG
					parent[Q] = check
					findPath_heapModify(open, Q, dist + 1 + findPath_H(Q, target))

/proc/findPath_test()
	var/sx = input("Source X", "Source X", 50) as num
	var/sy = input("Source Y", "Source Y", 50) as num
	var/sz = input("Source Z", "Source Z", 50) as num
	var/tx = input("Target X", "Target X", 50) as num
	var/ty = input("Target Y", "Target Y", 50) as num
	var/tz = input("Target Z", "Target Z", 50) as num
	var/list/path = findPath(locate(sx,sy,sz),locate(tx,ty,tz))
	if (!path)
		boutput(world, "No path found.")
	else
		boutput(world, "Path of [path.len] found.")
