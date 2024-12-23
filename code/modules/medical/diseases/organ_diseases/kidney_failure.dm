//unfinished
/datum/ailment/disease/kidney_failure
	name = "Kidney Failure"
	scantype = "Medical Emergency"
	max_stages = 3
	spread = "The patient's kidneys are starting to fail"
	cure_flags = CURE_CUSTOM
	cure_desc = "Anti-toxin drugs"
	recureprob = 10
	affected_species = list("Human")
	stage_prob = 1
	var/robo_restart = 0
	var/failing_organ = null	//which kidney got damaged enough that it trigged the kidney failure disease. Acceptable values "l", "r"

//these seemed like the cleanest way to allow you to cure an organfailure by removing only a single organ
/datum/ailment/disease/kidney_failure/left
	failing_organ = "l"
/datum/ailment/disease/kidney_failure/right
	failing_organ = "r"

/datum/ailment/disease/kidney_failure/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if (!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/H = affected_mob

	if (!H.organHolder || (!H.organHolder.left_kidney && !H.organHolder.right_kidney))
		H.cure_disease(D)
		return

	//so you only need to remove the one kidney to cure the disease.
	if ((failing_organ == "l" && !H.organHolder.left_kidney) || (failing_organ == "r" && !H.organHolder.right_kidney))
		H.cure_disease(D)
		return
	else if ((H.organHolder.left_kidney && H.organHolder.left_kidney.get_damage() < 5) && (H.organHolder.right_kidney && H.organHolder.right_kidney.get_damage() < 5))
		H.cure_disease(D)


		//handle robokidney failuer. should do some stuff I guess
		// else if (H.organHolder.kidney && H.organHolder.kidney.robotic && !H.organHolder.heart.health > 0)

	if (probmult(D.stage * 30))
		H.organHolder.damage_organs(0, 0, D.stage, 50, list("left_kidney", "right_kidney"))

	switch (D.stage)
		if (1)
			if (probmult(0.1))
				boutput(H, SPAN_NOTICE("You feel better."))
				H.cure_disease(D)
				return
			if (probmult(8)) H.emote(pick("pale", "shudder"))
			if (probmult(5))
				boutput(H, SPAN_ALERT("Your abdomen area hurts!"))
		if (2)
			if (probmult(0.1))
				boutput(H, SPAN_NOTICE("You feel better."))
				H.resistances += src.type
				H.ailments -= src
				return
			if (probmult(8)) H.emote(pick("pale", "groan"))
			if (probmult(5))
				boutput(H, SPAN_ALERT("Your back aches terribly!"))
			if (probmult(3))
				boutput(H, SPAN_ALERT("You feel excruciating pain in your upper-right abdomen!"))
				// H.organHolder.takekidney

			if (probmult(5)) H.emote(pick("faint", "collapse", "groan"))
		if (3)
			if (probmult(8)) H.emote(pick("twitch", "gasp"))

			if (probmult(20))
				H.emote(pick("twitch", "gasp"))
				H.losebreath++
			if (!H.hasStatus("dialysis")) //dialysis can be a somewhat permanent solution to kidney failure
				H.take_toxin_damage(1 * mult)
