/datum/abilityHolder/critter/flockdrone
	usesPoints = TRUE

	New()
		. = ..()
		if (!istype(owner, /mob/living/critter/flock/drone))
			stack_trace("Flockdrone abilityHolder initialized on non-flockdrone [identify_object(owner)]")

	onAbilityStat()
		..()
		. = list()
		.["Resources:"] = src.points

	proc/updateResources(resources)
		src.points = resources
		src.updateText(0, src.x_occupied, src.y_occupied)
