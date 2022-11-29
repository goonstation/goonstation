/datum/ailment/disease/space_plague
	name = "Space Plague"
	max_stages = 3
	spread = "Non-Contagious"
	cure = "Mercury"
	associated_reagent = "rat_venom"
	affected_species = list("Human")


/datum/ailment/disease/space_plague/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(1)
			if(probmult(5)) affected_mob.emote(pick("cough", "sneeze"))
			if (probmult(8))
				var/procmessage = pick("You feel utterly horrible.","You feel deathly ill.","You feel like your body is shutting down...")
				boutput(affected_mob, "<span class='alert'>[procmessage]</span>")
		if(2)
			if(probmult(10))
				for(var/datum/ailment/A in affected_mob.ailments)
					affected_mob.take_toxin_damage(1)
			if(probmult(8))
				affected_mob.emote("sneeze")
			if (probmult(8))
				var/procmessage = pick("You feel like you're dying...","Your innards ache horribly.")
				boutput(affected_mob, "<span class='alert'>[procmessage]</span>")
		if(3)
			if(probmult(10))
				for(var/datum/ailment/A in affected_mob.ailments)
					affected_mob.take_toxin_damage(1)
			if(probmult(5))
				affected_mob.emote(pick("cough", "sneeze"))
			if (probmult(8))
				var/procmessage = pick("It feels like you could drop dead any second...","Pain and nausea wrack your entire body.")
				boutput(affected_mob, "<span class='alert'>[procmessage]</span>")
			if(probmult(5))
				for(var/datum/ailment/disease/V in disease_controls.standard_diseases)
					if (istype(V) && V.spread == "Non-Contagious" && prob(10))
						affected_mob.contract_disease(V.type,null,null,1)
		else
			return
