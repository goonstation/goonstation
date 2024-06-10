//a parent for plant-based mob-critters. This one handles stuff like setting up plantgenes, species, and contributers
// Also, this is the type stuff like plant-poisons and botanic scanner will refer to.

/mob/living/critter/plant
	var/datum/plant/planttype = null //! saves the plattype the critter came from. Whenever someone wants a critter to replant itself :)
	var/datum/plantgenes/plantgenes = null //! saves the plantgenes of the critter. Important for seed creation as well as scaling with plant attributes
	var/generation = 0 //! For genetics tracking.
	var/list/growers = null //! This contains people who contributed to the plant. For AI purposes
	faction = list(FACTION_BOTANY)

/mob/living/critter/plant/valid_target(var/mob/living/potential_target)
	if (potential_target in src.growers) return FALSE
	if (iskudzuman(potential_target)) return FALSE
	return ..()


/mob/living/critter/plant/disposing()
	src.plantgenes = null
	..()

/mob/living/critter/plant/New()

	src.growers = list()

	if(ispath(src.planttype))
		var/datum/plant/species = HY_get_species_from_path(src.planttype, src)
		if (species)
			src.planttype = species
	src.plantgenes = new /datum/plantgenes(src)
	..()

/mob/living/critter/plant/proc/HY_set_species(var/datum/plant/species)
	if (species)
		src.planttype = species
	else
		if (ispath(src.planttype))
			src.planttype = new src.planttype(src)
		else
			qdel(src)
			return

/mob/living/critter/plant/proc/HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
	/// This proc gets called after the critter is created on-harvest. Use this one to apply any baseline-scaling, like health, to the critter with plant stats
	/// This proc needs to return the critter
	// First, we add the growing botanists to our little friend
	src.growers = src.growers | harvested_plantpot.contributors

	// We need to pass the plantgenes from the plant to our new lovely botany pet
	var/datum/plantgenes/new_genes = src.plantgenes

	// Copy the genes from the plant we're harvesting to the new piece of produce.
	HYPpassplantgenes(passed_genes,new_genes)
	src.generation = harvested_plantpot.generation
	src.planttype = HYPgenerateplanttypecopy(src, origin_plant)

	// If the plant this critter was harvested from was damaged, we damage the critter as well

	var/percent_health_on_spawn = round(harvested_plantpot.health / 10 * 100)
	if (origin_plant.starthealth > 0)
		percent_health_on_spawn = max(round(harvested_plantpot.health / origin_plant.starthealth * 100), 1)
	for (var/damage_type in src.healthlist)
		var/datum/healthHolder/manipulated_healthbar = healthlist[damage_type]
		var/reduced_health = clamp(round(manipulated_healthbar.maximum_value * percent_health_on_spawn / 100), 1, manipulated_healthbar.maximum_value)
		manipulated_healthbar.value = reduced_health
		manipulated_healthbar.last_value = reduced_health
	return src

