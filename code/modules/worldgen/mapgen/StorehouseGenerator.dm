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
	var/door_path = /obj/machinery/door/airlock/pyro/classic

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

	proc/fill_map_bsp()
		cell_grid = new/list(world.maxx,world.maxy)
		var/datum/bsp_node/room
		var/list/datum/bsp_node/branch
		var/datum/bsp_tree/tree = new(width=world.maxx, height=world.maxy, min_width=7, min_height=7)

		// Create a series of merged rooms, prune entire branch from which the rooms could merge
		for(var/x in 1 to 80)
			if(!length(tree.leaves))
				break
			room = pick(tree.leaves)

			tree.leaves -= room
			branch = tree.get_leaves(room.parent.parent.parent)
			tree.leaves -= branch

			set_type(room.x, room.y, room.x+room.width-1, room.y+room.height-1, FLOOR)
			for(var/door in 1 to rand(1,2))
				add_perimeter_door(room.x, room.y, room.x+room.width-1, room.y+room.height-1)

			for(var/datum/bsp_node/leaf in branch)
				if(tree.are_nodes_adjacent(room,leaf))
					set_type(leaf.x, leaf.y, leaf.x+leaf.width-1, leaf.y+leaf.height-1, FLOOR)
					for(var/door in 1 to rand(1,2))
						add_perimeter_door(leaf.x, leaf.y, leaf.x+leaf.width-1, leaf.y+leaf.height-1)

		// Create a series of small rooms, prune individual leaves
		for(var/x in 1 to 40)
			if(!length(tree.leaves))
				break
			room = pick(tree.leaves)

			tree.leaves -= room

			set_type(room.x, room.y, room.x+room.width-1, room.y+room.height-1, FLOOR)
			for(var/door in 1 to rand(1,2))
				add_perimeter_door(room.x, room.y, room.x+room.width-1, room.y+room.height-1)

		// Create a series of LARGE rooms, prune individual leaves
		for(var/x in 1 to 20)
			if(!length(tree.leaves))
				break
			room = pick(tree.leaves)
			room = room.parent
			room = room.parent
			branch = tree.get_leaves(room)
			tree.leaves -= branch

			set_type(room.x, room.y, room.x+room.width-1, room.y+room.height-1, FLOOR)
			for(var/door in 1 to rand(1,2))
				add_perimeter_door(room.x, room.y, room.x+room.width-1, room.y+room.height-1)

		// Iterate through remaining leaves and convert them into rooms and purge leaves of 1-4 parents to
		// reduce number of empty areas
		while(length(tree.leaves))
			room = pick(tree.leaves)
			set_type(room.x, room.y, room.x+room.width-1, room.y+room.height-1, FLOOR)
			for(var/door in 1 to rand(1,2))
				add_perimeter_door(room.x, room.y, room.x+room.width-1, room.y+room.height-1)

			for(var/i in 1 to rand(4))
				room = room.parent
			branch = tree.get_leaves(room)
			tree.leaves -= branch

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
						; // noop errors have been made
					else if(cell_grid[i-1][j] && cell_grid[i+1][j] && cell_grid[i][j-1] && cell_grid[i][j+1])
						cell_grid[i][j] = FLOOR
					else if(cell_grid[i-1][j] != WALL && cell_grid[i][j-1] != WALL)
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
	var/min_x = world.maxx
	var/min_y = world.maxy
	var/max_x = 0
	var/max_y = 0

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
		assign_turf(T, flags)
		src.lag_check(flags)

/datum/map_generator/storehouse_generator/proc/assign_turf(turf/T, flags)
	var/cell_value = cell_grid[T.x][T.y]

	var/generate_stuff = !(flags & (MAPGEN_IGNORE_FLORA|MAPGEN_IGNORE_FAUNA))

	if(flags & MAPGEN_FLOOR_ONLY)
		cell_value = FLOOR_ONLY

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
						new /obj/storage/crate/loot(T)
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
			var/obj/door = new door_path(T)
			if(cell_grid[T.x-1][T.y] == WALL)
				door.dir = NORTH
			else
				door.dir = WEST

/datum/map_generator/storehouse_generator/meaty
	floor_path = /turf/unsimulated/floor/setpieces/bloodfloor
	wall_path = /turf/unsimulated/wall/auto/adventure/meat
	door_path = /obj/machinery/door/airlock/pyro/classic

	var/list/meatier
	var/list/stomach

	New()
		..()

	assign_turf(turf/T, flags)
		var/generate_stuff = !(flags & (MAPGEN_IGNORE_FLORA|MAPGEN_IGNORE_FAUNA))
		var/cell_value = cell_grid[T.x][T.y]
		var/meaty = FALSE
		var/stomach_goop = FALSE
		var/index = T.x * world.maxx + T.y

		if(!meatier)
			meatier = rustg_dbp_generate("[rand(1,420)]", "5", "15", "[world.maxx]", "0.001", "0.9")
		if(!stomach)
			stomach = rustg_worley_generate("17", "10", "30", "[world.maxx]", "5", "10")

		if(index <= length(meatier))
			meaty = text2num(meatier[T.x * world.maxx + T.y])
		if(index <= length(stomach))
			stomach_goop = text2num(stomach[T.x * world.maxx + T.y])
		if(flags & MAPGEN_FLOOR_ONLY)
			cell_value = FLOOR_ONLY

		var/datum/biome/selected_biome
		switch(cell_value)
			if(FLOOR)
				if(meaty && stomach_goop)
					selected_biome = biomes[/datum/biome/meat/stomach]
				else
					if(meaty)
						selected_biome = biomes[/datum/biome/meat/meaty]
					else
						selected_biome = biomes[/datum/biome/meat]

				selected_biome.generate_turf(T, flags)

				if(generate_stuff && prob(2))
					var/rarity = rand(1, 100)
					switch(rarity)
						if(1 to 8)
							new /obj/storage/crate/loot(T)
						else
							make_cleanable(/obj/decal/cleanable/blood/gibs, T)

			if(FLOOR_ONLY)
				selected_biome = biomes[/datum/biome/meat]
				selected_biome.generate_turf(T, flags | MAPGEN_IGNORE_FAUNA)
				if(meaty)
					T.icon_state = "bloodfloor_2"
				else if(prob(60))
					T.icon_state = "bloodfloor_3"

				if(generate_stuff && prob(0.8))
					var/rarity = rand(1, 100)

					switch(rarity)
						if(1 to 8)
							selected_biome.fauna_hashmap?.add_weakref(new /obj/item/mine/gibs/armed(T))
						if(10 to 20)
							selected_biome.fauna_hashmap?.add_weakref(new /obj/item/mine/gibs(T))
						else
							make_cleanable(/obj/decal/cleanable/blood/gibs, T)

			if(WALL)
				if(meaty)
					if(prob(3))
						T.ReplaceWith(/turf/unsimulated/wall/auto/adventure/meat/eyes)
					else
						T.ReplaceWith(/turf/unsimulated/wall/auto/adventure/meat/meatier)
				else
					T.ReplaceWith(wall_path)

			if(DOOR)
				selected_biome = biomes[/datum/biome/meat]
				selected_biome.generate_turf(T, flags | MAPGEN_IGNORE_FAUNA | MAPGEN_IGNORE_FLORA)
				if(meaty)
					T.icon_state = "bloodfloor_2"

				var/obj/door
				if(meaty)
					door = new /obj/machinery/door/unpowered/martian/meat(T)
				else
					if(!generate_stuff || prob(80))
						door = new door_path(T)
					else
						door = new /obj/critter/monster_door(T)

				if(cell_grid[T.x-1][T.y] == WALL)
					door.dir = NORTH
				else
					door.dir = WEST

/turf/unsimulated/floor/auto/meat
	name = "bloody floor"
	desc = "Yuck."
	icon_state = "bloodfloor_2"

	edge_priority_level = FLOOR_AUTO_EDGE_PRIORITY_DIRT
	var/icon_edge = 'icons/misc/meatland.dmi'
	icon_state_edge = "acid_corners"

	edge_overlays()
		for(var/direction in list(SOUTH))
			var/turf/unsimulated/floor/setpieces/bloodfloor/stomach/T = get_step(src, direction)
			if(!istype(T) || !istype(get_step(T, direction), /turf/unsimulated/floor/setpieces/bloodfloor/stomach))
				continue
			var/edge_direction = turn(direction, 180)
			var/image/edge_overlay = image(src.icon_edge, "[icon_state_edge]",dir=edge_direction)
			edge_overlay.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR | RESET_ALPHA
			edge_overlay.layer = src.layer + (src.edge_priority_level / 1000)
			edge_overlay.plane = PLANE_FLOOR
			T.AddOverlays(edge_overlay, "edge_[edge_direction]")


/datum/biome/meat
	turf_type = /turf/unsimulated/floor/setpieces/bloodfloor
	flora_types = list(/obj/map/light/meatland = 95, /obj/meatlight=5)
	flora_density = 2
	minimum_flora_distance = 7

	fauna_types = list(	/mob/living/critter/blobman/meat = 25,
#ifdef HALLOWEEN
						/mob/living/critter/changeling/buttcrab/ai_controlled = 1,
						/mob/living/critter/changeling/eyespider/ai_controlled = 1,
						/mob/living/critter/changeling/legworm/ai_controlled=5,
						/mob/living/critter/changeling/handspider/ai_controlled=5,
#endif
						/obj/item/mine/gibs/armed=8,
						/obj/item/mine/gibs=5)
	fauna_density = 1
	minimum_fauna_distance = 5

/datum/biome/meat/meaty
	turf_type = /turf/unsimulated/floor/auto/meat
	flora_density = 5

/datum/biome/meat/stomach
	turf_type = /turf/unsimulated/floor/setpieces/bloodfloor/stomach

	fauna_types = list(/obj/stomachacid=1)
	flora_density = 100
	minimum_fauna_distance = null

	flora_types = null

#undef FLOOR
#undef WALL
#undef DOOR
#undef FLOOR_ONLY
