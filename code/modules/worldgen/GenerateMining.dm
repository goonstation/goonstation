#define ISDISTEDGE(A, D) (((A.x > (world.maxx - D) || A.x <= D)||(A.y > (world.maxy - D) || A.y <= D))?1:0) //1 if A is within D tiles range from edge of the map.

var/list/miningModifiers = list()
var/list/miningModifiersUsed = list()//Assoc list, type:times used

var/list/debrisModifiersBig = list()
var/list/debrisModifiersBigUsed = list()//Assoc list, type:times used

// because we don't need these shitty 5x6 prefabs to be weighted the same as the big ones
var/list/debrisModifiersSmall = list()
var/list/debrisModifiersSmallUsed = list()//Assoc list, type:times used

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
		//var/numAsteroidSeed = AST_SEEDS + rand(1, 5)
		var/list/possible_garbage = list(/obj/decal/floatingtiles, /obj/decal/cleanable/robot_debris/gib, /obj/item/raw_material/rock, /obj/lattice, /obj/item/raw_material/shard/glass, /obj/item/cable_coil/cut)
		var/drone_amount = rand(DEBRIS_DRONE_LOWER, DEBRIS_DRONE_UPPER)
		var/garbage_amount = rand(DEBRIS_GARBAGE_LOWER, DEBRIS_GARBAGE_UPPER)
		var/asteroid_amount = rand(DEBRIS_ASTEROID_LOWER, DEBRIS_ASTEROID_UPPER)
		var/loot_thingies = rand(DEBRIS_LOOT_LOWER, DEBRIS_LOOT_UPPER)

		for(var/i in 0 to asteroid_amount)
			var/ast_length = rand(DEBRIS_ASTEROID_LENGTH_LOWER, DEBRIS_ASTEROID_LENGTH_UPPER)
			var/turf/X = pick(debrisZ)

			while(!istype(X, /turf/space) || ISDISTEDGE(X, AST_MAPSEEDBORDER) || (X.loc.type != /area/space && !istype(X.loc , /area/allowGenerate)))
				X = pick(debrisZ)
				LAGCHECK(LAG_REALTIME)

			var/list/ast_turfs = list(X)
			var/list/full_ast_turfs = list()

			var/turf/curr_turf = X
			for(var/a in 0 to ast_length)
				var/turf/rand_step = get_step_rand(curr_turf)
				while(ast_turfs.Find(rand_step) || !istype(rand_step, /turf/space) || ISDISTEDGE(rand_step, AST_MAPSEEDBORDER) || (rand_step.loc.type != /area/space && !istype(rand_step.loc , /area/allowGenerate)))
					rand_step = get_step_rand(curr_turf)
					LAGCHECK(LAG_REALTIME)

				ast_turfs += rand_step
				curr_turf = rand_step

			full_ast_turfs = ast_turfs
			for(var/turf/T in ast_turfs)
				T.ReplaceWith(/turf/simulated/wall/asteroid)
				var/list/neighbors = getneighbours(T) //why does this have to be the bri'ish spelling
				for(var/turf/T2 in neighbors)
					if(ast_turfs.Find(T2) || !istype(T2, /turf/space) || ISDISTEDGE(T2, AST_MAPSEEDBORDER) || (T2.loc.type != /area/space && !istype(T2.loc, /area/allowGenerate)))
						continue

					full_ast_turfs += T2
					T2.ReplaceWith(/turf/simulated/wall/asteroid)

		for(var/i in 0 to loot_thingies)
			var/turf/possible_spot = pick(debrisZ)

			while(!istype(possible_spot, /turf/space) || ISDISTEDGE(possible_spot, AST_MAPSEEDBORDER) || (possible_spot.loc.type != /area/space && !istype(possible_spot.loc, /area/allowGenerate)))
				possible_spot = pick(debrisZ)
				LAGCHECK(LAG_REALTIME)

			var/turf/simulated/floor/base_floor = possible_spot.ReplaceWithFloor()
			base_floor.to_plating()
			var/numberthing = rand(1, 6)
			switch(numberthing)
				if(1)
					new/obj/storage/crate/loot(base_floor)
				if(2)
					new/obj/storage/crate/loot(base_floor)
				if(3)
					new/obj/artifact_type_spawner/vurdalak(base_floor)
				if(4)
					new/obj/artifact_type_spawner/vurdalak(base_floor)
				if(5) //6 is intentionally blank
					var/obj/C = pick(childrentypesof(/obj/storage/crate/trench_loot)) //placeholder, probably
					new C(base_floor)

			var/list/neighbors = getneighbours(possible_spot)
			for(var/turf/T in neighbors)
				if(!istype(T, /turf/space) || ISDISTEDGE(T, AST_MAPSEEDBORDER) || (T.loc.type != /area/space && !istype(T.loc, /area/allowGenerate)))
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
					if(!istype(T3, /turf/space) || ISDISTEDGE(T3, AST_MAPSEEDBORDER) || (T3.loc.type != /area/space && !istype(T3.loc, /area/allowGenerate)))
						continue

					if(prob(33))
						new/obj/lattice(T3)
					if(prob(15))
						var/obj/trash = pick(possible_garbage)
						new trash(T3)

		for(var/i in 0 to garbage_amount)
			var/turf/possible_spot = pick(debrisZ)

			while(!istype(possible_spot, /turf/space) || ISDISTEDGE(possible_spot, AST_MAPSEEDBORDER) || (possible_spot.loc.type != /area/space && !istype(possible_spot.loc, /area/allowGenerate)))
				possible_spot = pick(debrisZ)
				LAGCHECK(LAG_REALTIME)

			var/obj/garbage = pick(possible_garbage)
			new garbage(possible_spot)

		for(var/i in 0 to drone_amount)
			var/turf/possible_spot = pick(debrisZ)

			while(!istype(possible_spot, /turf/space) || ISDISTEDGE(possible_spot, AST_MAPSEEDBORDER) || (possible_spot.loc.type != /area/space && !istype(possible_spot.loc, /area/allowGenerate)))
				possible_spot = pick(debrisZ)
				LAGCHECK(LAG_REALTIME)

			//the closer to top right you are, the more dangerous drones that spawn

			var/drone_risk = max(1, ((possible_spot.x + possible_spot.y) / 2) / 10)
			var/list/drones = list()
			drones[/obj/critter/gunbot/drone/minigundrone] = drone_risk
			drones[/obj/critter/gunbot/drone/heavydrone] = drone_risk
			if(drone_risk < 10)
				drones[/obj/critter/gunbot/drone/buzzdrone] = 25-drone_risk
				drones[/obj/critter/gunbot/drone/laserdrone] = 20-drone_risk
			if(drone_risk > 10)
				drones[/obj/critter/gunbot/drone/cannondrone] = drone_risk-10
			if(drone_risk > 15)
				drones[/obj/critter/gunbot/drone/aciddrone] = drone_risk-15
			if(drone_risk > 20)
				drones[/obj/critter/gunbot/drone/assdrone] = drone_risk-20

			var/obj/drone = pick(drones)
			new drone(possible_spot)



		/*for(var/i=0, i<numAsteroidSeed, i++)
			var/turf/X = pick(debrisZ)

			while(!istype(X, /turf/space) || ISDISTEDGE(X, AST_MAPSEEDBORDER) || (X.loc.type != /area/space && !istype(X.loc , /area/allowGenerate)))
				X = pick(debrisZ)
				LAGCHECK(LAG_REALTIME)

			var/list/solidTiles = list()
			var/list/edgeTiles = list(X)
			var/list/visited = list()

			//var/sizeMod = rand(-AST_SIZERANGE,AST_SIZERANGE)

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
							*/
		return debrisZ

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
	for (var/n in 0 to num_to_place_big)
		game_start_countdown?.update_status("Setting up debris level...\n(Large Prefab [n]/[num_to_place_big])")
		var/datum/generatorPrefab/M = pickDebPrefabBig()
		if (M)
			var/maxX = (world.maxx - M.prefabSizeX - AST_MAPBORDER)
			var/maxY = (world.maxy - M.prefabSizeY - AST_MAPBORDER)
			var/stop = 0
			var/count= 0
			var/maxTries = (M.required ? 200:33)
			while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(1+AST_MAPBORDER, maxX), rand(1+AST_MAPBORDER,maxY), DEBRIS_ZLEVEL)
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

	var/num_to_place_small = DEBRIS_NUMSMALLPREFABS + rand(0, DEBRIS_NUMSMALLPREFABSEXTRA)
	for (var/n in 0 to num_to_place_small)
		game_start_countdown?.update_status("Setting up debris level...\n(Small Prefab [n]/[num_to_place_small])")
		var/datum/generatorPrefab/M = pickDebPrefabSmall()
		if (M)
			var/maxX = (world.maxx - M.prefabSizeX - AST_MAPBORDER)
			var/maxY = (world.maxy - M.prefabSizeY - AST_MAPBORDER)
			var/stop = 0
			var/count= 0
			var/maxTries = (M.required ? 200:33)
			while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(1+AST_MAPBORDER, maxX), rand(1+AST_MAPBORDER,maxY), DEBRIS_ZLEVEL)
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

	hotspot_controller.generate_map()

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
