//a parent for plant-based mob-critters. This one handles stuff like setting up plantgenes, species, and contributers
// Also, this is the type stuff like plant-poisons and botanic scanner will refer to.

/mob/living/critter/plant
	var/datum/plant/planttype = null //! saves the plattype the critter came from. Whenever someone wants a critter to replant itself :)
	var/datum/plantgenes/plantgenes = null //! saves the plantgenes of the critter. Important for seed creation as well as scaling with plant attributes
	var/generation = 0 //! For genetics tracking.
	var/growers = list() //! This contains people who contributed to the plant. For AI purposes

	New()
		if(ispath(src.planttype))
			var/datum/plant/species = HY_get_species_from_path(src.planttype, src)
			if (species)
				src.planttype = species
		src.plantgenes = new /datum/plantgenes(src)
		..()

	proc/HY_set_species(var/datum/plant/species)
		if (species)
			src.planttype = species
		else
			if (ispath(src.planttype))
				src.planttype = new src.planttype(src)
			else
				qdel(src)
				return

	proc/HYPsetup_dna(var/datum/plantgenes/DNA, var/percent_health_on_spawn = 100)
		/// This proc gets called after the critter is created on-harvest. Use this one to apply any baseline-scaling, like health, to the critter with plant stats
		// percent_health_on_spawn gets passed by the plantpot.
		if (percent_health_on_spawn < 1)
			percent_health_on_spawn = 1
		for (var/T in healthlist)
			var/datum/healthHolder/HB = healthlist[T]
			var/reduced_health = clamp(round(HB.maximum_value * percent_health_on_spawn / 100), 1, HB.maximum_value)
			HB.value = reduced_health
			HB.last_value = reduced_health


	disposing()
		src.plantgenes = null
		..()
