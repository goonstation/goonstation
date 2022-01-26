///This datum handles the transitioning from a turf to a specific biome, and handles spawning decorative structures and mobs.
/datum/biome
	///Type of turf this biome creates
	var/turf_type
	///Chance of having a structure from the flora types list spawn
	var/flora_density = 0
	///Chance of having a mob from the fauna types list spawn
	var/fauna_density = 0
	///list of type paths of objects that can be spawned when the turf spawns flora. Syntax: list(type = weight)
	var/list/flora_types = list(/obj/tree1 = 100)
	///list of type paths of mobs that can be spawned when the turf spawns fauna. Syntax: list(type = weight)
	var/list/fauna_types = list()

var/list/area/blacklist_flora_gen = list(/area/shuttle, /area/mining)

///This proc handles the creation of a turf of a specific biome type
/datum/biome/proc/generate_turf(var/turf/gen_turf)
	gen_turf.ReplaceWith(turf_type)

	if(length(fauna_types) && prob(fauna_density))
		var/mob/fauna = weighted_pick(fauna_types)
		new fauna(gen_turf)

	// Skip areas where flora generation can be problematic due to introduction of dense anchored objects
	if(gen_turf.z == Z_LEVEL_STATION)
		for(var/bad_area in blacklist_flora_gen)
			if(istype(gen_turf.loc, bad_area))
				return

	if(length(flora_types) && prob(flora_density))
		var/obj/structure/flora = weighted_pick(flora_types)
		new flora(gen_turf)

/datum/biome/mudlands
	turf_type = /turf/unsimulated/floor/auto/dirt
	flora_types = list(/obj/stone/random = 100, /obj/decal/fakeobjects/smallrocks = 100)
	flora_density = 3

/datum/biome/desert
	turf_type = /turf/unsimulated/floor/auto/sand
	flora_types = list(/obj/stone/random = 100, /obj/decal/fakeobjects/smallrocks = 100)
	flora_density = 1

/datum/biome/snow
	turf_type = /turf/unsimulated/floor/auto/snow
	flora_types = list(/obj/stone/snow/random = 100, /obj/decal/fakeobjects/smallrocks = 100, /obj/shrub/snow/random = 100, /obj/stone/random = 5)
	flora_density = 2

/datum/biome/snow/rocky
	turf_type = /turf/unsimulated/floor/auto/snow
	flora_types = list(/obj/stone/snow/random = 100, /obj/stone/random = 20, /obj/decal/fakeobjects/smallrocks = 20)
	flora_density = 5

/datum/biome/snow/forest
	flora_types = list(/obj/tree1/snow_random = 50, /obj/shrub/snow/random = 100, /obj/stone/snow/random = 10, /obj/decal/fakeobjects/smallrocks = 5)
	flora_density = 20

/datum/biome/snow/forest/thick
	flora_density = 30

/datum/biome/snow/rough
	turf_type = /turf/unsimulated/floor/auto/snow/rough
	flora_types = list(/obj/stone/snow/random = 100, /obj/decal/fakeobjects/smallrocks = 50, /obj/stone/random = 5)
	flora_density = 3

/datum/biome/plains
	turf_type = /turf/unsimulated/floor/auto/grass/swamp_grass
	flora_types = list(/obj/tree1/elm_random = 50, /obj/shrub/random = 100, /obj/stone/random = 100, /obj/decal/fakeobjects/smallrocks = 100)
	flora_density = 15

/datum/biome/jungle
	turf_type = /turf/unsimulated/floor/auto/grass/leafy
	flora_types = list(/obj/tree1/elm_random = 50, /obj/shrub/random = 100, /obj/stone/random = 10, /obj/decal/fakeobjects/smallrocks = 10)
	flora_density = 40

/datum/biome/jungle/deep
	flora_density = 65

/datum/biome/wasteland
	turf_type = /turf/unsimulated/greek/beach

/datum/biome/water
	turf_type = /turf/unsimulated/floor/auto/swamp

/datum/biome/water/clear
	turf_type = /turf/unsimulated/floor/auto/water

/datum/biome/water/ice
	turf_type = /turf/unsimulated/floor/auto/water/ice

/datum/biome/water/ice/rough
	turf_type = /turf/unsimulated/floor/auto/water/ice/rough

/datum/biome/mountain
	turf_type = /turf/simulated/wall/asteroid/mountain
