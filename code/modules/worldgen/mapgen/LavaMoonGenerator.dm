//the random offset applied to square coordinates, causes intermingling at biome borders
#define LAVA_MOON_BIOME_RANDOM_SQUARE_DRIFT 2

/datum/biome/lavamoon
	turf_type = /turf/unsimulated/floor/auto/iomoon

	fauna_types = list(/mob/living/critter/small_animal/crab/lava=100)
	fauna_density = 0.02

/datum/biome/lavamoon/minable
	turf_type = /turf/simulated/wall/auto/asteroid/mountain/lavamoon
	fauna_density = 0

/turf/unsimulated/floor/auto/iomoon
	name = "silicate crust"
	icon = 'icons/turf/floors.dmi'
	icon_state = "iocrust"
	opacity = 0
	density = 0
	carbon_dioxide = 20
	temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST-1

	update_icon()
		. = ..()
		var/connectdir = get_connected_directions_bitflag(list(/turf/unsimulated/floor/lava=1,/turf/unsimulated/floor/lava/with_warning=1), list(), TRUE, 2)
		var/found = FALSE
		if(connectdir)
			if((connectdir & 0xF) in cardinal)
				icon_state = "iocrust_edge"
				dir = turn((connectdir & 0xF), 180)
				found = TRUE
			else if((connectdir & 0xF) in ordinal)
				icon_state = "iocrust_corner"
				src.dir = turn((connectdir & 0xF), 45)
				switch(connectdir & 0xF)
					if(NORTHEAST)
						dir = NORTH
					if(SOUTHEAST)
						dir = WEST
					if(SOUTHWEST)
						dir = EAST
					if(NORTHWEST)
						dir = SOUTH
				found = TRUE
			else
				for (var/i = 1 to 4)  // needed for bitshift
					if(connectdir & (8 << i))
						if((connectdir & 0xF) == ordinal[i])
							icon_state = "iocrust_corner"
							src.dir = turn((connectdir & 0xF), 45)
							switch(connectdir & 0xF)
								if(NORTHEAST)
									dir = NORTH
								if(SOUTHEAST)
									dir = WEST
								if(SOUTHWEST)
									dir = EAST
								if(NORTHWEST)
									dir = SOUTH
							found = TRUE
						else if((connectdir & 0xF) & ordinal[i])
							if((connectdir & 0xF) in cardinal)
								icon_state = "iocrust_edge"
								dir = turn(connectdir, 180)
								found = TRUE
						else
							connectdir |= ordinal[i]
				if(!found && ((connectdir & 0xF) in ordinal))
					icon_state = "iocrust_edge"
					dir = turn((connectdir & 0xF), 180)
					found = TRUE
			if(!found)
				var/allow = src.allows_vehicles
				src.ReplaceWith(/turf/unsimulated/floor/lava/with_warning, force=TRUE)
				src.allows_vehicles = allow
				update_neighbors()

/datum/biome/lavamoon/lava
	turf_type = /turf/unsimulated/floor/lava/with_warning
	flora_types = list(/obj/map/light/lava=100)
	flora_density = 95

	fauna_density = 0

/turf/unsimulated/floor/lava/proc/update_neighbors()
	for (var/turf/unsimulated/floor/auto/T in orange(1,src))
		T.UpdateIcon()

/datum/biome/lavamoon/crustwall
	turf_type = /turf/unsimulated/wall/auto/adventure/iomoon
	fauna_density = 0
/datum/map_generator/lavamoon_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/lavamoon/crustwall,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/lavamoon,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/lavamoon,
		BIOME_HIGH_HUMIDITY = /datum/biome/lavamoon
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/lavamoon/crustwall,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/lavamoon,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/lavamoon,
		BIOME_HIGH_HUMIDITY = /datum/biome/lavamoon
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/lavamoon,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/lavamoon,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/lavamoon,
		BIOME_HIGH_HUMIDITY = /datum/biome/lavamoon
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/lavamoon,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/lavamoon,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/lavamoon,
		BIOME_HIGH_HUMIDITY = /datum/biome/lavamoon
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65
	var/lava_percent = 40
	wall_turf_type	= /turf/simulated/wall/auto/asteroid/mountain/lavamoon
	floor_turf_type = /turf/unsimulated/floor/plating/asteroid/lavamoon

	var/lava_noise = null
	var/datum/spatial_hashmap/manual/near_station

///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/lavamoon_generator/generate_terrain(list/turf/turfs, reuse_seed, flags)
	. = ..()
	var/height_seed = seeds[1]
	var/humidity_seed = seeds[2]
	var/heat_seed = seeds[3]

	if(!length(turfs))
		return

	if(!near_station && turfs[1].z == Z_LEVEL_STATION)
		near_station = new(cs=10)
		near_station.update_cooldown = INFINITY
		var/list/station_turfs = null
		var/list/station_areas = get_accessible_station_areas()
		for(var/AR in station_areas)
			station_turfs = get_area_turfs(station_areas[AR], 1)
			if(length(station_turfs))
				for(var/j in 1 to 5)
					near_station.add_target(pick(station_turfs))
		station_turfs = get_area_turfs(/area/listeningpost, 1)
		if(length(station_turfs))
			for(var/j in 1 to 5)
				near_station.add_target(pick(station_turfs))

	if(!lava_noise)
		src.lava_noise = rustg_cnoise_generate("[src.lava_percent]", "5", "6", "3", "[world.maxx]", "[world.maxy]")

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/lava_value
		var/index = gen_turf.x * world.maxx + gen_turf.y
		if(index <= length(lava_noise))
			lava_value = text2num(lava_noise[gen_turf.x * world.maxx + gen_turf.y])
		var/drift_x = (gen_turf.x + rand(-LAVA_MOON_BIOME_RANDOM_SQUARE_DRIFT, LAVA_MOON_BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-LAVA_MOON_BIOME_RANDOM_SQUARE_DRIFT, LAVA_MOON_BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/height = text2num(rustg_noise_get_at_coordinates("[height_seed]", "[drift_x]", "[drift_y]"))

		var/datum/biome/selected_biome
		if(length(near_station?.get_nearby(gen_turf, range=6)))
			selected_biome = /datum/biome/lavamoon
		else if(flags & MAPGEN_FLOOR_ONLY)
			selected_biome = /datum/biome/lavamoon
		else if(lava_value)
			selected_biome = /datum/biome/lavamoon/lava
		else if(height <= 0.85) //If height is less than 0.85, we generate biomes based on the heat and humidity of the area.
			var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]"))
			var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))
			var/heat_level //Type of heat zone we're in LOW-MEDIUM-HIGH
			var/humidity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH

			switch(heat)
				if(0 to 0.15)
					heat_level = BIOME_LOW_HEAT
				if(0.15 to 0.5)
					heat_level = BIOME_LOWMEDIUM_HEAT
				if(0.5 to 0.75)
					heat_level = BIOME_HIGHMEDIUM_HEAT
				if(0.75 to 1)
					heat_level = BIOME_HIGH_HEAT
			switch(humidity)
				if(0 to 0.20)
					humidity_level = BIOME_LOW_HUMIDITY
				if(0.20 to 0.5)
					humidity_level = BIOME_LOWMEDIUM_HUMIDITY
				if(0.5 to 0.75)
					humidity_level = BIOME_HIGHMEDIUM_HUMIDITY
				if(0.75 to 1)
					humidity_level = BIOME_HIGH_HUMIDITY
			selected_biome = possible_biomes[heat_level][humidity_level]
		else //Over 0.85; Minable!
			selected_biome = /datum/biome/lavamoon/minable
		selected_biome = biomes[selected_biome]
		selected_biome.generate_turf(gen_turf, flags)

		src.lag_check()

	for(var/turf/unsimulated/floor/lava/L in turfs)
		L.update_neighbors()

		src.lag_check()

///for the mapgen mountains, temp until we get something better
/turf/simulated/wall/auto/asteroid/mountain/lavamoon
	name = "silicate wall"
	desc = "You're inside a matrix of silicate. Neat."
	fullbright = 0
	replace_type = /turf/unsimulated/floor/plating/asteroid/lavamoon
	color = "#998E4E"
	stone_color = "#998E4E"
	carbon_dioxide = 20
	temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST-1

	destroy_asteroid(var/dropOre=1)
		if(src.ore || prob(5)) // provide less rock
			default_ore = /datum/material/crystal/gemstone
		. = ..()

/turf/unsimulated/floor/plating/asteroid/lavamoon
	name = "floor"
	desc = "A tunnel through the silicate. This doesn't seem to be water ice..."
	carbon_dioxide = 20
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST-1
	fullbright = 0
