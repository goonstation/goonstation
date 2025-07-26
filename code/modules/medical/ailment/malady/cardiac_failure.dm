/datum/ailment/malady/heartfailure
	name = "Cardiac Failure"
	scantype = "Medical Emergency"
	info = "The patient is having a cardiac emergency."
	max_stages = 3
	cure_flags = CURE_CUSTOM
	cure_desc = "Cardiac Stimulants"
	reagentcure = list("atropine"=8,"epinephrine"=10,"heparin"=5)
	affected_species = list("Human","Monkey")
	stage_advance_prob = 5

/datum/ailment/malady/heartfailure/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/malady/D, mult)
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
		else if (H.organHolder.heart && H.organHolder.heart.robotic && !H.organHolder.heart.broken && !D.robo_restart)
			var/datum/organHolder/oH = H.organHolder
			boutput(H, SPAN_ALERT("Your cyberheart detects a cardiac event and attempts to return to its normal rhythm!"))
			if (probmult(40) && oH.heart.emagged)
				D.robo_restart = 1
				SPAWN(oH.heart.emagged ? 200 : 300)
					D.robo_restart = 0
				SPAWN(3 SECONDS)
					if (H)
						H.cure_disease(D)
						boutput(H, SPAN_ALERT("Your cyberheart returns to its normal rhythm!"))
					return
			else if (probmult(25))
				D.robo_restart = 1
				SPAWN(oH.heart.emagged ? 200 : 300)
					D?.robo_restart = 0
				SPAWN(3 SECONDS)
					if (H)
						H.cure_disease(D)
						boutput(H, SPAN_ALERT("Your cyberheart returns to its normal rhythm!"))
					return
			else
				D.robo_restart = 1
				SPAWN(oH.heart.emagged ? 200 : 300)
					D?.robo_restart = 0
				SPAWN(3 SECONDS)
					if (H)
						boutput(H, SPAN_ALERT("Your cyberheart fails to return to its normal rhythm!"))

	switch (D.stage)
		if (1)
			if (probmult(0.1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.cure_disease(D)
				return
			if (probmult(8))
				affected_mob.emote(pick("pale", "shudder"))
			if (probmult(5))
				boutput(affected_mob, SPAN_ALERT("Your arm hurts!"))
			else if (probmult(5))
				boutput(affected_mob, SPAN_ALERT("Your chest hurts!"))
		if (2)
			if (probmult(0.1))
				boutput(affected_mob, SPAN_NOTICE("You feel better."))
				affected_mob.cure_disease(D)
				return
			if (probmult(8))
				affected_mob.emote(pick("pale", "groan"))
			if (probmult(5))
				boutput(affected_mob, SPAN_ALERT("Your heart lurches in your chest!"))
				affected_mob.losebreath++
			if (probmult(3))
				boutput(affected_mob, SPAN_ALERT("Your heart stops beating!"))
				affected_mob.losebreath+=3
			if (probmult(5))
				affected_mob.emote(pick("faint", "collapse", "groan"))
		if (3)
			affected_mob.take_oxygen_deprivation(1)
			if (probmult(8))
				affected_mob.emote(pick("twitch", "gasp"))
			if (probmult(1) && !affected_mob.hasStatus("defibbed")) // down from 5
				affected_mob.contract_disease(/datum/ailment/malady/flatline,null,null,1)
