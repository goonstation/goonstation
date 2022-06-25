/datum/abilityHolder/critter/flockdrone
	//this is jank, but we want to keep the resources stored on the drone not the abilityholder so we do this
	var/mob/living/critter/flock/drone/flockdrone
	var/resources_last = -1

	New()
		. = ..()
		if (istype(owner,/mob/living/critter/flock/drone))
			flockdrone = owner
		else
			stack_trace("Flockdrone abilityHolder initialized on non-flockdrone [src] (\ref[src])")

	onAbilityStat()
		..()
		if (!flockdrone)
			return
		.= list()
		.["Resources:"] = flockdrone.resources

	onLife()
		. = ..()
		if (!flockdrone)
			return
		if (resources_last != flockdrone.resources)
			resources_last = flockdrone.resources
			src.updateText(0, src.x_occupied, src.y_occupied)
