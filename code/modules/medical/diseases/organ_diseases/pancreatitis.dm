/datum/ailment/disease/pancreatitis
	name = "Pancreatitis"
	scantype = "Medical Emergency"
	max_stages = 3
	spread = "The patient's pancreas is dangerously enlarged"
	cure_flags = CURE_CUSTOM
	cure_desc = "Removal of organ"
	recureprob = 10
	affected_species = list("Human")
	stage_prob = 1
	var/robo_restart = 0

/datum/ailment/disease/pancreatitis/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if (!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/H = affected_mob

	if (!H.organHolder || !H.organHolder.pancreas || H.organHolder.pancreas.get_damage() <= 5)
		H.cure_disease(D)
		return

	//handle robopancreas failuer. should do some stuff I guess
	// else if (H.organHolder.pancreas && H.organHolder.pancreas.robotic && !H.organHolder.heart.health > 0)

	if (probmult(D.stage * 30))
		H.organHolder.pancreas.take_damage(0, 0, D.stage)

	switch (D.stage)
		if (1)
			if (probmult(0.1))
				boutput(H, SPAN_NOTICE("You feel better."))
				H.cure_disease(D)
				return
			if (probmult(8)) H.emote(pick("pale", "shudder"))
			if (probmult(5))
				boutput(H, SPAN_ALERT("Your abdomen hurts!"))
		if (2)
			if (probmult(8)) H.emote(pick("pale", "groan"))
			if (probmult(5))
				boutput(H, SPAN_ALERT("Your back aches terribly!"))
			if (probmult(3))
				boutput(H, SPAN_ALERT("You feel excruciating pain in your upper-right abdomen!"))
				// H.organHolder.takepancreas

			if (probmult(5)) H.emote(pick("faint", "collapse", "groan"))
		if (3)
			if (probmult(20))
				H.emote(pick("pale", "groan"))

			H.take_toxin_damage(1 * mult)
