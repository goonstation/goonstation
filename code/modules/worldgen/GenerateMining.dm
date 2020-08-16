#define ISDISTEDGE(A, D) (((A.x > (world.maxx - D) || A.x <= D)||(A.y > (world.maxy - D) || A.y <= D))?1:0) //1 if A is within D tiles range from edge of the map.
#define SPAWN(TYPE,LOC,NUM) for(var/i=0, i<NUM, i++) new TYPE(LOC)

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
		#ifdef UNDERWATER_MAP
		return new/turf/space/fluid/trench(src)
		#else
		return new/turf/space(src)
		#endif

	floor //Replaced with map appropriate floor tile for mining level (asteroid floor on all maps currently)
		name = "variable floor"
		icon_state = "floor"
		place()
			#ifdef UNDERWATER_MAP
			return new/turf/space/fluid/trench(src)
			#else
			return new/turf/simulated/floor/plating/airless/asteroid/noborders(src)
			#endif

	wall //Replaced with map appropriate wall tile for mining level (asteroid wall on all maps currently)
		name = "variable wall"
		icon_state = "wall"
		place()
			#ifdef UNDERWATER_MAP
			return new/turf/simulated/wall/asteroid/trench(src)
			#else
			return new/turf/simulated/wall/asteroid(src)
			#endif

	clear //Replaced with map appropriate clear tile for mining level (asteroid floor on oshan, space on other maps)
		name = "variable clear"
		icon_state = "clear"
		place()
			#ifdef UNDERWATER_MAP
			return new/turf/space/fluid/trench(src)
			#else
			return new/turf/space(src)
			#endif

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
	if(!current || !center || (current.loc.type != /area && !istype(current.loc , /area/allowGenerate)) || !istype(current, /turf/space))
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
	generate(var/list/miningZ)
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
				var/turf/T = locate(x,y,AST_ZLEVEL)
				if(map[x][y] && !ISDISTEDGE(T, 3) && T.loc && ((T.loc.type == /area) || istype(T.loc , /area/allowGenerate)) )
					var/turf/simulated/wall/asteroid/N = new/turf/simulated/wall/asteroid(T)
					N.quality = rand(-101,101)
					generated.Add(N)
				if(T.loc.type == /area || istype(T.loc, /area/allowGenerate))
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
			for (var/turf/simulated/wall/asteroid/A in range(4,pick(generated)))
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

		var/list/border = list()
		border |= (block(locate(1,1,AST_ZLEVEL), locate(AST_MAPBORDER,world.maxy,AST_ZLEVEL))) //Left
		border |= (block(locate(1,1,AST_ZLEVEL), locate(world.maxx,AST_MAPBORDER,AST_ZLEVEL))) //Bottom
		border |= (block(locate(world.maxx-(AST_MAPBORDER-1),1,AST_ZLEVEL), locate(world.maxx,world.maxy,AST_ZLEVEL))) //Right
		border |= (block(locate(1,world.maxy-(AST_MAPBORDER-1),AST_ZLEVEL), locate(world.maxx,world.maxy,AST_ZLEVEL))) //Top

		for(var/turf/T in border)
			new/turf/unsimulated/wall/trench(T)
			new/area/cordon/dark(T)
			LAGCHECK(LAG_REALTIME)

		for (var/i=0, i<55, i++)
			var/turf/T = locate(rand(1,world.maxx),rand(1,world.maxy),AST_ZLEVEL)
			for (var/turf/space/fluid/TT in range(rand(2,4),T))
				TT.spawningFlags |= SPAWN_TRILOBITE

		return miningZ

/datum/mapGenerator/asteroidsDistance //Generates a bunch of asteroids based on distance to seed/center. Super simple.
	generate(var/list/miningZ)
		var/numAsteroidSeed = AST_SEEDS + rand(1, 5)
		for(var/i=0, i<numAsteroidSeed, i++)
			var/turf/X = pick(miningZ)
			var/quality = rand(-101,101)

			while(!istype(X, /turf/space) || ISDISTEDGE(X, AST_MAPSEEDBORDER) || (X.loc.type != /area && !istype(X.loc , /area/allowGenerate)))
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
				if(!isnull(T) && T.loc && ((T.loc.type == /area) || istype(T.loc , /area/allowGenerate)))
					var/turf/simulated/wall/asteroid/AST = new/turf/simulated/wall/asteroid(T)
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

	var/extra = rand(0,AST_NUMPREFABSEXTRA)
	for(var/n=0, n<AST_NUMPREFABS+extra, n++)
		var/datum/generatorPrefab/M = pickPrefab()
		if(M)
			var/maxX = (world.maxx - M.prefabSizeX - AST_MAPBORDER)
			var/maxY = (world.maxy - M.prefabSizeY - AST_MAPBORDER)
			var/stop = 0
			var/count= 0
			var/maxTries = (M.required ? 200:33)
			while(!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(1+AST_MAPBORDER, maxX), rand(1+AST_MAPBORDER,maxY), AST_ZLEVEL)
				var/ret = M.applyTo(target)
				if(ret == 0)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to blocked area. [target] @ [showCoords(target.x, target.y, target.z)]")
				else
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type][M.required?" (REQUIRED)":""] succeeded. [target] @ [showCoords(target.x, target.y, target.z)]")
					stop = 1
				count++
				if(count >= 33)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to maximum tries [maxTries][M.required?" WARNING: REQUIRED FAILED":""]. [target] @ [showCoords(target.x, target.y, target.z)]")
		else break

	var/datum/mapGenerator/D

	if(map_currently_underwater)
		D = new/datum/mapGenerator/seaCaverns()
	else
		D = new/datum/mapGenerator/asteroidsDistance()

	miningZ = D.generate(miningZ)

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
			var/datum/generatorPrefab/P = pickweight(eligible)
			if(P.type in miningModifiersUsed)
				miningModifiersUsed[P.type] = (miningModifiersUsed[P.type] + 1)
			else
				miningModifiersUsed.Add(P.type)
				miningModifiersUsed[P.type] = 1
			return P
		else return null

/datum/generatorPrefab
	var/probability = 0
	var/maxNum = 0
	var/prefabPath = ""
	var/prefabSizeX = 5
	var/prefabSizeY = 5
	var/underwater = 0 //prefab will only be used if this matches map_currently_underwater. I.e. if this is 1 and map_currently_underwater is 1 then the prefab may be used.
	var/required = 0   //If 1 we will try to always place thing thing no matter what. Required prefabs will only ever be placed once.

	proc/applyTo(var/turf/target)
		var/adjustX = target.x
		var/adjustY = target.y

		 //Move prefabs backwards if they would end up outside the map.
		if((adjustX + prefabSizeX) > (world.maxx - AST_MAPBORDER))
			adjustX -= ((adjustX + prefabSizeX) - (world.maxx - AST_MAPBORDER))

		if((adjustY + prefabSizeY) > (world.maxy - AST_MAPBORDER))
			adjustY -= ((adjustY + prefabSizeY) - (world.maxy - AST_MAPBORDER))

		var/turf/T = locate(adjustX, adjustY, target.z)

		for(var/x=0, x<prefabSizeX; x++)
			for(var/y=0, y<prefabSizeX; y++)
				var/turf/L = locate(T.x+x, T.y+y, T.z)
				if(L && L.loc && ((L.loc.type != /area) && !istype(L.loc , /area/allowGenerate))) // istype(L.loc, /area/noGenerate)
					return 0

		var/loaded = file2text(prefabPath)

		if(T && loaded)
			var/dmm_suite/D = new/dmm_suite()
			D.read_map(loaded,T.x,T.y,T.z,prefabPath)
			return 1
		else return 0

	clown
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_clown.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

	vault
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_vault.dmm"
		prefabSizeX = 7
		prefabSizeY = 7

	shuttle
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_shuttle.dmm"
		prefabSizeX = 19
		prefabSizeY = 13

	cannibal
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_cannibal.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

	sleepership
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_sleepership.dmm"
		prefabSizeX = 15
		prefabSizeY = 19

	rockworms
		maxNum = 10
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_rockworms.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

	beacon // warp beacon for easy z5 teleporting.
		required = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_beacon.dmm"
		prefabSizeX = 5
		prefabSizeY = 5

	outpost // rest stop/outpost for miners to eat/rest/heal at.
		required = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_outpost.dmm"
		prefabSizeX = 20
		prefabSizeY = 20

	ksol // The wreck of the old radio buoy, rip
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_ksol.dmm"
		prefabSizeX = 35
		prefabSizeY = 27

	habitat // kube's habitat thing
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_habitat.dmm"
		prefabSizeX = 25
		prefabSizeY = 20

	smuggler // kube's smuggler thing
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_smuggler.dmm"
		prefabSizeX = 19
		prefabSizeY = 18

	tomb // small little tomb
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_tomb.dmm"
		prefabSizeX = 13
		prefabSizeY = 10

	janitor // adhara's janitorial hideout
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_janitor.dmm"
		prefabSizeX = 16
		prefabSizeY = 15

	pie_ship // Urs's ship originally built for the pie eating contest event
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_pie_ship.dmm"
		prefabSizeX = 16
		prefabSizeY = 21

	bee_sanctuary_space // Sov's Bee Sanctuary (Space Variant)
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_beesanctuary.dmm"
		prefabSizeX = 41
		prefabSizeY = 24

	sequestered_cloner // MarkNstein's Sequestered Cloner
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_sequestered_cloner.dmm"
		prefabSizeX = 20
		prefabSizeY = 15

	clown_nest // Gores abandoned Clown-Federation Outpost
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_clown_nest.dmm"
		prefabSizeX = 30
		prefabSizeY = 30

	dans_asteroid // Discount Dans Delivery Asteroid featuring advanced cooling technology
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_dans_asteroid.dmm"
		prefabSizeX = 37
		prefabSizeY = 48
	//UNDERWATER AREAS FOR OSHAN

	pit
		required = 1
		underwater = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_water_oshanpit.dmm"
		prefabSizeX = 8
		prefabSizeY = 8

	mantahole
		required = 1
		underwater = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_water_mantahole.dmm"
		prefabSizeX = 10
		prefabSizeY = 10

#if defined(MAP_OVERRIDE_OSHAN)
	elevator
		required = 1
		underwater = 1
		maxNum = 1
		probability = 100
		prefabPath = "assets/maps/prefabs/prefab_water_oshanelevator.dmm"
		prefabSizeX = 11
		prefabSizeY = 11
#endif
	robotfactory
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_robotfactory.dmm"
		prefabSizeX = 20
		prefabSizeY = 28

	racetrack
		underwater = 1
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_water_racetrack.dmm"
		prefabSizeX = 24
		prefabSizeY = 25

	zoo
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_zoo.dmm"
		prefabSizeX = 20
		prefabSizeY = 17

	outpost
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_outpost.dmm"
		prefabSizeX = 21
		prefabSizeY = 21

	sandyruins
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_sandyruins.dmm"
		prefabSizeX = 11
		prefabSizeY = 13

	greenhouse
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_greenhouse.dmm"
		prefabSizeX = 21
		prefabSizeY = 15

	genelab
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_genelab.dmm"
		prefabSizeX = 12
		prefabSizeY = 11

	beetrader
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_beetrader.dmm"
		prefabSizeX = 13
		prefabSizeY = 18

	stripmall
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_stripmall.dmm"
		prefabSizeX = 20
		prefabSizeY = 22

	blindpig
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_blindpig.dmm"
		prefabSizeX = 23
		prefabSizeY = 20

	strangeprison
		underwater = 1
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_water_strangeprison.dmm"
		prefabSizeX = 35
		prefabSizeY = 21

	seamonkey
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_seamonkey.dmm"
		prefabSizeX = 33
		prefabSizeY = 25

	ghost_house
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_ghosthouse.dmm"
		prefabSizeX = 23
		prefabSizeY = 34

	drone_battle
		underwater = 1
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_water_drone_battle.dmm"
		prefabSizeX = 24
		prefabSizeY = 21

	ydrone
		underwater = 1
		maxNum = 1
		probability = 10
		prefabPath = "assets/maps/prefabs/prefab_water_ydrone.dmm"
		prefabSizeX = 15
		prefabSizeY = 15

	honk
		underwater = 1
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_water_honk.dmm"
		prefabSizeX = 24
		prefabSizeY = 22

	disposal
		underwater = 1
		maxNum = 1
		probability = 35
		prefabPath = "assets/maps/prefabs/prefab_water_disposal.dmm"
		prefabSizeX = 16
		prefabSizeY = 13

	sketchy
		underwater = 1
		maxNum = 1
		probability = 35
		prefabPath = "assets/maps/prefabs/prefab_water_sketchy.dmm"
		prefabSizeX = 21
		prefabSizeY = 15

	water_treatment // Sov's water treatment facility
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_watertreatment.dmm"
		prefabSizeX = 33
		prefabSizeY = 14

	bee_sanctuary //Sov's Bee Sanctuary
		underwater = 1
		maxNum = 1
		probability = 30
		prefabPath = "assets/maps/prefabs/prefab_water_beesanctuary.dmm"
		prefabSizeX = 34
		prefabSizeY = 19

#if defined(MAP_OVERRIDE_OSHAN)
	sea_miner
		underwater = 1
		maxNum = 1
		probability = 35
		prefabPath = "assets/maps/prefabs/prefab_water_miner.dmm"
		prefabSizeX = 21
		prefabSizeY = 15
#endif

#if defined(MAP_OVERRIDE_MANTA)
	sea_miner
		underwater = 1
		maxNum = 1
		required = 1
		prefabPath = "assets/maps/prefabs/prefab_water_miner_manta.dmm"
		prefabSizeX = 21
		prefabSizeY = 15
#endif

	cache_small_loot
		underwater = 1
		maxNum = -1
		probability = 1
		prefabPath = "assets/maps/prefabs/prefab_water_cache_smallloot.dmm"
		prefabSizeX = 4
		prefabSizeY = 4

	cache_small_oxygen
		underwater = 1
		maxNum = -1
		probability = 1
		prefabPath = "assets/maps/prefabs/prefab_water_cache_smalloxygen.dmm"
		prefabSizeX = 4
		prefabSizeY = 4

	cache_small_skull
		underwater = 1
		maxNum = -1
		probability = 1
		prefabPath = "assets/maps/prefabs/prefab_water_cache_smallskull.dmm"
		prefabSizeX = 3
		prefabSizeY = 3

	sea_crashed
		underwater = 1
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_water_crashed.dmm"
		prefabSizeX = 24
		prefabSizeY = 32
