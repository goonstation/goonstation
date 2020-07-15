/* -------------------- Neurogenic Shock -------------------- */
/datum/ailment/malady/brainfailure
	name = "Traumatic Brain Injury"
	scantype = "Medical Emergency"
	info = "The patient is having a neurophysiological emergency."
	max_stages = 3
	cure = "Neuro-Stimulants"
	reagentcure = list( "coffee" = list(1,10),	// Sort of a stimulant
						"espresso" = 1,			// Even slightly more of a stimulant
						"saline" = 2,			// 
						"mannitol" = 5, 		// Brain meds
						"epinephrine" = 5, 		// 
						"synaptizine" = 15)) 	// i like synaptizine :D
	recureprob = 10
	affected_species = list("Human","Monkey")
	stage_prob = 5

/datum/ailment/malady/brainfailure/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/malady/D)
	if (..())
		return

	if (ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if (!H.organHolder)
			H.cure_disease(D)
			return
		if (!H.organHolder.brain)
			H.cure_disease(D)
			return

	switch (D.stage)
		if (1)
			if (prob(1) && prob(10))
				boutput(affected_mob, "<span class='notice'>Your head feels somewhat less painful.</span>")
				affected_mob.cure_disease(D)
				return
			if (prob(5))
				affected_mob.changeStatus("slowed", rand(10,20))
				affected_mob.change_misstep_chance(3)
				boutput(affected_mob, "<span class='alert'>You suddenly find yourself struggling to keep balance.</span>")
			if (prob(8))
				affected_mob.emote(pick("pale", "shudder"))
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>A clear, slippery fluid drips from your nose.</span>")
				affected_mob.take_brain_damage(1)
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>Your [pick("nose starts", "ears start"] bleeding.</span>")
				affected_mob.take_bleeding_damage(affected_mob, null, 0, DAMAGE_STAB, 1)
			else if(prob(12))
				affected_mob.stuttering = max(10, affected_mob.stuttering)
				boutput(affected_mob, "<span class='alert'>You feel [pick("numb", "confused", "dizzy", "dazed")].</span>")
				affected_mob.emote("collapse")

		if (2)
			if (prob(8))
				boutput(affected_mob, "<span class='alert'>Your head [pick("feels like shit","hurts like fuck","pounds horribly","twinges with an awful pain")].</span>")
				affected_mob.emote(pick("groan", "grimace"))
				affected_mob.change_misstep_chance(3)
			if (prob(5))
				affected_mob.changeStatus("slowed", rand(30,45))
				affected_mob.change_misstep_chance(4)
				boutput(affected_mob, "<span class='alert'>Your legs feel [pick("oddly ","")]weak.</span>")
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>A clear, slippery fluid seeps from your nose.</span>")
				affected_mob.take_brain_damage(1)
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>You sneeze, spraying blood everywhere!</span>")
				affected_mob.bleed(affected_mob, 2, 2)
			if (prob(8))
				affected_mob.emote("gasp")
				affected_mob.losebreath+=3
			if (prob(12))
				boutput(affected_mob, "<span class='alert'>You feel [pick("numb", "confused", "dizzy", "dazed")].</span>")
				affected_mob.drowsyness += 2
			if (prob(1) && prob(1) && prob(1))	// Thanks, find+replace!
				boutput(affected_mob, "<span class='alert'>Your brain stops beating!</span>")
				affected_mob.losebreath+=3
			if(prob(12))
				affected_mob.stuttering = max(10, affected_mob.stuttering)
				boutput(affected_mob, "<span class='alert'>You feel [pick("numb", "confused", "dizzy", "dazed")].</span>")
				affected_mob.emote("collapse")
			else if (prob(2))
				boutput(affected_mob, "<span class='alert'>Your head hurts!</span>")
				affected_mob.take_brain_damage(1)

		if (3)
			affected_mob.take_oxygen_deprivation(1)
			if (prob(8))
				affected_mob.emote(pick("twitch", "gasp", "collapse", "faint"))
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>A clear, slippery fluid seeps from your nose.</span>")
				owner.take_brain_damage(1)
			if (prob(12))
				boutput(affected_mob, "<span class='alert'>You feel [pick("numb", "confused", "dizzy", "dazed")].</span>")
				affected_mob.drowsyness += 3
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>Your [pick("nose starts", "ears start"] bleeding!</span>")
				take_bleeding_damage(affected_mob, null, 1, DAMAGE_STAB, 1)
			if (prob(2))
				boutput(affected_mob, "<span class='alert'>Your head hurts!</span>")
				affected_mob.take_brain_damage(1)
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>You sneeze, spraying blood everywhere!</span>")
				affected_mob.bleed(affected_mob, 2, 2)
			if (prob(8))
				affected_mob.emote("gasp")
				affected_mob.losebreath+=10
			if(prob(12))
				affected_mob.stuttering = max(10, affected_mob.stuttering)
				boutput(affected_mob, "<span class='alert'>You feel [pick("numb", "confused", "dizzy", "dazed")].</span>")
				affected_mob.emote("collapse")
			if (prob(5))
				affected_mob.changeStatus("slowed", rand(60,120))
				affected_mob.change_misstep_chance(5)
				boutput(affected_mob, "<span class='alert'>Your legs feel very weak.</span>")
			if (prob(1)) // down from 5
				affected_mob.contract_disease(/datum/ailment/malady/coma,null,null,1)
				
				
/* -------------------- Headache -------------------- */
/datum/ailment/malady/headache
	name = "Cephalgia"
	scantype = "Unpleasant Symptom"
	info = "The patient has a headache."
	max_stages = 3
	cure = "Analgesics"
	reagentcure = list( "salicylic_acid" = 10,	// 
						"morphine" = 75,		// hecka painkiller
						"synaptizine" = 25) 	// i like synaptizine :D
	recureprob = 10
	affected_species = list("Human","Monkey")
	stage_prob = 5

/datum/ailment/malady/headache/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/malady/D)
	if (..())
		return

	if (ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if (!H.organHolder)
			H.cure_disease(D)
			return
		if (!H.organHolder.brain)
			H.cure_disease(D)
			return

	switch (D.stage)
		if (1)
			if (prob(1) && prob(10))
				boutput(affected_mob, "<span class='notice'>Your headache passes.</span>")
				affected_mob.cure_disease(D)
				return
			if (prob(8))
				affected_mob.emote(pick("groan", "grimace, blink_r"))
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>Your head hurts.</span>")

		if (2)
			if (prob(8))
				affected_mob.emote(pick("groan", "grimace", "cry", "weep", "moan))
			if (prob(5))
				boutput(affected_mob, "<span class='alert'>A sudden sharp pain shoots through your head, throwing off your balance!</span>")
				affected_mob.change_misstep_chance(1)
			if (prob(3))
				if (owner.stuttering <= 5)
					owner.stuttering++
			if (prob(5))
				affected_mob.emote(pick("faint", "collapse", "groan"))

		if (3)
			affected_mob.take_oxygen_deprivation(1)
			if (prob(8))
				affected_mob.emote(pick("groan", "grimace", "cry", "weep", "moan))
			if (prob(8))
				affected_mob.emote(pick("groan", "grimace, blink_r"))
			if (owner.get_eye_blurry() <= 5)
				boutput(affected_mob, "<span class='alert'>You feel a nagging pressure behind your eyes!</span>")
				owner.change_eye_blurry(2)
			if (prob(8))
				boutput(affected_mob, "<span class='alert'>The pain in your head is making it hard to walk straight!</span>")
				affected_mob.change_misstep_chance(3)
			if (prob(5))
				affected_mob.emote(pick("faint", "collapse", "groan"))
			if (prob(5))
				if (owner.stuttering <= 5)
					owner.stuttering++


