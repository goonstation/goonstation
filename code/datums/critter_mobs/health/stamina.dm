/datum/healthHolder/stamina
	name = "stamina"
	associated_damage_type = "stamina"
	maximum_value = 200
	minimum_value = -100
	value = 200
	depletion_threshold = -100
	count_in_total = 0

	var/regeneration_rate = 20

	on_life()
		HealDamage(regeneration_rate)

	on_deplete()
		holder.visible_message("<span class='alert'>[holder] collapses!</span>")
		holder.changeStatus("paralysis", 6 SECONDS)

	// @todo finish this
