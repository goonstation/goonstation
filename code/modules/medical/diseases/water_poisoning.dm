/datum/ailment/disease/water_poisoning
	name = "Water Poisoning"
	max_stages = 3
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	cure_desc = "Pyrosium"
	reagentcure = list("pyrosium")
	associated_reagent = "cocktail_quadruplewater"
	affected_species = ("Human, Monkey")
