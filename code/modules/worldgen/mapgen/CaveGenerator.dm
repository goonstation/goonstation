//the random offset applied to square coordinates, causes intermingling at biome borders
#define BIOME_RANDOM_SQUARE_DRIFT 2

/datum/map_generator/cave_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mountain/cave/floor,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mountain/cave/floor,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mudlands,
		BIOME_HIGH_HUMIDITY = /datum/biome/mudlands
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mountain/cave/floor,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mountain/cave/floor,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mountain/cave/floor,
		BIOME_HIGH_HUMIDITY = /datum/biome/mudlands
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mountain/cave/floor,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mountain/cave/floor,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mountain/cave/floor,
		BIOME_HIGH_HUMIDITY = /datum/biome/mudlands
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mountain/cave/floor,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mountain/cave/floor,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mountain/cave/floor,
		BIOME_HIGH_HUMIDITY = /datum/biome/mudlands
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65

	var/big_caves = null
	var/smol_caves = null
	var/rock_wall_biome = /datum/biome/mountain/cave
	wall_turf_type	= /turf/simulated/wall/auto/asteroid/mountain/cave
	floor_turf_type = /turf/unsimulated/floor/cave/asteroid/earthen

/datum/map_generator/cave_generator/adventure
	///2D list of all biomes based on heat and humidity combos.
	possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_HIGH_HUMIDITY = /datum/biome/adventure/cave
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_HIGH_HUMIDITY = /datum/biome/adventure/cave
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_HIGH_HUMIDITY = /datum/biome/adventure/cave
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/adventure/cave,
		BIOME_HIGH_HUMIDITY = /datum/biome/adventure/cave
		)
	)
	rock_wall_biome = /datum/biome/adventure/cave/wall
	wall_turf_type	= /turf/unsimulated/wall/auto/adventure/cave
	floor_turf_type = /turf/unsimulated/floor/cave


/datum/biome/asteroid
	turf_type = /turf/unsimulated/floor/cave/asteroid

/datum/biome/asteroid/wall
	turf_type = /turf/simulated/wall/auto/asteroid/cave

/datum/biome/asteroid/fermid
	flora_types = list(/obj/overlay/tile_effect/cracks/spawner/fermid/random=5, /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/fermid=1)
	flora_density = 0.1

	fauna_types = list(/mob/living/critter/fermid=100, /obj/overlay/tile_effect/cracks/spawner/fermid=50, /mob/living/critter/fermid/spitter=5, /mob/living/critter/fermid/worker=25, /mob/living/critter/fermid/worker/green=25, /mob/living/critter/fermid/spitter/blue=1, /mob/living/critter/fermid/spitter/orange=1, /mob/living/critter/fermid/hulk=10, /mob/living/critter/fermid/hulk/purple=1)
	fauna_density = 1
	minimum_fauna_distance = 5

/datum/biome/asteroid/fermid/hive
	fauna_density = 2
	minimum_fauna_distance = 4

/datum/biome/asteroid/fermid/nest
	flora_types = list(/obj/overlay/tile_effect/cracks/spawner/fermid=10, /obj/overlay/tile_effect/cracks/spawner/fermid/random=5, /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/fermid=5, /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/fermid/random=1)
	flora_density = 4

	fauna_types = list(/mob/living/critter/fermid=100, /obj/overlay/tile_effect/cracks/spawner/fermid=25, /mob/living/critter/fermid/worker=25, /mob/living/critter/fermid/hulk=10, /mob/living/critter/fermid/queen=5, /mob/living/critter/fermid/grub=5)
	fauna_density = 2
	minimum_fauna_distance = 3

/turf/simulated/wall/auto/asteroid/cave
	replace_type = /turf/unsimulated/floor/cave/asteroid

/datum/map_generator/cave_generator/asteroid
	///2D list of all biomes based on heat and humidity combos.
	possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/asteroid,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/asteroid,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/asteroid,
		BIOME_HIGH_HUMIDITY = /datum/biome/asteroid
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/asteroid,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/asteroid,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/asteroid/fermid,
		BIOME_HIGH_HUMIDITY = /datum/biome/asteroid/fermid
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/asteroid,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/asteroid,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/asteroid/fermid/hive,
		BIOME_HIGH_HUMIDITY = /datum/biome/asteroid/fermid
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/asteroid,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/asteroid/fermid,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/asteroid/fermid/hive,
		BIOME_HIGH_HUMIDITY = /datum/biome/asteroid/fermid/nest
		)
	)
	rock_wall_biome = /datum/biome/asteroid/wall
	wall_turf_type	= /turf/simulated/wall/auto/asteroid/cave
	floor_turf_type = /turf/unsimulated/floor/cave/asteroid

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/cave_generator/generate_terrain(list/turfs, reuse_seed, flags)
	. = ..()
	var/cave_seed = seeds[1]
	var/humidity_seed = seeds[2]
	var/heat_seed = seeds[3]

	if(!big_caves)
		switch(rand(1,3))
			if(1)
				src.big_caves = rustg_dbp_generate("[cave_seed]", "30", "30", "[world.maxx]", "0.0001", "0.1")
			if(2)
				src.big_caves = rustg_dbp_generate("[cave_seed]", "5", "40", "[world.maxx]", "0.01", "0.2")
			else
				src.big_caves = rustg_worley_generate("20", "10", "5", "[world.maxx]", "4", "6")

	if(!smol_caves)
		switch(rand(1,3))
			if(1)
				src.smol_caves = rustg_dbp_generate("[cave_seed]", "3", "7", "[world.maxx]", "0.0001", "0.8")
			if(2)
				src.smol_caves = rustg_dbp_generate("[cave_seed]", "20", "5", "[world.maxx]", "0.0001", "0.8")
			else
				src.smol_caves = rustg_cnoise_generate("60", "10", "5", "4", "[world.maxx]", "[world.maxy]")

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/drift_x = (gen_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/cave_carved_value
		var/index = gen_turf.x * world.maxx + gen_turf.y
		if(index <= length(big_caves))
			cave_carved_value = text2num(big_caves[gen_turf.x * world.maxx + gen_turf.y]) + text2num(smol_caves[gen_turf.x * world.maxx + gen_turf.y])

		var/datum/biome/selected_biome
		if(cave_carved_value) //If height is less than 0.85, we generate biomes based on the heat and humidity of the area.
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
		else
			selected_biome = src.rock_wall_biome
		selected_biome = biomes[selected_biome]
		selected_biome.generate_turf(gen_turf, flags)

		src.lag_check(flags)


/turf/simulated/wall/auto/asteroid/mountain/cave
	name = "cave"
	desc = "a cave wall"
	color = "#7c5855"
	stone_color = "#7c5855"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = 330
	default_ore = null
	replace_type = /turf/unsimulated/floor/plating/asteroid/cave

/turf/unsimulated/floor/plating/asteroid/cave
	name = "cave"
	desc = "cave floor"
	color = "#7c5855"
	stone_color = "#7c5855"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = 330
	fullbright = 0

/datum/biome/mountain/cave/floor
	turf_type = /turf/unsimulated/floor/cave/asteroid/earthen

/turf/unsimulated/floor/cave/asteroid/earthen
	color = "#7c5855"

/turf/unsimulated/floor/cave/asteroid
	name = "cave"
	desc = "cave floor"
	icon = 'icons/turf/walls/asteroid.dmi'
	icon_state = "astfloor1"
	fullbright = 0

#undef BIOME_RANDOM_SQUARE_DRIFT
