/**
 * Allocation of map regions.
 *
 * The system written in this file is used to get access to rectangular regions of the map space where you can place whatever you want to.
 * Intended usage is for map structures that either don't need to be loaded at all times or of which there can be multiples of. For example if you
 * wanted to make a locker that leads to its pocket dimension you will need to create a new pocket dimension for each locker. That's where allocating
 * a region for each of them would come in handy.
 *
 * Example usage:
 * ```
 * var/datum/allocated_region/region = global.region_allocator.allocate(width=10, height=8)
 * for(var/x in 1 to region.width)
 * 	for(var/y in 1 to region.height)
 * 		if(x == 1 || y == 1 || x == region.width || y == region.height)
 * 			region.turf_at(x, y).ReplaceWith(/turf/unsimulated/wall)
 * 		else
 * 			region.turf_at(x, y).ReplaceWith(/turf/unsimulated/floor)
 * mob.set_loc(region.turf_at(2, 2))
 * boutput(mob, "You are in prison now.")
 * SPAWN(60 SECONDS)
 * 	mob.set_loc(whatever)
 * 	qdel(region)
 * ```
 */

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



/**
 * Represents a map region you have allocated access to.
 * While you hold a reference to this region you are free to assume nothing else will allocate this part of the map and touch your region.
 * You should also not go out of its bounds of course.
 * Deallocate the region by qdel()ing it or dropping all references to it.
 */
/datum/allocated_region
	/// Bottom left corner of the region
	var/turf/bottom_left
	/// Width in tiles
	var/width
	/// Height in tiles
	var/height
	/// Corresponding node in the region_allocator quad tree
	var/datum/region_node/node

	New(turf/bottom_left, width, height, datum/region_node/node)
		..()
		src.bottom_left = bottom_left
		src.width = width
		src.height = height
		ASSERT(node.state == NODE_STATE_FREE)
		node.set_state(NODE_STATE_USED)
		src.node = node
		global.region_allocator.allocated_regions += get_weakref(src)

	proc/free()
		PRIVATE_PROC(TRUE)
		ASSERT(node.state == NODE_STATE_USED)
		node.free_up_from_used()
		src.node = null
		global.region_allocator.allocated_regions -= src.weakref

	proc/clean_up(turf/main_turf=/turf/space, turf/edge_turf=/turf/cordon, area/main_area=/area/space)
		if(ispath(main_area))
			main_area = new main_area(null)
		for(var/turf/T in REGION_TURFS(src))
			var/target_type = turf_on_border(T) ? edge_turf : main_turf
			T = T.ReplaceWith(target_type, FALSE, FALSE, FALSE, force=TRUE)
			if(!isnull(main_area))
				main_area.contents += T
			for(var/atom/movable/AM in T)
				if(!istype(AM, /obj/overlay/tile_effect))
					qdel(AM)

	proc/move_movables_to(atom/destination)
		for(var/atom/movable/AM in REGION_TILES(src))
			if(!AM.anchored)
				AM.set_loc(destination)

	/// returns the center turf of the region, biasing towards top right if dimensions even
	proc/get_center()
		RETURN_TYPE(/turf)
		. = locate(
			src.bottom_left.x + round(src.width / 2),
			src.bottom_left.y + round(src.height / 2),
			src.bottom_left.z
		)

	/// returns a random turf in the region
	proc/get_random_turf()
		RETURN_TYPE(/turf)
		. = locate(
			src.bottom_left.x + rand(0, src.width - 1),
			src.bottom_left.y + rand(0, src.height - 1),
			src.bottom_left.z
		)

	/**
	 * Given local coordinates (x, y) returns you a turf at these coordinates in the region.
	 * I.e. (1, 1) will return src.bottom_left .
	 * This is the preferred method to access turfs in the region.
	 * If coordinates are out of bounds null will be returned.
	 */
	proc/turf_at(x, y)
		RETURN_TYPE(/turf)
		if(x > width || y > height || x < 1 || y < 1)
			return null
		return locate(
			bottom_left.x + x - 1,
			bottom_left.y + y - 1,
			bottom_left.z
		)

	/**
	 * Checks if a turf is in the region.
	 */
	proc/turf_in_region(turf/T)
		return T.z == bottom_left.z && T.x >= bottom_left.x && T.x < bottom_left.x + width && T.y >= bottom_left.y && T.y < bottom_left.y + height

	/**
	 * Returns the relative coordinates of the turf in the region (1, 1) being bottom left corner.
	 * Returns null if the turf is not in the region.
	 */
	proc/relative_turf_coords(turf/T)
		if(turf_in_region(T))
			. = list(T.x - bottom_left.x, T.y - bottom_left.y)

	/// Checks if the turf is on the (inner) border of the region
	proc/turf_on_border(turf/T)
		if(T.z != bottom_left.z)
			return FALSE
		return T.x == bottom_left.x || T.x == bottom_left.x + width - 1 || T.y == bottom_left.y || T.y == bottom_left.y + height - 1

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
		global.dont_init_space = TRUE
		world.setMaxZ(world.maxz + 1)
		global.dont_init_space = FALSE
		var/size = min(world.maxx, world.maxy)
		. = new/datum/region_node(1, 1, world.maxz, size, parent=null)

	proc/get_free_node(size)
		RETURN_TYPE(/datum/region_node)
		PRIVATE_PROC(TRUE)
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

	/**
	 * Calling this proc will give you an access to a region of the map where you can do whatever you want. (Usually load a prefab or generate
	 * some room or something like that).
	 * This region is not guaranteed to be empty of things so clean it up before use.
	 * To free up the region just delete the /datum/allocated_region object or drop all references to it.
	 * See [/datum/allocated_region] for details.
	 */
	proc/allocate(width, height)
		RETURN_TYPE(/datum/allocated_region)
		var/datum/region_node/node = src.get_free_node(max(width, height))
		. = new/datum/allocated_region(locate(node.x, node.y, node.z), width, height, node)


#undef NODE_STATE_FREE
#undef NODE_STATE_USED
#undef NODE_STATE_SPLIT

#undef MINIMUM_NODE_SIZE
