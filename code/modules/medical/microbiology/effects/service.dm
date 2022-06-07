// Effects related to Botany, Cooking, Distilling go Here
ABSTRACT_TYPE(/datum/microbioeffects/service)
/datum/microbioeffects/service/detoxication
	name = "Detoxication"
	desc = "The pathogen aids the host body in metabolizing ethanol."

	mob_act(var/mob/M as mob, var/datum/microbe/origin)
		var/times = 1
		var/met = 0
		for (var/rid in M.reagents.reagent_list)
			var/datum/reagent/R = M.reagents.reagent_list[rid]
			if (rid == "ethanol" || istype(R, /datum/reagent/fooddrink/alcoholic))
				met = 1
				for (var/i = 1, i <= times, i++)
					if (R) //Wire: Fix for Cannot execute null.on mob life().
						R.on_mob_life()
					if (!R || R.disposed)
						break
				if (R && !R.disposed)
					M.reagents.remove_reagent(rid, R.depletion_rate * times)
		if (met)
			M.reagents.update_total()

	react_to(var/R, var/zoom)
		if (R == "ethanol")
			return "The pathogen appears to have entirely metabolized the ethanol."

	may_react_to()
		return "The pathogen appears to react with a pure intoxicant."


//datum/microbioeffects/service/antimiasma
	//On turf (floor):
		//Define a 'durability' var
		//If miasma cloud is on the turf, remove it and reduce durability

//datum/microbioeffects/service/autodry
	//On turf (floor):
		//Define a durability var
		//Basically port over the water drain code and add a durability

//datum/microbioeffects/service/drycleaning
	//On object:
		//Define a durability var
		//If the object gets bloody (clothing), clean it and reduce durability

//datum/microbioeffects/service/breadmoonrising
	//On object:
		//Check if it is bread
		//???
		//Make bread
		//Make more bread




//This is just calomel, keeping for reference
/*datum/pathogeneffects/benevolent/metabolisis
	name = "Accelerated Metabolisis"
	desc = "The pathogen accelerates the metabolisis of all chemicals present in the host body."

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		var/times = 1
		var/met = 0
		for (var/rid in M.reagents.reagent_list)
			var/datum/reagent/R = M.reagents.reagent_list[rid]
			met = 1
			for (var/i = 1, i <= times, i++)
				if (R) //Wire: Fix for Cannot execute null.on mob life().
					R.on_mob_life()
				if (!R || R.disposed)
					break
			if (R && !R.disposed)
				M.reagents.remove_reagent(rid, R.depletion_rate * times)
		if (met)
			M.reagents.update_total()


	react_to(var/R, var/zoom)
		return "The pathogen appears to have entirely metabolized... all chemical agents in the dish."

	may_react_to()
		return "The pathogen appears to be rapidly breaking down certain materials around it."
*/
