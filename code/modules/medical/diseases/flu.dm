/datum/ailment/disease/flu
	name = "The Flu"
	max_stages = 3
	spread = "Airborne"
	virulence = 30 // Reduced from 100 %. Station-wide, basically incurable and unavoidable epidemics weren't fun (Convair880).
	resistance_prob = 25 // Increased from 0 %.
	cure = "Sleep"
	associated_reagent = "green mucus"
	affected_species = list("Human")

/datum/ailment/disease/flu/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				boutput(affected_mob, "<span style=\"color:red\">Your muscles ache.</span>")
				if(prob(20))
					random_brute_damage(affected_mob, 1)
			if(prob(1))
				boutput(affected_mob, "<span style=\"color:red\">Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.take_toxin_damage(1)
					affected_mob.updatehealth()

		if(3)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				boutput(affected_mob, "<span style=\"color:red\">Your muscles ache.</span>")
				if(prob(20))
					random_brute_damage(affected_mob, 1)
			if(prob(1))
				boutput(affected_mob, "<span style=\"color:red\">Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.take_toxin_damage(1)
					affected_mob.updatehealth()
