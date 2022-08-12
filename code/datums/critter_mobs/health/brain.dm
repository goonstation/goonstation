/datum/healthHolder/brain
	name = "brain"
	associated_damage_type = "brain"
	maximum_value = 120
	minimum_value = 0
	value = 120
	depletion_threshold = 0
	count_in_total = 0

	on_life()
		if (!holder.does_it_metabolize())
			return
		if (holder.reagents.has_reagent("mannitol"))
			HealDamage(3)


