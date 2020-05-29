/datum/ailment/disease/noheart
	name = "Cardiac Abscondment"
	scantype = "Medical Emergency"
	max_stages = 1
	spread = "The patient's heart is missing."
	cure = "Heart Transplant"
	affected_species = list("Human","Monkey")

/datum/ailment/disease/noheart/stage_act(var/mob/living/carbon/human/H,var/datum/ailment/D)
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
			H.take_brain_damage(3)
		else if (prob(10))
			H.take_brain_damage(1)

		H.changeStatus("weakened", 5 SECONDS)
		H.losebreath+=20
		H.take_oxygen_deprivation(20)
