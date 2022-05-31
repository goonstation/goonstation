// Effects related to medical healing go here
ABSTRACT_TYPE(/datum/microbioeffects/benevolent)
/datum/microbioeffects/benevolent
	name = "Medical Probiotics"

/datum/microbioeffects/benevolent/mending
	name = "Wound Mending"
	desc = "Slow paced brute damage healing."

	mob_act(var/mob/M as mob, var/datum/microbe/origin)
		if (prob(10))
			M.HealDamage("All", 2, 0)

	onadd(var/datum/microbe/origin)
		origin.effectdata += "woundmend"

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			if (zoom)
				return "Microscopic damage on the synthetic flesh appears to be mended by the pathogen."

	may_react_to()
		return "The pathogen appears to have the ability to bond with organic tissue."

/datum/microbioeffects/benevolent/healing
	name = "Burn Healing"
	desc = "Slow paced burn damage healing."

	mob_act(var/mob/M as mob, var/datum/microbe/origin)
		if (prob(10))
			M.HealDamage("All", 0, 2)

	onadd(var/datum/microbe/origin)
		origin.effectdata += "burnheal"

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			if (zoom)
				return "The pathogen does not appear to mend the synthetic flesh. Perhaps something that might cause other types of injuries might help."
		if (R == "infernite")
			if (zoom)
				return "The pathogen repels the scalding hot chemical and quickly repairs any damage caused by it to organic tissue."

	may_react_to()
		return "The pathogen appears to have the ability to bond with organic tissue."

/datum/microbioeffects/benevolent/fleshrestructuring
	name = "Flesh Restructuring"
	desc = "Fast paced general healing."

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (prob(10))
			M.HealDamage("All", 2, 2)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.bleeding)
				repair_bleeding_damage(M, 80, 2)
				if (prob(50))
					M.show_message("<span class='notice'>You feel your wounds closing by themselves.</span>")

	onadd(var/datum/microbe/origin)
		origin.effectdata += "fleshrest"

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
/*
datum/pathogeneffects/benevolent/cleansing
	name = "Cleansing"
	desc = "The pathogen cleans the body of damage caused by toxins."

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
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
	desc = "The pathogen converts organic tissue into oxygen when required by the host."

	may_react_to()
		return "The pathogen appears to radiate oxygen."

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			return "The pathogen consumes the synthflesh and converts it into oxygen."

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		var/mob/living/carbon/C = M
		if (C.get_oxygen_deprivation())
			C.setStatus("patho_oxy_speed_bad", duration = INFINITE_STATUS, optional = origin.stage/2.5)

datum/pathogeneffects/benevolent/oxygenstorage
	name = "Oxygen Storage"
	desc = "The pathogen stores oxygen and releases it when needed by the host."

	may_react_to()
		return "The pathogen appears to have a bubble of oxygen around it."

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		if(!origin.symptom_data["oxygen_storage"]) // if not yet set, initialize
			origin.symptom_data["oxygen_storage"] = 0

		var/mob/living/carbon/C = M
		if (C.get_oxygen_deprivation())
			if(origin.symptom_data["oxygen_storage"] > 10)
				C.setStatus("patho_oxy_speed", duration = INFINITE_STATUS, optional = origin.symptom_data["oxygen_storage"])
				origin.symptom_data["oxygen_storage"] = 0
		else
			// faster reserve replenishment at higher stages
			origin.symptom_data["oxygen_storage"] = min(100, origin.symptom_data["oxygen_storage"] + origin.stage*2)

datum/pathogeneffects/benevolent/resurrection
	name = "Necrotic Resurrection"
	desc = "The pathogen will resurrect you if it procs while you are dead."
	var/cooldown = 5 MINUTES

	may_react_to()
		return "Some of the pathogen's dead cells seem to remain active."

	mob_act_dead(var/mob/M as mob, var/datum/pathogen/origin)
		if (origin.in_remission)
			return
		if (origin.stage < 3)
			return
		if(!origin.symptom_data["resurrect_cd"]) // if not yet set, initialize it so that it is off cooldown
			origin.symptom_data["resurrect_cd"] = -cooldown
		if(TIME-origin.symptom_data["resurrect_cd"] < cooldown)
			return
		// Shamelessly stolen from Strange Reagent
		if (isdead(M) || istype(get_area(M),/area/afterlife/bar))
			origin.symptom_data["resurrect_cd"] = TIME
			// range from 65 to 45. This is applied to both brute and burn, so the total max damage after resurrection is 130 to 90.
			var/cap =	95 - origin.stage * 10
			var/brute = min(cap, M.get_brute_damage())
			var/burn = min(cap, M.get_burn_damage())

			// let's heal them before we put some of the damage back
			// but they don't get back organs/limbs/whatever, so I don't use full_heal
			M.HealDamage("All", 100000, 100000)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.blood_volume = 500 					// let's not have people immediately suffocate from being exsanguinated
				H.take_toxin_damage(-INFINITY)
				H.take_oxygen_deprivation(-INFINITY)
				H.take_brain_damage(-INFINITY)

			M.TakeDamage("chest", brute, burn)
			M.take_brain_damage(70)						// and a lot of brain damage
			setalive(M)
			M.changeStatus("paralysis", 15 SECONDS) 			// paralyze the person for a while, because coming back to life is hard work
			M.change_misstep_chance(40)					// even after getting up they still have some grogginess for a while
			M.stuttering = 15
			if (M.ghost && M.ghost.mind && !(M.mind && M.mind.dnr)) // if they have dnr set don't bother shoving them back in their body
				M.ghost.show_text("<span class='alert'><B>You feel yourself being dragged out of the afterlife!</B></span>")
				M.ghost.mind.transfer_to(M)
				qdel(M.ghost)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				H.contract_disease(/datum/ailment/disease/tissue_necrosis, null, null, 1) // this disease will make the person more and more rotten even while alive
				H.visible_message("<span class='alert'>[H] suddenly starts moving again!</span>","<span class='alert'>You feel the pathogen weakening as you rise from the dead.</span>")

	react_to(var/R, var/zoom)
		if (R == "synthflesh")
			return "Dead parts of the synthflesh seem to still be transferring blood."

datum/pathogeneffects/benevolent/neuronrestoration
	name = "Neuron Restoration"
	desc = "Infection slowly repairs nerve cells in the brain."

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (origin.in_remission)
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

datum/pathogeneffects/benevolent/genetictemplate
	name = "Genetic Template"
	desc = "Spreads a mutation from patient zero to other afflicted."

	var/list/mutationMap = list() // stores the kind of mutation with the index being the pathogen's name (which is something like "L41D9")

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		if (!!origin.in_remission || !M.bioHolder)
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

		var/datum/bioEffect/BE = BEE.GetCopy()
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
		if (origin.in_remission)
			return
		var/datum/bioEffect/BE = mutationMap[origin.name_base] // cure the mutation when the pathogen is cured
		M.bioHolder.RemoveEffect(BE.id)

	react_to(var/R, var/zoom)
		if (R == "mutadone")
			if (zoom)
				return "Approximately 0% of the individual microbodies appear to have returned to genetic normalcy." // it always reinforces

	may_react_to()
		return "The pathogen cells all look exactly alike."

datum/pathogeneffects/benevolent/exclusiveimmunity
	name = "Exclusive Immunity"
	desc = "The pathogen occupies almost all possible routes of infection, preventing other diseases from entering."

	mob_act(var/mob/M as mob, var/datum/pathogen/origin)
		//if (other pathogens detected)
			//grab their in_remission
			//set their vals to 1

	may_react_to()
		return "The pathogen appears to have the ability to bond with organic tissue."

*/
