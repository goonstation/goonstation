//the random offset applied to square coordinates, causes intermingling at biome borders
 #define MARS_BIOME_RANDOM_SQUARE_DRIFT 2


/datum/biome/mars
	turf_type = /turf/unsimulated/floor/setpieces/martian

	flora_types = list(/obj/machinery/light/beacon=10)
	flora_density = 2
	minimum_flora_distance = 14

/datum/biome/mars/duststorm
	turf_type = /turf/unsimulated/floor/setpieces/martian/station_duststorm

/datum/biome/mars/martian_area
	fauna_types = list(/mob/living/critter/martian=50, /mob/living/critter/martian/soldier=10, /mob/living/critter/martian/mutant=1, /mob/living/critter/martian/initiate=5, /mob/living/critter/martian/warrior=10)
	fauna_density = 1
	minimum_fauna_distance = 3

/datum/biome/mars/martian_area/duststorm
	turf_type = /turf/unsimulated/floor/setpieces/martian/station_duststorm

/datum/biome/mars/martian_rock
	turf_type = /turf/unsimulated/wall/setpieces/martian/auto

/datum/biome/mars/minable
	turf_type =  /turf/simulated/wall/auto/asteroid/mars

/datum/map_generator/mars_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mars/martian_area,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mars/martian_rock,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mars,
		BIOME_HIGH_HUMIDITY = /datum/biome/mars
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mars,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mars/martian_rock,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mars/martian_rock,
		BIOME_HIGH_HUMIDITY = /datum/biome/mars
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mars,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mars,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mars/martian_rock,
		BIOME_HIGH_HUMIDITY = /datum/biome/mars
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mars,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mars,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mars,
		BIOME_HIGH_HUMIDITY = /datum/biome/mars/martian_area
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65
	var/floor_only_biome = /datum/biome/mars
	wall_turf_type	= /turf/simulated/wall/auto/asteroid/mars
	floor_turf_type = /turf/unsimulated/floor/plating/asteroid/mars

/datum/map_generator/mars_generator/duststorm
	///2D list of all biomes based on heat and humidity combos.
	possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mars/martian_area/duststorm,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mars/martian_rock,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mars/duststorm,
		BIOME_HIGH_HUMIDITY = /datum/biome/mars/duststorm
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mars/duststorm,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mars/martian_rock,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mars/martian_rock,
		BIOME_HIGH_HUMIDITY = /datum/biome/mars/duststorm
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mars/duststorm,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mars/duststorm,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mars/martian_rock,
		BIOME_HIGH_HUMIDITY = /datum/biome/mars/duststorm
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mars/duststorm,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mars/duststorm,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mars/duststorm,
		BIOME_HIGH_HUMIDITY = /datum/biome/mars/martian_area/duststorm
		)
	)
	floor_only_biome = /datum/biome/mars/duststorm
	floor_turf_type = /turf/unsimulated/floor/setpieces/martian/station_duststorm

 ///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/mars_generator/generate_terrain(list/turfs, reuse_seed, flags)
	. = ..()
	var/height_seed = seeds[1]
	var/humidity_seed = seeds[2]
	var/heat_seed = seeds[3]

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/drift_x = (gen_turf.x + rand(-MARS_BIOME_RANDOM_SQUARE_DRIFT, MARS_BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-MARS_BIOME_RANDOM_SQUARE_DRIFT, MARS_BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/height = text2num(rustg_noise_get_at_coordinates("[height_seed]", "[drift_x]", "[drift_y]"))

		var/datum/biome/selected_biome
		if(flags & MAPGEN_FLOOR_ONLY)
			selected_biome = floor_only_biome
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
			selected_biome = /datum/biome/mars/minable
		selected_biome = biomes[selected_biome]
		selected_biome.generate_turf(gen_turf, flags)

		src.lag_check(flags)

/turf/unsimulated/floor/setpieces/martian/station_duststorm

	New()
		src.rocks = prob(10)
		..()

	Entered(atom/movable/O)
		..()
		if (ishuman(O))
			if(!ON_COOLDOWN(O,"mars_duststorm", rand(5 SECONDS, 15 SECONDS)))
				var/mob/living/jerk = O
				if (!isdead(jerk))
					if((istype(jerk:wear_suit, /obj/item/clothing/suit/armor/mars))&&(istype(jerk:head, /obj/item/clothing/head/helmet/mars))) return
					step(jerk,EAST)
					if(jerk.protected_from_space()) // Be kind around station...
						return
					random_brute_damage(jerk, 20, checkarmor=TRUE) // Allow armor to resist
					jerk.do_disorient(stamina_damage = 100, knockdown = 3 SECONDS, disorient = 5 SECOND)
					if(prob(50))
						playsound(src, 'sound/impact_sounds/Flesh_Stab_2.ogg', 50, TRUE)
						boutput(jerk, pick("Dust gets caught in your eyes!","The wind blows you off course!","Debris pierces through your skin!"))

/turf/unsimulated/floor/plating/asteroid/mars
	stone_color = "#c96433"
	color = "#c96433"
	carbon_dioxide = 500
	nitrogen = 0
	oxygen = 0
	temperature = 100
	fullbright = 0

 ///for the mapgen mountains, temp until we get something better
/turf/simulated/wall/auto/asteroid/mars
	name = "martian rock"
	desc = "Hey, it's not red at all!"
	fullbright = 0
	color = "#c96433"
	stone_color = "#c96433"
	replace_type = /turf/unsimulated/floor/plating/asteroid/mars

	destroy_asteroid(var/dropOre=1)
		var/image/ambient_light = src.GetOverlayImage("ambient")
		var/image/weather = src.GetOverlayImage("weather")
		..()
		src.UpdateIcon()
		for (var/turf/simulated/wall/auto/asteroid/A in orange(1,src))
			A.UpdateIcon()
		src.UpdateOverlays(ambient_light, "ambient")
		src.UpdateOverlays(weather, "weather")

/turf/unsimulated/wall/setpieces/martian/auto
	plane = PLANE_FLOOR

	New()
		..()
		SPAWN(3 SECONDS)
			if(istype(src))
				src.UpdateIcon()

	update_icon()
		var/dir_sum
		// If there is rhyme or reason to the order of mars-c I can't find it...
		var/list/lookup = list("1"=list("mars-s",1),
							   "2"=list("mars-s",2),
							   "4"=list("mars-s",4),
							   "5"=list("mars-c",2),
							   "6"=list("mars-c",1),
							   "8"=list("mars-s",8),
							   "9"=list("mars-c",6),
							   "10"=list("mars-c",4))
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if (T && (!istype(T, src.type)))
				dir_sum |= dir
		if(dir_sum in alldirs)
			var/lookup_value = lookup["[dir_sum]"]
			src.icon_state = lookup_value[1]
			src.dir = lookup_value[2]
			return
		else if(dir_sum)
			clear_and_update_neighbors()
			return

	proc/clear_and_update_neighbors()
		var/list/turf/neighbors = list()
		for(var/direction in cardinal)
			neighbors += get_step(src, direction)
		src.ReplaceWith(/turf/unsimulated/floor/setpieces/martian/station_duststorm, force=TRUE)
		for(var/turf/unsimulated/wall/setpieces/martian/auto/cliff in neighbors)
			cliff.UpdateIcon()

