/datum/abilityHolder/floor_goblin
	usesPoints = 1
	pointName = "Shoes stolen"
	regenRate = 0
	tabName = "Floor Goblin"
	var/shoes_stolen = 0

	onAbilityStat()
		..()
		.= list()
		.["Shoes stolen:"] = points
		return
