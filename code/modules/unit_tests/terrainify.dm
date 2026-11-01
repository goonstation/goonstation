
/datum/unit_test/terrainify

/datum/unit_test/terrainify/proc/is_turf_path_safe(turf_path)
	if(ispath(turf_path, /turf/unsimulated))
		. = TRUE
	else if(ispath(turf_path, /turf/simulated/wall/auto/asteroid))
		var/turf/simulated/wall/auto/asteroid/a_type = turf_path
		if(ispath(a_type::replace_type, /turf/unsimulated))
			. = TRUE
	else if(isnull(turf_path))
		. = TRUE

	if(!.)
		. = .

/datum/unit_test/terrainify/Run()
	// Iterate through map generators and ensure none of them generate simulated turf
	for(var/map_gen_type in childrentypesof(/datum/map_generator))
		var/datum/map_generator/gen_under_test = new map_gen_type()
		if("possible_biomes" in gen_under_test.vars)
			for(var/i in gen_under_test.vars["possible_biomes"])
				for(var/j in gen_under_test.vars["possible_biomes"][i])
					var/datum/biome/gen_biome = gen_under_test.vars["possible_biomes"][i][j]
					TEST_ASSERT(is_turf_path_safe(gen_biome::turf_type),"[map_gen_type]'s [i][j] biome [gen_biome] has sim element")

		TEST_ASSERT(is_turf_path_safe(gen_under_test.wall_turf_type), "[map_gen_type]'s wall_turf_type has sim element")
		TEST_ASSERT(is_turf_path_safe(gen_under_test.floor_turf_type), "[map_gen_type]'s floor_turf_type has sim element")

	// Iterate through /datum/biome and ensure none of them generate simulated turf
	// This is mostly redundant but Azrun can't be trusted
	for(var/biome_path in childrentypesof(/datum/biome))
		var/datum/biome/biome = biome_path
		TEST_ASSERT(is_turf_path_safe(biome::turf_type), "[biome]'s turf_type has sim element")
