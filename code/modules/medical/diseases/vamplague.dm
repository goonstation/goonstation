/datum/ailment/disease/vamplague
	name = "Grave Fever"
	max_stages = 3
	spread = "Non-Contagious"
	cure = "Antibiotics"
	recureprob = 20
	associated_reagent = "grave dust"
	affected_species = list("Human")

// Buffed this somewhat, as grave fever was quite underwhelming (Convair880).
/datum/ailment/disease/vamplague/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return

	var/toxdamage = D.stage * 2
	var/stuntime = D.stage * 2

	if (prob(10))
		affected_mob.emote(pick("cough","groan", "gasp"))
		affected_mob.losebreath++

	if (prob(15))
		if (prob(33))
			boutput(affected_mob, "<span class='alert'>You feel sickly and weak.</span>")
			affected_mob.changeStatus("slowed", 30)
		affected_mob.take_toxin_damage(toxdamage)

	if (prob(5))
		boutput(affected_mob, "<span class='alert'>Your joints ache horribly!</span>")
		affected_mob.changeStatus("weakened", stuntime * 10)
		affected_mob.changeStatus("stunned", stuntime * 10)

//The other vamplague, the one that makes vampires
/datum/ailment/disease/vampiritis
	name = "Draculaculiasis"
	max_stages = 3
	stage_prob = 9
	spread = "Non-Contagious"
	cure = "None"
	associated_reagent = "vampire_serum"
	affected_species = list("Human")

	stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
		if (..())
			return

		if (isvampire(affected_mob))
			affected_mob.cure_disease(D)
			return

		if (D.stage < max_stages)
			if (prob(5))
				affected_mob.emote(pick("shiver", "pale"))
			if (prob(8))
				boutput(affected_mob, "<span class='alert'>You taste blood.  Gross.</span>")
			if (prob(5))
				affected_mob.emote(pick("shiver","pale","drool"))

		else
			if (prob(40))
				boutput(affected_mob, "<span class='alert'>Your heart stops...</span>")
				affected_mob.playsound_local(affected_mob.loc, "heartbeat.ogg", 50, 1)
				affected_mob.emote("collapse")

				affected_mob.make_vampire(FALSE, TRUE)
				affected_mob.cure_disease(D)
