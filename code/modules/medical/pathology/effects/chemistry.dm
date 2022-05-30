// Effects related to reagent production go here

datum/pathogeneffects/neutral/brewery
	name = "Auto-Brewery"
	desc = "The pathogen aids the host body in metabolizing chemicals into ethanol."

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		var/times = 1
		if (origin.stage > 3)
			times++
		if (origin.stage > 4)
			times++
		var/met = 0
		for (var/rid in M.reagents.reagent_list)
			var/datum/reagent/R = M.reagents.reagent_list[rid]
			if (!(rid == "ethanol" || istype(R, /datum/reagent/fooddrink/alcoholic)))
				met = 1
				for (var/i = 1, i <= times, i++)
					if (R) //Wire: Fix for Cannot execute null.on mob life().
						R.on_mob_life()
					if (!R || R.disposed)
						break
				if (R && !R.disposed)
					var/amt = R.depletion_rate * times
					M.reagents.remove_reagent(rid, amt)
					M.reagents.add_reagent("ethanol", amt)
		if (met)
			M.reagents.update_total()

	react_to(var/R, var/zoom)
		if (!(R == "ethanol"))
			return "The pathogen appears to have entirely metabolized all chemical agents in the dish into... ethanol."

	may_react_to()
		return "The pathogen appears to react with anything but a pure intoxicant."
