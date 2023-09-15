#define FLOOR 1
#define WALL 2
#define DOOR 3
#define FLOOR_ONLY 4

/datum/map_generator/storehouse_generator
	var/cell_grid
	var/gen_min_x = 1
	var/gen_min_y = 1
	var/gen_max_x
	var/gen_max_y

	var/floor_path = /turf/simulated/floor/industrial
	var/wall_path = /turf/simulated/wall/auto/supernorn/material/mauxite

	New()
		. = ..()
		src.gen_max_x = world.maxx
		src.gen_max_y = world.maxy

	proc/generate_map()
		cell_grid = new/list(world.maxx,world.maxy)
		build_rooms()
		build_walls()

	proc/fill_map()
		cell_grid = new/list(world.maxx,world.maxy)
		build_rooms(30, maximum_size=80)
		build_rooms(50, maximum_size=60)
		build_rooms(250, maximum_size=30)

		build_walls()

		for(var/i in src.gen_min_x to src.gen_max_x)
			for(var/j in src.gen_min_y to src.gen_max_y)

				if(i<=src.gen_min_x || i>=src.gen_max_x || j<=src.gen_min_y || j>=src.gen_max_y)
					cell_grid[i][j] = WALL
				else if(!cell_grid[i][j])
					if(prob(80))
						cell_grid[i][j] = FLOOR_ONLY
					else
						cell_grid[i][j] = FLOOR

	proc/build_rooms(count=30, maximum_size=25)
		var/x
		var/y
		var/max_x
		var/max_y
		var/overlay_range = maximum_size - 5
		for(var/i in 1 to count)
			var/floor_n_door = TRUE
			if(prob(90))
				//Pick new location
				x = rand(src.gen_min_x, src.gen_max_x-5)
				y = rand(src.gen_min_y, src.gen_max_y-5)
				max_x = min(x+rand(5,maximum_size),src.gen_max_x)
				max_y = min(y+rand(5,maximum_size),src.gen_max_y)

			// else if(prob(25) && (max_x-x>6 || max_y-y > 6))
			// 	//subdivide
			// 	if(prob(50))
			// 		x = rand(x+6, max_x-6)
			// 		max_x = x
			// 	else
			// 		y = rand(y+6, max_y-6)
			// 		max_y = y
			// 	set_type(x, y, max_x, max_y, WALL, force=TRUE)
			// 	add_perimeter_door(x, y, max_x, max_y)
			// 	floor_n_door = FALSE

			else
				//overlay
				x = clamp(rand(x, max_x), src.gen_min_x, src.gen_max_x)
				y = clamp(rand(y, max_y), src.gen_min_y, src.gen_max_y)

				max_x = clamp(x+rand(-overlay_range,overlay_range), src.gen_min_x, src.gen_max_x)
				max_y = clamp(y+rand(-overlay_range,overlay_range), src.gen_min_y, src.gen_max_y)

			if(floor_n_door)
				set_type(x, y, max_x, max_y, FLOOR)
				for(var/door in 1 to rand(1,2))
					add_perimeter_door(x, y, max_x, max_y)
			LAGCHECK(LAG_MED)

	proc/build_walls()
		for(var/i in src.gen_min_x to src.gen_max_x)
			for(var/j in src.gen_min_y to src.gen_max_y)
				if(cell_grid[i][j] == DOOR)
					if(i<=src.gen_min_x || i>=src.gen_max_x || j<=src.gen_min_y || j>=src.gen_max_y)
						// noop errors have been made
					else if(cell_grid[i-1][j] && cell_grid[i+1][j] && cell_grid[i][j-1] && cell_grid[i][j+1])
						cell_grid[i][j] = FLOOR
					else
						continue
				if(is_wall(i,j))
					cell_grid[i][j] = WALL
			LAGCHECK(LAG_MED)


	proc/add_perimeter_door(start_x, start_y, max_x, max_y)
		var/tries = 5
		var/x
		var/y
		while(tries-- > 0)

			x = rand(start_x+2, max_x-2)
			y = rand(start_y+2, max_y-2)

			if(rand(50))
				x = prob(50) ? start_x : max_x
			else
				y = prob(50) ? start_y : max_y
			if(x<=src.gen_min_x || x>=src.gen_max_x || y<=src.gen_min_y || y>=src.gen_max_y)
				continue
			else
				cell_grid[x][y] = DOOR
				tries = 0

	proc/set_type(start_x, start_y, max_x, max_y, type, force)
		for(var/i in start_x to max_x)
			for(var/j in start_y to max_y)
				if(!cell_grid[i][j] || force)
					cell_grid[i][j] = type

	proc/is_wall(x, y)
		if(cell_grid[x][y]!=FLOOR)
			return FALSE
		if(x<=src.gen_min_x || x>=src.gen_max_x || y<=src.gen_min_y || y>=src.gen_max_y)
			return TRUE
		if(cell_grid[x-1][y] || cell_grid[x+1][y] || cell_grid[x][y-1] || cell_grid[x][y+1])
			if(!cell_grid[x-1][y+1] \
			|| !cell_grid[x-1][y]   \
			|| !cell_grid[x-1][y-1] \
			|| !cell_grid[x][y+1]   \
			|| !cell_grid[x][y-1]   \
			|| !cell_grid[x+1][y+1] \
			|| !cell_grid[x+1][y]   \
			|| !cell_grid[x+1][y-1])
				return TRUE

	proc/clear_walls(turfs)
		for(var/turf/T in turfs)
			if(cell_grid[T.x][T.y])
				src.cell_grid[T.x][T.y] = FLOOR_ONLY

/datum/map_generator/storehouse_generator/generate_terrain(list/turfs, reuse_seed, flags)
	var/cell_value

	var/min_x = world.maxx
	var/min_y = world.maxy
	var/max_x = 0
	var/max_y = 0

	var/generate_stuff = !(flags & (MAPGEN_IGNORE_FLORA|MAPGEN_IGNORE_FAUNA))

	var/turf/sample = turfs[1]
	if(!length(cell_grid) || !reuse_seed)
		if(sample.z == Z_LEVEL_STATION)
			generate_map()
		else
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
			generate_map()

	for(var/turf/T in turfs) //Go through all the turfs and generate them
		cell_value = cell_grid[T.x][T.y]

		switch(cell_value)
			if(FLOOR)
				T.ReplaceWith(floor_path)
				if((T.x % 5 == 0) && (T.y % 5 == 0) && prob(95))
					if(prob(80))
						new /obj/machinery/light/small/floor/harsh/very(T)
					else
						new /obj/machinery/light/small/floor/broken(T)
				if(generate_stuff && prob(10))
					make_cleanable(/obj/decal/cleanable/dirt,T)
				if(generate_stuff && prob(2))
					var/rarity = rand(1, 100)
					switch(rarity)
						if(1 to 10)
							new /obj/storage/crate/loot/puzzle(T)
						if(11 to 90)
							new /obj/storage/crate(T)
						if(91 to 100)
							new /obj/storage/crate/wooden/(T)

			if(FLOOR_ONLY)
				T.ReplaceWith(floor_path)

			if(WALL)
				T.ReplaceWith(wall_path)

			if(DOOR)
				T.ReplaceWith(floor_path)
				var/obj/door = new /obj/machinery/door/airlock/pyro/classic(T)
				if(cell_grid[T.x-1][T.y] == WALL)
					door.dir = NORTH
				else
					door.dir = WEST

		LAGCHECK(LAG_MED)

#undef FLOOR
#undef WALL
#undef DOOR
#undef FLOOR_ONLY
