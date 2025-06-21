/datum/ailment/disease/noheart
	name = "Cardiac Abscondment"
	scantype = "Medical Emergency"
	max_stages = 1
	info = "The patient's heart is full of holes."
	cure_flags = CURE_ORGAN_REPLACEMENT
	can_be_asymptomatic = FALSE
	affected_species = list("Human","Monkey")

/datum/ailment/disease/noheart/stage_act(var/mob/living/carbon/human/H, var/datum/ailment/D, mult)
	if (..())
		return
	if (!H.organHolder)
		H.cure_disease(D)
		return
	if (!H.organHolder.heart)
		H.cure_disease(D)
		return
	else
		if (H.get_oxygen_deprivation())
			H.take_brain_damage(3 * mult)
		else if (probmult(10))
			H.take_brain_damage(1)

		H.changeStatus("knockdown", 5 * mult SECONDS)
		H.losebreath+=20 * mult
		H.take_oxygen_deprivation(20 * mult)
