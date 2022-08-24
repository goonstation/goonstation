/datum/ailment/disability/deaf
	name = "Deafness"
	max_stages = 1
	cure = "Unknown"
	affected_species = list("Human","Monkey")

/datum/ailment/disability/deaf/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	var/mob/living/M = D.affected_mob
	M.take_ear_damage(5 * mult, 1)
