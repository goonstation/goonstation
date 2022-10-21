/datum/ailment/disease/edisons_disease
	name = "Edison's Disease"
	max_stages = 8
	spread = "Sight"
	cure = "Phthalocyanine"
	reagentcure = list("phthalocyanine")
	recureprob = 50
	stage_prob = 3
	resistance_prob = 40
	//associated_reagent = ""
	affected_species = list("Human")
	var/list/symptom_list_minor = list("brighter...", "as if it has a colored halo.", "luminescent.", "beautiful and shiny!")
	var/list/symptom_list_moderate = list("You feel hot.", "The light hurts your eyes!", "Your face stings!")
	var/list/symptom_list_severe = list("Your head is pounding!", "Your head feels like it is going to explode!", "You feel like you're about to catch on fire!", "Water... Need water...", "Your skin burns.")

	proc
		cause_blindness(var/mob/living/affected_mob)
			affected_mob.contract_disease(/datum/ailment/disability/blind, null, null, 1)
			boutput(affected_mob, "<span class='alert'>The world goes white!</span>")
		update_light(var/atom/affected, var/luminosity)
			// TODO: port to the new lighting system, I have no fucking idea how I'm meant to store the light datum
			/*affected.sd_SetLuminosity(luminosity)
			affected.sd_SetColor((255 - rand(0, 40))/255, (255 - rand(10,90)) / 255, (255 - rand(15, 110)) / 255)*/

/datum/ailment/disease/edisons_disease/on_infection(var/mob/living/affected_mob,var/datum/ailment_data/D)
	boutput(affected_mob, "<span class='alert'>Your eyes feel strange...</span>")

/datum/ailment/disease/edisons_disease/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if(D.stage >= 2)
		if(prob(50))
			update_light(affected_mob, D.stage)

		if(D.stage < 3)
			if(probmult(25))
				boutput(affected_mob, "<span class='alert'>Everything looks... </span>" + pick(symptom_list_minor))
		else if(D.stage < 5)
			if(probmult(25))
				boutput(affected_mob, "<span class='alert'> </span>" + pick(symptom_list_moderate))
			if(probmult(5))
				cause_blindness(affected_mob)
			if(probmult(5))
				affected_mob.TakeDamage("All", 0, 2, 0, DAMAGE_BURN)
				boutput(affected_mob, "<span class='alert'>You feel hot.</span>")
		else if(D.stage < 7)
			if(probmult(25))
				boutput(affected_mob, "<span class='alert'> </span>" + pick(symptom_list_severe))
			if(probmult(30))
				cause_blindness(affected_mob)
			if(probmult(10))
				affected_mob.TakeDamage("All", 0, 5, 0, DAMAGE_BURN)
				boutput(affected_mob, "<span class='alert'>You feel very hot!</span>")
		else
			if(probmult(80))
				cause_blindness(affected_mob)
			if(probmult(20))
				affected_mob.TakeDamage("All", 0, 10, 0, DAMAGE_BURN)
				boutput(affected_mob, "<span class='alert'>It burns!</span>")
			if(probmult(50))
				// Stole this shit from GBS
				for(var/mob/O in viewers(affected_mob, null))
					O.show_message(text("<span class='alert'><B>[]</B> starts convulsing violently!</span>", affected_mob), 1)
				affected_mob.changeStatus("weakened", 15 SECONDS)
				affected_mob.make_jittery(1000)
				SPAWN(rand(20, 100))
					if (affected_mob)
						logTheThing(LOG_COMBAT, affected_mob, "was gibbed by the disease [name] at [log_loc(affected_mob)].")
						var/list/gibs = affected_mob.gib()
						for(var/obj/decal/cleanable/gib in gibs)
							update_light(gib, rand(2,6))
				return
	else
		return
