/datum/ailment/disease/kuru
	name = "Space Kuru"
	max_stages = 4
	cure = "Incurable"
	associated_reagent = "prions"
	affected_species = list("Human")

/datum/ailment/disease/kuru/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	switch(D.stage)
		if(1)
			if (prob(50))
				affected_mob.emote("laugh")
			if (prob(50))
				affected_mob.make_jittery(25)
		if(2)
			if (prob(50))
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(text("<span style=\"color:red\"><B>[]</B> laughs uncontrollably!</span>", affected_mob), 1)
				affected_mob.changeStatus("stunned", 10 SECONDS)
				affected_mob.changeStatus("weakened", 10 SECONDS)
				affected_mob.make_jittery(250)
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
		if(3)
			if(prob(25))
				boutput(affected_mob, "<span style=\"color:red\">You feel like you are about to drop dead!</span>")
				boutput(affected_mob, "<span style=\"color:red\">Your body convulses painfully!</span>")
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				random_brute_damage(affected_mob, 5)
				affected_mob.take_oxygen_deprivation(5)
				affected_mob.updatehealth()
				affected_mob.changeStatus("stunned", 10 SECONDS)
				affected_mob.changeStatus("weakened", 10 SECONDS)
				affected_mob.make_jittery(250)
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(text("<span style=\"color:red\"><B>[]</B> laughs uncontrollably!</span>", affected_mob), 1)
		if(4)
			if(prob(25))
				boutput(affected_mob, "<span style=\"color:red\">You feel like you are going to die!</span>")
				affected_mob.take_oxygen_deprivation(75)
				random_brute_damage(affected_mob, 75)
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				affected_mob.changeStatus("stunned", 10 SECONDS)
				affected_mob.changeStatus("weakened", 10 SECONDS)
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(text("<span style=\"color:red\"><B>[]</B> laughs uncontrollably!</span>", affected_mob), 1)










