// Effects related to reagent production go here
ABSTRACT_TYPE(/datum/microbioeffects/chemistry)
/datum/microbioeffects/chemistry
	name = "Chemical Effects"



//The following subdatum would allow limited chemical production for specific chems:
/**
 * Space cleaner
 * Styptic
 * Silver Sulfadizine
 * Charcoal		//Hopefully this one is blessed
 * Epinephrine
 * Mutadone
 */
//datum/microbioeffects/chemistry/...

	//On Object:
		//Check if its a reagent container
		//If yes..
		//Check its reagents
		//If it has the specific chem...
		//Produce more of it using prob(probability)
		//Stops when duration hits 0.

/datum/microbioeffects/chemistry/spacecleaner
	name = "Space Cleaner Production"
	desc = "The microbial culture produces space cleaner."

	reagent_act(var/obj/item/reagent_containers/glass/B, var/datum/microbe/origin)
		if (B.reagents.is_full())
			return
		else
			B.reagents.add_reagent("cleaner", origin.probability)
			return

	react_to(var/R, var/zoom)
		if (!(R == "water"))
			return "The microbes rapidly consume the water and excrete space cleaner."

	may_react_to()
		return "The microbes appear to produce some kind of chemical."

/datum/microbioeffects/chemistry/styptic
	name = "Styptic Powder Production"
	desc = "The microbial culture produces stypic powder."

	reagent_act(var/obj/item/reagent_containers/glass/B, var/datum/microbe/origin)
		if (B.reagents.is_full())
			return
		else
			B.reagents.add_reagent("styptic_powder", origin.probability)
			return

	react_to(var/R, var/zoom)
		if (!(R == "carbon"))
			return "The microbes rapidly consume the carbon sample and excrete styptic powder."

	may_react_to()
		return "The microbes appear to produce some kind of chemical."

/datum/microbioeffects/chemistry/sulfadizine
	name = "Silver Sulfadizine Production"
	desc = "The microbial culture produces silver sulfadizine."

	reagent_act(var/obj/item/reagent_containers/glass/B, var/datum/microbe/origin)
		if (B.reagents.is_full())
			return
		else
			B.reagents.add_reagent("silver_sulfadizine", origin.probability)
			return

	react_to(var/R, var/zoom)
		if (!(R == "carbon"))
			return "The microbes rapidly consume the carbon sample and excrete silver sulfadizine."

	may_react_to()
		return "The microbes appear to produce some kind of chemical."

/datum/microbioeffects/chemistry/charcoal
	name = "Charcoal Production"
	desc = "The microbial culture produces charcoal."

	reagent_act(var/obj/item/reagent_containers/glass/B, var/datum/microbe/origin)
		if (B.reagents.is_full())
			return
		else
			B.reagents.add_reagent("charcoal", origin.probability)
			return

	react_to(var/R, var/zoom)
		if (!(R == "carbon"))
			return "The microbes attach to the carbon sample and form spires of charcoal."

	may_react_to()
		return "The microbes appear to produce some kind of chemical."

/datum/microbioeffects/chemistry/epinephrine
	name = "Epinepherine Production"
	desc = "The microbial culture produces epinepherine."

	reagent_act(var/obj/item/reagent_containers/glass/B, var/datum/microbe/origin)
		if (B.reagents.is_full())
			return
		else
			B.reagents.add_reagent("epinepherine", origin.probability)
			return

	react_to(var/R, var/zoom)
		if (!(R == "sugar"))
			return "The microbes rapidly consume the sample and excrete epinepherine."

	may_react_to()
		return "The microbes appear to produce some kind of chemical."

/datum/microbioeffects/chemistry/mutadone
	name = "Mutadone Production"
	desc = "The microbial culture produces mutadone."

	reagent_act(var/obj/item/reagent_containers/glass/B, var/datum/microbe/origin)
		if (B.reagents.is_full())
			return
		else
			B.reagents.add_reagent("mutadone", origin.probability)
			return

	react_to(var/R, var/zoom)
		if (!(R == "carbon"))
			return "The microbes rapidly consume the carbon sample and excrete mutadone."

	may_react_to()
		return "The microbes appear to produce some kind of chemical."

/*datum/pathogeneffects/chemistry/ethanol
	name = "Auto-Brewery"
	desc = "The pathogen aids the host body in metabolizing chemicals into ethanol."

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		var/met = 0
		for (var/rid in M.reagents.reagent_list)
			var/datum/reagent/R = M.reagents.reagent_list[rid]
			if (!(rid == "ethanol" || istype(R, /datum/reagent/fooddrink/alcoholic)))
				met = 1
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
*/
/*
/datum/microbioeffects/chemistry/doubler
	name = "Chemical Production"
	desc = "The microbes appear to generate ethanol."

	reagent_act(var/obj/item/reagent_containers/glass/B, var/datum/microbe/origin)
		B.reagents.add_reagent("ethanol", 1)
		B.reagents.update_total()

	onadd(var/datum/microbe/origin)
		origin.effectdata += "doubler"

	react_to(var/R, var/zoom)
		if (!(R == "ethanol"))
			return "The pathogen appears to have entirely metabolized all chemical agents in the dish into... ethanol."

	may_react_to()
		return "The pathogen appears to react with anything but a pure intoxicant."

*/
