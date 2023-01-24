//unfinished
/datum/ailment/disease/respiratory_failure
	name = "Respiratory Failure"
	scantype = "Medical Emergency"
	max_stages = 3
	spread = "The patient's respiratory is starting to fail"
	cure = "Oxygen-healing drugs or surgery"
	reagentcure = list("organ_drug1")
	recureprob = 10
	affected_species = list("Human")
	stage_prob = 1
	var/robo_restart = 0
	var/failing_organ = null	//which lung got damaged enough that it trigged the lung failure disease. Acceptable values "l", "r"

//these seemed like the cleanest way to allow you to cure an organfailure by removing only a single organ
/datum/ailment/disease/respiratory_failure/left
	failing_organ = "l"
/datum/ailment/disease/respiratory_failure/right
	failing_organ = "r"

/datum/ailment/disease/respiratory_failure/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if (!ishuman(affected_mob))
		return
	var/mob/living/carbon/human/H = affected_mob

	if (!H.organHolder|| (!H.organHolder.left_lung && !H.organHolder.right_lung))
		H.cure_disease(D)
		return

	//so you only need to remove the one lung to cure the disease. 
	if ((failing_organ == "l" && !H.organHolder.left_lung) || (failing_organ == "r" && !H.organHolder.right_lung))
		H.cure_disease(D)
		return

	//if one lung is dead, you're in stage 3 resp failure, no exceptions. Need to fix with lung surgery to replace the dead one.
	if ((H.organHolder.left_lung && H.organHolder.left_lung.get_damage() >= 100) || (H.organHolder.right_lung && H.organHolder.right_lung.get_damage() >= 100))
		D.stage = 3
	else if ((H.organHolder.left_lung && H.organHolder.left_lung.get_damage() < 5) && (H.organHolder.right_lung && H.organHolder.right_lung.get_damage() < 5))
		H.cure_disease(D)

		//handle roborespiratory failuer. should do some stuff I guess
		// else if (H.organHolder.respiratory && H.organHolder.respiratory.robotic && !H.organHolder.heart.health > 0)
	if (probmult(D.stage * 30))
		H.organHolder.damage_organs(0, 0, D.stage, 50, list("left_lung", "right_lung"))
	switch (D.stage)
		if (1)
			if (probmult(0.1))
				boutput(H, "<span class='notice'>You feel better.</span>")
				H.cure_disease(D)
				return
			if (probmult(8)) H.emote(pick("pale", "shudder"))
			if (probmult(5))
				boutput(H, "<span class='alert'>Your ribs hurt!</span>")
		if (2)
			if (probmult(0.1))
				boutput(H, "<span class='notice'>You feel better.</span>")
				H.resistances += src.type
				H.ailments -= src
				return
			if (probmult(8)) H.emote(pick("pale", "groan"))
			if (probmult(10))
				boutput(H, "<span class='alert'>It hurts to breathe!</span>")
				H.losebreath++

			if (probmult(5)) H.emote(pick("faint", "collapse", "groan"))
		if (3)
			if (probmult(8)) H.emote(pick("twitch", "gasp"))

			if (probmult(20))
				H.emote(pick("twitch", "gasp"))
				boutput(H, "<span class='alert'>You can hardly breathe due to the pain!</span>")

				H.organHolder.damage_organs(0, 0, 3, 60, list("left_lung", "right_lung"))
				H.losebreath+=3

			H.take_oxygen_deprivation(1 * mult)
