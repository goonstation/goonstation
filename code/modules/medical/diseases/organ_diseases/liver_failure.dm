/datum/ailment/disease/liver_failure
	name = "Liver Failure"
	scantype = "Medical Emergency"
	max_stages = 3
	spread = "The patient's liver is starting to fail"
	cure_flags = CURE_CUSTOM
	cure_desc = "Anti-toxin drugs"
	recureprob = 10
	affected_species = list("Human")
	stage_prob = 1
	var/robo_restart = 0

/datum/ailment/disease/liver_failure/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if (!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/H = affected_mob

	if (!H.organHolder || !H.organHolder.liver || H.organHolder.liver.get_damage() <= 5)
		H.cure_disease(D)
		return

		//handle roboliver failuer. should do some stuff I guess
		// else if (H.organHolder.liver && H.organHolder.liver.robotic && !H.organHolder.heart.health > 0)

	if (probmult(D.stage * 30))
		H.organHolder.liver.take_damage(0, 0, D.stage)

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
				// H.organHolder.takeliver

			if (probmult(5)) H.emote(pick("faint", "collapse", "groan"))
		if (3)
			if (probmult(20))
				H.emote(pick("twitch", "groan"))
			var/damage = 1 * mult
			if (H.hasStatus("dialysis"))
				damage /= 3 //liver dialysis is experimental, doesn't completely solve the damage
			H.take_toxin_damage(damage)
