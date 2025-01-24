/obj/mapping_helper/plant
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "plant"
	var/plant_type = null
	var/mutation_type = null
	var/plant_density = FALSE

/obj/mapping_helper/plant/setup()
	if (..())
		return
	var/turf/T = get_turf(src)
	if (!T)
		return TRUE
	var/datum/component/arable/component = T.AddComponent(/datum/component/arable/single_use)
	var/obj/item/seed/seed = new
	seed.dont_mutate = TRUE
	var/datum/plant/plant = HY_get_species_from_path(src.plant_type)
	var/datum/plantmutation/mutation = null
	for (var/datum/plantmutation/possible_mutation in plant.mutations)
		if (possible_mutation.type == src.mutation_type)
			mutation = possible_mutation
			break
	seed.generic_seed_setup(plant)
	seed.plantgenes.mutation = mutation
	component.plant_seed(T, seed, null)
	component.P.density = src.plant_density
	component.P.growth = seed.planttype.harvtime //set it to just matured
	SPAWN(1) //look someone else did SPAWN(0) elsewhere in the chain and I just need this to work
		component.P.ProcessMachine()

/obj/mapping_helper/plant/grass
	plant_type = /datum/plant/herb/grass
