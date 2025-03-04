/datum/ailment/disease/appendicitis
	name = "Appendicitis"
	scantype = "Medical Emergency"
	max_stages = 3
	spread = "The patient's appendicitis is dangerously enlarged"
	cure_flags = CURE_CUSTOM
	cure_desc = "Removal of organ"
	recureprob = 10
	affected_species = list("Human")
	stage_prob = 1
	can_be_asymptomatic = FALSE
	var/robo_restart = 0

/datum/ailment/disease/appendicitis/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if (!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/H = affected_mob

	if (!H.organHolder || !H.organHolder.appendix || H.organHolder.appendix.robotic)
		H.cure_disease(D)
		return

		//handle robopancreas failuer. should do some stuff I guess
		// else if (H.organHolder.pancreas && H.organHolder.pancreas.robotic && !H.organHolder.heart.health > 0)

	if (probmult(D.stage * 30))
		H.organHolder.appendix.take_damage(0, 0, D.stage)
	if (D.stage == 2)
		H.add_vomit_behavior(/datum/vomit_behavior/blood)
	else
		H.remove_vomit_behavior(/datum/vomit_behavior/blood)
	switch (D.stage)
		if (1)
			if (probmult(0.1))
				H.show_text(pick_string("organ_disease_messages.txt", "feelbetter"), "blue")
				H.cure_disease(D)
				return
			if (probmult(8)) H.emote(pick("pale", "shudder"))
			if (probmult(5))
				boutput(H, SPAN_ALERT("Your abdomen hurts!"))
			if (probmult(10))
				H.show_text(pick_string("organ_disease_messages.txt", "appendicitis0"), "red")
		if (2)
			if (probmult(0.1))
				H.show_text(pick_string("organ_disease_messages.txt", "feelbetter"), "blue")
				H.resistances += src.type
				H.ailments -= src
				return
			if (probmult(30))
				H.nauseate(1)
			if (probmult(8))
				H.emote(pick("pale", "groan"))
			if (probmult(8))
				H.bodytemperature += 4
				H.show_text(pick_string("organ_disease_messages.txt", "appendicitis1"), "red")
			if (probmult(5))
				boutput(H, SPAN_ALERT("Your back aches terribly!"))
			if (probmult(3))
				boutput(H, SPAN_ALERT("You feel excruciating pain in your upper-right abdomen!"))
				// H.organHolder.takepancreas

			if (probmult(5)) H.emote(pick("faint", "collapse", "groan"))
		if (3)
			if (probmult(20))
				H.emote(pick("twitch", "groan"))
			//human's appendix burst, and add a load of toxic chemicals to the person.
			if (probmult(10))
				if (H.organHolder.appendix.get_damage() >= 90)
					H.cure_disease(D)
					H.organHolder.appendix.take_damage(200,200,200)
					// H.organHolder.drop_organ("appendix")
					H.emote("collapse")
					H.setStatus("knockdown", 3 SECONDS)

					if (prob(20))
						H.reagents.add_reagent("toxin", 20)
					boutput(H, SPAN_ALERT("Your appendix has burst! Seek medical help!"))

			H.take_toxin_damage(1 * mult)
