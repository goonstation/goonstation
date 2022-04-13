#define NODE_STATE_FREE 0
#define NODE_STATE_USED 1
#define NODE_STATE_SPLIT 2

#define MINIMUM_NODE_SIZE 9

var/global/datum/region_allocator/region_allocator = new

/datum/region_node
	var/size
	var/x
	var/y
	var/z
	var/state = NODE_STATE_FREE
	var/list/datum/region_node/children
	var/datum/region_node/parent = null
	var/n_free_children = 0

	New(x, y, z, size, parent=null)
		..()
		src.x = x
		src.y = y
		src.z = z
		src.size = size
		src.parent = parent
		if(src.parent)
			LAZYLISTADD(src.parent.children, src)
			ASSERT(src.parent.state != NODE_STATE_USED)
			src.parent.set_state(NODE_STATE_SPLIT)
			src.parent.n_free_children++
		LAZYLISTADD(global.region_allocator.free_nodes["[size]"], src)

	proc/set_state(new_state)
		if(src.state == NODE_STATE_FREE && new_state != NODE_STATE_FREE)
			global.region_allocator.free_nodes["[size]"] -= src // maybe optimize to check end first if byond doesn't already do that
			src.parent?.n_free_children--
		else if(src.state != NODE_STATE_FREE && new_state == NODE_STATE_FREE)
			global.region_allocator.free_nodes["[size]"] += src
			src.parent?.n_free_children++
		src.state = new_state

	disposing()
		if(src.state == NODE_STATE_FREE)
			global.region_allocator.free_nodes["[size]"] -= src
			src.parent?.n_free_children--
		..()

	proc/split()
		if(src.state != NODE_STATE_FREE)
			return FALSE
		var/child_size = round(src.size / 2)
		if(child_size < MINIMUM_NODE_SIZE)
			return FALSE
		new/datum/region_node(src.x + child_size, src.y + child_size, src.z, child_size, src)
		new/datum/region_node(src.x + child_size, src.y, src.z, child_size, src)
		new/datum/region_node(src.x, src.y + child_size, src.z, child_size, src)
		new/datum/region_node(src.x, src.y, src.z, child_size, src)
		return TRUE

	proc/free_up_from_used()
		ASSERT(state == NODE_STATE_USED)
		set_state(NODE_STATE_FREE)
		if(length(global.region_allocator.free_nodes["[size]"]) > 4)
			parent?.attempt_join()

	proc/attempt_join()
		ASSERT(length(children) == 4 && state == NODE_STATE_SPLIT)
		if(n_free_children != 4)
			return FALSE
		for(var/datum/region_node/child in children)
			child.dispose()
		src.children = null
		src.set_state(NODE_STATE_FREE)
		return TRUE


/datum/allocated_region
	var/turf/bottom_left
	var/width
	var/height
	var/datum/region_node/node

	New(turf/bottom_left, width, height, datum/region_node/node)
		..()
		src.bottom_left = bottom_left
		src.width = width
		src.height = height
		ASSERT(node.state == NODE_STATE_FREE)
		node.set_state(NODE_STATE_USED)
		src.node = node
		global.region_allocator.allocated_regions[src] = 1

	proc/free()
		PRIVATE_PROC(TRUE)
		ASSERT(node.state == NODE_STATE_USED)
		node.free_up_from_used()
		src.node = null
		global.region_allocator.allocated_regions -= src

	proc/turf_at(x, y)
		RETURN_TYPE(/turf)
		if(x > width || y > height || x < 1 || y < 1)
			return null
		return locate(
			bottom_left.x + x - 1,
			bottom_left.y + y - 1,
			bottom_left.z
		)

	proc/turf_in_region(turf/T)
		return T.z == bottom_left.z && T.x >= bottom_left.x && T.x < bottom_left.x + width && T.y >= bottom_left.y && T.y < bottom_left.y + height

	disposing()
		free()
		..()

	Del()
		if(src.node)
			free()
		. = ..()


/datum/region_allocator
	var/list/list/free_nodes = list()
	var/list/datum/allocated_region/allocated_regions = list()

	proc/add_z_level()
		RETURN_TYPE(/datum/region_node)
		world.setMaxZ(world.maxz + 1)
		var/size = min(world.maxx, world.maxy)
		. = new/datum/region_node(1, 1, world.maxz, size, parent=null)

	proc/get_free_node(size)
		RETURN_TYPE(/datum/region_node)
		var/datum/region_node/best_fit = null
		for(var/node_size_str in src.free_nodes)
			if(length(src.free_nodes[node_size_str]) <= 0)
				continue
			var/node_size = text2num(node_size_str)
			if(node_size < size)
				continue
			if(isnull(best_fit) || node_size < best_fit.size)
				best_fit = src.free_nodes[node_size_str][length(src.free_nodes[node_size_str])]
		if(isnull(best_fit))
			best_fit = src.add_z_level()
		while(round(best_fit.size / 2) >= size)
			if(!best_fit.split())
				break
			best_fit = best_fit.children[length(best_fit.children)]
		return best_fit

	proc/allocate(width, height)
		RETURN_TYPE(/datum/allocated_region)
		var/datum/region_node/node = src.get_free_node(max(width, height))
		. = new/datum/allocated_region(locate(node.x, node.y, node.z), width, height, node)


#undef NODE_STATE_FREE
#undef NODE_STATE_USED
#undef NODE_STATE_SPLIT

#undef MINIMUM_NODE_SIZE
