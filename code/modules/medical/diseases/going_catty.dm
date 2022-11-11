/datum/ailment/disease/going_catty
	name = "Toxoplasmosis"
	max_stages = 4
	spread = "Non-Contagious"
	cure = "Antibiotics"
	associated_reagent = "mewtini"
	reagentcure = list("spaceacillin")
	affected_species = list("Human")

/datum/ailment/disease/going_catty/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(probmult(5))
				affected_mob.emote("yawn")
		if(3)
			if(probmult(6))
				boutput(affected_mob, "<span class='alert'>You feel like your ears itch.</span>")
			if(probmult(3))
				affected_mob.emote("stretch")
			if(probmult(2))
				boutput(affected_mob, "<span class='alert'>You feel your tailbone bending.</span>")
			if(probmult(2))
				boutput(affected_mob, "<span class='alert'>You feel your body contort... And like you could use some milk.</span>")
		if(4)
			boutput(affected_mob, "<span class='alert'>You feel your physical form condensing into something hairy and small... Uh oh...</span>")
			affected_mob.visible_message("<span class='alert'><b>[affected_mob] transforms!</b></span>")
			affected_mob.unequip_all()
			logTheThing(LOG_COMBAT, affected_mob, "is transformed into a critter cat by the [name] reagent at [log_loc(affected_mob)].")
			affected_mob.make_critter(/mob/living/critter/small_animal/cat)
