//the random offset applied to square coordinates, causes intermingling at biome borders
#define ICEMOON_BIOME_RANDOM_SQUARE_DRIFT 2

/datum/biome/icemoon/snow
	turf_type = /turf/unsimulated/floor/arctic/snow/autocliff
	flora_types = list(/obj/stone/random = 10, /obj/fakeobject/smallrocks = 10)
	flora_density = 1

	fauna_types = list(/mob/living/critter/small_animal/seal = 15, /mob/living/critter/brullbar = 5)
	fauna_density = 0.5

/datum/biome/icemoon/snow/trees
	flora_types = list(/obj/tree{dir=NORTH} = 10,/obj/tree{dir=EAST} = 10, /obj/stone/random = 10, /obj/fakeobject/smallrocks = 10)
	flora_density = 3

/datum/biome/icemoon/ice
	turf_type = /turf/unsimulated/floor/arctic/snow/ice

	fauna_types = list(/mob/living/critter/spider/ice/queen=1, /mob/living/critter/spider/ice/nice=5, /mob/living/critter/spider/ice=20, /mob/living/critter/brullbar=5)
	fauna_density = 0.5

/datum/biome/icemoon/icewall
	turf_type = /turf/simulated/wall/auto/asteroid/mountain/icemoon

/datum/biome/icemoon/abyss
	turf_type = /turf/unsimulated/floor/arctic/abyss

/datum/map_generator/icemoon_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/icemoon/ice,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/icemoon/ice,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/icemoon/icewall,
		BIOME_HIGH_HUMIDITY = /datum/biome/icemoon/ice
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/icemoon/icewall,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/icemoon/snow,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/icemoon/snow,
		BIOME_HIGH_HUMIDITY = /datum/biome/icemoon/snow
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/icemoon/snow,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/icemoon/snow,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/icemoon/snow,
		BIOME_HIGH_HUMIDITY = /datum/biome/icemoon/snow
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/icemoon/snow,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/icemoon/snow,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/icemoon/snow/trees,
		BIOME_HIGH_HUMIDITY = /datum/biome/icemoon/snow/trees
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65
	wall_turf_type	= /turf/simulated/wall/auto/asteroid/mountain/icemoon
	floor_turf_type = /turf/unsimulated/floor/plating/asteroid/icemoon

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/icemoon_generator/generate_terrain(list/turfs, reuse_seed, flags)
	. = ..()
	var/height_seed = seeds[1]
	var/humidity_seed = seeds[2]
	var/heat_seed = seeds[3]

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/drift_x = (gen_turf.x + rand(-ICEMOON_BIOME_RANDOM_SQUARE_DRIFT, ICEMOON_BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-ICEMOON_BIOME_RANDOM_SQUARE_DRIFT, ICEMOON_BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/height = text2num(rustg_noise_get_at_coordinates("[height_seed]", "[drift_x]", "[drift_y]"))

		var/datum/biome/selected_biome
		if(flags & MAPGEN_FLOOR_ONLY)
			selected_biome = /datum/biome/icemoon/snow
		else if(height <= 0.85) //If height is less than 0.85, we generate biomes based on the heat and humidity of the area.
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
		else //Over 0.85; It's the abyss
			selected_biome = /datum/biome/icemoon/abyss
		selected_biome = biomes[selected_biome]
		var/tmp_flags = flags
		if(istype(selected_biome, /datum/biome/icemoon/abyss))
			tmp_flags |= MAPGEN_IGNORE_BUILDABLE
		selected_biome.generate_turf(gen_turf, tmp_flags)

		src.lag_check()


///for the mapgen mountains, temp until we get something better
/turf/simulated/wall/auto/asteroid/mountain/icemoon
	name = "ice wall"
	desc = "You're inside a glacier. Wow."
	fullbright = 0
	replace_type = /turf/unsimulated/floor/plating/asteroid/icemoon
	default_material = "ice"
	color = "#8df"
	stone_color = "#8df"
	carbon_dioxide = 100
	nitrogen = 0
	oxygen = 0
	temperature = 100

	destroy_asteroid(var/dropOre=1)
		if(src.ore || prob(33)) // provide less rock
			default_ore = /obj/item/raw_material/ice
		. = ..()

/turf/unsimulated/floor/plating/asteroid/icemoon
	name = "floor"
	desc = "A tunnel through the glacier. This doesn't seem to be water ice..."
	carbon_dioxide = 100
	nitrogen = 0
	oxygen = 0
	temperature = 100
	fullbright = 0


/turf/unsimulated/floor/arctic/snow/autocliff
	New()
		..()
		SPAWN(3 SECONDS)
			if(istype(src))
				src.UpdateIcon()

	update_icon()
		var/dir_sum
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if (T && (istype(T, /turf/unsimulated/floor/arctic/abyss)))
				dir_sum |= dir
		if(dir_sum in alldirs)
			src.icon = 'icons/turf/floors.dmi'
			src.icon_state = "snow_corner"
			src.dir = dir_sum
			clear_contents()
			return
		else if(dir_sum)
			clear_and_update_neighbors()
			return

		for (var/dir in ordinal)
			var/turf/T = get_step(src, dir)
			if (T && (istype(T, /turf/unsimulated/floor/arctic/abyss)))
				dir_sum |= dir
		if(dir_sum in alldirs)
			src.icon = 'icons/turf/floors.dmi'
			src.icon_state = "snow_cliff1"
			src.dir = dir_sum
			clear_contents()
		else if(dir_sum)
			clear_and_update_neighbors()
			return

	proc/clear_and_update_neighbors()
		var/list/turf/neighbors = getNeighbors(src, alldirs)
		clear_contents()
		src.ReplaceWith(/turf/unsimulated/floor/arctic/abyss, force=TRUE)
		for(var/turf/unsimulated/floor/arctic/snow/autocliff/cliff in neighbors)
			cliff.UpdateIcon()

	proc/clear_contents()
		for(var/atom/A in src.contents)
			if (istype(A, /obj/overlay) || istype(A, /obj/effects)) continue
			qdel(A)
