/datum/ailment/disease/vamplague
	name = "Grave Fever"
	max_stages = 4
	spread = "Non-Contagious"
	cure_flags = CURE_ANTIBIOTICS
	associated_reagent = "grave dust"
	affected_species = list("Human")

// Buffed this somewhat, as grave fever was quite underwhelming (Convair880).
/datum/ailment/disease/vamplague/stage_act(mob/living/affected_mob,datum/ailment_data/D,mult)
	if (..())
		return

	var/toxdamage = (D.stage-1) * 3
	var/stuntime = (D.stage-1) * 3

	if (probmult(10))
		affected_mob.emote(pick("cough","groan", "gasp"))
		affected_mob.losebreath++

	if (probmult(15))
		if (prob(33))
			boutput(affected_mob, SPAN_ALERT("You feel sickly and weak."))
			affected_mob.changeStatus("slowed", 3 SECONDS, (D.stage-1) * 3)
		affected_mob.take_toxin_damage(toxdamage)
		affected_mob.organHolder?.damage_organ(tox=toxdamage, organ=pick("heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix"))

	if (probmult(10))
		boutput(affected_mob, SPAN_ALERT("Your joints ache horribly!"))
		affected_mob.changeStatus("knockdown", stuntime SECONDS)
		affected_mob.changeStatus("stunned", stuntime SECONDS)
		affected_mob.take_toxin_damage(toxdamage * 2)

//The other vamplague, the one that makes vampires
/datum/ailment/disease/vampiritis
	name = "Draculaculiasis"
	max_stages = 3
	stage_prob = 9
	spread = "Non-Contagious"
	cure_flags = CURE_UNKNOWN
	associated_reagent = "vampire_serum"
	affected_species = list("Human")

	stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
		if (..())
			return

		if (isvampire(affected_mob))
			affected_mob.cure_disease(D)
			return

		if (D.stage < max_stages)
			if (probmult(5))
				affected_mob.emote(pick("shiver", "pale"))
			if (probmult(8))
				boutput(affected_mob, SPAN_ALERT("You taste blood.  Gross."))
			if (probmult(5))
				affected_mob.emote(pick("shiver","pale","drool"))

		else
			if (probmult(40))
				boutput(affected_mob, SPAN_ALERT("Your heart stops..."))
				affected_mob.playsound_local(affected_mob.loc, 'sound/effects/heartbeat.ogg', 50, 1)
				affected_mob.emote("collapse")

				affected_mob.mind?.add_antagonist(ROLE_VAMPIRE, do_pseudo = TRUE)
				affected_mob.cure_disease(D)
