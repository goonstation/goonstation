//the random offset applied to square coordinates, causes intermingling at biome borders
#define DESERT_BIOME_RANDOM_SQUARE_DRIFT 2
/datum/map_generator/desert_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/desert,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/desert,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mudlands,
		BIOME_HIGH_HUMIDITY = /datum/biome/water/clear
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/desert,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/desert,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/desert,
		BIOME_HIGH_HUMIDITY = /datum/biome/mudlands
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/desert/rough,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/desert,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/desert,
		BIOME_HIGH_HUMIDITY = /datum/biome/desert
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/desert/rough,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/desert/rough,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/desert,
		BIOME_HIGH_HUMIDITY = /datum/biome/desert
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/desert_generator/generate_terrain(var/list/turfs, var/reuse_seed)
	. = ..()
	var/height_seed = seeds[1]
	var/humidity_seed = seeds[2]
	var/heat_seed = seeds[3]

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/drift_x = (gen_turf.x + rand(-DESERT_BIOME_RANDOM_SQUARE_DRIFT, DESERT_BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-DESERT_BIOME_RANDOM_SQUARE_DRIFT, DESERT_BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/height = text2num(rustg_noise_get_at_coordinates("[height_seed]", "[drift_x]", "[drift_y]"))


		var/datum/biome/selected_biome
		if(height <= 0.85) //If height is less than 0.85, we generate biomes based on the heat and humidity of the area.
			var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]"))
			var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))
			var/heat_level //Type of heat zone we're in LOW-MEDIUM-HIGH
			var/humidity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH

			switch(heat)
				if(0 to 0.10)
					heat_level = BIOME_LOW_HEAT
				if(0.10 to 0.45)
					heat_level = BIOME_LOWMEDIUM_HEAT
				if(0.45 to 0.80)
					heat_level = BIOME_HIGHMEDIUM_HEAT
				if(0.80 to 1)
					heat_level = BIOME_HIGH_HEAT
			switch(humidity)
				if(0 to 0.35)
					humidity_level = BIOME_LOW_HUMIDITY
				if(0.35 to 0.5)
					humidity_level = BIOME_LOWMEDIUM_HUMIDITY
				if(0.5 to 0.92)
					humidity_level = BIOME_HIGHMEDIUM_HUMIDITY
				if(0.92 to 1)
					humidity_level = BIOME_HIGH_HUMIDITY
			selected_biome = possible_biomes[heat_level][humidity_level]
		else //Over 0.85; It's a mountain
			selected_biome = /datum/biome/mountain/desert
		selected_biome = biomes[selected_biome]
		selected_biome.generate_turf(gen_turf)

		gen_turf.temperature = 330 // 56.9C

		if (current_state >= GAME_STATE_PLAYING)
			LAGCHECK(LAG_LOW)
		else
			LAGCHECK(LAG_HIGH)


///for the mapgen mountains, temp until we get something better
/turf/simulated/wall/asteroid/mountain/desert
	name = "mountain"
	desc = "a sandy mountain"
	color = "#957a59"
	stone_color = "#957a59"

	New()
		..()

	destroy_asteroid(var/dropOre=0)
		var/new_color = src.color
		var/image/weather = GetOverlayImage("weather")
		var/image/ambient = GetOverlayImage("ambient")

		src.RL_SetOpacity(0)
		for (var/turf/simulated/floor/plating/airless/asteroid/A in range(src,1))
			A.UpdateIcon()
		src.ReplaceWith(/turf/simulated/floor/plating/airless/asteroid/desert)
		src.color = new_color
		src.opacity = 0
		src.levelupdate()

		if(weather)
			src.UpdateOverlays(weather, "weather")
		if(ambient)
			src.UpdateOverlays(ambient, "ambient")

		return src

/turf/simulated/floor/plating/airless/asteroid/desert
	color = "#957a59"
	stone_color = "#957a59"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = 330
	fullbright = 0

	update_icon()
		var/image/ambient_light = src.GetOverlayImage("ambient")
		var/image/weather = src.GetOverlayImage("weather")
		..()
		if(length(overlays) != length(overlay_refs)) //hack until #5872 is resolved
			overlay_refs.len = 0
		src.UpdateOverlays(ambient_light, "ambient")
		src.UpdateOverlays(weather, "weather")
