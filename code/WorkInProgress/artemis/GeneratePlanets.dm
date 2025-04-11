/// The following is based on GenerateMining.dm

var/planetZLevel = null
var/list/planetGenerators = list()//Assoc list
var/list/planetModifiers = list()
var/list/planetModifiersUsed = list()//Assoc list, type:times used
var/list/planet_seeds = list()

#ifdef ENABLE_ARTEMIS
/proc/makePlanetLevel()
	//var/list/turf/planetZ = list()
	var/startTime = world.timeofday
	if(!planetZLevel)
		boutput(world, SPAN_ALERT("Skipping Planet Generation!"))
		return
	else
		boutput(world, SPAN_ALERT("Generating Planet Level ..."))

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
				var/datum/mapPrefab/planet/M = pick_map_prefab(/datum/mapPrefab/planet, wanted_tags_any=PREFAB_PLANET)
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
						var/datum/loadedProperties/ret = M.applyTo(target)
						if (!ret)
							logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [M.type] failed due to blocked area. [target] @ [showCoords(target.x, target.y, target.z)]")
						else
							logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [M.type][M.required?" (REQUIRED)":""] succeeded. [target] @ [showCoords(target.x, target.y, target.z)]")
							stop = 1
							if(istype(A,/area/map_gen/planet))
								var/area/map_gen/planet/P = A
								P.prefabs |= ret

							var/space_turfs = block(locate(ret.sourceX, ret.sourceY, ret.sourceZ), locate(ret.maxX, ret.maxY, ret.maxZ))
							for(var/turf/T in space_turfs)
								if(!istype(T, /turf/space))
									space_turfs -= T
							A.map_generator.generate_terrain(space_turfs)
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

	boutput(world, SPAN_ALERT("Generated Planet Level in [((world.timeofday - startTime)/10)] seconds!"))

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
	var/area/map_gen/planet/no_prefab/no_prefab_ref
	var/area/map_gen/planet/no_foreground/occlude_ref

	no_prefab
		allow_prefab = FALSE

	no_foreground
		occlude_foreground_parallax_layers = TRUE

/datum/planetData
	var/name
	var/image/ambient_light
	var/datum/map_generator/generator

	New(name, light, generator)
		. = ..()
		src.name = name
		src.ambient_light = light
		src.generator = generator

/datum/planetManager
	var/list/datum/allocated_region/regions = list()
	var/minimum_z = INFINITY

	proc/add_planet(datum/allocated_region/region, datum/planetData/data)
		if(region.bottom_left.z < minimum_z)
			minimum_z = region.bottom_left.z
		regions[region] = data

	proc/repair_planet(turf/T)
		if(T.z >= minimum_z)
			for(var/datum/allocated_region/region in regions)
				if(region.turf_in_region(T))
					var/datum/planetData/planet = regions[region]
					if(planet)
						planet.generator.generate_terrain(list(T), reuse_seed=TRUE, flags=MAPGEN_IGNORE_FLORA|MAPGEN_IGNORE_FAUNA)
						T.AddOverlays(planet.ambient_light, "ambient")
						return TRUE

	proc/get_generator(turf/T)
		if(T.z >= minimum_z)
			for(var/datum/allocated_region/region in regions)
				if(region.turf_in_region(T))
					var/datum/planetData/planet = regions[region]
					if(planet)
						return planet.generator

var/global/datum/planetManager/PLANET_LOCATIONS = new /datum/planetManager()

/proc/GeneratePlanetChunk(width=null, height=null, prefabs_to_place=1, datum/map_generator/generator=/datum/map_generator/desert_generator, color=null, name=null, use_lrt=TRUE, seed_ore=TRUE, mapgen_flags=null)
	var/startTime = world.timeofday
	var/turf/T
	if(istext(generator)) generator = text2path(generator)
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
	var/area/map_gen/planet/planet_area = new/area/map_gen/planet
	planet_area.no_prefab_ref = new/area/map_gen/planet/no_prefab
	planet_area.occlude_ref = new/area/map_gen/planet/no_foreground

	planet_area.name = name
	planet_area.no_prefab_ref.name = name
	planet_area.occlude_ref.name = name
	region.clean_up(main_area=planet_area)

	//Parallax it?
	if(istype(generator, /datum/map_generator/snow_generator) && prob(15) )
		planet_area.area_parallax_render_source_group = new /datum/parallax_render_source_group/planet/snow()

	else if(istype(generator, /datum/map_generator/desert_generator) && prob(15) )
		planet_area.area_parallax_render_source_group = new /datum/parallax_render_source_group/planet/desert()

	else if(istype(generator, /datum/map_generator/forest_generator) && prob(95))
		planet_area.area_parallax_render_source_group = new /datum/parallax_render_source_group/planet/forest()

	else if(istype(generator, /datum/map_generator/lavamoon_generator) && prob(95))
		planet_area.area_parallax_render_source_group = new /datum/parallax_render_source_group/planet/lava_moon()

	// Occlude overlays on edges
	if(planet_area.area_parallax_render_source_group)
		planet_area.no_prefab_ref.area_parallax_render_source_group = planet_area.area_parallax_render_source_group
		for(var/turf/cordon/CT in planet_area)
			new/obj/foreground_parallax_occlusion(CT)

	//Populate with Biome!
	var/turfs = block(locate(region.bottom_left.x+1, region.bottom_left.y+1, region.bottom_left.z), locate(region.bottom_left.x+region.width-2, region.bottom_left.y+region.height-2, region.bottom_left.z) )
	generator.generate_terrain(turfs, reuse_seed=TRUE, flags=mapgen_flags)

	var/list/turf/secondary_turfs = list()
	for(var/turf/space/missed in turfs)
		secondary_turfs += missed

	if(length(secondary_turfs))
		logTheThing(LOG_DEBUG, null, "Planet Generation required second pass!")
		message_admins("Planet region required second pass with [generator]. (WHY??!?)")
		generator.generate_terrain(secondary_turfs, reuse_seed=TRUE, flags=mapgen_flags)

	//Force Outer Edge to be Cordon Area
	var/area/border_area = new /area/cordon(null)
	for(var/x in 1 to region.width)
		for(var/y in 1 to region.height)
			if(x == 1 || y == 1 || x == region.width || y == region.height)
				T = region.turf_at(x, y)
				if(T)
					border_area.contents += T
			generator.lag_check(mapgen_flags)

	//Lighten' Up the Place
	var/image/ambient_light = new /image/ambient
	if(!color)
		ambient_light.color = "#888888"
	else
		ambient_light.color = color

	for(T in turfs)
		T.AddOverlays(ambient_light, "ambient")
		LAGCHECK(LAG_LOW)

	PLANET_LOCATIONS.add_planet(region, new /datum/planetData(name, ambient_light, generator))

	var/failsafe = 800
	//Make it interesting, slap some prefabs on that thing
	for (var/n = 1, n <= prefabs_to_place && failsafe-- > 0)
		var/datum/mapPrefab/planet/P = pick_map_prefab(/datum/mapPrefab/planet, wanted_tags_any=PREFAB_PLANET)
		if (P)
			var/maxX = (region.bottom_left.x + region.width - P.prefabSizeX - AST_MAPBORDER)
			var/maxY = (region.bottom_left.y + region.height - P.prefabSizeY - AST_MAPBORDER)
			var/stop = 0
			var/count= 0
			var/maxTries = (P.required ? 200:80)

			if(region.bottom_left.x+AST_MAPBORDER >= maxX || region.bottom_left.y+AST_MAPBORDER >= maxY)
				continue

			while (!stop && count < maxTries && failsafe-- > 0) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(region.bottom_left.x+AST_MAPBORDER, maxX), rand(region.bottom_left.y+AST_MAPBORDER,maxY), region.bottom_left.z)
				if(!P.check_biome_requirements(target))
					count++
					continue

				var/datum/loadedProperties/ret = P.applyTo(target)
				if (ret)
					var/space_turfs = block(locate(ret.sourceX, ret.sourceY, ret.sourceZ), locate(ret.maxX, ret.maxY, ret.maxZ))
					for(T in space_turfs)
						if(!istype(T, /turf/space))
							space_turfs -= T
					generator.generate_terrain(space_turfs, reuse_seed=TRUE)
					for(T in space_turfs)
						T.AddOverlays(ambient_light, "ambient")
						generator.lag_check(mapgen_flags)

					logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [P.type][P.required?" (REQUIRED)":""] succeeded. [target] @ [log_loc(target)]")
					n++
					stop = 1
				else
					logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [P.type] failed due to blocked area. [target] @ [log_loc(target)]")
				count++
				generator.lag_check(mapgen_flags)
			if (count == maxTries)
				logTheThing(LOG_DEBUG, null, "Prefab placement #[n] [P.type] failed due to maximum tries [maxTries][P.required?" WARNING: REQUIRED FAILED":""].")
		else break

	if(seed_ore)
		var/list/turf/mountains = list()
		for(var/turf/simulated/wall/auto/asteroid/mountain in turfs)
			mountains += mountain
		if(length(mountains))
			var/seed_density = clamp(length(mountains)/500, 2, 30)
			for(var/j in 1 to seed_density)
				Turfspawn_Asteroid_SeedOre(mountains, fullbright=FALSE)
				generator.lag_check(mapgen_flags)

			for(var/i in 1 to seed_density/2)
				if(length(mountains))
					var/turf/target_center = pick(mountains)
					var/list/turf/ast_list = list()
					for(var/turf/simulated/wall/auto/asteroid/AST in range(target_center, "[rand(2,9)]x[rand(2,9)]"))
						ast_list |= AST
					Turfspawn_Asteroid_SeedOre(ast_list, veins=rand(1,3), rarity_mod=rand(0,40), fullbright=FALSE)
					Turfspawn_Asteroid_SeedEvents(mountains)
					generator.lag_check(mapgen_flags)

	//Allow folks to like uh, get here?
	if(use_lrt)
		var/lrt_placed = FALSE
		var/maxTries = 80
		while(!lrt_placed)
			if(!maxTries)
				message_admins("Planet region failed to place LRT coordinates!!!")
				break

			T = pick(turfs)
			if(!checkTurfPassable(T))
				maxTries--
				generator.lag_check(mapgen_flags)
				continue

			new /obj/landmark/lrt/planet(T, name)
			new /obj/decal/teleport_mark(T)
			lrt_placed = TRUE
			special_places.Add(name)

	var/gen_text = "Planet region generated at [log_loc(region.bottom_left)] with [generator] in [(world.timeofday - startTime)/10] seconds."
	logTheThing(LOG_ADMIN, usr, gen_text)
	logTheThing(LOG_DIARY, usr, gen_text, "admin")
	message_admins(gen_text)

	return turfs

/datum/map_generator/asteroids
	clear_turf_type = /turf/space

	generate_terrain(var/list/turfs, var/reuse_seed, var/flags)
		if(!length(seeds))
			seeds = list(null)

			var/datum/mapGenerator/asteroidsDistance/D = new()
			D.generate(turfs, numAsteroidSeed=(length(turfs)/2000))
			for(var/turf/T in turfs)
				T.generate_worldgen()

/datum/map_generator/sea_caves
	clear_turf_type = /turf/space/fluid/trench

	generate_terrain(var/list/turfs, var/reuse_seed, var/flags)
		if(!length(seeds))
			seeds = list(null)

			//ocean_reagent_id = reagent.id
			ocean_reagent_id = "water"
			var/datum/reagents/R = new /datum/reagents(100)
			R.add_reagent(ocean_reagent_id, 100)

			ocean_fluid_obj?.group?.reagents?.clear_reagents()
			fluid_turf_setup(first_time=FALSE)
			ocean_name = "ocean of " + R.get_master_reagent_name()
			ocean_color = R.get_average_color().to_rgb()
			qdel(R)

			if(!bioluminescent_algae)
				bioluminescent_algae = new()
				bioluminescent_algae.setup()
			var/datum/mapGenerator/seaCaverns/D
			D = new
			D.generate(turfs, ore_seeds=(length(turfs)/1125))

			for(var/turf/space/space_turf in turfs)
				space_turf.ReplaceWith(/turf/space/fluid/trench)
				space_turf.name = "ocean floor"
				space_turf.RL_Init()

				if (prob(1))
					new /obj/item/seashell(space_turf)

				if (prob(7))
					var/obj/plant = pick(childrentypesof(/obj/sea_plant))
					var/obj/sea_plant/P = new plant(space_turf)
					P.initialize()

				if((flags & MAPGEN_IGNORE_FAUNA) == 0)
					if (prob(1) && prob(2))
						new /obj/critter/gunbot/drone/buzzdrone/fish(space_turf)
					else if (prob(1) && prob(4))
						new /obj/critter/gunbot/drone/gunshark(space_turf)
					else if (prob(1) && prob(20))
						var/mob/fish = pick(childrentypesof(/mob/living/critter/aquatic/fish))
						new fish(space_turf)

					if (prob(2) && prob(20))
						new /obj/overlay/tile_effect/cracks/spawner/trilobite(space_turf)
					if (prob(2) && prob(20))
						new /obj/overlay/tile_effect/cracks/spawner/pikaia(space_turf)

					if (prob(1) && prob(16))
						new /mob/living/critter/small_animal/hallucigenia(space_turf)
					else if (prob(1) && prob(15))
						new /obj/overlay/tile_effect/cracks/spawner/pikaia(space_turf)

				if (prob(1) && prob(9))
					var/obj/storage/crate/trench_loot/C = pick(childrentypesof(/obj/storage/crate/trench_loot))
					var/obj/storage/crate/trench_loot/created_loot = new C(space_turf)
					created_loot.initialize()

			for(var/turf/T in turfs)
				T.generate_worldgen()

/obj/landmark/lrt/planet //for use with long range teleporter locations, please add new subtypes of this for new locations and use those
	name_override = LANDMARK_LRT

	New(newLoc, name)
		src.name = name // store name
		..()

obj/decal/teleport_mark
	icon = 'icons/misc/artemis/temps.dmi'
	icon_state = "decal_tele"
	name = "teleport mark"
	anchored = ANCHORED
	layer = FLOOR_EQUIP_LAYER1
	alpha = 180

	New(var/atom/location)
		..()
		for(var/obj/O in location)
			if(O == src) continue
			if(istype(O, /obj/decal/teleport_mark) || istype(O,/obj/machinery/lrteleporter) || istype(O,/obj/fakeobject/teleport_pad) )
				qdel(src)
				return
