/datum/ailment/disease/pancreatitis
	name = "Pancreatitis"
	scantype = "Medical Emergency"
	max_stages = 3
	spread = "The patient's pancreas is dangerously enlarged"
	cure = "Surgery"
	reagentcure = list("organ_drug3")
	recureprob = 10
	affected_species = list("Human")
	stage_prob = 1
	var/robo_restart = 0

/datum/ailment/disease/pancreatitis/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
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
	
	if (prob(D.stage * 30))
		H.organHolder.pancreas.take_damage(0, 0, D.stage)

	switch (D.stage)
		if (1)
			if (prob(1) && prob(10))
				boutput(H, "<span style=\"color:blue\">You feel better.</span>")
				H.cure_disease(D)
				return
			if (prob(8)) H.emote(pick("pale", "shudder"))
			if (prob(5))
				boutput(H, "<span style=\"color:red\">Your abdomen hurts!</span>")
		if (2)
			if (prob(8)) H.emote(pick("pale", "groan"))
			if (prob(5))
				boutput(H, "<span style=\"color:red\">Your back aches terribly!</span>")
			if (prob(3))
				boutput(H, "<span style=\"color:red\">You feel excruciating pain in your upper-right adbomen!</span>")
				// H.organHolder.takepancreas

			if (prob(5)) H.emote(pick("faint", "collapse", "groan"))
		if (3)
			if (prob(20))
				H.emote(pick("pale", "groan"))

			H.take_toxin_damage(1)
			H.updatehealth()
