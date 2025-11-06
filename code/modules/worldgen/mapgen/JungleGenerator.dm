//the random offset applied to square coordinates, causes intermingling at biome borders
#define BIOME_RANDOM_SQUARE_DRIFT 2

/datum/map_generator/jungle_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/plains,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mudlands,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mudlands,
		BIOME_HIGH_HUMIDITY = /datum/biome/water/swamp
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/plains,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/jungle,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle,
		BIOME_HIGH_HUMIDITY = /datum/biome/mudlands
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/plains,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/plains,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle/deep,
		BIOME_HIGH_HUMIDITY = /datum/biome/jungle
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/wasteland,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/plains,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle,
		BIOME_HIGH_HUMIDITY = /datum/biome/jungle/deep
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65
	wall_turf_type	= /turf/simulated/wall/auto/asteroid/mountain
	floor_turf_type = /turf/unsimulated/floor/plating/asteroid/mountain

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/jungle_generator/generate_terrain(list/turfs, reuse_seed, flags)
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

		src.lag_check(flags)


///for the mapgen mountains, temp until we get something better
/turf/simulated/wall/auto/asteroid/mountain
	name = "mountain"
	desc = "a rocky mountain"
	fullbright = 0
	default_ore = null
	replace_type = /turf/unsimulated/floor/plating/asteroid/mountain

	destroy_asteroid(var/dropOre=1)
		var/image/weather = GetOverlayImage("weather")
		var/image/ambient = GetOverlayImage("ambient")

		if(src.ore || prob(8)) // provide less rock
			default_ore = /obj/item/raw_material/rock
		var/could_build = src.can_build
		. = ..()
		if(could_build)
			src.can_build = could_build

			var/turf/unsimulated/T = src
			if(istype(T))
				T.can_replace_with_stuff = TRUE

		for (var/turf/unsimulated/floor/plating/asteroid/A in range(src,1))
			A.UpdateIcon()

		if(weather)
			src.AddOverlays(weather, "weather")
		if(ambient)
			src.AddOverlays(ambient, "ambient")

		if(istype(src, /turf/simulated))
			if(air) // force reverting air to floor turf as this is post replace
#define _TRANSFER_GAS_TO_AIR(GAS, ...) air.GAS = GAS;
				APPLY_TO_GASES(_TRANSFER_GAS_TO_AIR)
#undef _TRANSFER_GAS_TO_AIR

				air.temperature = temperature

		if(station_repair.allows_vehicles)
			src.allows_vehicles = station_repair.allows_vehicles

		return src

/turf/unsimulated/floor/plating/asteroid/mountain
	name = "mountain"
	desc = "a rocky mountain"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	fullbright = 0

#undef BIOME_RANDOM_SQUARE_DRIFT
