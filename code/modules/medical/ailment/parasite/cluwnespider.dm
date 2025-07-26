/datum/ailment/parasite/cluwnespider
	name = "Spider Eggs"
	max_stages = 5
	stage_advance_prob = 5
	affected_species = list("Human", "Monkey")
	high_temeprature_cure = INFINITY

/datum/ailment/parasite/cluwnespider/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if (2,3)
			if(probmult(1))
				affected_mob.emote("sneeze")
			if(probmult(1))
				affected_mob.emote("cough")
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your throat feels sore."))
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Mucous runs down the back of your throat."))
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("You think you've gotten on the bad end of a joke."))
		if(4)
			if(probmult(1))
				affected_mob.emote("sneeze")
			if(probmult(1))
				affected_mob.emote("cough")
			if(probmult(2))
				boutput(affected_mob, SPAN_ALERT("Your stomach feels funny, but like a BAD attempt of being funny."))
				if(prob(20))
					affected_mob.take_toxin_damage(1)
		if(5)
			boutput(affected_mob, SPAN_ALERT("You feel something tearing its way out of your stomach..."))
			if (affected_mob.get_toxin_damage() < 30)
				affected_mob.take_toxin_damage(10 * mult)

			if(probmult(40))
				var/babyspiders = null
				babyspiders = rand(3,5)
				while(babyspiders-- > 0)
					var/mob/living/critter/spider/clown/cluwne/larva = new /mob/living/critter/spider/clown/cluwne (get_turf(affected_mob))
					larva.name = "li'l [affected_mob:real_name]"

				playsound(affected_mob.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
				affected_mob.visible_message(SPAN_ALERT("<b>[affected_mob] horks up a cluwnespider! Run!</b>"), SPAN_ALERT("<b>You cough up...a OH GOD FUCK FUCK FUCK.</b>"))

				affected_mob.cure_disease(D)
