/// The following is based on GenerateMining.dm

var/planetZLevel = null
var/list/planetGenerators = list()//Assoc list
var/list/planetModifiers = list()
var/list/planetModifiersUsed = list()//Assoc list, type:times used
var/list/planet_seeds = list()

#if ENABLE_ARTEMIS
/proc/makePlanetLevel()
	//var/list/turf/planetZ = list()
	var/startTime = world.timeofday
	if(!planetZLevel)
		boutput(world, "<span class='alert'>Skipping Planet Generation!</span>")
		return
	else
		boutput(world, "<span class='alert'>Generating Planet Level ...</span>")

	// SEED zee Planets!!!!
	for(var/area/map_gen/planet/A in by_type[/area/map_gen])
		if(!planet_seeds[A.name])
			planet_seeds[A.name] = list("height"=GALAXY.Rand.xor_rand(1,50000), "humidity"=GALAXY.Rand.xor_rand(1,50000), "heat"=GALAXY.Rand.xor_rand(1,50000))

		var/seed = planet_seeds[A.name]
		A.generate_perlin_noise_terrain(list(seed["height"], seed["humidity"], seed["heat"]))

		if(A.allow_prefab)
			var/list/area_turfs = get_area_turfs(A)
			var/num_to_place = PLANET_NUMPREFABS + GALAXY.Rand.xor_rand(0, PLANET_NUMPREFABSEXTRA)
			for (var/n = 1, n <= num_to_place, n++)
				game_start_countdown?.update_status("Setting up planet level...\n(Prefab [n]/[num_to_place])")
				var/datum/mapPrefab/planet/M = pick_map_prefab(/datum/mapPrefab/planet)
				if (M)
					var/maxX = (world.maxx - M.prefabSizeX - PLANET_MAPBORDER)
					var/maxY = (world.maxy - M.prefabSizeY - PLANET_MAPBORDER)
					var/stop = 0
					var/count= 0
					var/maxTries = (M.required ? 200 : 33)
					while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
						var/turf/target = locate(GALAXY.Rand.xor_rand(1+PLANET_MAPBORDER, maxX), GALAXY.Rand.xor_rand(1+PLANET_MAPBORDER,maxY), planetZLevel)
						target = GALAXY.Rand.xor_pick(area_turfs)
						//var/area/A = get_area(target)
						if(!M.check_biome_requirements(target))
							count = INFINITY
							break
						var/ret = M.applyTo(target)
						if (!ret)
							logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [M.type] failed due to blocked area. [target] @ [showCoords(target.x, target.y, target.z)]")
						else
							logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [M.type][M.required?" (REQUIRED)":""] succeeded. [target] @ [showCoords(target.x, target.y, target.z)]")
							stop = 1
							if(istype(A,/area/map_gen/planet))
								var/area/map_gen/planet/P = A
								P.prefabs |= ret
						count++
					if (count == maxTries)
						logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [M.type] failed due to maximum tries [maxTries][M.required?" WARNING: REQUIRED FAILED":""].")
				else break

	for(var/area/map_gen/planet/A in by_type[/area/map_gen])
		if(!A.allow_prefab)
			var/area/map_gen/planet/parent_area = get_area_by_type(A.parent_type)
			parent_area.biome_turfs += A.biome_turfs
			parent_area.overlays += A.overlays
			for(var/turf/T in A)
				new parent_area.type(T)
		else
			for(var/datum/loadedProperties/prefab in A.prefabs)
				var/list/turf/prefab_turfs = block(locate(prefab.sourceX, prefab.sourceY, prefab.sourceZ),locate(prefab.maxX, prefab.maxY, prefab.maxZ))
				var/list/turf/regen_turfs = list()
				for(var/turf/variableTurf/T in prefab_turfs)
					regen_turfs += T
					if(istype(T.loc, /area/space)) //space...
						new A.type(T)
				if(length(regen_turfs))
					A.map_generator.generate_terrain(regen_turfs, reuse_seed=TRUE)

	// // remove temporary areas
	var/area/A
	var/turf/AT
	var/turf/west_turf
	for (AT in get_area_turfs(/area/noGenerate))
		if(AT.z != planetZLevel) continue
		if(!istype(AT, /turf/space)) continue
		west_turf = get_step(AT, WEST)
		while(west_turf.x > 0)
			if(istype(west_turf.loc, /area/map_gen/planet))
				break

			west_turf = get_step(west_turf, WEST)
		A = get_area(west_turf)
		new A.type(AT)

	for (AT in get_area_turfs(/area/allowGenerate))
		if(AT.z != planetZLevel) continue
		if(!istype(AT, /turf/space) && !istype(AT, /turf/map_gen)) continue
		west_turf = get_step(AT, WEST)
		while(west_turf.x > 0)
			if(istype(west_turf.loc, /area/map_gen/planet))
				break

			west_turf = get_step(west_turf, WEST)
		A = get_area(west_turf)
		new A.type(AT)

	boutput(world, "<span class='alert'>Generated Planet Level in [((world.timeofday - startTime)/10)] seconds!")

/obj/landmark/artemis_planets
	name = "zlevel"
	icon_state = "x3"
	add_to_landmarks = FALSE

	init(delay_qdel=TRUE)
		if(!planetZLevel)
			planetZLevel = src.z
		..()

#define DEFINE_PLANET(_PATH, _NAME) \
	/area/map_gen/planet/_PATH{name=_NAME};\
	/area/map_gen/planet/_PATH/no_prefab{allow_prefab = FALSE};

/area/map_gen/planet
	New()
		..()
		if(isnull(planetGenerators[name]))
			var/map_generator_path = pick(/datum/map_generator/jungle_generator,/datum/map_generator/desert_generator,/datum/map_generator/snow_generator)
			planetGenerators[name] = new map_generator_path()

	generate_perlin_noise_terrain(list/seed_list)
		if(generated)
			return
		map_generator = planetGenerators[name]
		if(seed_list)
			map_generator.set_seed(seed_list)
		map_generator.generate_terrain(get_area_turfs(src), reuse_seed=TRUE)
		generated = TRUE

	proc/colorize_planet(color)
		src.ambient_light = color
		if(src.ambient_light)
			var/image/I = new /image/ambient
			I.color = src.ambient_light
			overlays += I

	store_biome(turf/T, datum/biome/B)
		if(!biome_turfs[B])
			biome_turfs[B] = list()
		biome_turfs[B] |= T

	proc/clear_biomes()
		biome_turfs = list()

DEFINE_PLANET(alpha, "Alpha")
DEFINE_PLANET(beta, "Beta")
DEFINE_PLANET(charlie, "Charlie")
DEFINE_PLANET(delta, "Delta")
DEFINE_PLANET(echo, "Echo")
DEFINE_PLANET(foxtrot, "Foxtrot")
DEFINE_PLANET(gamma, "Gamma")
DEFINE_PLANET(hotel, "Hotel")
DEFINE_PLANET(indigo, "Indigo")

#endif

/area/map_gen/planet
	name = "planet generation area"
	var/list/turf/biome_turfs = list()
	var/list/datum/loadedProperties/prefabs = list()
	var/allow_prefab = TRUE
	var/generated = FALSE

	no_prefab
		allow_prefab = FALSE


/datum/planetManager
	var/list/datum/allocated_region/regions = list()

var/global/datum/planetManager/PLANET_LOCATIONS = new /datum/planetManager()

/proc/GeneratePlanetChunk(width=null, height=null, prefabs_to_place=1, datum/map_generator/generator=/datum/map_generator/desert_generator, color=null, name=null, use_lrt=TRUE)
	var/turf/T

	if(ispath(generator)) generator = new generator()
	if(!width)	width = rand(80,130)
	if(!height)	height = rand(80,130)
	if(!name)
		name = ""
		if (prob(50))
			name += pick_string("station_name.txt", "greek")
		else
			name += pick_string("station_name.txt", "militaryLetters")
		name += " "

		if (prob(30))
			name += pick_string("station_name.txt", "romanNum")
		else
			name += "[rand(2, 99)]"

	//Generate and cleanup region
	var/datum/allocated_region/region = global.region_allocator.allocate(width, height)
	region.clean_up(main_area=/area/map_gen/planet)

	//Populate with Biome!
	var/turfs = block(locate(region.bottom_left.x+1, region.bottom_left.y+1, region.bottom_left.z), locate(region.bottom_left.x+region.width-2, region.bottom_left.y+region.height-2, region.bottom_left.z) )
	generator.generate_terrain(turfs, reuse_seed=TRUE)

	// Workaround while region.cleanup() uses REGION_TILES(src) which excludes border tiles...
	var/area/border_area = new /area/cordon(null)
	for(var/x in 1 to region.width)
		for(var/y in 1 to region.height)
			if(x == 1 || y == 1 || x == region.width || y == region.height)
				T = region.turf_at(x, y)
				T.ReplaceWith(/turf/cordon)
				border_area.contents += T

			if (current_state >= GAME_STATE_PLAYING)
				LAGCHECK(LAG_LOW)
			else
				LAGCHECK(LAG_HIGH)

	//Lighten' Up the Place
	var/image/ambient_light = new /image/ambient
	if(!color)
		ambient_light.color = "#888888"
	else
		ambient_light.color = color

	for(T in turfs)
		T.UpdateOverlays(ambient_light, "ambient")
		LAGCHECK(LAG_LOW)

	PLANET_LOCATIONS.regions.Add(region)

	//Make it interesting, slap some prefabs on that thing
	for (var/n = 1, n <= prefabs_to_place, n++)
		var/datum/mapPrefab/planet/P = pick_map_prefab(/datum/mapPrefab/planet)
		if (P)
			var/maxX = (region.bottom_left.x + region.width - P.prefabSizeX - AST_MAPBORDER)
			var/maxY = (region.bottom_left.y + region.height - P.prefabSizeY - AST_MAPBORDER)
			var/stop = 0
			var/count= 0
			var/maxTries = (P.required ? 200:33)
			while (!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(region.bottom_left.x+AST_MAPBORDER, maxX), rand(region.bottom_left.y+AST_MAPBORDER,maxY), region.bottom_left.z)
				if(!P.check_biome_requirements(target))
					count = INFINITY
					break

				var/datum/loadedProperties/ret = P.applyTo(target)
				if (ret)
					var/space_turfs = block(locate(ret.sourceX, ret.sourceY, ret.sourceZ), locate(ret.maxX, ret.maxY, ret.maxZ))
					for(T in space_turfs)
						if(!istype(T, /turf/space))
							space_turfs -= T
					generator.generate_terrain(space_turfs, reuse_seed=TRUE)
					for(T in space_turfs)
						T.UpdateOverlays(ambient_light, "ambient")
						LAGCHECK(LAG_LOW)

					logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [P.type][P.required?" (REQUIRED)":""] succeeded. [target] @ [log_loc(target)]")
					stop = 1
				else
					logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [P.type] failed due to blocked area. [target] @ [log_loc(target)]")
				count++
			if (count == maxTries)
				logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [P.type] failed due to maximum tries [maxTries][P.required?" WARNING: REQUIRED FAILED":""].")
		else break

	//Allow folks to like uh, get here?
	if(use_lrt)
		var/lrt_placed = FALSE
		var/maxTries = 80
		while(!lrt_placed)
			if(!maxTries)
				message_admins("Planet region failed to place LRT coordinates!!!")
				break

			T = pick(turfs)
			if(T.density)
				maxTries--
				continue

			new /obj/landmark/lrt/planet(T, name)
			new /obj/decal/teleport_mark(T)
			lrt_placed = TRUE
			special_places.Add(name)

	logTheThing(LOG_ADMIN, usr, "Planet region generated at [log_loc(region.bottom_left)] with [generator].")
	logTheThing(LOG_DIARY, usr, "Planet region generated at [log_loc(region.bottom_left)] with [generator].", "admin")
	message_admins("Planet region generated at [log_loc(region.bottom_left)] with [generator].")


/obj/landmark/lrt/planet //for use with long range teleporter locations, please add new subtypes of this for new locations and use those
	name_override = LANDMARK_LRT

	New(newLoc, name)
		src.name = name // store name
		..()
