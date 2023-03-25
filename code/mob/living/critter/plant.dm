//a parent for plant-based mob-critters. This one handles stuff like setting up plantgenes, species, and contributers
// Also, this is the type stuff like plant-poisons and botanic scanner will refer to.

/mob/living/critter/plant
	var/datum/plant/planttype = null //! saves the plattype the critter came from. Whenever someone wants a critter to replant itself :)
	var/datum/plantgenes/plantgenes = null //! saves the plantgenes of the critter. Important for seed creation as well as scaling with plant attributes
	var/generation = 0 //! For genetics tracking.
	var/growers = list() //! This contains people who contributed to the plant. For AI purposes

	proc/HY_set_species(var/datum/plant/species)
		if (species)
			src.planttype = species
		else
			if (ispath(src.planttype))
				src.planttype = new src.planttype(src)
			else
				qdel(src)
				return

	proc/Setup_DNA()

	disposing()
		src.plantgenes = null
		..()
