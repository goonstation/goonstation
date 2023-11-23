/datum/healthHolder/toxin
	name = "toxic"
	associated_damage_type = "toxin"

	maximum_value = 0
	value = 0
	depletion_threshold = -200

	on_life()
		if (!holder.does_it_metabolize())
			return
		if (holder.bodytemperature < T0C - 45 && holder.reagents.has_reagent("cryoxadone"))
			HealDamage(3)

	TakeDamage(amt, bypass_multiplier = 0)
		var/resist_toxic = holder.bioHolder?.HasEffect("resist_toxic")
		if(resist_toxic && amt > 0)
			if(resist_toxic > 1)
				src.value = maximum_value
				health_update_queue |= holder
				return
			else
				amt *= 0.33
		. = ..(amt, bypass_multiplier)
