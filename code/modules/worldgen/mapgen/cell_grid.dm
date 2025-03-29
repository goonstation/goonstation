
/datum/cell_grid
	/// 2d Cell Grid
	var/grid

/datum/cell_grid/New(width, height)
	. = ..()
	grid = new/list(width,height)

/// Get the Manhattan distance between two points
/datum/cell_grid/proc/get_manhattan_distance(x1, y1, x2, y2)
	return abs(x1 - x2) + abs(y1 - y2)

/// Get the (Chebyshev) distance between two points
/datum/cell_grid/proc/get_distance(x1, y1, x2, y2)
	return max(abs(x1 - x2), abs(y1 - y2))

/// Draw in a region (box) from (min_x, min) to (max_x, max_y)
/datum/cell_grid/proc/draw_area(min_x, min_y, max_x, max_y, value, override)
	for(var/x in min_x to max_x)
		for(var/y in min_y to max_y)
			if(!src.grid[x][y] || override) src.grid[x][y] = value

/// Draw 2 orthogonal lines that connect (x1,y1) to (x2,y2)
/datum/cell_grid/proc/drawLShape(x1, y1, x2, y2, value1, value2, override)
	var/corner_x = x1
	var/corner_y = y2
	if(prob(50))
		corner_x = x2
		corner_y = y1

	draw_line(x1, y1, corner_x, corner_y, value1, override)
	draw_line(corner_x, corner_y, x2, y2, value2, override)

/// Draw 2 orthogonal boxes that connect (x1,y1) to (x2,y2) based on the internal size
/datum/cell_grid/proc/drawLBox(x1, y1, x2, y2, value1, value2, border_value1, border_value2, internal_size=1, override)
	var/corner_x = x1
	var/corner_y = y2
	if(prob(50) )
		corner_x = x2
		corner_y = y1

		draw_box(x1, y1-internal_size+1, corner_x, corner_y+internal_size-1, value1, value1, override)
		draw_box(corner_x-internal_size+1, corner_y, x2+internal_size-1, y2, value2, value2, override)
	else
		draw_box(x1-internal_size+1, y1, corner_x+internal_size-1, corner_y, value1, value1, override)
		draw_box(corner_x, corner_y-internal_size+1, x2, y2+internal_size-1, value2, value2, override)

/// Retrieve list of (x,y) tuples composing line from (x1,y1) to (x2,y2) - Bresenham Line
/datum/cell_grid/proc/draw_box(min_x, min_y, max_x, max_y, inner_value, border_value, override)
	draw_line(min_x, max_y,   max_x, max_y, border_value, override)
	draw_line(max_x, max_y-1, max_x, min_y+1, border_value, override)
	draw_line(max_x, min_y,   min_x, min_y, border_value, override)
	draw_line(min_x, min_y+1, min_x, max_y-1, border_value, override)
	draw_area(min_x+1, min_y+1, max_x-1, max_y-1, inner_value, override)

/// Retrieve list of (x,y) tuples composing line from (x1,y1) to (x2,y2) - Bresenham Line
/datum/cell_grid/proc/get_line(x1, y1, x2, y2, contigious=TRUE)
	. = list()
	var/px=x1		//starting x
	var/py=y1
	var/dx=x2-px	//x distance
	var/dy=y2-py
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
				if(contigious)
					. += list(list(px,py)) // contigious please!
			px+=sdx		//Step on in x direction
			. += list(list(px,py))
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
				if(contigious)
					. = list(list(px,py)) // contigious please!
			py+=sdy
			. += list(list(px,py))

/// Retrieve directions (N,E,S,W) where box has truthy elements adjacent to it
/datum/cell_grid/proc/box_has_border(x1, y1, x2, y2)
	var/point
	//NORTH
	for(point in get_line(x1, y2+1, x2, y2+1))
		if(grid[point[1]][point[2]])
			. |= NORTH
			break

	//SOUTH
	for(point in get_line(x1, y1-1, x2, y1-1))
		if(grid[point[1]][point[2]])
			. |= SOUTH
			break

	//EAST
	for(point in get_line(x2+1, y1, x2+1, y2))
		if(grid[point[1]][point[2]])
			. |= EAST
			break

	//WEST
	for(point in get_line(x1-1, y1, x1-1, y2))
		if(grid[point[1]][point[2]])
			. |= WEST
			break

/// Get list of (x,y) tuples that make up edges of a box (x1,y1) to (x2,y2)
/datum/cell_grid/proc/get_box_border(x1, y1, x2, y2, dir, exclude_edges)
	. = list()
	var/point
	if(dir & NORTH)
		for(point in get_line(x1+exclude_edges, y2+1, x2-exclude_edges, y2+1))
			if(grid[point[1]][point[2]])
				. |= list(point)

	if(dir & SOUTH)
		for(point in get_line(x1+exclude_edges, y1-1, x2-exclude_edges, y1-1))
			if(grid[point[1]][point[2]])
				. |= list(point)

	if(dir & EAST)
		for(point in get_line(x2+1, y1+exclude_edges, x2+1, y2-exclude_edges))
			if(grid[point[1]][point[2]])
				. |= list(point)

	if(dir & WEST)
		for(point in get_line(x1-1, y1+exclude_edges, x1-1, y2-exclude_edges))
			if(grid[point[1]][point[2]])
				. |= list(point)

/// Set of list of (x,y) tuples in cell grid
/datum/cell_grid/proc/fill_points(list/points, value, override)
	for(var/point in points)
		if(length(point)!=2)
			break
		if(point[1] > 0 && point[1] < length(grid) \
		&& point[2] > 0 && point[2] < length(grid[1]) )
			continue
		if(!src.grid[point[1]][point[2]] || override)
			src.grid[point[1]][point[2]] = value

/// Draw line from (x1,y1) to (x2,y2) - Bresenham Line Drawing
/datum/cell_grid/proc/draw_line(x1, y1, x2, y2, value, override, contigious=TRUE)
	var/px=x1		//starting x
	var/py=y1
	var/dx=x2-px	//x distance
	var/dy=y2-py
	var/dxabs=abs(dx)//Absolute value of x distance
	var/dyabs=abs(dy)
	var/sdx=sign(dx)	//Sign of x distance (+ or -)
	var/sdy=sign(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(!src.grid[px][py] || override)  src.grid[px][py] = value
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
				if(contigious)
					if(!src.grid[px][py] || override)  src.grid[px][py] = value // contigious please!
			px+=sdx		//Step on in x direction
			if(!src.grid[px][py] || override) src.grid[px][py] = value
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
				if(contigious)
					if(!src.grid[px][py] || override) src.grid[px][py] = value // contigious please!
			py+=sdy
			if(!src.grid[px][py] || override) src.grid[px][py] = value

/// Retrieve an attribute of a cell when cell use associative arrays
/datum/cell_grid/proc/get_cell_attribute(x, y, attribute)
	if(length(grid[x][y]) == 3)
		. = grid[x][y][attribute]

/// Convert a string array to cell_grid assigning value_alive when 1 and value_dead when 0
/datum/cell_grid/proc/draw_from_string(cell_string, value_alive, value_dead, override)
	for(var/x in 1 to length(grid))
		for(var/y in 1 to length(grid[1]))
			var/index = x * length(grid) + y
			var/cell_value
			if(index <= length(cell_string))
				cell_value = text2num(cell_string[index])
			if(cell_value)
				if(!src.grid[x][y] || override) src.grid[x][y] = value_alive
			else
				if(!src.grid[x][y] || override) src.grid[x][y] = value_dead

/// Retrieve a list of contigious open/set regions that contain the corresponding (x,y) tuple lists for those regions
/datum/cell_grid/proc/find_contigious_cells()
	var/visited = new/list(length(src.grid),length(src.grid[1]))

	var/connected_cells = list()
	var/group_id = 0
	var/current_group = list()
	var/list/to_visit = list()
	for(var/x in 1 to length(visited))
		for(var/y in 1 to length(visited[1]))
			if(!visited[x][y])
				if(src.grid[x][y])
					to_visit = list(list(x,y))
					current_group = list()
					while(length(to_visit))
						var/cell_x = to_visit[1][1]
						var/cell_y = to_visit[1][2]
						if(!visited[cell_x][cell_y] && src.grid[cell_x][cell_y])
							if((cell_x-1 >= 1) && !visited[cell_x-1][cell_y] ) //WEST
								to_visit += list(list(cell_x-1,cell_y))
							if((cell_x+1 <= length(grid))&& !visited[cell_x+1][cell_y]) //EAST
								to_visit += list(list(cell_x+1,cell_y))
							if((cell_y+1 <= length(grid[1]))&& !visited[cell_x][cell_y+1])  //NORTH
								to_visit += list(list(cell_x, cell_y+1))
							if((cell_y-1 >= 1) && !visited[cell_x][cell_y-1])  //SOUTH
								to_visit += list(list(cell_x, cell_y-1))

							current_group += list(list(to_visit[1][1],to_visit[1][2]))
						visited[cell_x][cell_y] = TRUE
						to_visit.Cut(1,2)
					connected_cells["[group_id++]"] += current_group
				else
					visited[x][y] = TRUE
	return connected_cells

/// Determine if cell has any empty/closed/falsey neighbors
/datum/cell_grid/proc/has_empty_neighbor(x, y, diagonals=FALSE)
	if((x-1 >= 1) && !src.grid[x-1][y] ) //WEST
		. = TRUE
	else if((x+1 <= length(grid))&& !src.grid[x+1][y]) //EAST
		. = TRUE
	else if((y+1 <= length(grid[1]))&& !src.grid[x][y+1])  //NORTH
		. = TRUE
	else if((y-1 >= 1) && !src.grid[x][y-1])  //SOUTH
		. = TRUE

	if(diagonals)
		if((x-1 >= 1) && (y-1 >= 1) && !src.grid[x-1][y-1] ) //SW
			. = TRUE
		else if((x+1 <= length(grid)) && (y-1 >= 1) && !src.grid[x+1][y-1]) //SE
			. = TRUE
		else if((x-1 >= 1) && (y+1 <= length(grid[1]))&& !src.grid[x-1][y+1])  //NW
			. = TRUE
		else if((x+1 <= length(grid)) && (y+1 <= length(grid[1])) && !src.grid[x+1][y+1])  //NE
			. = TRUE

/// Generates maze with the botom left of (x1,y1) and top right of (x2,y2) where all open cells are set to the floor_value
/datum/cell_grid/proc/generate_maze(x1, y1, x2, y2, floor_value, override)
	var/list/valid_grid = new/list(length(src.grid),length(src.grid[1]))

	var/list/unvisited_cells = list()
	var/list/frontier_cells = list()

	for(var/x in x1 to x2)
		if(x % 2)
			continue
		for(var/y in y1 to y2)
			if(!((y) % 2) && (!src.grid[x][y] || override) )
				valid_grid[x][y] = TRUE
				unvisited_cells += list(list(x,y))

	frontier_cells += list(pick(unvisited_cells))

	while(length(frontier_cells))
		var/point = pick(frontier_cells)
		var/list/neighbors = get_cell_neighbors(point[1],point[2], cardinal, 2)

		for(var/neighbor_point in neighbors)
			// exclude used neighbors and invalid neighbors
			if(src.grid[neighbor_point[1]][neighbor_point[2]] \
				|| !valid_grid[neighbor_point[1]][neighbor_point[2]] )
				neighbors -= list(neighbor_point)

		if(!length(neighbors))
			frontier_cells -= list(point)
			continue

		var/visit_point = pick(neighbors)
		var/offset_x = (visit_point[1] - point[1])/2
		var/offset_y = (visit_point[2] - point[2])/2

		frontier_cells += list(visit_point)

		if(!src.grid[visit_point[1]][visit_point[2]] || override)
			src.grid[visit_point[1]][visit_point[2]] = floor_value

		visit_point = list(point[1]+offset_x,point[2]+offset_y)
		if(!src.grid[visit_point[1]][visit_point[2]] || override)
			src.grid[visit_point[1]][visit_point[2]] = floor_value

/// Retrieve list of list(x,y) tuples for coordinate provided
/datum/cell_grid/proc/get_cell_neighbors(x, y, neighbors, offset=1)
	var/adj_x
	var/adj_y
	. = list()
	for(var/dir in neighbors)
		adj_x = x
		adj_y = y

		if(dir & NORTH)
			adj_y += offset
		if(dir & EAST)
			adj_x += offset
		if(dir & SOUTH)
			adj_y -= offset
		if(dir & WEST)
			adj_x -= offset

		if(adj_x > 0 && adj_x < length(grid) \
		&& adj_y > 0 && adj_y < length(grid[1]))
			. += list(list(adj_x, adj_y))
