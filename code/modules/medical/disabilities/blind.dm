/datum/ailment/disability/blind
	name = "Blindness"
	max_stages = 1
	cure = "Unknown"
	affected_species = list("Human","Monkey")

/datum/ailment/disability/blind/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	affected_mob.take_eye_damage(5 * mult, 1)
