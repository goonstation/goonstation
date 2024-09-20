//the random offset applied to square coordinates, causes intermingling at biome borders
#define BIOME_RANDOM_SQUARE_DRIFT 2

/datum/map_generator/snow_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mudlands,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow/rocky,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow/rough,
		BIOME_HIGH_HUMIDITY = /datum/biome/water/ice/rough
		),

	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/snow/rocky,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow/rough,
		BIOME_HIGH_HUMIDITY = /datum/biome/snow/rough
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/snow,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow/rough,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow/forest,
		BIOME_HIGH_HUMIDITY = /datum/biome/snow/forest/thick
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/plains,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow/forest,
		BIOME_HIGH_HUMIDITY = /datum/biome/water/clear
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 85
	wall_turf_type	= /turf/simulated/wall/auto/asteroid/mountain
	floor_turf_type = /turf/unsimulated/floor/plating/asteroid/mountain

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/snow_generator/generate_terrain(list/turfs, reuse_seed, flags)
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
				if(0 to 0.35)
					heat_level = BIOME_LOW_HEAT
				if(0.35 to 0.65)
					heat_level = BIOME_LOWMEDIUM_HEAT
				if(0.65 to 0.9)
					heat_level = BIOME_HIGHMEDIUM_HEAT
				if(0.9 to 1)
					heat_level = BIOME_HIGH_HEAT
			switch(humidity)
				if(0 to 0.2)
					humidity_level = BIOME_LOW_HUMIDITY
				if(0.2 to 0.5)
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

		gen_turf.temperature = 235 // -38C and lowest breathable temperature with standard atmos

		src.lag_check()


/turf/simulated/wall/auto/asteroid/mountain/snow
	replace_type = /turf/unsimulated/floor/plating/asteroid/mountain/snow

/turf/unsimulated/floor/plating/asteroid/mountain/snow
	temperature = 235

#undef BIOME_RANDOM_SQUARE_DRIFT
