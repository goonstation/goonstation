/datum/ailment/mindmites
	name = "Mindmites"
	scantype = "Extraplanar Mental Infection"
	max_stages = 1
	spread = "Non-Contagious"
	affected_species = list("Human", "Monkey")
	cure_flags = CURE_CUSTOM
	cure_desc = "Mannitol, ethanol, morphine, or haloperidol"
	can_be_asymptomatic = FALSE
	var/list/active_mindmites = list()

	on_infection(mob/living/affected_mob, datum/ailment_data/D)
		..()
		get_image_group(CLIENT_IMAGE_GROUP_MINDMITE_VISION).add_mob(affected_mob)

	on_remove(mob/living/affected_mob, datum/ailment_data/D)
		..()
		get_image_group(CLIENT_IMAGE_GROUP_MINDMITE_VISION).remove_mob(affected_mob)

		for (var/mite in src.active_mindmites)
			qdel(mite)
		src.active_mindmites = null

	stage_act(mob/living/affected_mob, datum/ailment_data/D, mult)
		if (..())
			return
		if (probmult(15) && length(src.active_mindmites) <= 5)
			var/turf/T = get_turf(affected_mob)
			var/mob/living/critter/mindmite/mite = new(locate(T.x + rand(-5, 5), T.y + rand(-5, 5), T.z), target_mob = affected_mob, mindmites_ailment = src)
			src.active_mindmites += mite

