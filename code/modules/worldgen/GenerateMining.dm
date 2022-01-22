#define ISDISTEDGE(A, D) (((A.x > (world.maxx - D) || A.x <= D)||(A.y > (world.maxy - D) || A.y <= D))?1:0) //1 if A is within D tiles range from edge of the map.
#define DEBRIS_NOGENERATE_PREFAB_EXCLUSION 8
#define DEBRIS_NOGENERATE_ASTEROID_EXCLUSION 8


var/list/miningModifiers = list()
var/list/miningModifiersUsed = list()//Assoc list, type:times used

var/list/debrisModifiersBig = list()
var/list/debrisModifiersBigUsed = list()//Assoc list, type:times used

// because we don't need these shitty 5x6 prefabs to be weighted the same as the big ones
var/list/debrisModifiersSmall = list()
var/list/debrisModifiersSmallUsed = list()//Assoc list, type:times used

var/list/debrisDroneBeacons = list()
var/list/debrisDroneBeaconsUsed = list()

var/icon/debris_map = 0
var/icon/debris_map_html = 0
var/list/debris_map_colors = list(
	empty = rgb(30, 30, 45),
	solid = rgb(180,180,180),
	station = rgb(27, 163, 186),
	syndicate = rgb(237, 3, 3),
	other = rgb(136, 2, 44))

//Notes:
//Anything not encased in an area inside a prefab may be replaced with asteroids during generation. In other words, everything not inside that area is considered "transparent"
//Make sure all your actual structures are inside that area.

/turf/variableTurf
	icon = 'icons/turf/internal.dmi'
	name = ""

	New()
		..()
		place()

	proc/place()
		if (map_currently_underwater)
			src.ReplaceWith(/turf/space/fluid/trench, FALSE, TRUE, FALSE, TRUE)
		else
			src.ReplaceWith(/turf/space, FALSE, TRUE, FALSE, TRUE)

	floor //Replaced with map appropriate floor tile for mining level (asteroid floor on all maps currently)
		name = "variable floor"
		icon_state = "floor"
		place()
			if (map_currently_underwater)
				src.ReplaceWith(/turf/space/fluid/trench, FALSE, TRUE, FALSE, TRUE)
			else
				src.ReplaceWith(/turf/simulated/floor/plating/airless/asteroid, FALSE, TRUE, FALSE, TRUE)

	wall //Replaced with map appropriate wall tile for mining level (asteroid wall on all maps currently)
		name = "variable wall"
		icon_state = "wall"
		place()
			src.ReplaceWith(/turf/simulated/wall/asteroid, FALSE, TRUE, FALSE, TRUE)

	clear //Replaced with map appropriate clear tile for mining level (asteroid floor on oshan, space on other maps)
		name = "variable clear"
		icon_state = "clear"
		place()
			if (map_currently_underwater)
				src.ReplaceWith(/turf/space/fluid/trench, FALSE, TRUE, FALSE, TRUE)
			else
				src.ReplaceWith(/turf/space, FALSE, TRUE, FALSE, TRUE)

/area/noGenerate
	name = ""
	icon_state = "blockgen"

/area/allowGenerate //Areas of this type do not block asteroid/cavern generation.
	name = ""
	icon_state = "allowgen"

	trench
		name = "Trench"
		sound_group = "trench"
		force_fullbright = 0
		requires_power = 0
		luminosity = 0
		sound_environment = 22
		ambient_light = TRENCH_LIGHT

/proc/decideSolid(var/turf/current, var/turf/center, var/sizemod = 0)
	if(!current || !center || (current.loc.type != /area/space && !istype(current.loc , /area/allowGenerate)) || !istype(current, /turf/space))
		return 0
	if(ISDISTEDGE(current, AST_MAPBORDER))
		return 0
	var/probability = 100 - (((abs(center.x - current.x) + abs(center.y - current.y)) - (AST_MINSIZE+sizemod)) * AST_REDUCTION) + rand(-AST_TILERNG,AST_TILERNG)
	if((abs(center.x - current.x) + abs(center.y - current.y)) <= (AST_MINSIZE+sizemod) || prob(probability))
		return 1
	return 0

/datum/mapGenerator
	var/list/seeds = list()
	var/list/generated = list()

	proc/generate(var/list/levelTurfs)
		return levelTurfs

/proc/CAGetSolid(var/L, var/currentX, var/currentY, var/generation)
	var/default = 1 //1 = wall, 0 = empty
	var/minSolid = 5 //Min amount of solid tiles in a given window to produce another solid tile, less = more dense map
	var/fillLarge = 0 //If 1, put rocks in the middle of very large open caverns so they don't look so empty. Can create very tight maps.
	var/endFill = -1 //Reduce minSolid by this much in the last few passes (produces tighter corridors)
	var/passTwoRange = 2 //Range Threshold for second pass (fill pass, see fillLarge). The higher the number, the larger the cavern needs to be before it is filled in.

	var/count = 0
	for(var/xx=-1, xx<=1, xx++)
		for(var/yy=-1, yy<=1, yy++)
			if(currentX+xx <= world.maxx && currentX+xx >= 1 && currentY+yy <= world.maxy && currentY+yy >= 1)
				count += L[currentX+xx][currentY+yy]
			else //OOB, count as wall.
				count += default

	var/count2 = 0
	if(fillLarge)
		for(var/xx=-passTwoRange, xx<=passTwoRange, xx++)
			for(var/yy=-passTwoRange, yy<=passTwoRange, yy++)
				if(abs(xx)==passTwoRange && abs(yy)==passTwoRange) continue //Skip diagonals for this one. Better results
				if(currentX+xx <= world.maxx && currentX+xx >= 1 && currentY+yy <= world.maxy && currentY+yy >= 1)
					count2 += L[currentX+xx][currentY+yy]
				else //OOB, count as wall.
					count2 += default

	return (count >= minSolid + ((generation==4||generation==3) ? endFill : 0 ) || (count2<=(generation==4?1:2) && fillLarge && (generation==3 || generation==4)) ) //Remove ((generation==4||generation==3)?-1:0) for larger corridors

/datum/mapGenerator/seaCaverns //Cellular automata based generator. Produces cavern-like maps. Empty space is filled with asteroid floor.
	generate(var/list/miningZ, var/z_level = AST_ZLEVEL, var/generate_borders = TRUE)
		var/map[world.maxx][world.maxy]
		for(var/x=1,x<=world.maxx,x++)
			for(var/y=1,y<=world.maxy,y++)
				map[x][y] = pick(90;1,100;0) //Initialize randomly.

		for(var/i=0, i<5, i++) //5 Passes to smooth it out.
			var/mapnew[world.maxx][world.maxy]
			for(var/x=1,x<=world.maxx,x++)
				for(var/y=1,y<=world.maxy,y++)
					mapnew[x][y] = CAGetSolid(map, x, y, i)
					LAGCHECK(LAG_REALTIME)
			map = mapnew

		for(var/x=1,x<=world.maxx,x++)
			for(var/y=1,y<=world.maxy,y++)
				var/turf/T = locate(x,y,z_level)
				if(map[x][y] && !ISDISTEDGE(T, 3) && T.loc && ((T.loc.type == /area/space) || istype(T.loc , /area/allowGenerate)) )
					var/turf/simulated/wall/asteroid/N = T.ReplaceWith(/turf/simulated/wall/asteroid/dark, FALSE, TRUE, FALSE, TRUE)
					N.quality = rand(-101,101)
					generated.Add(N)
				if(T.loc.type == /area/space || istype(T.loc, /area/allowGenerate))
					new/area/allowGenerate/trench(T)
				LAGCHECK(LAG_REALTIME)

		var/list/used = list()
		for(var/s=0, s<20, s++)
			var/turf/TU = pick(generated - used)
			var/list/L = list()
			for(var/turf/simulated/wall/asteroid/A in orange(5,TU))
				L.Add(A)
			seeds.Add(TU)
			seeds[TU] = L
			used.Add(L)
			used.Add(TU)

			var/list/holeList = list()
			for(var/k=0, k<AST_RNGWALKINST, k++)
				var/turf/T = pick(L)
				for(var/j=0, j<rand(AST_RNGWALKCNT,round(AST_RNGWALKCNT*1.5)), j++)
					holeList.Add(T)
					T = get_step(T, pick(NORTH,EAST,SOUTH,WEST))
					if(!istype(T, /turf/simulated/wall/asteroid)) continue
					var/turf/simulated/wall/asteroid/ast = T
					ast.destroy_asteroid(0)


		for(var/i=0, i<80, i++)
			var/list/L = list()
			for (var/turf/simulated/wall/asteroid/dark/A in range(4,pick(generated)))
				L+=A

			Turfspawn_Asteroid_SeedOre(L, rand(2,8), rand(1,70))

		for(var/i=0, i<80, i++)
			Turfspawn_Asteroid_SeedOre(generated)


		//for(var/i=0, i<100, i++)
		//	if(prob(20))
		//		Turfspawn_Asteroid_SeedOre(generated, rand(2,6), rand(0,70))
		//	else
		//		Turfspawn_Asteroid_SeedOre(generated)

		for(var/i=0, i<40, i++)
			Turfspawn_Asteroid_SeedEvents(generated)

		if(generate_borders)
			var/list/border = list()
			border |= (block(locate(1,1,z_level), locate(AST_MAPBORDER,world.maxy,z_level))) //Left
			border |= (block(locate(1,1,z_level), locate(world.maxx,AST_MAPBORDER,z_level))) //Bottom
			border |= (block(locate(world.maxx-(AST_MAPBORDER-1),1,z_level), locate(world.maxx,world.maxy,z_level))) //Right
			border |= (block(locate(1,world.maxy-(AST_MAPBORDER-1),z_level), locate(world.maxx,world.maxy,z_level))) //Top

			for(var/turf/T in border)
				T.ReplaceWith(/turf/unsimulated/wall/trench, FALSE, TRUE, FALSE, TRUE)
				new/area/cordon/dark(T)
				LAGCHECK(LAG_REALTIME)

		for (var/i=0, i<55, i++)
			var/turf/T = locate(rand(1,world.maxx),rand(1,world.maxy),z_level)
			for (var/turf/space/fluid/TT in range(rand(2,4),T))
				TT.spawningFlags |= SPAWN_TRILOBITE

		return miningZ

/datum/mapGenerator/asteroidsDistance //Generates a bunch of asteroids based on distance to seed/center. Super simple.
	generate(var/list/miningZ)
		var/numAsteroidSeed = AST_SEEDS + rand(1, 5)
		for(var/i=0, i<numAsteroidSeed, i++)
			var/turf/X = pick(miningZ)
			var/quality = rand(-101,101)

			while(!istype(X, /turf/space) || ISDISTEDGE(X, AST_MAPSEEDBORDER) || (X.loc.type != /area/space && !istype(X.loc , /area/allowGenerate)))
				X = pick(miningZ)
				LAGCHECK(LAG_REALTIME)

			var/list/solidTiles = list()
			var/list/edgeTiles = list(X)
			var/list/visited = list()

			var/sizeMod = rand(-AST_SIZERANGE,AST_SIZERANGE)

			while(edgeTiles.len)
				var/turf/curr = edgeTiles[1]
				edgeTiles.Remove(curr)

				if(curr in visited) continue
				else visited.Add(curr)

				var/turf/north = get_step(curr, NORTH)
				var/turf/east = get_step(curr, EAST)
				var/turf/south = get_step(curr, SOUTH)
				var/turf/west = get_step(curr, WEST)
				if(decideSolid(north, X, sizeMod))
					solidTiles.Add(north)
					edgeTiles.Add(north)
				if(decideSolid(east, X, sizeMod))
					solidTiles.Add(east)
					edgeTiles.Add(east)
				if(decideSolid(south, X, sizeMod))
					solidTiles.Add(south)
					edgeTiles.Add(south)
				if(decideSolid(west, X, sizeMod))
					solidTiles.Add(west)
					edgeTiles.Add(west)
				LAGCHECK(LAG_REALTIME)

			var/list/placed = list()
			for(var/turf/T in solidTiles)
				if((T?.loc?.type == /area/space) || istype(T?.loc , /area/allowGenerate))
					var/turf/simulated/wall/asteroid/AST = T.ReplaceWith(/turf/simulated/wall/asteroid)
					placed.Add(AST)
					AST.quality = quality
				LAGCHECK(LAG_REALTIME)

			if(prob(15))
				Turfspawn_Asteroid_SeedOre(placed, rand(2,6), rand(0,40))
			else
				Turfspawn_Asteroid_SeedOre(placed)

			Turfspawn_Asteroid_SeedEvents(placed)

			if(placed.len)
				generated.Add(placed)
				if(placed.len > 9)
					seeds.Add(X)
					seeds[X] = placed
					var/list/holeList = list()
					for(var/k=0, k<AST_RNGWALKINST, k++)
						var/turf/T = pick(placed)
						for(var/j=0, j<rand(AST_RNGWALKCNT,round(AST_RNGWALKCNT*1.5)), j++)
							holeList.Add(T)
							T = get_step(T, pick(NORTH,EAST,SOUTH,WEST))
							if(!istype(T, /turf/simulated/wall/asteroid)) continue
							var/turf/simulated/wall/asteroid/ast = T
							ast.destroy_asteroid(0)
		return miningZ


/datum/mapGenerator/debrisDistance //Generates a bunch of space junk and drones
	generate(var/list/debrisZ)
		var/list/possible_garbage = list(/obj/decal/floatingtiles, /obj/decal/cleanable/robot_debris/gib, /obj/item/raw_material/rock, /obj/lattice, /obj/item/raw_material/shard/glass, /obj/item/cable_coil/cut)
		var/drone_amount = rand(DEBRIS_DRONE_LOWER, DEBRIS_DRONE_UPPER)
		var/garbage_amount = rand(DEBRIS_GARBAGE_LOWER, DEBRIS_GARBAGE_UPPER)
		var/asteroid_amount = rand(DEBRIS_ASTEROID_LOWER, DEBRIS_ASTEROID_UPPER)
		var/loot_thingies = rand(DEBRIS_LOOT_LOWER, DEBRIS_LOOT_UPPER)

		for(var/i in 1 to asteroid_amount)
			var/ast_length = rand(DEBRIS_ASTEROID_LENGTH_LOWER, DEBRIS_ASTEROID_LENGTH_UPPER)
			var/turf/X = pick(debrisZ)
			var/turf_check = FALSE

			while(istype(get_area(X), /area/noGenerate) || !istype(X, /turf/space) || ISDISTEDGE(X, AST_MAPSEEDBORDER) || (X.loc.type != /area/space && !istype(X.loc , /area/allowGenerate)) || X.x >= 290 || X.y >= 290 || X.x <= 10 || X.y <= 10)
				X = pick(debrisZ)
				LAGCHECK(LAG_REALTIME)

			while(!turf_check) //there may be a better way to do this, but it works
				var/atom/t_thing
				for(var/atom/T as obj|turf in view(3, X))
					if(!istype(T, /turf/space))
						t_thing = T
						break
				for(var/area/noGenerate/NG in range(DEBRIS_NOGENERATE_ASTEROID_EXCLUSION, X))
					if(!t_thing)
						t_thing = NG
					break
				if(!t_thing)
					turf_check = TRUE
				else
					X = pick(debrisZ)
					LAGCHECK(LAG_REALTIME)

			var/list/ast_turfs = list(X)
			var/list/full_ast_turfs = list()

			var/turf/curr_turf = X
			for(var/a in 1 to ast_length)
				var/turf/rand_step = get_step_rand(curr_turf)
				var/shit_fucked = 0

				while(ast_turfs.Find(rand_step) || !istype(rand_step, /turf/space) || (rand_step.loc.type != /area/space && !istype(rand_step.loc , /area/allowGenerate)))
					if(ISDISTEDGE(rand_step, AST_MAPSEEDBORDER) || !rand_step)
						shit_fucked += 1
					rand_step = get_step_rand(curr_turf)
					LAGCHECK(LAG_REALTIME)
					if(shit_fucked >= 5)
						rand_step = curr_turf

				ast_turfs += rand_step
				curr_turf = rand_step

			full_ast_turfs = ast_turfs
			for(var/turf/T in ast_turfs)
				var/turf/simulated/wall/asteroid/ast_wall = T.ReplaceWith(/turf/simulated/wall/asteroid)
				ast_wall.hardness = ((ast_wall.x > 150 ? 300 - ast_wall.x : ast_wall.x) + (ast_wall.y > 150 ? 300 - ast_wall.y : ast_wall.y)) / 15
				var/list/neighbors = getneighbours(T) //why does this have to be the bri'ish spelling
				for(var/turf/T2 in neighbors)
					if(ast_turfs.Find(T2) || !istype(T2, /turf/space) || ISDISTEDGE(T2, AST_MAPSEEDBORDER) || (T2.loc.type != /area/space && !istype(T2.loc, /area/allowGenerate)))
						continue

					full_ast_turfs += T2
					var/turf/simulated/wall/asteroid/ast_wall2 = T2.ReplaceWith(/turf/simulated/wall/asteroid)
					ast_wall2.hardness = ((ast_wall.x > 150 ? 300 - ast_wall.x : ast_wall.x) + (ast_wall.y > 150 ? 300 - ast_wall.y : ast_wall.y)) / 15
			Turfspawn_Asteroid_SeedOre(full_ast_turfs, 1, debris_field = TRUE)

		for(var/i in 1 to loot_thingies)
			var/turf/possible_spot = pick(debrisZ)
			var/xcalc
			var/ycalc
			var/turf_check = FALSE

			while(istype(get_area(possible_spot), /area/noGenerate) || !istype(possible_spot, /turf/space) || ISDISTEDGE(possible_spot, AST_MAPSEEDBORDER) || (possible_spot.loc.type != /area/space && !istype(possible_spot.loc, /area/allowGenerate)) || possible_spot.x >= 295 || possible_spot.y >= 295 || possible_spot.x <= 5 || possible_spot.y <= 5)
				possible_spot = pick(debrisZ)
				LAGCHECK(LAG_REALTIME)


			while(!turf_check) //there may be a better way to do this, but it works
				var/atom/t_thing
				for(var/atom/T as obj|turf in view(3, possible_spot))
					if(!istype(T, /turf/space))
						t_thing = T
						break
				if(!t_thing)
					turf_check = TRUE
				else
					possible_spot = pick(debrisZ)
					LAGCHECK(LAG_REALTIME)

			var/obj/lattice/base_floor = new(possible_spot)
			var/numberthing = rand(1, 10)
			if(numberthing >= 8)
				new/obj/storage/crate/loot(base_floor)
			else if(numberthing >= 5)
				new/obj/artifact_type_spawner/vurdalak(base_floor)
			else if(numberthing >= 2) //10% chance to get nada
				if(possible_spot.x > 150)
					xcalc = 300 - possible_spot.x
				else
					xcalc = possible_spot.x

				if(possible_spot.y > 150)
					ycalc = 300 - possible_spot.y
				else
					ycalc = possible_spot.y

				if((xcalc + ycalc) >= 250)
					var/obj/C = pick(childrentypesof(/obj/storage/crate/debris_loot/high))
					new C(base_floor)
				else if((xcalc + ycalc) >= 150)
					var/obj/C = pick(childrentypesof(/obj/storage/crate/debris_loot/med))
					new C(base_floor)
				else
					var/obj/C = pick(childrentypesof(/obj/storage/crate/debris_loot/low))
					new C(base_floor)

			var/list/neighbors = getneighbours(possible_spot)
			for(var/turf/T in neighbors)
				if(istype(get_area(T), /area/noGenerate) || !istype(T, /turf/space) || ISDISTEDGE(T, AST_MAPSEEDBORDER) || (T.loc.type != /area/space && !istype(T.loc, /area/allowGenerate)) || T.x >= 295 || T.y >= 295)
					continue

				var/floor_or_what = pick("turf", "obj", "nothing")
				switch(floor_or_what)
					if("turf")
						var/T2 = pick("plating", "burned", "damaged")
						switch(T2)
							if("plating")
								var/turf/simulated/floor/W = T.ReplaceWithFloor()
								W.to_plating()
							if("burned")
								var/turf/simulated/floor/W = T.ReplaceWithFloor()
								W.burnt = TRUE
								W.icon_state = pick("floorscorched1", "floorscorched2")
							if("damaged")
								var/turf/simulated/floor/W = T.ReplaceWithFloor()
								W.broken = TRUE
								W.icon_state = pick("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

					if("obj")
						var/obj/O = pick(/obj/lattice, /obj/structure/girder/displaced, /obj/grille/steel)
						new O(T)

					if("nothing")
						continue

				var/list/neighbors2 = getneighbours(T)
				for(var/turf/T3 in neighbors2)
					if(istype(get_area(T3), /area/noGenerate) || !istype(T3, /turf/space) || ISDISTEDGE(T3, AST_MAPSEEDBORDER) || (T3.loc.type != /area/space && !istype(T3.loc, /area/allowGenerate)))
						continue

					if(prob(33))
						new/obj/lattice(T3)
					if(prob(15))
						var/obj/trash = pick(possible_garbage)
						new trash(T3)

					if(prob(15)) //we're going DEEP
						var/list/neighbors3 = getneighbours(T3)
						for(var/turf/T4 in neighbors3)
							if(istype(get_area(T), /area/noGenerate) || !istype(T, /turf/space) || ISDISTEDGE(T, AST_MAPSEEDBORDER) || (T.loc.type != /area/space && !istype(T.loc, /area/allowGenerate)))
								continue

							var/floor_or_obj = pick("turf", "obj")
							switch(floor_or_obj)
								if("turf")
									var/T2 = pick("plating", "burned", "damaged")
									switch(T2)
										if("plating")
											var/turf/simulated/floor/W = T.ReplaceWithFloor()
											W.to_plating()
										if("burned")
											var/turf/simulated/floor/W = T.ReplaceWithFloor()
											W.burnt = TRUE
											W.icon_state = pick("floorscorched1", "floorscorched2")
										if("damaged")
											var/turf/simulated/floor/W = T.ReplaceWithFloor()
											W.broken = TRUE
											W.icon_state = pick("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

								if("obj")
									var/obj/O = pick(/obj/lattice, /obj/structure/girder/displaced, /obj/grille/steel)
									new O(T)


		for(var/i in 1 to garbage_amount)
			var/turf/possible_spot = pick(debrisZ)

			while(istype(get_area(possible_spot), /area/noGenerate) || !istype(possible_spot, /turf/space) || ISDISTEDGE(possible_spot, AST_MAPSEEDBORDER) || (possible_spot.loc.type != /area/space && !istype(possible_spot.loc, /area/allowGenerate)))
				possible_spot = pick(debrisZ)
				LAGCHECK(LAG_REALTIME)

			var/obj/garbage = pick(possible_garbage)
			new garbage(possible_spot)

		for(var/i in 1 to drone_amount)
			var/turf/possible_spot = pick(debrisZ)
			var/xcalc
			var/ycalc

			while(istype(get_area(possible_spot), /area/noGenerate) || !istype(possible_spot, /turf/space) || ISDISTEDGE(possible_spot, AST_MAPSEEDBORDER) || (possible_spot.loc.type != /area/space && !istype(possible_spot.loc, /area/allowGenerate)))
				possible_spot = pick(debrisZ)
				LAGCHECK(LAG_REALTIME)

			//the closer to center you are, the more dangerous drones that spawn

			if(possible_spot.x > 150)
				xcalc = 300 - possible_spot.x
			else
				xcalc = possible_spot.x

			if(possible_spot.y > 150)
				ycalc = 300 - possible_spot.y
			else
				ycalc = possible_spot.y

			var/drone_risk = max(1, ((xcalc + ycalc) / 2) / 10)

			var/list/drones = list()
			drones[/obj/critter/gunbot/drone/heavydrone] = drone_risk
			if(drone_risk < 10)
				drones[/obj/critter/gunbot/drone/buzzdrone] = 25-drone_risk
				drones[/obj/critter/gunbot/drone/laserdrone] = 20-drone_risk
			if(drone_risk > 10)
				drones[/obj/critter/gunbot/drone/cannondrone] = drone_risk-10
				drones[/obj/critter/gunbot/drone/minigundrone] = drone_risk-10
			if(drone_risk > 15)
				drones[/obj/critter/gunbot/drone/aciddrone] = drone_risk-15
			if(drone_risk > 20)
				drones[/obj/critter/gunbot/drone/assdrone] = drone_risk-20

			var/obj/drone = pick(drones)
			new drone(possible_spot)

		return debrisZ

///////// DEBRIS FIELD MAPPING SHIT /////////

/proc/generate_debris_map()
	if (!debris_map)
		Z_LOG_DEBUG("Debris Map", "Generating map ...")
		debris_map = icon('icons/misc/trenchMapEmpty.dmi', "template") //yeah i'm reusing it, sue me
		var/turf_color = null
		for (var/x = 1, x <= world.maxx, x++)
			for (var/y = 1, y <= world.maxy, y++)
				var/turf/T = locate(x,y,3)
				if (T.name == "asteroid" || T.name == "cavern wall" || T.type == /turf/simulated/floor/plating/airless/asteroid)
					turf_color = "solid"
				else if (T.name == "trench floor" || T.name == "\proper space")
					turf_color = "empty"
				else
					turf_color = "other"

				debris_map.DrawBox(debris_map_colors[turf_color], x * 2, y * 2, x * 2 + 1, y * 2 + 1)
		for_by_tcl(B, /obj/machinery/drone_beacon)
			var/turf/T = get_turf(B)
			debris_map.DrawBox(debris_map_colors["syndicate"], T.x * 2 - 2, T.y * 2 - 2, T.x * 2 + 2, T.y * 2 + 2)
		for_by_tcl(S, /obj/machinery/sword_terminal)
			var/turf/T = get_turf(S)
			debris_map.DrawBox(debris_map_colors["syndicate"], T.x * 2 - 2, T.y * 2 - 2, T.x * 2 + 2, T.y * 2 + 2)

			Z_LOG_DEBUG("Debris Map", "Map generation complete")
			generate_debris_map_html()

/proc/generate_debris_map_html()
	if (!debris_map)
		return

	debris_map_html = {"
<!doctype html>
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge;">
	<style type="text/css">
		body {
			background: black;
			color: white;
			font-family: 'Consolas', 'Ubuntu Mono', monospace;
		}
		* {
			border-sizing: border-box;
			image-rendering: -moz-crisp-edges;
			image-rendering: -o-crisp-edges;
			image-rendering: -webkit-optimize-contrast;
			image-rendering: crisp-edges;
			image-rendering: pixelated;
			-ms-interpolation-mode:nearest-neighbor;
			}
		#map {
			position: relative;
			height: 600px;
			width: 600px;
			overflow: hidden;
			margin: 0 auto;
		}
		#map img {
			position: absolute;
			bottom: 0
			left: 0;
		}
		.hotspot {
			position: absolute;
			background: rgba(255, 120, 120, 0.6);
		}
		.key {
			text-align: center;
			margin-top: 0.5em;
		}
		.key > span {
			white-space: nowrap;
			display: inline-block;
			margin: 0 0.5em;
		}
		.key > span > span {
			display: inline-block;
			height: 1em;
			width: 1em;
			border: 1px solid white;
		}
		.empty { background-color: [debris_map_colors["empty"]]; }
		.solid { background-color: [debris_map_colors["solid"]]; }
		.station { background-color: [debris_map_colors["station"]]; }
		.syndicate { background-color: [debris_map_colors["syndicate"]]; }
		.other { background-color: [debris_map_colors["other"]]; }
	</style>
</head>
<body>
		<div id='map'>
			<img src="trenchmap.png" height="600">
		</div>
		<div class='key'>
			<span><span class='solid'></span> Solid Rock</span>
			<span><span class='station'></span> NT Asset</span>
			<span><span class='syndicate'></span> Syndicate</span>
			<span><span class='other'></span> Unknown</span>
			</div>
</body>
</html>
"}

/proc/show_debris_map(var/client/C)
	if (!C)
		return
	if (!debris_map_html || !debris_map)
		boutput(C, "oh no, map doesnt exist!")
		return
	C << browse_rsc(debris_map, "trenchmap.png")
	C << browse(debris_map_html, "window=trench_map;size=650x700;title=Debris Map")


/proc/makeMiningLevel()
	var/list/miningZ = list()
	var/startTime = world.timeofday
	if(world.maxz < AST_ZLEVEL)
		boutput(world, "<span class='alert'>Skipping Mining Generation!</span>")
		return
	else
		boutput(world, "<span class='alert'>Generating Mining Level ...</span>")

	for(var/turf/T)
		if(T.z == AST_ZLEVEL)
			miningZ.Add(T)

	var/num_to_place = AST_NUMPREFABS + rand(0,AST_NUMPREFABSEXTRA)
	for (var/n = 1, n <= num_to_place, n++)
		game_start_countdown?.update_status("Setting up mining level...\n(Prefab [n]/[num_to_place])")
		var/datum/generatorPrefab/M = pickAstPrefab()
		if (M)
			var/maxX = (world.maxx - M.prefabSizeX - AST_MAPBORDER)
			var/maxY = (world.maxy - M.prefabSizeY - AST_MAPBORDER)
			var/stop = 0
			var/count= 0
			var/maxTries = (M.required ? 200:33)
			while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(1+AST_MAPBORDER, maxX), rand(1+AST_MAPBORDER,maxY), AST_ZLEVEL)
				var/ret = M.applyTo(target)
				if (ret == 0)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to blocked area. [target] @ [showCoords(target.x, target.y, target.z)]")
				else
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type][M.required?" (REQUIRED)":""] succeeded. [target] @ [showCoords(target.x, target.y, target.z)]")
					stop = 1
				count++
				if (count >= 33)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to maximum tries [maxTries][M.required?" WARNING: REQUIRED FAILED":""]. [target] @ [showCoords(target.x, target.y, target.z)]")
		else break

	var/datum/mapGenerator/D

	if(map_currently_underwater)
		D = new/datum/mapGenerator/seaCaverns()
	else
		D = new/datum/mapGenerator/asteroidsDistance()

	game_start_countdown?.update_status("Setting up mining level...\nGenerating terrain...")
	miningZ = D.generate(miningZ)

	// remove temporary areas
	for (var/turf/T in get_area_turfs(/area/noGenerate))
		if (map_currently_underwater)
			new /area/allowGenerate/trench(T)
		else
			new /area/space(T)
	if (!map_currently_underwater)
		for (var/turf/T in get_area_turfs(/area/allowGenerate))
			new /area/space(T)

	boutput(world, "<span class='alert'>Generated Mining Level in [((world.timeofday - startTime)/10)] seconds!")

	hotspot_controller.generate_map()

/proc/makeDebrisLevel()
	var/list/debrisZ = list()
	var/startTime = world.timeofday
	if(world.maxz < DEBRIS_ZLEVEL)
		boutput(world, "<span class='alert'>Skipping Debris Generation!</span>")
		return
	else
		boutput(world, "<span class='alert'>Generating Debris Level ...</span>")

	for(var/turf/T)
		if(T.z == DEBRIS_ZLEVEL)
			debrisZ.Add(T)

	var/num_to_place_big = DEBRIS_NUMBIGPREFABS + rand(0, DEBRIS_NUMBIGPREFABSEXTRA)
	for (var/n in 1 to num_to_place_big)
		game_start_countdown?.update_status("Setting up debris level...\n(Large Prefab [n]/[num_to_place_big])")
		var/datum/generatorPrefab/M = pickDebPrefabBig()
		if (M)
			var/maxX = (world.maxx - M.prefabSizeX - AST_MAPBORDER)
			var/maxY = (world.maxy - M.prefabSizeY - AST_MAPBORDER)
			var/stop = FALSE
			var/count = 0
			var/maxTries = (M.required ? 200:33)
			while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(1+AST_MAPBORDER, maxX), rand(1+AST_MAPBORDER,maxY), DEBRIS_ZLEVEL)
				var/area_stop = FALSE
				var/ret
				for(var/area/noGenerate/NG in range(DEBRIS_NOGENERATE_PREFAB_EXCLUSION, target))
					area_stop = TRUE
					break
				if(!area_stop)
					ret = M.applyTo(target)
				if (!ret)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to proximity to a NoGenerate area, or was blocked. [target] @ [showCoords(target.x, target.y, target.z)]")
				else
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type][M.required?" (REQUIRED)":""] succeeded. [target] @ [showCoords(target.x, target.y, target.z)]")
					stop = TRUE
				count++
				if (count >= 33)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to maximum tries [maxTries][M.required?" WARNING: REQUIRED FAILED":""]. [target] @ [showCoords(target.x, target.y, target.z)]")
		else break

	var/num_to_place_small = DEBRIS_NUMSMALLPREFABS + rand(0, DEBRIS_NUMSMALLPREFABSEXTRA)
	for (var/n in 1 to num_to_place_small)
		game_start_countdown?.update_status("Setting up debris level...\n(Small Prefab [n]/[num_to_place_small])")
		var/datum/generatorPrefab/M = pickDebPrefabSmall()
		if (M)
			var/maxX = (world.maxx - M.prefabSizeX - AST_MAPBORDER)
			var/maxY = (world.maxy - M.prefabSizeY - AST_MAPBORDER)
			var/stop = FALSE
			var/count = 0
			var/maxTries = (M.required ? 200:33)
			while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(1+AST_MAPBORDER, maxX), rand(1+AST_MAPBORDER,maxY), DEBRIS_ZLEVEL)
				var/area_stop = FALSE
				var/ret
				for(var/area/noGenerate/NG in range(DEBRIS_NOGENERATE_PREFAB_EXCLUSION, target))
					area_stop = TRUE
					break
				if(!area_stop)
					ret = M.applyTo(target)
				if (!ret)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to proximity to a NoGenerate area, or was blocked. [target] @ [showCoords(target.x, target.y, target.z)]")
				else
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type][M.required?" (REQUIRED)":""] succeeded. [target] @ [showCoords(target.x, target.y, target.z)]")
					stop = TRUE
				count++
				if (count >= 33)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to maximum tries [maxTries][M.required?" WARNING: REQUIRED FAILED":""]. [target] @ [showCoords(target.x, target.y, target.z)]")
		else break

	for (var/n in 1 to DEBRIS_DRONE_BEACONS)
		game_start_countdown?.update_status("Setting up debris level...\n(Drone Beacon [n]/[DEBRIS_DRONE_BEACONS])")
		var/datum/generatorPrefab/M = pickDebDroneBeacon()
		if (M)
			var/maxX = (world.maxx - M.prefabSizeX - AST_MAPBORDER)
			var/maxY = (world.maxy - M.prefabSizeY - AST_MAPBORDER)
			var/stop = FALSE
			var/count = 0
			var/maxTries = (M.required ? 200:33)
			while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(1+AST_MAPBORDER, maxX), rand(1+AST_MAPBORDER,maxY), DEBRIS_ZLEVEL)
				var/area_stop = FALSE
				var/ret
				for(var/area/noGenerate/NG in range(DEBRIS_NOGENERATE_PREFAB_EXCLUSION, target))
					area_stop = TRUE
					break
				if(!area_stop)
					ret = M.applyTo(target)
				if (!ret)
					logTheThing("debug", null, null, "Drone Beacon #[n] [M.type] failed due to proximity to a NoGenerate area, or was blocked. [target] @ [showCoords(target.x, target.y, target.z)]")
				else
					logTheThing("debug", null, null, "Drone Beacon #[n] [M.type][M.required?" (REQUIRED)":""] succeeded. [target] @ [showCoords(target.x, target.y, target.z)]")
					stop = TRUE
				count++
				if (count >= 60) //we really need these fucking things to spawn
					logTheThing("debug", null, null, "Drone Beacon #[n] [M.type] failed due to maximum tries [maxTries][M.required?" WARNING: REQUIRED FAILED":""]. [target] @ [showCoords(target.x, target.y, target.z)]")
		else break

	var/datum/mapGenerator/D = new/datum/mapGenerator/debrisDistance()

	game_start_countdown?.update_status("Setting up debris level...\nGenerating terrain...")
	debrisZ = D.generate(debrisZ)

	// remove temporary areas
	for (var/turf/T in get_area_turfs(/area/noGenerate))
		if (map_currently_underwater)
			new /area/allowGenerate/trench(T)
		else
			new /area/space(T)
	if (!map_currently_underwater)
		for (var/turf/T in get_area_turfs(/area/allowGenerate))
			new /area/space(T)

	boutput(world, "<span class='alert'>Generated Debris Level in [((world.timeofday - startTime)/10)] seconds!")

	generate_debris_map()

/proc/pickAstPrefab()
	var/list/eligible = list()
	var/list/required = list()

	for(var/datum/generatorPrefab/M in miningModifiers)
		if(M.underwater != map_currently_underwater) continue
		if(M.type in miningModifiersUsed)
			if(M.required) continue
			if(M.maxNum != -1)
				if(miningModifiersUsed[M.type] >= M.maxNum)
					continue
				else
					eligible.Add(M)
					eligible[M] = M.probability
			else
				eligible.Add(M)
				eligible[M] = M.probability
		else
			eligible.Add(M)
			eligible[M] = M.probability
			if(M.required) required.Add(M)

	if(length(required))
		var/datum/generatorPrefab/P = required[1]
		miningModifiersUsed.Add(P.type)
		miningModifiersUsed[P.type] = 1
		return P
	else
		if(length(eligible))
			var/datum/generatorPrefab/P = weighted_pick(eligible)
			if(P.type in miningModifiersUsed)
				miningModifiersUsed[P.type] = (miningModifiersUsed[P.type] + 1)
			else
				miningModifiersUsed.Add(P.type)
				miningModifiersUsed[P.type] = 1
			return P
		else return null

/proc/pickDebPrefabBig()
	var/list/eligibleBig = list()
	var/list/requiredBig = list()

	//big prefab handling
	for(var/datum/generatorPrefab/M in debrisModifiersBig)
		if(M.underwater != map_currently_underwater) continue
		if(M.type in debrisModifiersBigUsed)
			if(M.required) continue
			if(M.maxNum != -1)
				if(debrisModifiersBigUsed[M.type] >= M.maxNum)
					continue
				else
					eligibleBig.Add(M)
					eligibleBig[M] = M.probability
			else
				eligibleBig.Add(M)
				eligibleBig[M] = M.probability
		else
			eligibleBig.Add(M)
			eligibleBig[M] = M.probability
			if(M.required) requiredBig.Add(M)

	if(length(requiredBig))
		var/datum/generatorPrefab/P = requiredBig[1]
		debrisModifiersBigUsed.Add(P.type)
		debrisModifiersBigUsed[P.type] = 1
		return P
	else
		if(length(eligibleBig))
			var/datum/generatorPrefab/P = weighted_pick(eligibleBig)
			if(P.type in debrisModifiersBigUsed)
				debrisModifiersBigUsed[P.type] = (debrisModifiersBigUsed[P.type] + 1)
			else
				debrisModifiersBigUsed.Add(P.type)
				debrisModifiersBigUsed[P.type] = 1
			return P
		else return null

/proc/pickDebPrefabSmall()
	var/list/eligibleSmall = list()
	var/list/requiredSmall = list()

	//small prefab handling
	for(var/datum/generatorPrefab/M in debrisModifiersSmall)
		if(M.underwater != map_currently_underwater) continue
		if(M.type in debrisModifiersSmallUsed)
			if(M.required) continue
			if(M.maxNum != -1)
				if(debrisModifiersSmallUsed[M.type] >= M.maxNum)
					continue
				else
					eligibleSmall.Add(M)
					eligibleSmall[M] = M.probability
			else
				eligibleSmall.Add(M)
				eligibleSmall[M] = M.probability
		else
			eligibleSmall.Add(M)
			eligibleSmall[M] = M.probability
			if(M.required) requiredSmall.Add(M)

	if(length(requiredSmall))
		var/datum/generatorPrefab/P = requiredSmall[1]
		debrisModifiersSmallUsed.Add(P.type)
		debrisModifiersSmallUsed[P.type] = 1
		return P
	else
		if(length(eligibleSmall))
			var/datum/generatorPrefab/P = weighted_pick(eligibleSmall)
			if(P.type in debrisModifiersSmallUsed)
				debrisModifiersSmallUsed[P.type] = (debrisModifiersSmallUsed[P.type] + 1)
			else
				debrisModifiersSmallUsed.Add(P.type)
				debrisModifiersSmallUsed[P.type] = 1
			return P
		else return null

/proc/pickDebDroneBeacon()
	var/list/eligibleSmall = list()
	var/list/requiredSmall = list()

	//small prefab handling
	for(var/datum/generatorPrefab/M in debrisDroneBeacons)
		if(M.underwater != map_currently_underwater) continue
		if(M.type in debrisDroneBeaconsUsed)
			if(M.required) continue
			if(M.maxNum != -1)
				if(debrisDroneBeaconsUsed[M.type] >= M.maxNum)
					continue
				else
					eligibleSmall.Add(M)
					eligibleSmall[M] = M.probability
			else
				eligibleSmall.Add(M)
				eligibleSmall[M] = M.probability
		else
			eligibleSmall.Add(M)
			eligibleSmall[M] = M.probability
			if(M.required) requiredSmall.Add(M)

	if(length(requiredSmall))
		var/datum/generatorPrefab/P = requiredSmall[1]
		debrisDroneBeaconsUsed.Add(P.type)
		debrisDroneBeaconsUsed[P.type] = 1
		return P
	else
		if(length(eligibleSmall))
			var/datum/generatorPrefab/P = weighted_pick(eligibleSmall)
			if(P.type in debrisDroneBeaconsUsed)
				debrisDroneBeaconsUsed[P.type] = (debrisDroneBeaconsUsed[P.type] + 1)
			else
				debrisDroneBeaconsUsed.Add(P.type)
				debrisDroneBeaconsUsed[P.type] = 1
			return P
		else return null

#undef DEBRIS_NOGENERATE_PREFAB_EXCLUSION
#undef DEBRIS_NOGENERATE_ASTEROID_EXCLUSION
