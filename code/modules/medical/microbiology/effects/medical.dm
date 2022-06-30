// Effects related to medical healing go here
ABSTRACT_TYPE(/datum/microbioeffects/benevolent)
/datum/microbioeffects/benevolent
	name = "Medical Probiotics"

/datum/microbioeffects/benevolent/mending
	name = "Wound Mending"
	desc = "Slow paced brute damage healing."
	reactionlist = list("synthflesh")
	reactionmessage = "Microscopic damage on the synthetic flesh appears to be mended by the microbes."

	mob_act(var/mob/M, var/datum/microbesubdata/P)
		if (prob(P.probability*2))
			M.HealDamage("All", 2, 0)

/datum/microbioeffects/benevolent/healing
	name = "Burn Healing"
	desc = "Slow paced burn damage healing."
	reactionlist = MB_HOT_REAGENTS
	reactionmessage = "The microbes repel the scalding hot chemical and quickly repair any damage caused by it to organic tissue."

	mob_act(var/mob/M, var/datum/microbesubdata/P)
		if (prob(P.probability*2))
			M.HealDamage("All", 0, 2)

/datum/microbioeffects/benevolent/fleshrestructuring
	name = "Flesh Restructuring"
	desc = "Fast paced general healing."
	reactionlist = MB_ACID_REAGENTS
	reactionmessage = "The microbes become agitated and work to repair the damage caused by the acid."

	mob_act(var/mob/M, var/datum/microbesubdata/P)
		if (prob(P.probability*2))
			M.HealDamage("All", 2, 2)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.bleeding)
				repair_bleeding_damage(M, 80, 2)
				if (prob(20))
					M.show_message("<span class='notice'>You feel your wounds closing by themselves.</span>")

	//podrickequus's first code, yay

/datum/microbioeffects/benevolent/cleansing
	name = "Cleansing"
	desc = "The microbes clean the body of damage caused by toxins."
	reactionlist = MB_TOXINS_REAGENTS
	reactionmessage = "The microbes appear to have entirely metabolized... all chemical agents in the dish."

	mob_act(var/mob/M, var/datum/microbesubdata/P)
		if (prob(P.probability) && M.get_toxin_damage())
			M.take_toxin_damage(-1)
			if (prob(2))
				M.show_message("<span class='notice'>You feel cleansed.</span>")

/datum/microbioeffects/benevolent/oxygenconversion
	name = "Oxygen Conversion"
	desc = "The microbes convert organic tissue into oxygen when required by the host."
	reactionlist = list("synthflesh")
	reactionmessage = "The microbes consume the synthflesh, converting it into oxygen."

	onadd(var/datum/microbe/origin)
		origin.effectdata += "Oxy Conversion"

	mob_act(var/mob/M, var/datum/microbesubdata/P)
		var/mob/living/carbon/C = M
		if (C.get_oxygen_deprivation())
			C.setStatus("patho_oxy_speed_bad", duration = INFINITE_STATUS, optional = 1)

/datum/microbioeffects/benevolent/oxygenstorage
	name = "Oxygen Storage"
	desc = "The microbes store oxygen and releases it when needed by the host."
	reactionlist = MB_OXY_MEDS_CATAGORY
	reactionmessage = "The microbes appear to generate bubbles of oxygen around the reagent."

	onadd(var/datum/microbe/origin)
		origin.effectdata += "Oxy Storage"

	mob_act(var/mob/M, var/datum/microbesubdata/P)
		if(!P.master.effectdata["oxygen_storage"]) // if not yet set, initialize
			P.master.effectdata["oxygen_storage"] = 0

		var/mob/living/carbon/C = M
		if (C.get_oxygen_deprivation())
			if(P.master.effectdata["oxygen_storage"] > 10)
				C.setStatus("patho_oxy_speed", duration = INFINITE_STATUS, optional = P.master.effectdata["oxygen_storage"])
				P.master.effectdata["oxygen_storage"] = 0
		else
			// faster reserve replenishment at higher stages
			P.master.effectdata["oxygen_storage"] = min(100, P.master.effectdata["oxygen_storage"] + 2)

/datum/microbioeffects/benevolent/resurrection
	name = "Necrotic Resurrection"
	desc = "The microbes will attempt to revive dead hosts."
	reactionlist = list("synthflesh")
	reactionmessage = "Dead parts of the synthflesh seem to start transferring blood again!"
	var/cooldown = 1 MINUTES			// Make this competitive?

	onadd(var/datum/microbe/origin)
		origin.effectdata += "Ressurection"

	mob_act_dead(var/mob/M, var/datum/microbesubdata/P)
		if(!P.master.effectdata["resurrect_cd"]) // if not yet set, initialize it so that it is off cooldown
			P.master.effectdata["resurrect_cd"] = -cooldown
		if(TIME-P.master.effectdata["resurrect_cd"] < cooldown)
			return
		if (M.traitHolder.hasTrait("puritan"))	//See forum post "Cloning: A Discussion". Opinion seems that puritans should have only borging.
			return
		// Shamelessly stolen from Strange Reagent
		if (isdead(M) || istype(get_area(M),/area/afterlife/bar))
			P.master.effectdata["resurrect_cd"] = TIME
			// range from 65 to 45. This is applied to both brute and burn, so the total max damage after resurrection is 130 to 90.
			var/brute = min(rand(45,65), M.get_brute_damage())
			var/burn = min(rand(45,65), M.get_burn_damage())

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
				H.visible_message("<span class='alert'>[H] suddenly starts moving again!</span>","<span class='alert'>You feel the disease weakening as you rise from the dead.</span>")


/datum/microbioeffects/benevolent/neuronrestoration
	name = "Neuron Restoration"
	desc = "Infection slowly repairs nerve cells in the brain."
	reactionlist = MB_BRAINDAMAGE_REAGENTS
	reactionmessage = "The microbes release a chemical in an attempt to counteract the effects of the test reagent."

	mob_act(var/mob/M, var/datum/microbesubdata/P)
		if (prob(P.probability))
			M.take_brain_damage(-1)

/datum/microbioeffects/benevolent/metabolisis
	name = "Accelerated Metabolisis"
	desc = "The pathogen accelerates the metabolisis of all chemicals present in the host body."
	reactionlist = list("water")
	reactionmessage = "The microbes metabolize the water: it seems capable of processing any reagent."

	mob_act(var/mob/M, var/datum/microbesubdata/origin)
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
datum/pathogeneffects/benevolent/genetictemplate
	name = "Genetic Template"
	desc = "Spreads a mutation from patient zero to other afflicted."

	var/list/mutationMap = list() // stores the kind of mutation with the index being the pathogen's name (which is something like "L41D9")

	mob_act(var/mob/M, var/datum/microbesubdata/P)
		if (!M.bioHolder)
			return
		if(mutationMap[origin.name] == null) // if no mutation has been picked yet, go for a random one from this person
			var/list/filtered = new/list()
			for(var/T in M.bioHolder.effects)
				var/datum/bioEffect/instance = M.bioHolder.effects[T]
				if(!instance || istype(instance, /datum/bioEffect/hidden)) continue // hopefully this catches all non-mutation bioeffects?
				filtered.Add(instance)
			if(!filtered.len) return // wow, this nerd has no mutations, screw this
			mutationMap[origin.name] = pick(filtered)
			boutput(M, "You somehow feel more attuned to your [mutationMap[origin.name]].") // So patient zero will know when the mutation has been chosen

		if(origin.effectdata["genetictemplate"] == origin.stage) // early return if we would just put the same mutation anyway
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
		origin.effectdata["genetictemplate"] = origin.stage // save the last stage that we added the mutation with

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
*/
/*
/datum/microbioeffects/service/detoxication
	name = "Detoxication"
	desc = "The pathogen aids the host body in metabolizing ethanol."

	mob_act(var/datum/microbesubdata/P)
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
*/
