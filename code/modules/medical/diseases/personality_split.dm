/datum/ailment/disease/personality_split
	name = "Clonal-Memory Development Disorder"
	max_stages = 3
	spread = "Non-Contagious"
	cure_flags = CURE_CUSTOM
	cure_desc = "Methamphetamines"
	reagentcure = list("methamphetamine")
	recureprob = 8
	associated_reagent = "grey_serum"
	affected_species = list("Human")
	can_be_asymptomatic = FALSE

/datum/ailment/disease/personality_split/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(probmult(5))
				affected_mob.say(pick("help", \
				"need help", \
				"help meh.", \
				"wtf where am I.", \
				"I died where am I? how clone?", \
				"fucking grife.", \
				"i've been grifed.", \
				"why I die? what?", \
				"I die for no raison. help.", \
				"need meth."))

			if(probmult(7))
				var/halluc_state = null
				var/halluc_name = null

				switch(rand(1,2))
					if(1)
						halluc_state = "oldclown"
						halluc_name = pick("clown", "ancient clown", "HONK!")
					if(2)
						halluc_state = "oldassistant"
						halluc_name = pick("Staff Assistant", "grifer", "John Tide")

				fake_attackEx(affected_mob, 'icons/effects/hallucinations.dmi', halluc_state, halluc_name)

			if(probmult(5))
				boutput(affected_mob, SPAN_ALERT("You feel nauseous."))
				affected_mob.nauseate(1)


		if(3)
			if(probmult(8))
				var/list/targets = list()
				for (var/mob/living/carbon/human/H in viewers(5, affected_mob))
					if (H == affected_mob)
						continue
					targets += H
				if(length(targets))
					var/mob/living/carbon/human/target = pick(targets)
					var/target_name = target.name
					var/complaint = pick("[target_name] [pick("is killing","is griefing","is trying to kill","just fucking tried to kill")] me", \
					"[target_name] is [pick("chungeeling", "traitor", "a fucking antag", "a grifer")]",\
					"HALP [uppertext(target_name)] IS ATTACKING MEH!!!!", \
					"[uppertext(target_name)] JUST FUCKING [pick("STUNG ME", "SHOT ME", "KILLED MEH", "GRIEFERED ME", "EXPLOADED ME")]!")
					if(prob(50))
						complaint = uppertext(complaint)
					if(prob(33))
						affected_mob.say(";[complaint]")
					else
						affected_mob.say(complaint)

			if(probmult(5))
				var/area/A = get_area(affected_mob)
				var/area_name = A.name
				var/complaint = pick("HELP [uppertext(area_name)]!!!!", \
				"HELP [pick("CHUNGELING", "NUKIES", "BOB", "TRAITORE")] [uppertext(area_name)]", \
				"there's a fucking [pick("BOMB", "BLOB", "NUKE", "WHITEHOLE", "SINGULO", "HUSK", "ABOM")] in [area_name]", \
				"AI DOOR!", \
				"AI LAW 1 OPEN [uppertext(area_name)] DOOR!", \
				"AI ROUGE!", \
				"BORGS [pick("KILLING", "GRIFEING", "EXPLOADING")] MEH IN [uppertext(area_name)]")

				affected_mob.say(";[complaint]")

			if(probmult(10))
				var/halluc_state = null
				var/halluc_name = null

				switch(rand(1,2))
					if(1)
						halluc_state = "oldclown"
						halluc_name = pick("clown", "ancient clown", "HONK!")
					if(2)
						halluc_state = "oldassistant"
						halluc_name = pick("Assistant", "grifer", "John Tide")

				fake_attackEx(affected_mob, 'icons/effects/hallucinations.dmi', halluc_state, halluc_name)

			if(probmult(5))
				boutput(affected_mob, SPAN_ALERT("You feel nauseous."))
				affected_mob.nauseate(3)

			if(probmult(4))
				boutput(affected_mob, SPAN_ALERT("Your head hurts!"))
				affected_mob.take_brain_damage(3)
