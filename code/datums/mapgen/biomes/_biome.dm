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

///This proc handles the creation of a turf of a specific biome type
/datum/biome/proc/generate_turf(var/turf/gen_turf)
	gen_turf.ReplaceWith(turf_type)
	if(length(fauna_types) && prob(fauna_density))
		var/mob/fauna = weighted_pick(fauna_types)
		new fauna(gen_turf)

	if(length(flora_types) && prob(flora_density))
		var/obj/structure/flora = weighted_pick(flora_types)
		new flora(gen_turf)

/datum/biome/mudlands
	turf_type = /turf/unsimulated/floor/auto/dirt
	flora_types = list(/obj/stone/random = 100, /obj/decal/fakeobjects/smallrocks = 100)
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

/datum/biome/mountain
	turf_type = /turf/simulated/wall/asteroid/mountain
