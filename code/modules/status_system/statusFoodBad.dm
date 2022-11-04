
/datum/statusEffect/simpledot/foodTox
	id = "food_damage_tox"
	name = "Food DoT (Toxin+)"
	icon_state = "foodbad"
	exclusiveGroup = "Food"
	damage_tox = 0.5 // 15 tox damage
	maxDuration = 10 MINUTES
	unique = 1
	tickSpacing = 20

	small
		name = "Food DoT (Toxin)"
		id = "food_damage_tox_small"
		damage_tox = 0.25 // 7.5 tox damage

	big
		name = "Food DoT (Toxin++)"
		id = "food_damage_tox_big"
		damage_tox = 1 // 30 tox damage

	getTooltip()
		. = "Dealing [damage_tox] toxin damage every [tickSpacing/(1 SECOND)] sec."

	getChefHint()
		. = "Poisons the consumer, dealing [damage_tox] toxin damage every [tickSpacing/(1 SECOND)] sec."
