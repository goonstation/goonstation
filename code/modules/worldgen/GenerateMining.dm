#define ISDISTEDGE(A, D) (((A.x > (world.maxx - D) || A.x <= D)||(A.y > (world.maxy - D) || A.y <= D))?1:0) //1 if A is within D tiles range from edge of the map.

var/list/miningModifiers = list()
var/list/miningModifiersUsed = list()//Assoc list, type:times used

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
		var/datum/generatorPrefab/M = pickPrefab()
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

/proc/pickPrefab()
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

	if(required.len)
		var/datum/generatorPrefab/P = required[1]
		miningModifiersUsed.Add(P.type)
		miningModifiersUsed[P.type] = 1
		return P
	else
		if(eligible.len)
			var/datum/generatorPrefab/P = weighted_pick(eligible)
			if(P.type in miningModifiersUsed)
				miningModifiersUsed[P.type] = (miningModifiersUsed[P.type] + 1)
			else
				miningModifiersUsed.Add(P.type)
				miningModifiersUsed[P.type] = 1
			return P
		else return null
