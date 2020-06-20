

datum/pathogeneffects/benevolent
	name = "Benevolent"
	rarity = RARITY_ABSTRACT
	beneficial = 1

datum/pathogeneffects/benevolent/mending
	name = "Wound Mending"
	desc = "Slow paced brute damage healing."
	rarity = RARITY_COMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		//if (prob(origin.stage * 5))
		M.HealDamage("All", origin.stage / 2, 0)

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			if (zoom)
				return "Microscopic damage on the synthetic flesh appears to be mended by the pathogen."

	may_react_to()
		return "The pathogen appears to have the ability to bond with organic tissue."

datum/pathogeneffects/benevolent/healing
	name = "Burn Healing"
	desc = "Slow paced burn damage healing."
	rarity = RARITY_COMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		//if (prob(origin.stage * 5))
		M.HealDamage("All", 0, origin.stage / 2)

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			if (zoom)
				return "The pathogen does not appear to mend the synthetic flesh. Perhaps something that might cause other types of injuries might help."
		if (R == "infernite")
			if (zoom)
				return "The pathogen repels the scalding hot chemical and quickly repairs any damage caused by it to organic tissue."

	may_react_to()
		return "The pathogen appears to have the ability to bond with organic tissue."

datum/pathogeneffects/benevolent/fleshrestructuring
	name = "Flesh Restructuring"
	desc = "Fast paced general healing."
	rarity = RARITY_RARE

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (prob(origin.stage * 5))
			M.HealDamage("All", origin.stage, origin.stage)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.bleeding)
					repair_bleeding_damage(M, 80, 2)
			if (prob(50))
				M.show_message("<span class='notice'>You feel your wounds closing by themselves.</span>")

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			if (zoom)
				return "The pathogen appears to mimic the behavior of the synthflesh."
		if (R == "acid")
			if (zoom)
				return "The pathogen becomes agitated and works to repair the damage caused by the sulfuric acid."

	may_react_to()
		return "The pathogen appears to be rapidly repairing the other cells around it."
	//podrickequus's first code, yay

datum/pathogeneffects/benevolent/detoxication
	name = "Detoxication"
	desc = "The pathogen aids the host body in metabolizing ethanol."
	rarity = RARITY_COMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		var/times = 1
		if (origin.stage > 3)
			times++
		if (origin.stage > 4)
			times++
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

datum/pathogeneffects/benevolent/metabolisis
	name = "Accelerated Metabolisis"
	desc = "The pathogen accelerates the metabolisis of all chemicals present in the host body."
	rarity = RARITY_RARE

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		var/times = 1
		if (origin.stage > 3)
			times++
		if (origin.stage > 4)
			times++
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

datum/pathogeneffects/benevolent/cleansing
	name = "Cleansing"
	desc = "The pathogen cleans the body of damage caused by toxins."
	rarity = RARITY_UNCOMMON

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		//if (prob(origin.stage * 5) && M.get_toxin_damage())
		if (M.get_toxin_damage())
			M.take_toxin_damage(-origin.stage / 2)
			if (prob(12))
				M.show_message("<span class='notice'>You feel cleansed.</span>")

	react_to(var/R, var/zoom)
		return "The pathogen appears to have entirely metabolized... all chemical agents in the dish."

	may_react_to()
		return "The pathogen seems to be much cleaner than normal."

datum/pathogeneffects/benevolent/oxygenconversion
	name = "Oxygen Conversion"
	desc = "The pathogen converts organic tissue into oxygen."
	rarity = RARITY_VERY_RARE

	may_react_to()
		return "The pathogen appears to radiate a red bubble of oxygen."

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			return "The pathogen consumes the synthflesh and converts it into oxygen."

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (M:losebreath > 0)
			M.TakeDamage("chest", M:losebreath * 2, 0)
			M:losebreath = 0
			if (prob(25))
				M.show_message("<span class='alert'>You feel your body deteriorating as you breathe on.</span>")
		if (M.get_oxygen_deprivation())
			if (origin.stage != 0)
				M.take_oxygen_deprivation(0 - (origin.stage / 2))

datum/pathogeneffects/benevolent/oxygenproduction
	name = "Oxygen Production"
	desc = "The pathogen produces oxygen."
	rarity = RARITY_VERY_RARE

	may_react_to()
		return "The pathogen appears to radiate a bubble of oxygen."

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (M:losebreath > 0)
			M:losebreath = 0
		if (M.get_oxygen_deprivation())
			M.take_oxygen_deprivation(0 - origin.stage)

datum/pathogeneffects/benevolent/resurrection
	name = "Necrotic Resurrection"
	desc = "The pathogen will resurrect you if it procs while you are dead."
	rarity = RARITY_VERY_RARE

	may_react_to()
		return "Some of the pathogen's dead cells seem to remain active."

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (origin.stage < 5)
			return
		if(prob(5))
			M.show_message("<span class='alert'>You feel a sudden craving for ... brains??</span>")

	disease_act_dead(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (origin.stage < 5)
			return
		// Shamelessly stolen from Strange Reagent
		if (isdead(M) || istype(get_area(M),/area/afterlife/bar))
			var/brute = M.get_brute_damage()>45?45:M.get_brute_damage()
			var/burn = M.get_burn_damage()>45?45:M.get_burn_damage()

			// let's heal them before we put some of the damage back
			// but they don't get back organs/limbs/whatever, so I don't use full_heal
			M.HealDamage("All", 100000, 100000)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.blood_volume = 500 					// let's not have people immediately suffocate from being exsanguinated
				H.take_toxin_damage(-INFINITY)
				H.take_oxygen_deprivation(-INFINITY)

			M.TakeDamage("chest", brute, burn)			// this makes it so our burn and brute are between 0-45, so at worst we will have 10% hp
			M.take_brain_damage(70)						// and a lot of brain damage
			setalive(M)
			M.changeStatus("paralysis", 150) 			// paralyze the person for a while, because coming back to life is hard work
			M.change_misstep_chance(40)					// even after getting up they still have some grogginess for a while
			M.stuttering = 15
			if (M.ghost && M.ghost.mind && !(M.mind && M.mind.dnr)) // if they have dnr set don't bother shoving them back in their body
				M.ghost.show_text("<span class='alert'><B>You feel yourself being dragged out of the afterlife!</B></span>")
				M.ghost.mind.transfer_to(M)
				qdel(M.ghost)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				H.contract_disease(/datum/ailment/disease/tissue_necrosis, null, null, 1) // this disease will make the person more and more rotten even while alive
				H.remission(origin)			// set the pathogen into remission, so it will be gone soon. Unlikely for a person to revive twice like this!
				H.immunity(origin)
				H.visible_message("<span class='alert'>[H] suddenly starts moving again!</span>","<span class='alert'>You feel the pathogen weakening as you rise from the dead.</span>")

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			return "Dead parts of the synthflesh seem to still be transferring blood."


datum/pathogeneffects/benevolent/brewery
	name = "Auto-Brewery"
	desc = "The pathogen aids the host body in metabolizing chemicals into ethanol."
	rarity = RARITY_RARE
	beneficial = 0

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
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

datum/pathogeneffects/benevolent/oxytocinproduction
	name = "Oxytocin Production"
	desc = "The pathogen produces Pure Love within the infected."
	infect_type = INFECT_TOUCH // TODO: make also spread via hugs, will require reworking pure love and part of the emote call, so I'll do it in another patch
	rarity = RARITY_COMMON
	spread = SPREAD_BODY | SPREAD_HANDS
	infect_message = "<span style=\"color:pink\">You can't help but feel loved.</span>"
	infect_attempt_message = "Their touch is suspiciously soft..."

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		var/check_amount = M.reagents.get_reagent_amount("love")
		if (!check_amount || check_amount < 5)
			M.reagents.add_reagent("love", origin.stage / 3)

	may_react_to()
		return "The pathogen's cells appear to be... hugging each other?"

datum/pathogeneffects/benevolent/neuronrestoration
	name = "Neuron Restoration"
	desc = "Infection slowly repairs nerve cells in the brain."
	rarity = RARITY_UNCOMMON
	infect_type = INFECT_NONE
	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		switch (origin.stage)
			if (2)
				if (prob(5))
					M.take_brain_damage(-1)
			if (3)
				if (prob(10))
					M.take_brain_damage(-1)
			if (4)
				if (prob(15))
					M.take_brain_damage(-2)
			if (5)
				if (prob(20))
					M.take_brain_damage(-2)

	react_to(var/R, var/zoom)
		if (!(R == "neurotoxin"))
			return "The pathogen releases a chemical in an attempt to counteract the effects of the neurotoxin."

	may_react_to()
		return "The pathogen appears to have a gland that may affect neural functions."

datum/pathogeneffects/benevolent/sunglass
	name = "Sunglass Glands"
	desc = "The infected grew sunglass glands."
	infect_type = INFECT_NONE
	rarity = RARITY_UNCOMMON

	proc/glasses(var/mob/living/carbon/human/M as mob)
		var/obj/item/clothing/glasses/G = M.glasses
		var/obj/item/clothing/glasses/N = new/obj/item/clothing/glasses/sunglasses()
		M.show_message({"<span class='notice'>[pick("You feel cooler!", "You find yourself wearing sunglasses.", "A pair of sunglasses grow onto your face.")][G?" But you were already wearing glasses!":""]</span>"})
		if (G)
			N.loc = M.loc
			var/turf/T = get_edge_target_turf(M, pick(alldirs))
			N.throw_at(T,rand(0,5),1)
		else
			N.loc = M
			N.layer = M.layer
			N.master = M
			M.glasses = N
			M.update_clothing()

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (!(H.glasses) || (!(istype(H.glasses, /obj/item/clothing/glasses/sunglasses)) && prob(50)))
				switch(origin.stage)
					if (2 to 4)
						if (prob(15))
							glasses(M)
					if (5)
						if (prob(25))
							glasses(M)

	may_react_to()
		return "The pathogen appears to be sensitive to sudden flashes of light."

	react_to(var/R, var/zoom)
		if (R == "flashpowder")
			if (zoom)
				return "The individual microbodies appear to be wearing sunglasses."
			else
				return "The pathogen appears to have developed a resistance to the flash powder."

datum/pathogeneffects/benevolent/genetictemplate
	name = "Genetic Template"
	desc = "Spreads a mutation from patient zero to other afflicted."
	rarity = RARITY_VERY_RARE
	infect_type = INFECT_NONE
	var/list/mutationMap = list() // stores the kind of mutation with the index being the pathogen's name (which is something like "L41D9")

	disease_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic || !M.bioHolder)
			return
		if(mutationMap[origin.name_base] == null) // if no mutation has been picked yet, go for a random one from this person
			var/list/filtered = new/list()
			for(var/T in M.bioHolder.effects)
				var/datum/bioEffect/instance = M.bioHolder.effects[T]
				if(!instance || istype(instance, /datum/bioEffect/hidden)) continue // hopefully this catches all non-mutation bioeffects?
				filtered.Add(instance)
			if(!filtered.len) return // wow, this nerd has no mutations, screw this
			mutationMap[origin.name_base] = pick(filtered)
			boutput(M, "You somehow feel more attuned to your [mutationMap[origin.name_base]].") // So patient zero will know when the mutation has been chosen

		if(origin.symptom_data["genetictemplate"] == origin.stage) // early return if we would just put the same mutation anyway
			return

		var/datum/bioEffect/BEE = mutationMap[origin.name_base] // remove old version of mutation
		M.bioHolder.RemoveEffect(BEE.id)

		var/datum/bioEffect/BE = new BEE.type
		var/datum/dna_chromosome/chromo = new /datum/dna_chromosome/anti_mutadone() // reinforce always
		chromo.apply(BE)
		if (origin.stage >= 2)
			BE.altered = 0 // this lets us apply another chromosome. yay!
			chromo = new /datum/dna_chromosome() // stabilize after stage 2
			chromo.apply(BE)
		if (origin.stage >= 3)
			BE.altered = 0
			chromo = new /datum/dna_chromosome/safety() // synchronize starting at stage 3
			chromo.apply(BE)
		if (origin.stage >= 4)
			BE.altered = 0
			chromo = new /datum/dna_chromosome/power_enhancer() // empower starting at stage 4
			chromo.apply(BE)
		if (origin.stage >= 5)
			BE.altered = 0
			chromo = new /datum/dna_chromosome/cooldown_reducer() // reduce cooldown starting at stage 5
			chromo.apply(BE)
		M.bioHolder.AddEffectInstance(BE) // add updated version of mutation!
		origin.symptom_data["genetictemplate"] = origin.stage // save the last stage that we added the mutation with

	oncured(mob/M as mob, var/datum/pathogen/origin)
		if (!origin.symptomatic)
			return
		var/datum/bioEffect/BE = mutationMap[origin.name_base] // cure the mutation when the pathogen is cured
		M.bioHolder.RemoveEffect(BE.id)

	react_to(var/R, var/zoom)
		if (R == "mutadone")
			if (zoom)
				return "Approximately 0% of the individual microbodies appear to have returned to genetic normalcy." // it always reinforces

	may_react_to()
		return "The pathogen cells all look exactly alike."