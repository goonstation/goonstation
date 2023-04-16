//the random offset applied to square coordinates, causes intermingling at biome borders
 #define VOID_BIOME_RANDOM_SQUARE_DRIFT 2

/obj/decal/floatingtiles/random
	New()
		..()
		icon_state = "floattiles[rand(1,6)]"
		dir = pick(cardinal)

/datum/biome/void
	turf_type = /turf/unsimulated/floor/void

	flora_types = list(/obj/map/light/void=1)
	flora_density = 0.7

	var/corridor_density = 0.5

	generate_turf(gen_turf, flags)
		. = ..()
		if((flags & (MAPGEN_TURF_ONLY) == 0) && prob(corridor_density))
			new/obj/map/light/void(gen_turf)
			SPAWN(5 SECONDS)
				void_corridor(get_step(gen_turf, pick(cardinal)), rand(6,10), start=TRUE)

	proc/void_corridor(turf/T, max_size=7, start=FALSE)
		if(max_size <= 0)
			return
		if(!T || T.x==1 || T.y==1 || T.x==world.maxx || T.y==world.maxy)
			return
		if(T.type != src.turf_type)
			return

		if(!start && prob(5))
			return

		var/image/ambient_light = T.GetOverlayImage("ambient")
		var/floor_path = weighted_pick(list(/turf/unsimulated/floor/plating=5, /turf/unsimulated/floor/plating/random=5, /turf/unsimulated/floor/damaged5=1, /turf/unsimulated/floor/plating/damaged2=3, /turf/unsimulated/floor/plating/damaged3=3))
		T.ReplaceWith(floor_path, force=TRUE)

		if(prob(1))
			if(prob(50))
				new/obj/decal/cleanable/blood/splatter(T)
			else
				new/obj/decal/cleanable/generic(T)

		T.UpdateOverlays(ambient_light, "ambient")

		void_corridor(get_step(T,pick(cardinal)), max_size-1)

		for(var/dir in alldirs)
			if(prob(40))
				continue
			var/turf/N = get_step(T,dir)

			if(!N || N.x==1 || N.y==1 || N.x==world.maxx || N.y==world.maxy)
				continue

			if(N.type == turf_type && !(locate(/obj/lattice) in N.contents) )
				if(prob(5))
					var/obj/decal/D = new/obj/decal/floatingtiles/random(N)
					D.dir = dir
				else
					new/obj/lattice(N)


/datum/biome/void/oddities
	flora_types = list(/obj/decal/floatingtiles/random=1, /obj/item/spook=1, /obj/map/light/void=2)
	flora_density = 1

	fauna_types = list( /obj/critter/floateye=4, /obj/item/spook=1)
	fauna_density = 0.6

	corridor_density = 0.3

/datum/biome/void/spooky
	flora_types = list(/obj/decal/floatingtiles/random=1, /obj/map/light/void=5)
	flora_density = 0.5

	fauna_types = list(/obj/item/spook=3, /mob/living/critter/aberration=1, /obj/critter/crunched=2, /obj/critter/spirit=6)
	fauna_density = 0.5

	corridor_density = 1

/datum/map_generator/void_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/void/spooky,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/void/oddities,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/void,
		BIOME_HIGH_HUMIDITY = /datum/biome/void/oddities
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/void/oddities,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/void,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/void/oddities,
		BIOME_HIGH_HUMIDITY = /datum/biome/void
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/void,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/void/oddities,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/void,
		BIOME_HIGH_HUMIDITY = /datum/biome/void/oddities
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/void/oddities,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/void,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/void/oddities,
		BIOME_HIGH_HUMIDITY = /datum/biome/void/spooky
		)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65

 ///Seeds the rust-g perlin noise with a random number.
/datum/map_generator/void_generator/generate_terrain(list/turfs, reuse_seed, flags)
	. = ..()
	var/height_seed = seeds[1]
	var/humidity_seed = seeds[2]
	var/heat_seed = seeds[3]

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/drift_x = (gen_turf.x + rand(-VOID_BIOME_RANDOM_SQUARE_DRIFT, VOID_BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-VOID_BIOME_RANDOM_SQUARE_DRIFT, VOID_BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

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
		else //Over 0.85; It's MORE VOID HAHAHAHAHA
			selected_biome = /datum/biome/void
		selected_biome = biomes[selected_biome]
		selected_biome.generate_turf(gen_turf, flags)

		if (current_state >= GAME_STATE_PLAYING)
			LAGCHECK(LAG_LOW)
		else
			LAGCHECK(LAG_HIGH)

