//the random offset applied to square coordinates, causes intermingling at biome borders
#define BIOME_RANDOM_SQUARE_DRIFT 2

/datum/map_generator/forest_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/forest/clearing,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/forest/thin,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/forest/thin,
		BIOME_HIGH_HUMIDITY = /datum/biome/forest
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/forest/clearing,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/forest/thin,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/forest,
		BIOME_HIGH_HUMIDITY = /datum/biome/forest/dense
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/forest/clearing,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/forest/thin,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/forest,
		BIOME_HIGH_HUMIDITY = /datum/biome/forest/dense
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/forest,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/forest,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/forest/dense,
		BIOME_HIGH_HUMIDITY = /datum/biome/forest/dense
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65
	wall_turf_type	= /turf/simulated/wall/auto/asteroid/mountain
	floor_turf_type = /turf/simulated/floor/plating/airless/asteroid/mountain

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/forest_generator/generate_terrain(list/turfs, reuse_seed, flags)
	. = ..()
	var/height_seed = seeds[1]
	var/humidity_seed = seeds[2]
	var/heat_seed = seeds[3]

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/drift_x = (gen_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/height = text2num(rustg_noise_get_at_coordinates("[height_seed]", "[drift_x]", "[drift_y]"))


		var/datum/biome/selected_biome
		if(height <= 0.85) //If height is less than 0.85, we generate biomes based on the heat and humidity of the area.
			var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]"))
			var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))
			var/heat_level //Type of heat zone we're in LOW-MEDIUM-HIGH
			var/humidity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH

			switch(heat)
				if(0 to 0.25)
					heat_level = BIOME_LOW_HEAT
				if(0.25 to 0.5)
					heat_level = BIOME_LOWMEDIUM_HEAT
				if(0.5 to 0.75)
					heat_level = BIOME_HIGHMEDIUM_HEAT
				if(0.75 to 1)
					heat_level = BIOME_HIGH_HEAT
			switch(humidity)
				if(0 to 0.25)
					humidity_level = BIOME_LOW_HUMIDITY
				if(0.25 to 0.5)
					humidity_level = BIOME_LOWMEDIUM_HUMIDITY
				if(0.5 to 0.75)
					humidity_level = BIOME_HIGHMEDIUM_HUMIDITY
				if(0.75 to 1)
					humidity_level = BIOME_HIGH_HUMIDITY
			selected_biome = possible_biomes[heat_level][humidity_level]
		else //Over 0.85; It's a mountain
			selected_biome = /datum/biome/mountain
		selected_biome = biomes[selected_biome]
		selected_biome.generate_turf(gen_turf, flags)

		if (current_state >= GAME_STATE_PLAYING)
			LAGCHECK(LAG_LOW)
		else
			LAGCHECK(LAG_HIGH)

/datum/biome/forest/generate_turf(turf/gen_turf, flags)
	. = ..()

	// Cull Trees
	if((flags & MAPGEN_IGNORE_FLORA) == 0)
		var/obj/tree/here_tree = locate() in gen_turf
		if(here_tree)
			var/list/things = orange(1,gen_turf)
			if(gen_turf.z == Z_LEVEL_STATION)
				var/area/station/nearby_station = locate() in things
				if(nearby_station)
					qdel(here_tree)
					return

			for (var/obj/tree/there_tree in things)
				if(prob(66))
					qdel(here_tree)
					return

#undef BIOME_RANDOM_SQUARE_DRIFT
