/datum/ailment/disease/appendicitis
	name = "Appendicitis"
	scantype = "Medical Emergency"
	max_stages = 3
	spread = "The patient's appendicitis is dangerously enlarged"
	cure = "surgery"
	reagentcure = list("organ_drug3")
	recureprob = 10
	affected_species = list("Human")
	stage_prob = 1
	var/robo_restart = 0

/datum/ailment/disease/appendicitis/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
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

	if (prob(D.stage * 30))
		H.organHolder.appendix.take_damage(0, 0, D.stage)
	switch (D.stage)
		if (1)
			if (prob(1) && prob(10))
				H.show_text(pick_string("organ_disease_messages.txt", "feelbetter"), "blue")
				H.cure_disease(D)
				return
			if (prob(8)) H.emote(pick("pale", "shudder"))
			if (prob(5))
				boutput(H, "<span style=\"color:red\">Your abdomen hurts!</span>")
			if (prob(10))
				H.show_text(pick_string("organ_disease_messages.txt", "appendicitis0"), "red")
		if (2)
			if (prob(1) && prob(10))
				H.show_text(pick_string("organ_disease_messages.txt", "feelbetter"), "blue")
				H.resistances += src.type
				H.ailments -= src
				return
			if (prob(10))
				H.vomit()
				H.visible_message("<span style=\"color:red\">[H] suddenly and violently vomits!</span>")
			else if (prob(2))
				H.visible_message("<span style=\"color:red\">[H] vomits blood!</span>")
				playsound(H.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				random_brute_damage(H, rand(5,8))
				bleed(H, rand(5,8), 5)
			if (prob(8)) H.emote(pick("pale", "groan"))
			if (prob(8))
				H.bodytemperature += 4
				H.show_text(pick_string("organ_disease_messages.txt", "appendicitis1"), "red")
			if (prob(5))
				boutput(H, "<span style=\"color:red\">Your back aches terribly!</span>")
			if (prob(3))
				boutput(H, "<span style=\"color:red\">You feel excruciating pain in your upper-right adbomen!</span>")
				// H.organHolder.takepancreas

			if (prob(5)) H.emote(pick("faint", "collapse", "groan"))
		if (3)
			if (prob(20))
				H.emote(pick("twitch", "groan"))
			//human's appendix burst, and add a load of toxic chemicals or bacteria to the person.
			if (prob(10))
				if (H.organHolder.appendix.get_damage() >= 90)
					H.cure_disease(D)
					H.organHolder.appendix.take_damage(200,200,200)
					// H.organHolder.drop_organ("appendix")
					H.emote("collapse")
					H.setStatus("weakened", 3 SECONDS)

					if (prob(20))
						H.reagents.add_reagent("toxin", 20)
					add_pathogens(H, 30)
					boutput(H, "<span style=\"color:red\">Your appendix has burst! Seek medical help!</span>")

			H.take_toxin_damage(1)
			H.updatehealth()

//stolen from the admin button because I know fuck all about pathogens - Kyle
/datum/ailment/disease/appendicitis/proc/add_pathogens(var/mob/living/A, var/amount)
	if (!A || !A.reagents)
		return 0

	A.reagents.add_reagent("pathogen", amount)
	var/datum/reagent/blood/pathogen/R = A.reagents.get_reagent("pathogen")
	var/datum/pathogen/P = unpool(/datum/pathogen)
	P.setup(1)
	R.pathogens += P.pathogen_uid
	R.pathogens[P.pathogen_uid] = P

	return 1
