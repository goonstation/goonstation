/datum/ailment/disability/cough
	name = "Chronic Cough"
	max_stages = 1
	cure = "styptic_powder"
	reagentcure = list("styptic_powder")
	recureprob = 10
	affected_species = list("Human")

/datum/ailment/disability/cough/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	var/mob/living/M = D.affected_mob
	if (probmult(10))
		M.emote("cough")
	if (probmult(2))
		M.changeStatus("stunned", 5 SECONDS)
		M.visible_message("<span class='alert'><B>[M.name]</B> suffers a coughing fit</span>")
