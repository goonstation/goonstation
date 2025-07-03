///All possible biomes in assoc list as type || instance
var/list/datum/biome/biomes = list()

///Initialize all biomes, assoc as type || instance
proc/initialize_biomes()
	for(var/biome_path in concrete_typesof(/datum/biome))
		var/datum/biome/biome_instance = new biome_path()
		biomes[biome_path] += biome_instance

///This type is responsible for any map generation behavior that is done in areas, override this to allow for area-specific map generation. This generation is ran by areas on world/proc/init().
/datum/map_generator
	var/list/seeds
	var/floor_turf_type
	var/wall_turf_type
	var/clear_turf_type
	var/lag_check_count

///This proc will be ran by areas on world/proc/init(), and provides the areas turfs as argument to allow for generation.
/datum/map_generator/proc/generate_terrain(var/list/turfs, var/reuse_seed, var/flags)
	if(!reuse_seed || !length(seeds))
		LAZYLISTINIT(seeds)
		seeds.len = 0
		seeds += rand(0, 50000)
		seeds += rand(0, 50000)
		seeds += rand(0, 50000)
	return

/datum/map_generator/proc/set_seed(list/seed_list)
	if(length(seed_list))
		seeds = seed_list

/datum/map_generator/proc/lag_check(var/flags)
	if(flags & MAPGEN_SLOW_GENERATION)
		lag_check_count++
		if(lag_check_count % 10 == 0)
			sleep(1)

	if (current_state >= GAME_STATE_PLAYING)
		LAGCHECK(LAG_LOW)
	else
		LAGCHECK(LAG_HIGH)

ABSTRACT_TYPE(/area/map_gen)
/area/map_gen
	name = "map gen"
	icon = 'icons/turf/map_gen.dmi'
	icon_state = "genarea"

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

	proc/generate_perlin_noise_terrain()
		if(src.map_generator)
			map_generator = new map_generator()
			map_generator.generate_terrain(get_area_turfs(src))

/area/map_gen/jungle
	name = "planet generation area"
	map_generator = /datum/map_generator/jungle_generator

/area/map_gen/desert
	name = "planet generation area"
	map_generator = /datum/map_generator/desert_generator

/area/map_gen/snow
	name = "planet generation area"
	map_generator = /datum/map_generator/snow_generator

/turf/map_gen
	name = "ungenerated turf"
	desc = "If you see this, and you're not a ghost, yell at coders"
	icon = 'icons/turf/map_gen.dmi'
	icon_state = "genturf"
