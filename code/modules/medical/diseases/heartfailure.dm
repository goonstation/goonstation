/*
/datum/ailment/disease/heartfailure
	name = "Cardiac Failure"
	scantype = "Medical Emergency"
	max_stages = 3
	spread = "The patient is having a cardiac emergency."
	cure = "Cardiac Stimulants"
	reagentcure = list("atropine" = 8, // atropine is used to treat bradycardia (very low heart rates)
	"epinephrine" = 10,
	"heparin",
	"nitroglycerin")
	recureprob = 10
	affected_species = list("Human")
	stage_prob = 5
	var/robo_restart = 0

/datum/ailment/disease/heartfailure/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if (ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if (!H.organHolder)
			H.cure_disease(D)
			return
		if (!H.organHolder.heart)
			H.cure_disease(D)
			return
		else if (H.organHolder.heart && H.organHolder.heart.robotic && !H.organHolder.heart.broken && !src.robo_restart)
			var/datum/organHolder/oH = H.organHolder
			boutput(H, "<span class='alert'>Your cyberheart detects a cardiac event and attempts to return to its normal rhythm!</span>")
			if (prob(40) && oH.heart.emagged)
				src.robo_restart = 1
				SPAWN(oH.heart.emagged ? 200 : 300)
					src.robo_restart = 0
				SPAWN(3 SECONDS)
					if (H)
						H.cure_disease(D)
						boutput(H, "<span class='alert'>Your cyberheart returns to its normal rhythm!</span>")
					return
			else if (prob(25))
				src.robo_restart = 1
				SPAWN(oH.heart.emagged ? 200 : 300)
					src.robo_restart = 0
				SPAWN(3 SECONDS)
					if (H)
						H.cure_disease(D)
						boutput(H, "<span class='alert'>Your cyberheart returns to its normal rhythm!</span>")
					return
			else
				src.robo_restart = 1
				SPAWN(oH.heart.emagged ? 200 : 300)
					src.robo_restart = 0
				SPAWN(3 SECONDS)
					if (H)
						boutput(H, "<span class='alert'>Your cyberheart fails to return to its normal rhythm!</span>")

	switch (D.stage)
		if (1)
			if (prob(1) && prob(10))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
				return
			if (prob(8))
				affected_mob.emote(pick("pale", "shudder"))
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>Your arm hurts!</span>")
			else if (prob(5))
				boutput(affected_mob, "<span class='alert'>Your chest hurts!</span>")
		if (2)
			if (prob(1) && prob(10))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.resistances += src.type
				affected_mob.ailments -= src
				return
			if (prob(8))
				affected_mob.emote(pick("pale", "groan"))
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>Your heart lurches in your chest!</span>")
				affected_mob.losebreath++
			if (prob(3))
				boutput(affected_mob, "<span class='alert'>Your heart stops beating!</span>")
				affected_mob.losebreath+=3
			if (prob(5))
				affected_mob.emote(pick("faint", "collapse", "groan"))
		if (3)
			affected_mob.take_oxygen_deprivation(1)
			if (prob(8))
				affected_mob.emote(pick("twitch", "gasp"))
			if (prob(1)) // down from 5
				affected_mob.contract_disease(/datum/ailment/disease/flatline,null,null,1)
*/
