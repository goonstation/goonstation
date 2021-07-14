/// The following is based on GenerateMining.dm

var/planetZLevel = null
var/list/planetModifiers = list()
var/list/planetModifiersUsed = list()//Assoc list, type:times used

/proc/makePlanetLevel()
	var/list/planetZ = list()
	var/startTime = world.timeofday
	if(!planetZLevel)
		boutput(world, "<span class='alert'>Skipping Planet Generation!</span>")
		return
	else
		boutput(world, "<span class='alert'>Generating Planet Level ...</span>")

	for(var/turf/T)
		if(T.z == planetZLevel)
			planetZ.Add(T)

	var/num_to_place = PLANET_NUMPREFABS + rand(0, PLANET_NUMPREFABSEXTRA)
	for (var/n = 1, n <= num_to_place, n++)
		game_start_countdown?.update_status("Setting up mining level...\n(Prefab [n]/[num_to_place])")
		var/datum/generatorPlanetPrefab/M = pickPlanetPrefab()
		if (M)
			var/maxX = (world.maxx - M.prefabSizeX - PLANET_MAPBORDER)
			var/maxY = (world.maxy - M.prefabSizeY - PLANET_MAPBORDER)
			var/stop = 0
			var/count= 0
			var/maxTries = (M.required ? 200:33)
			while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(1+PLANET_MAPBORDER, maxX), rand(1+PLANET_MAPBORDER,maxY), planetZLevel)
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

	// var/datum/mapGenerator/D

	// if(map_currently_underwater)
	// 	D = new/datum/mapGenerator/seaCaverns()
	// else
	// 	D = new/datum/mapGenerator/asteroidsDistance()

	game_start_countdown?.update_status("Setting up Planet level...\nGenerating terrain...")
	//planetZ = D.generate(planetZ)

	// // remove temporary areas
	var/area/A
	var/turf/T
	var/turf/west_turf
	for (T in get_area_turfs(/area/noGenerate))
		if(T.z != planetZLevel) continue
		if(!istype(T, /turf/space)) continue
		west_turf = get_step(T, WEST)
		while(west_turf.x > 0)
			if(istype(west_turf.loc, /area/map_gen/planet))
				break

			west_turf = get_step(west_turf, WEST)
		A = get_area(west_turf)
		new A.type(T)

	for (T in get_area_turfs(/area/allowGenerate))
		if(T.z != planetZLevel) continue
		if(!istype(T, /turf/space)) continue
		west_turf = get_step(T, WEST)
		while(west_turf.x > 0)
			if(istype(west_turf.loc, /area/map_gen/planet))
				break

			west_turf = get_step(west_turf, WEST)
		A = get_area(west_turf)
		new A.type(T)

	boutput(world, "<span class='alert'>Generated Planet Level in [((world.timeofday - startTime)/10)] seconds!")

/proc/pickPlanetPrefab()
	var/list/eligible = list()
	var/list/required = list()

	for(var/datum/generatorPlanetPrefab/M in planetModifiers)
		if(M.type in planetModifiersUsed)
			if(M.required) continue
			if(M.maxNum != -1)
				if(planetModifiersUsed[M.type] >= M.maxNum)
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
		var/datum/generatorPlanetPrefab/P = required[1]
		planetModifiersUsed.Add(P.type)
		planetModifiersUsed[P.type] = 1
		return P
	else
		if(eligible.len)
			var/datum/generatorPlanetPrefab/P = weighted_pick(eligible)
			if(P.type in planetModifiersUsed)
				planetModifiersUsed[P.type] = (planetModifiersUsed[P.type] + 1)
			else
				planetModifiersUsed.Add(P.type)
				planetModifiersUsed[P.type] = 1
			return P
		else return null

/area/map_gen/planet
	name = "planet generation area"
	map_generator = /datum/map_generator/jungle_generator

	generate_perlin_noise_terrain()
		if(src.map_generator)
			map_generator = new map_generator()
			// Azrun TODO This is where we seed BIOME
			map_generator.generate_terrain(get_area_turfs(src))

	alpha

	beta

	charlie

	delta

	echo

	foxtrot

	gamma

	hotel

	indigo



ABSTRACT_TYPE(/datum/generatorPlanetPrefab)
/datum/generatorPlanetPrefab
	var/probability = 0
	var/maxNum = 0
	var/prefabPath = ""
	var/prefabSizeX = 5
	var/prefabSizeY = 5
	var/required = 0   //If 1 we will try to always place thing thing no matter what. Required prefabs will only ever be placed once.
	var/std_prefab_path
	var/underwater

	proc/applyTo(var/turf/target)
		var/adjustX = target.x
		var/adjustY = target.y

		 //Move prefabs backwards if they would end up outside the map.
		if((adjustX + prefabSizeX) > (world.maxx - PLANET_MAPBORDER))
			adjustX -= ((adjustX + prefabSizeX) - (world.maxx - PLANET_MAPBORDER))

		if((adjustY + prefabSizeY) > (world.maxy - PLANET_MAPBORDER))
			adjustY -= ((adjustY + prefabSizeY) - (world.maxy - PLANET_MAPBORDER))

		var/turf/T = locate(adjustX, adjustY, target.z)

		for(var/x=0, x<prefabSizeX; x++)
			for(var/y=0, y<prefabSizeY; y++)
				var/turf/L = locate(T.x+x, T.y+y, T.z)
				if(L?.loc && ((L.loc.type != /area/space) && !istype(L.loc , /area/allowGenerate))) // istype(L.loc, /area/noGenerate)
					return 0

		var/loaded = file2text(prefabPath)

		if(T && loaded)
			var/dmm_suite/D = new/dmm_suite()
			var/datum/loadedProperties/props = D.read_map(loaded,T.x,T.y,T.z,prefabPath)
			if(prefabSizeX != props.maxX - props.sourceX + 1 || prefabSizeY != props.maxY - props.sourceY + 1)
				CRASH("size of prefab [prefabPath] is incorrect ([prefabSizeX]x[prefabSizeY] != [props.maxX - props.sourceX + 1]x[props.maxY - props.sourceY + 1])")
			convertSpace(T, prefabSizeX, prefabSizeY)
			return 1
		else return 0

	proc/convertSpace(turf/start, prefabSizeX, prefabSizeY)
		for(var/x=0, x<prefabSizeX; x++)
			for(var/y=0, y<prefabSizeY; y++)
				var/turf/T = locate(start.x+x, start.y+y, start.z)
				if(istype(T, /turf/space))
					new /area/allowGenerate(T)

	tomb // small little tomb
		maxNum = 1
		probability = 20
		prefabPath = "assets/maps/prefabs/prefab_tomb.dmm"
		prefabSizeX = 13
		prefabSizeY = 10

	vault
		maxNum = 1
		probability = 25
		prefabPath = "assets/maps/prefabs/prefab_vault.dmm"
		prefabSizeX = 7
		prefabSizeY = 7

/obj/landmark/artemis_planets
	name = "zlevel"
	icon_state = "x3"
	add_to_landmarks = FALSE

	init()
		if(!planetZLevel)
			planetZLevel = src.z
		..()
