/datum/ailment/disease/cold
	name = "The Cold"
	max_stages = 3
	spread = "Airborne"
	virulence = 30 // Reduced from 100 %. Station-wide, basically incurable and unavoidable epidemics weren't fun (Convair880).
	resistance_prob = 25 // Increased from 0 %.
	cure = "Sleep"
	associated_reagent = "mucus"
	affected_species = list("Human")
//
/datum/ailment/disease/cold/stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(prob(1) && prob(10))
				D.state = "Remissive"
				return
			if(prob(5))
				affected_mob.emote("sneeze")
				for (var/obj/critter/martian/C in range(3,src))
					C.CritterDeath()
			if(prob(5))
				affected_mob.emote("cough")
				for (var/obj/critter/martian/C in range(3,src))
					C.CritterDeath()
			if(prob(1))
				boutput(affected_mob, "<span class='alert'>Your throat feels sore.</span>")
			if(prob(1))
				boutput(affected_mob, "<span class='alert'>Mucous runs down the back of your throat.</span>")
		if(3)
			if(affected_mob.sleeping && prob(25))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
				return
			if(prob(1) && prob(10))
				boutput(affected_mob, "<span class='notice'>You feel better.</span>")
				affected_mob.cure_disease(D)
			if(prob(5))
				affected_mob.emote("sneeze")
				for (var/obj/critter/martian/C in range(3,src))
					C.CritterDeath()
			if(prob(5))
				affected_mob.emote("cough")
				for (var/obj/critter/martian/C in range(3,src))
					C.CritterDeath()
			if(prob(1))
				boutput(affected_mob, "<span class='alert'>Your throat feels sore.</span>")
			if(prob(1))
				boutput(affected_mob, "<span class='alert'>Mucous runs down the back of your throat.</span>")
			if(prob(1) && prob(50))
				boutput(affected_mob, "<span class='alert'>Your cold feels even worse, somehow.</span>")
				D.master = get_disease_from_path(/datum/ailment/disease/flu)
