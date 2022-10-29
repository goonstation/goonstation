/datum/ailment/disease/teleportitis
	name = "Teleportitis"
	max_stages = 1
	spread = "Non-Contagious"
	cure = "Electric Shock"
	associated_reagent = "liquid spacetime"
	affected_species = list("Human")

/datum/ailment/disease/teleportitis/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	if(probmult(5))
		affected_mob.emote("hiccup")
	if(probmult(15))
		if (!isturf(affected_mob.loc))
			return
		if (isrestrictedz(affected_mob.z))
			boutput(affected_mob, "<span class='notice'>You feel a bit strange. Almost... guilty?</span>")
			return

		var/list/randomturfs = new/list()
		for(var/turf/T in orange(affected_mob, 10))
			if(istype(T, /turf/space) || T.density)
				continue
			randomturfs.Add(T)
		if(randomturfs.len > 0)
			boutput(affected_mob, "<span class='alert'>You are suddenly zapped away elsewhere!</span>")
			var/turf/destination = pick(randomturfs)
			logTheThing(LOG_COMBAT, affected_mob, "was teleported by Teleportitis from [log_loc(affected_mob)] to [log_loc(destination)].")
			affected_mob.set_loc(destination)
			elecflash(affected_mob)
