/datum/healthHolder/flesh_burn
	name = "burn"
	associated_damage_type = "burn"

	on_life()
		if (!holder.does_it_metabolize())
			return
		if (holder.bodytemperature < T0C - 45 && holder.reagents.has_reagent("cryoxadone"))
			HealDamage(12)
