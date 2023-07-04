#define FLOOR 1
#define WALL 2
#define DOOR 3

/datum/map_generator/storehouse_generator
	var/cell_grid
	New()
		. = ..()
		cell_grid = new/list(300,300)

		var/x
		var/y
		var/max_x
		var/max_y
		for(var/i in 1 to 30)
			var/floor_n_door = TRUE
			if(prob(90))
				//Pick new location
				x = rand(1, 300)
				y = rand(1, 300)
				max_x = min(x+rand(5,25),300)
				max_y = min(y+rand(5,25),300)
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
				x = clamp(rand(x, max_x), 1, 300)
				y = clamp(rand(y, max_y), 1, 300)
				max_x = clamp(x+rand(-20,20), 1, 300)
				max_y = clamp(y+rand(-20,20), 1, 300)

			if(floor_n_door)
				set_type(x, y, max_x, max_y, FLOOR)
				for(var/door in 1 to rand(1,2))
					add_perimeter_door(x, y, max_x, max_y)

		build_walls()

	proc/build_walls()
		for(var/i in 1 to 300)
			for(var/j in 1 to 300)
				if(cell_grid[i][j] == DOOR)
					if(cell_grid[i-1][j] && cell_grid[i+1][j] && cell_grid[i][j-1] && cell_grid[i][j+1])
						cell_grid[i][j] = FLOOR
					else
						continue
				if(is_wall(i,j))
					cell_grid[i][j] = WALL


	proc/add_perimeter_door(start_x, start_y, max_x, max_y)
		var/x = rand(start_x+2, max_x-2)
		var/y = rand(start_y+2, max_y-2)
		if(rand(50))
			x = prob(50) ? start_x : max_x
		else
			y = prob(50) ? start_y : max_y
		cell_grid[x][y] = DOOR

	proc/set_type(start_x, start_y, max_x, max_y, type, force)
		for(var/i in start_x to max_x)
			for(var/j in start_y to max_y)
				if(!cell_grid[i][j] || force)
					cell_grid[i][j] = type

	proc/is_wall(x, y)
		if(cell_grid[x][y]!=FLOOR)
			return FALSE
		if(x==0 || x==300 || y==0 || y==300)
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

/datum/map_generator/storehouse_generator/generate_terrain(list/turfs, reuse_seed, flags)
	var/cell_value
	for(var/turf/T in turfs) //Go through all the turfs and generate them
		cell_value = cell_grid[T.x][T.y]

		switch(cell_value)
			if(FLOOR)
				T.ReplaceWith(/turf/simulated/floor/industrial)
				if((T.x % 5 == 0) && (T.y % 5 == 0) && prob(95))
					if(prob(80))
						new /obj/machinery/light/small/floor/harsh/very(T)
					else
						new /obj/machinery/light/small/floor/broken(T)
				if(prob(10))
					make_cleanable(/obj/decal/cleanable/dirt,T)
				if(prob(2))
					var/rarity = rand(1, 100)
					switch(rarity)
						if(1 to 10)
							new /obj/storage/crate/loot/puzzle(T)
						if(11 to 90)
							new /obj/storage/crate(T)
						if(91 to 100)
							new /obj/storage/crate/wooden/(T)

			if(WALL)
				T.ReplaceWith(/turf/simulated/wall/auto/supernorn/material/mauxite)

			if(DOOR)
				T.ReplaceWith(/turf/simulated/floor/industrial)
				var/obj/door = new /obj/machinery/door/airlock/pyro/classic(T)
				if(cell_grid[T.x-1][T.y] == WALL)
					door.dir = NORTH
				else
					door.dir = WEST

#undef FLOOR
#undef WALL
#undef DOOR
