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
	floor_turf_type = /turf/unsimulated/floor/plating/asteroid/mountain

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
		selected_biome = adjust_biome(gen_turf, selected_biome)
		selected_biome = biomes[selected_biome]
		selected_biome.generate_turf(gen_turf, flags)

		src.lag_check(flags)

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


/datum/map_generator/forest_generator/proc/adjust_biome(turf/gen_turf, datum/biome/path)
	. = path

/datum/biome/forest/dense/dark
	flora_types = list(/obj/tree{layer = EFFECTS_LAYER_UNDER_1} = 5, /obj/tree/elm_random=25, /obj/shrub/random{last_use=INFINITY} = 5, /obj/machinery/plantpot/bareplant/swamp_flora = 1)
#ifdef HALLOWEEN
	fauna_types = list(/mob/living/critter/changeling/eyespider/ai_controlled = 5, /mob/living/critter/changeling/legworm/ai_controlled = 5, /mob/living/critter/changeling/handspider/ai_controlled = 5, /mob/living/critter/bear=1, /mob/living/critter/small_animal/frog=5, /mob/living/critter/small_animal/bird/owl=1)
#else
	fauna_types = list(/mob/living/critter/bear=1, /mob/living/critter/small_animal/frog=5, /mob/living/critter/small_animal/bird/owl=1)
#endif

/datum/biome/forest
	var/dark = FALSE

/datum/biome/forest/thin/dark
	dark = TRUE
	flora_types = list(/obj/tree{layer = EFFECTS_LAYER_UNDER_1} = 5, /obj/tree/elm_random=5, /obj/shrub/random{last_use=INFINITY} = 50, /obj/machinery/plantpot/bareplant/tree = 5, /obj/machinery/plantpot/bareplant/swamp_flora = 50)
	fauna_types = list(/mob/living/critter/small_animal/mouse=5, /mob/living/critter/small_animal/mouse/mad=1, /mob/living/critter/small_animal/snake=2, /mob/living/critter/small_animal/bird/crow=1)

/datum/biome/forest/dark
	dark = TRUE
	flora_types = list(/obj/tree{layer = EFFECTS_LAYER_UNDER_1} = 5, /obj/tree/elm_random=30, /obj/shrub/random{last_use=INFINITY} = 50)
	fauna_types = list(/mob/living/critter/small_animal/firefly/ai_controlled = 1, /mob/living/critter/small_animal/firefly/pyre/ai_controlled = 3, /mob/living/critter/small_animal/firefly/lightning/ai_controlled = 3, /mob/living/critter/bear=1, /mob/living/critter/small_animal/bird/crow=5)

/datum/biome/forest/clearing/dark
	dark = TRUE
	flora_types = list(/obj/shrub/random{last_use=INFINITY} = 150, /obj/machinery/plantpot/bareplant/flower = 5, /obj/machinery/plantpot/bareplant/swamp_flora = 1 )
	fauna_types = list(/mob/living/critter/small_animal/mouse=5, /mob/living/critter/small_animal/mouse/mad=1, /mob/living/critter/small_animal/snake=3)

/datum/map_generator/forest_generator/dark
	var/list/dark_region
	var/static/list/dark_lookup = list(/datum/biome/forest/clearing=/datum/biome/forest/clearing/dark,
						   /datum/biome/forest/thin=/datum/biome/forest/thin/dark,
						   /datum/biome/forest=/datum/biome/forest/dark,
						   /datum/biome/forest/dense=/datum/biome/forest/dense/dark)

	New()
		..()
		if(!dark_region)
			dark_region = rustg_dbp_generate("[rand(1,420)]", "5", "15", "[world.maxx]", "0.001", "0.9")

/datum/map_generator/forest_generator/dark/adjust_biome(turf/gen_turf, datum/biome/path)
	var/dark
	var/index = gen_turf.x * world.maxx + gen_turf.y
	if(index <= length(dark_region))
		dark = text2num(dark_region[index])
	if(dark && dark_lookup[path])
		. = dark_lookup[path]
	else
		. = path
