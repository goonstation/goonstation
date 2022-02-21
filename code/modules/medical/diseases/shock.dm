/*
/datum/ailment/disease/shock
	name = "Shock"
	scantype = "Medical Emergency"
	max_stages = 3
	spread = "The patient is in shock."
	cure = "Saline Solution"
	reagentcure = list("saline")
	recureprob = 10
	affected_species = list("Human","Monkey")
	stage_prob = 6

/datum/ailment/disease/shock/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	if(affected_mob.health >= 25)
		boutput(affected_mob, "<span class='notice'>You feel better.</span>")
		affected_mob.cure_disease(D)
		return
	switch(D.stage)
		if(1)
			if(prob(1) && prob(10))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
				return
			if(prob(8)) affected_mob.emote(pick("shiver", "pale", "moan"))
			if(prob(5))
				boutput(affected_mob, "<span class='alert'>You feel weak!</span>")
		if(2)
			if(prob(1) && prob(10))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
				return
			if(prob(8)) affected_mob.emote(pick("shiver", "pale", "moan", "shudder", "tremble"))
			if(prob(5))
				boutput(affected_mob, "<span class='alert'>You feel absolutely terrible!</span>")
			if(prob(5)) affected_mob.emote("faint", "collapse", "groan")
		if(3)
			if(prob(1) && prob(10))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
				return
			if(prob(8)) affected_mob.emote(pick("shudder", "pale", "tremble", "groan", "shake"))
			if(prob(5))
				boutput(affected_mob, "<span class='alert'>You feel horrible!</span>")
			if(prob(5)) affected_mob.emote(pick("faint", "collapse", "groan"))
			if(prob(7))
				boutput(affected_mob, "<span class='alert'>You can't breathe!</span>")
				affected_mob.losebreath++
			if(prob(5))
				affected_mob.contract_disease(/datum/ailment/disease/heartfailure,null,null,1)
*/
