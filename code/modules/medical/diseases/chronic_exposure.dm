// Parent for chronic exposure diseases (e.g mercury poisoning)

ABSTRACT_TYPE(/datum/ailment/disease/chronic_exposure)
/datum/ailment/disease/chronic_exposure
	name = "Chronic Exposure \[You shouldn't be seeing this!\]"
	scantype = "Poisoning"
	max_stages = 3
	stage_prob = 0
	spread = "Non-Contagious"
	cure = "Unknown"
	associated_reagent = null // there isn't really one???
	affected_species = list("Human","Monkey")
	/// Invisible if a health scan isn't using both organ and reagent scan
	var/require_upgraded_scanner = TRUE
	/// Used to determine at what trace_reagents values to progress/regress the disease
	var/threshold_1 = 5
	var/threshold_2 = 10
	var/threshold_3 = 15


/// Rolls a chance to progress or regress the disease
/datum/ailment/disease/chronic_exposure/proc/progress_check(var/mob/living/affected_mob, var/datum/ailment_data/D)
	var/mob/living/carbon/human/H = null
	if(ishuman(affected_mob))
		H = affected_mob
	var/metabolized_reagent = H.trace_reagents[associated_reagent]
	if(isnull(metabolized_reagent))
		metabolized_reagent = 0
	var/adv_prob = 0 // how likely we are to advance to the next stage
	// we check frequently so we need to keep probabilities relatively low
	if((D.stage == 1) && (metabolized_reagent > threshold_2))
		adv_prob += (metabolized_reagent - threshold_2) * 2
	else if((D.stage == 2) && (metabolized_reagent > threshold_3))
		adv_prob += (metabolized_reagent - threshold_3) * 2
	if(prob(adv_prob))
		D.stage++
		stage_update(affected_mob, D)
		return

	var/reg_prob = 0 // how likely we are to *regress* to the previous stage/be cured!
	if((D.stage == 1) && (metabolized_reagent < threshold_1)) // looks like we've had a lot of the toxin removed!
		if(prob((metabolized_reagent - threshold_1)) * 2) // the 2 is kinda arbitrary here, just bumps up the chances a bit
			affected_mob.cure_disease(D)
	else if((D.stage == 2) && (metabolized_reagent <= threshold_2))
		reg_prob = (threshold_2 - metabolized_reagent) * 2
	else if((D.stage == 3) && (metabolized_reagent <= threshold_3))
		reg_prob = (threshold_3 - metabolized_reagent) * 2
	if(prob(reg_prob))
		D.stage--
		stage_update(affected_mob, D)

/datum/ailment/disease/chronic_exposure/proc/calculate_chance(var/threshold)
	. = 0


/datum/ailment/disease/chronic_exposure/on_infection(mob/living/affected_mob, datum/ailment_data/D)
	src.stage_update(affected_mob, D)
	..()

/datum/ailment/disease/chronic_exposure/on_remove(mob/living/affected_mob, datum/ailment_data/D)
	..()

/// Triggers when the stage changes
/// Used to add/remove buffs/debuffs or other permanent effects
/datum/ailment/disease/chronic_exposure/proc/stage_update(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	return

// just to avoid copy/pasting this code block like 10 times
// (directly cut/paste from addiction code lol)
/datum/ailment/disease/chronic_exposure/proc/puke(var/mob/living/affected_mob)
	if (affected_mob.nutrition > 10)
		affected_mob.visible_message("<span class='alert'>[affected_mob] vomits on the floor profusely!</span>",\
		"<span class='alert'>You vomit all over the floor!</span>")
		affected_mob.vomit(rand(3,5))
	else
		affected_mob.visible_message("<span class='alert'>[affected_mob] gags and retches!</span>",\
		"<span class='alert'>Your stomach lurches painfully!</span>")
		affected_mob.changeStatus("stunned", 2 SECONDS)
		affected_mob.changeStatus("weakened", 2 SECONDS)
