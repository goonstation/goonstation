/datum/ailment/disease/rat_plague
	name = "Rat Plague"
	max_stages = 4
	spread = "Non-Contagious"
	cure = "Mercury"
	reagentcure = list("mercury")
	associated_reagent = "rat_spit"
	stage_prob = 6
	affected_species = list("Human")


/datum/ailment/disease/rat_plague/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(1)
			if(probmult(5)) affected_mob.emote(pick("cough", "sneeze"))
			if (probmult(8))
				var/procmessage = pick("You start to shiver.","You feel deathly ill.","Your heart is beating hard in your chest...")
				boutput(affected_mob, "<span class='alert'>[procmessage]</span>")
		if(2)
			if(probmult(10))
				for(var/datum/ailment/A in affected_mob.ailments)
					affected_mob.take_toxin_damage(1)
			if(probmult(8))
				affected_mob.emote(pick("sneeze", "cough", "pale"))
			if (probmult(8))
				var/procmessage = pick("Your heart is beating irregularly...","Your whole body aches.","You feel the blood rush in your temples.")
				boutput(affected_mob, "<span class='alert'>[procmessage]</span>")
		if(3)
			if(probmult(15))
				for(var/datum/ailment/A in affected_mob.ailments)
					affected_mob.take_toxin_damage(2)
			if(probmult(10))
				affected_mob.emote(pick("sneeze", "cough", "pale"))
			if (probmult(8))
				var/procmessage = pick("Your entire body hurts...","You just want to ball up in a corner and let the pain pass.","The suffering is unbearable.")
				boutput(affected_mob, "<span class='alert'>[procmessage]</span>")
		if(4)
			if(probmult(10))
				for(var/datum/ailment/A in affected_mob.ailments)
					affected_mob.take_toxin_damage(2)
			if(probmult(5))
				affected_mob.emote(pick("cough", "sneeze", "pale"))
			if (probmult(5))
				var/procmessage = pick("It feels like you could drop dead any second...","You are getting worse by the minute.")
				boutput(affected_mob, "<span class='alert'>[procmessage]</span>")
			if(probmult(4))
				var/list/disease_list = list(/datum/ailment/disease/tissue_necrosis,
				/datum/ailment/disease/space_madness,
				/datum/ailment/parasite/bee_larva,
				/datum/ailment/malady/hypoglycemia,
				/datum/ailment/malady/bloodclot,
				/datum/ailment/malady/heartdisease,
				/datum/ailment/disease/food_poisoning,
				/datum/ailment/disease/flu,
				/datum/ailment/disease/clowning_around,
				/datum/ailment/disease/berserker,
				/datum/ailment/disease/appendicitis,
				/datum/ailment/disease/liver_failure,
				/datum/ailment/disease/infection)
				affected_mob.contract_disease(pick(disease_list),null,null,1)
		else
			return
