///This datum handles the transitioning from a turf to a specific biome, and handles spawning decorative structures and mobs.
/datum/biome
	///Type of turf this biome creates
	var/turf_type
	///Chance of having a structure from the flora types list spawn
	var/flora_density = 0
	var/minimum_flora_distance = 0
	///Chance of having a mob from the fauna types list spawn
	var/fauna_density = 0
	var/minimum_fauna_distance = 0
	///list of type paths of objects that can be spawned when the turf spawns flora. Syntax: list(type = weight)
	var/list/flora_types = list(/obj/tree = 100)
	///list of type paths of mobs that can be spawned when the turf spawns fauna. Syntax: list(type = weight)
	var/list/fauna_types = list()

	var/datum/spatial_hashmap/manual/fauna_hashmap
	var/datum/spatial_hashmap/manual/flora_hashmap


var/list/area/blacklist_flora_gen = list(/area/shuttle, /area/mining)

/datum/biome/New()
	. = ..()
	if(minimum_fauna_distance)
		fauna_hashmap = new(cs=minimum_fauna_distance)
		fauna_hashmap.update_cooldown = INFINITY
	if(minimum_flora_distance)
		flora_hashmap = new(cs=minimum_flora_distance)
		flora_hashmap.update_cooldown = INFINITY

///This proc handles the creation of a turf of a specific biome type
/datum/biome/proc/generate_turf(var/turf/gen_turf, flags=0)
	gen_turf.ReplaceWith(src.turf_type, keep_old_material=FALSE, handle_dir=FALSE)

	if( flags & MAPGEN_ALLOW_VEHICLES )
		gen_turf.allows_vehicles = TRUE

	if((flags & MAPGEN_IGNORE_FAUNA) == 0)
		if(length(fauna_types) && prob(fauna_density))
			if(!fauna_hashmap || !length(fauna_hashmap.get_nearby(gen_turf, src.minimum_fauna_distance)))
				var/mob/fauna = weighted_pick(fauna_types)
				fauna = new fauna(gen_turf)
				fauna_hashmap?.add_weakref(fauna)

	// Skip areas where flora generation can be problematic due to introduction of dense anchored objects
	if((gen_turf.z == Z_LEVEL_STATION || isgenplanet(gen_turf)) && ((flags & MAPGEN_IGNORE_BUILDABLE) == 0))
		gen_turf.can_build = TRUE
		var/turf/unsimulated/T = gen_turf
		if(istype(T))
			T.can_replace_with_stuff = TRUE


		for(var/bad_area in blacklist_flora_gen)
			if(istype(gen_turf.loc, bad_area))
				return


	if((flags & MAPGEN_IGNORE_FLORA) == 0)
		if(length(flora_types) && prob(flora_density))
			if(!flora_hashmap || !length(flora_hashmap.get_nearby(gen_turf, src.minimum_flora_distance)))
				var/obj/flora = weighted_pick(flora_types)
				flora = new flora(gen_turf)
				flora_hashmap?.add_weakref(flora)

	var/area/A = get_area(gen_turf)
	A.store_biome(gen_turf, src.type)

/datum/biome/mudlands
	turf_type = /turf/unsimulated/floor/auto/dirt
	flora_types = list(/obj/stone/random = 100, /obj/fakeobject/smallrocks = 100)
	flora_density = 3

/datum/biome/desert
	turf_type = /turf/unsimulated/floor/auto/sand
	flora_types = list(/obj/stone/random = 100, /obj/fakeobject/smallrocks = 100)
	flora_density = 1

	fauna_types = list(/mob/living/critter/small_animal/scorpion=15, /mob/living/critter/small_animal/rattlesnake=1, /mob/living/critter/small_animal/armadillo=1, /mob/living/critter/small_animal/wasp=5)
	fauna_density = 0.2
	minimum_fauna_distance = 5

/datum/biome/desert/rough
	turf_type = /turf/unsimulated/floor/auto/sand/rough
	flora_density = 5

/datum/biome/snow
	turf_type = /turf/unsimulated/floor/auto/snow
	flora_types = list(/obj/stone/snow/random = 100, /obj/fakeobject/smallrocks = 100, /obj/shrub/snow/random{last_use=INFINITY} = 100, /obj/stone/random = 5)
	flora_density = 2

	fauna_types = list(/mob/living/critter/small_animal/bunny/hare=10)
	fauna_density = 0

/datum/biome/snow/rocky
	turf_type = /turf/unsimulated/floor/auto/snow
	flora_types = list(/obj/stone/snow/random = 100, /obj/stone/random = 20, /obj/fakeobject/smallrocks = 20)
	flora_density = 5

	fauna_types = list(/mob/living/critter/small_animal/bunny/hare=5, /mob/living/critter/small_animal/goat=1)
	fauna_density = 0.05

/datum/biome/snow/forest
	flora_types = list(/obj/tree/snow_random = 50, /obj/shrub/snow/random{last_use=INFINITY} = 100, /obj/stone/snow/random = 10, /obj/fakeobject/smallrocks = 5)
	flora_density = 20

	fauna_density = 0.1
	minimum_fauna_distance = 10

/datum/biome/snow/forest/thick
	flora_density = 30

	fauna_types = list(/mob/living/critter/small_animal/bunny/hare=20, /mob/living/critter/small_animal/jackalope=1, /mob/living/critter/small_animal/wolf=1)
	fauna_density = 0.2
	minimum_fauna_distance = 10

/datum/biome/snow/rough
	turf_type = /turf/unsimulated/floor/auto/snow/rough
	flora_types = list(/obj/stone/snow/random = 100, /obj/fakeobject/smallrocks = 50, /obj/stone/random = 5)
	flora_density = 3

	fauna_types = list(/mob/living/critter/small_animal/bunny/hare=10, /mob/living/critter/small_animal/goat=1, /mob/living/critter/small_animal/wolf=1)
	fauna_density = 0.2
	minimum_fauna_distance = 20

/datum/biome/plains
	turf_type = /turf/unsimulated/floor/auto/grass/swamp_grass
	flora_types = list(/obj/tree/elm_random = 50, /obj/shrub/random{last_use=INFINITY} = 100, /obj/stone/random = 100, /obj/fakeobject/smallrocks = 100)
	flora_density = 15

/datum/biome/forest
	turf_type = /turf/unsimulated/floor/grasslush/thin
	flora_types = list(/obj/tree{layer = EFFECTS_LAYER_UNDER_1} = 55, /obj/tree/elm_random=1, /obj/shrub/random{last_use=INFINITY} = 50)
	flora_density = 20
	minimum_flora_distance = 2

	fauna_types = list(/mob/living/critter/small_animal/firefly/ai_controlled = 5, /mob/living/critter/small_animal/firefly/pyre/ai_controlled = 1, /mob/living/critter/small_animal/firefly/lightning/ai_controlled = 1, /mob/living/critter/bear=5, /mob/living/critter/small_animal/bird/crow=5)
	fauna_density = 0.2

/datum/biome/forest/dense
	turf_type = /turf/unsimulated/floor/grasslush/thinner
	flora_types = list(/obj/tree{layer = EFFECTS_LAYER_UNDER_1} = 75, /obj/tree/elm_random=1, /obj/shrub/random{last_use=INFINITY} = 5, /obj/machinery/plantpot/bareplant/tree = 5)
	flora_density = 35
	minimum_flora_distance = 1

	fauna_types = list(/mob/living/critter/small_animal/dragonfly/ai_controlled = 20, /mob/living/critter/bear=1, /mob/living/critter/small_animal/frog=5, /mob/living/critter/small_animal/bird/owl=5)

/datum/biome/forest/thin
	turf_type = /turf/unsimulated/floor/grasslush
	flora_types = list(/obj/tree{layer = EFFECTS_LAYER_UNDER_1} = 5, /obj/tree/elm_random=5, /obj/shrub/random{last_use=INFINITY} = 150, /obj/machinery/plantpot/bareplant/tree = 5, /obj/machinery/plantpot/bareplant/flower = 50)
	flora_density = 10
	minimum_flora_distance = 3

	fauna_types = list(/mob/living/critter/small_animal/mouse=5, /mob/living/critter/small_animal/pig=1, /mob/living/critter/small_animal/snake=1, /mob/living/critter/small_animal/bird/crow=1)
	fauna_density = 0.5

/datum/biome/forest/clearing
	turf_type = /turf/unsimulated/floor/grasslush
	flora_types = list(/obj/shrub/random{last_use=INFINITY} = 150, /obj/machinery/plantpot/bareplant/flower = 50)
	flora_density = 5
	minimum_flora_distance = 4

	fauna_types = list(/mob/living/critter/small_animal/mouse=10, /mob/living/critter/small_animal/snake=1)

/datum/biome/jungle
	turf_type = /turf/unsimulated/floor/auto/grass/leafy
	flora_types = list(/obj/tree/elm_random = 75, /obj/shrub/random{last_use=INFINITY} = 150, /obj/stone/random = 10, /obj/fakeobject/smallrocks = 10, /obj/machinery/plantpot/bareplant/swamp_flora = 1)
	flora_density = 40

	fauna_types = list(/mob/living/critter/small_animal/dragonfly/ai_controlled = 50, /mob/living/critter/small_animal/firefly/ai_controlled = 10, /mob/living/critter/small_animal/firefly/lightning/ai_controlled = 2, /mob/living/critter/small_animal/firefly/pyre/ai_controlled = 1, /mob/living/critter/small_animal/iguana = 3, /mob/living/critter/small_animal/frog=1)
	fauna_density = 0.2

/datum/biome/jungle/deep
	flora_density = 65
	fauna_density = 0.8

/datum/biome/wasteland
	turf_type = /turf/unsimulated/greek/beach

/datum/biome/water
	turf_type = /turf/unsimulated/floor/auto/swamp

/datum/biome/water/swamp
	fauna_types = list(/mob/living/critter/small_animal/dragonfly/ai_controlled=30, /mob/living/critter/small_animal/firefly/lightning/ai_controlled=1, /mob/living/critter/small_animal/firefly/pyre/ai_controlled=1, /mob/living/critter/small_animal/frog=5)
	fauna_density = 0.5

/datum/biome/water/clear
	turf_type = /turf/unsimulated/floor/auto/water

/datum/biome/water/ice
	turf_type = /turf/unsimulated/floor/auto/water/ice

	fauna_types = list(/mob/living/critter/small_animal/seal_arctic/baby=1, /mob/living/critter/small_animal/seal_arctic/adult=5)
	fauna_density = 0.2

/datum/biome/water/ice/rough
	turf_type = /turf/unsimulated/floor/auto/water/ice/rough

	fauna_density = 0.5


/datum/biome/mountain
	turf_type = /turf/simulated/wall/auto/asteroid/mountain

/datum/biome/mountain/desert
	turf_type = /turf/simulated/wall/auto/asteroid/mountain/desert

/datum/biome/mountain/cave
	turf_type = /turf/simulated/wall/auto/asteroid/mountain/cave

/datum/biome/adventure/cave
	turf_type = /turf/unsimulated/floor/cave

/datum/biome/adventure/cave/wall
	turf_type = /turf/unsimulated/wall/auto/adventure/cave

