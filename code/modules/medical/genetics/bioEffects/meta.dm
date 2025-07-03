/datum/bioEffect/activator
	name = "Booster Gene X"
	desc = "This function of this gene is not well-researched."
	researched_desc = "This gene will activate every latent mutation in the subject when activated."
	id = "activator"
	secret = 1
	isBad = 1
	probability = 33
	blockCount = 2
	blockGaps = 4
	lockProb = 100
	lockedGaps = 1
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	curable_by_mutadone = 0

	OnAdd()
		var/mob/living/L = owner
		var/datum/bioHolder/B = L.bioHolder

		for(var/ID in B.effectPool)
			B.ActivatePoolEffect(B.effectPool[ID], 1, 0)
			//Overrides incomplete DNA sequences
		. = ..()

/datum/bioEffect/scrambler
	name = "Booster Gene Y"
	desc = "This function of this gene is not well-researched."
	researched_desc = "This gene will completely randomise the subject's gene pool and remove all active effects."
	id = "gene_scrambler"
	secret = 1
	isBad = 1
	probability = 33
	blockCount = 2
	blockGaps = 4
	lockProb = 100
	lockedGaps = 1
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	curable_by_mutadone = 0

	OnAdd()
		var/mob/living/L = owner
		var/datum/bioHolder/B = L.bioHolder

		B.RemoveAllEffects(null, TRUE)
		B.BuildEffectPool()
		. = ..()

/datum/bioEffect/remove_all
	name = "Booster Gene Z"
	desc = "This function of this gene is not well-researched."
	researched_desc = "This gene will remove all active and latent effects from the subject."
	id = "gene_clearer"
	secret = 1
	isBad = 1
	probability = 33
	blockCount = 2
	blockGaps = 4
	lockProb = 100
	lockedGaps = 1
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10
	curable_by_mutadone = 0

	OnAdd()
		var/mob/living/L = owner
		var/datum/bioHolder/B = L.bioHolder

		B.RemoveAllEffects(null, TRUE)
		B.RemoveAllPoolEffects()
		. = ..()

/datum/bioEffect/early_secret_access
	name = "High Complexity DNA"
	desc = "No effect on subject. Unlocks new research possibilities and can be used as a wildcard in combinations."
	id = "early_secret_access"
	secret = 1
	effectType = EFFECT_TYPE_POWER
	mob_exclusive = /mob/living/carbon/human
	can_research = 0
	blockCount = 1
	probability = 35
	reclaim_fail = 100
	lockProb = 100
	blockGaps = 0
	lockedGaps = 2
	lockedDiff = 6
	lockedChars = list("G","C","A","T","U")
	lockedTries = 12
	wildcard = 1


// Largely for admin gimmicks with adding bioeffects because there's no way to make them not eat stability.
// Basically give this and then give all your fucked up superpowers or whatever
/datum/bioEffect/stability_maximizer
	name = "Genetic Stabilizer"
	desc = "Boosts the genetic stability of the target to impossibly safe levels."
	id = "stability_maximizer"
	msgGain = "Your genes feel like they're rock solid."
	msgLose = "You feel vulnerable to genetic stability again."
	probability = 0
	occur_in_genepools = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	stability_loss = -999999

