/datum/ailment/disease/dnaspread
	name = "Space Rhinovirus"
	max_stages = 4
	spread = "Airborne"
	cure = "Antibiotics"
	associated_reagent = "liquid dna"
	affected_species = list("Human")
	//Also important for rhinovirus is strain_data on ailment_data/disease, which is where the bioholders transformed from/to are stored

/datum/ailment/disease/dnaspread/on_infection(mob/living/affected_mob, datum/ailment_data/disease/D)
	..()
	D.strain_data["orig_bioholder"] = null // This also functions as a latch so infection only tries transforming you once
	if (!D.strain_data["pzero_bioholder"]) // Oh-hoh-hoo, patient zero~
		var/datum/bioHolder/pzero = new /datum/bioHolder
		pzero.CopyOther(affected_mob.bioHolder)
		D.strain_data["pzero_bioholder"] = pzero //unlike orig_bioholder this one shares the same datum across all infections
		D.state = "Asymptomatic" // We can't turn into ourselves

/datum/ailment/disease/dnaspread/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/disease/D, mult)
	..()
	switch(D.stage)
		if(2, 3) //Pretend to be a cold and give time to spread.
			if(probmult(8))
				affected_mob.emote("sneeze")
			if(probmult(8))
				affected_mob.emote("cough")
			if(probmult(D.stage)) //Making these two slightly spicier than probmult(1)
				boutput(affected_mob, "<span class='alert'>Your muscles ache.</span>")
				if(prob(20))
					random_brute_damage(affected_mob, 1)
			if(probmult(D.stage))
				boutput(affected_mob, "<span class='alert'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.take_toxin_damage(2)
		if(4)
			if (probmult(20) && !D.strain_data["orig_bioholder"] && D.state != "Remissive")
				if (!D.strain_data["pzero_bioholder"])
					affected_mob.cure_disease(src)
					return
				//Save original dna for when the disease is cured.

				var/datum/bioHolder/orig = new /datum/bioHolder
				orig.CopyOther(affected_mob.bioHolder)
				D.strain_data["orig_bioholder"] = orig

				//This is copied from mutagen, I haven't bothered with mutagen-blocked mutantraces
				affected_mob.bioHolder.CopyOther(D.strain_data["pzero_bioholder"])
				affected_mob.real_name = affected_mob.bioHolder.ownerName
				if (affected_mob.bioHolder?.mobAppearance?.mutant_race)
					affected_mob.set_mutantrace(affected_mob.bioHolder.mobAppearance.mutant_race.type)
				affected_mob.UpdateName()

				boutput(affected_mob, "<span class='alert'>You don't feel like yourself..</span>")
				D.state = "Dormant" //Just chill out at stage 4
	return

/datum/ailment/disease/dnaspread/on_remove(mob/living/affected_mob, datum/ailment_data/disease/D)
	if (affected_mob)
		if (D.strain_data["orig_bioholder"])
			affected_mob.bioHolder.CopyOther(D.strain_data["orig_bioholder"])
			affected_mob.real_name = affected_mob.bioHolder.ownerName
			if (affected_mob.bioHolder?.mobAppearance?.mutant_race)
				affected_mob.set_mutantrace(affected_mob.bioHolder.mobAppearance.mutant_race.type)
			affected_mob.UpdateName()
			boutput(affected_mob, "<span class='notice'>You feel more like yourself.</span>")
	..()
