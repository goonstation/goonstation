/datum/healthHolder/flesh_burn
	name = "burn"
	associated_damage_type = "burn"

	/*
	on_react(var/datum/reagents/R, var/method = 1, var/react_volume = null)
		if (!R || !R.total_volume)
			return
		if (!react_volume)
			react_volume = R.total_volume
		var/fract = react_volume / R.total_volume
		if (method == 1)
			var/datum/reagent/S = R.get_reagent("silver_sulfadiazine")
			if (S)
				holder.emote("scream")
				boutput(holder, "<span class='notice'>The silver sulfadiazine soothes your burns.</span>")
				HealDamage(fract * S.volume * 2)
			S = R.get_reagent("synthflesh")
			if (S)
				HealDamage(fract * S.volume * 1.5)
	*/

	on_life()
		if (!holder.does_it_metabolize())
			return
		if (holder.bodytemperature < T0C - 45 && holder.reagents.has_reagent("cryoxadone"))
			HealDamage(12)
