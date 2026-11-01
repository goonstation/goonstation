/datum/abilityHolder/space_phoenix
	usesPoints = FALSE
	regenRate = FALSE

	var/stored_critter_count = 0
	var/stored_human_count = 0

	onAbilityStat()
		. = ..()
		. = list()
		.["Critters:"] = src.stored_critter_count
		.["Humans:"] = src.stored_human_count
