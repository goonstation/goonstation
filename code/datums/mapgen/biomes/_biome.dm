///This datum handles the transitioning from a turf to a specific biome, and handles spawning decorative structures and mobs.
/datum/biome
	///Type of turf this biome creates
	var/turf_type
	///Chance of having a structure from the flora types list spawn
	var/flora_density = 0
	///Chance of having a mob from the fauna types list spawn
	var/fauna_density = 0
	///list of type paths of objects that can be spawned when the turf spawns flora
	var/list/flora_types = list(/obj/tree1)
	///list of type paths of mobs that can be spawned when the turf spawns fauna
	var/list/fauna_types = list()

///This proc handles the creation of a turf of a specific biome type
/datum/biome/proc/generate_turf(var/turf/gen_turf)
	gen_turf.ReplaceWith(turf_type)
	if(length(fauna_types) && prob(fauna_density))
		var/mob/fauna = pick(fauna_types)
		new fauna(gen_turf)

	if(length(flora_types) && prob(flora_density))
		var/obj/structure/flora = pick(flora_types)
		new flora(gen_turf)

/datum/biome/mudlands
	turf_type = /turf/unsimulated/dirt
	flora_types = list(/obj/stone/random, /obj/decal/fakeobjects/smallrocks)
	flora_density = 3

/datum/biome/plains
	turf_type = /turf/unsimulated/floor/setpieces/swampgrass
	flora_types = list(/obj/tree1/elm_random, /obj/shrub/random, /obj/stone/random, /obj/decal/fakeobjects/smallrocks)
	flora_density = 15

/datum/biome/jungle
	turf_type = /turf/unsimulated/floor/grass/leafy
	flora_types = list(/obj/tree1/elm_random, /obj/shrub/random, /obj/stone/random, /obj/decal/fakeobjects/smallrocks)
	flora_density = 40

/datum/biome/jungle/deep
	flora_density = 65

/datum/biome/wasteland
	turf_type = /turf/unsimulated/greek/beach

/datum/biome/water
	turf_type = /turf/unsimulated/floor/swamp

/datum/biome/mountain
	turf_type = /turf/simulated/wall/asteroid
