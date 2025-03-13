#define WALL 0
#define FLOOR 1

#define OTHER 5

/datum/map_generator/room_maze_generator
	var/cell_grid
	var/gen_min_x = 1
	var/gen_min_y = 1
	var/gen_max_x
	var/gen_max_y

	var/tree_type = /datum/bsp_tree
	var/room_size = 7
	wall_turf_type	= /turf/unsimulated/wall/auto/adventure/cave
	floor_turf_type = /turf/unsimulated/floor/cave

	var/edge_proc = /datum/map_generator/room_maze_generator/proc/connect_nodes_by_edges
	/// Border between rooms
	/// 0 means they will overlap such that they will share a wall
	var/room_border = 1

	New()
		. = ..()
		src.gen_max_x = world.maxx
		src.gen_max_y = world.maxy

	proc/fill_map()
		cell_grid = new/list(world.maxx,world.maxy)

		var/datum/bsp_tree/tree = new tree_type(x=gen_min_x, y=gen_min_y, width=gen_max_x-gen_min_x+1, height=gen_max_y-gen_min_y+1,
									  min_width=room_size, min_height=room_size)

		call(src, edge_proc)(tree)

	proc/build_room(datum/bsp_node/room)
		var/x = room.x + 1 + max(room_border - 1, 0)
		var/y = room.y + 1 + max(room_border - 1, 0)
		var/max_x = min(room.x+room.width-1-room_border, gen_max_x-1)
		var/max_y = min(room.y+room.height-1-room_border, gen_max_y-1)

		// Border consumes room
		if(x > max_x || y > max_y)
			return

		for(var/i in x to max_x)
			for(var/j in y to max_y)
				cell_grid[i][j] = FLOOR

	proc/connect_nodes_by_edges(datum/bsp_tree/tree)
		var/list/datum/bsp_node/nodes_to_visit = list(tree.root)
		while(length(nodes_to_visit))
			var/datum/bsp_node/current = nodes_to_visit[length(nodes_to_visit)]
			nodes_to_visit -= current

			if(current.left)
				nodes_to_visit += current.left
				nodes_to_visit += current.right
				connect_rooms(current.left, current.right)
			else
				build_room(current)
			LAGCHECK(LAG_MED)

	proc/connect_nodes_by_spatial_distance(datum/bsp_tree/tree)
		var/datum/spatial_hashmap/datums/spatial_map = new(cs=room_size*2, zlevels=1)
		spatial_map.update_cooldown = INFINITY
		var/center_x
		var/center_y
		for(var/datum/bsp_node/node in tree.leaves)
			center_x = node.x + node.width * 0.5
			center_y = node.y + node.height * 0.5
			spatial_map.add_target(center_x, center_y, 1, node)
			build_room(node)
		var/list/datum/bsp_node/connected = list()
		connected += pick(tree.leaves)
		tree.leaves -= connected
		var/datum/bsp_node/traverser
		var/datum/bsp_node/new_connection
		var/backtrack_ptr = 0
		while(length(tree.leaves))
			if(!length(connected))
				//FUCK SHIT FUCK
				break
			var/list/nearby
			var/attaching_loose_node = backtrack_ptr == length(connected)
			if(attaching_loose_node)
				//We backtracked and still didn't find anything... try connecting
				for(traverser in tree.leaves)
					center_x = traverser.x + traverser.width * 0.5
					center_y = traverser.y + traverser.height * 0.5
					nearby = spatial_map.get_nearby_by_coords(center_x, center_y, 1, room_size)
					nearby -= tree.leaves
					if(length(nearby))
						break // We found something!
				if(!length(nearby))
					break // We didn't find anything!!
			else
				traverser = connected[length(connected)-backtrack_ptr]
				center_x = traverser.x + traverser.width * 0.5
				center_y = traverser.y + traverser.height * 0.5
				nearby = spatial_map.get_nearby_by_coords(center_x, center_y, 1, room_size + backtrack_ptr)
				nearby -= connected
			if(length(nearby))
				backtrack_ptr = 0
				new_connection = pick(nearby)
				connect_rooms_by_line(traverser, new_connection)
				if(attaching_loose_node)
					connected += traverser
					tree.leaves -= traverser
				else
					connected += new_connection
					tree.leaves -= new_connection

			else
				backtrack_ptr++
		backtrack_ptr = 0

	// Based on proc/getline() but ensures the lines is contigious
	proc/connect_rooms_by_line(datum/bsp_node/room_a, datum/bsp_node/room_b) // Bresenham Line Drawing
		var/px=room_a.x+round(room_a.width*0.5)		//starting x
		var/py=room_a.y+round(room_a.height*0.5)
		var/dx=(room_b.x+round(room_b.width*0.5))-px	//x distance
		var/dy=(room_b.y+round(room_b.height*0.5))-py
		var/dxabs=abs(dx)//Absolute value of x distance
		var/dyabs=abs(dy)
		var/sdx=sign(dx)	//Sign of x distance (+ or -)
		var/sdy=sign(dy)
		var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
		var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
		var/j			//Generic integer for counting
		if(dxabs>=dyabs)	//x distance is greater than y
			for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
				y+=dyabs
				if(y>=dxabs)	//Every dyabs steps, step once in y direction
					y-=dxabs
					py+=sdy
					cell_grid[px][py] = FLOOR // contigious please!
				px+=sdx		//Step on in x direction
				cell_grid[px][py] = FLOOR
		else
			for(j=0;j<dyabs;j++)
				x+=dxabs
				if(x>=dyabs)
					x-=dyabs
					px+=sdx
					cell_grid[px][py] = FLOOR // contigious please!
				py+=sdy
				cell_grid[px][py] = FLOOR

	proc/connect_rooms(datum/bsp_node/room_a, datum/bsp_node/room_b)
		var/min_x
		var/min_y
		var/max_x
		var/max_y
		var/range
		if(room_a.x == room_b.x)
			range = round(room_a.width * 0.2)
			min_x = room_a.x + room_a.width * 0.5 + rand(-range, range)
			max_x = min_x + prob(15)
			min_y = room_a.y + room_a.height-1-max(room_border - 1, 1)
			max_y = room_b.y + max(room_border - 1, 1)
		else
			range = room_a.height * 0.2
			min_x = room_a.x + room_a.width-1-max(room_border - 1, 1)
			max_x = room_b.x + max(room_border - 1, 1)
			min_y = room_a.y + room_a.height * 0.5 + rand(-range, range)
			max_y = min_y + prob(15)

		if(min_x < 0)	min_x = 0
		if(min_y < 0)	min_y = 0
		if(max_x > src.gen_max_x)	max_x = src.gen_max_x
		if(max_y > src.gen_max_y)	max_y = src.gen_max_y

		for(var/i in min_x to max_x)
			for(var/j in min_y to max_y)
				cell_grid[i][j] = FLOOR

/datum/map_generator/room_maze_generator/generate_terrain(list/turfs, reuse_seed, flags)
	var/min_x = world.maxx
	var/min_y = world.maxy
	var/max_x = 0
	var/max_y = 0

	var/turf/sample = turfs[1]
	if(!length(cell_grid) || !reuse_seed)
		if(sample.z != Z_LEVEL_STATION)
			for(var/turf/T in turfs)
				if(T.x < min_x)
					min_x = T.x
				if(T.y < min_y)
					min_y = T.y
				if(T.x > max_x)
					max_x = T.x
				if(T.y > max_y)
					max_y = T.y

			src.gen_min_x = min_x
			src.gen_min_y = min_y
			src.gen_max_x = max_x
			src.gen_max_y = max_y
		fill_map()

	for(var/turf/T in turfs) //Go through all the turfs and generate them
		assign_turf(T, flags)
		src.lag_check()

/datum/map_generator/room_maze_generator/proc/assign_turf(turf/T, flags)
	var/cell_value = src.cell_grid[T.x][T.y]

	if(flags & MAPGEN_FLOOR_ONLY)
		cell_value = FLOOR

	switch(cell_value)
		if(WALL, null)
			T.ReplaceWith(wall_turf_type, handle_air=FALSE)

		if(FLOOR)
			T.ReplaceWith(floor_turf_type, handle_air=FALSE)

		if(OTHER)
			T.ReplaceWith(floor_turf_type, handle_air=FALSE)
			new/obj/item/material_piece/slag(T)

/datum/map_generator/room_maze_generator/random
	room_size = 3
	tree_type = /datum/bsp_tree/maze

/datum/map_generator/room_maze_generator/spatial
	room_size = 7
	edge_proc = /datum/map_generator/room_maze_generator/proc/connect_nodes_by_spatial_distance

#undef WALL
#undef FLOOR
#undef OTHER
