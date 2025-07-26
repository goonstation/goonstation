/datum/ailment/parasite/spidereggs
	name = "Spider Eggs"
	max_stages = 5
	stage_advance_prob = 8
	affected_species = list("Human", "Monkey")

/datum/ailment/parasite/spidereggs/surgery(var/mob/living/surgeon, var/mob/living/affected_mob, var/datum/ailment_data/D)
	if (D.disposed)
		return 0
	if (affected_mob.reagents.has_reagent("spidereggs"))
		affected_mob.reagents.del_reagent("spidereggs")
	var/outcome = rand(90)
	if (surgeon.traitHolder.hasTrait("training_medical"))
		outcome += 10
	var/numb = affected_mob.reagents.has_reagent("morphine") || affected_mob.sleeping
	switch (outcome)
		if (0 to 5)
			// im doctor
			surgeon.visible_message(SPAN_ALERT("<b>[surgeon] cuts open [affected_mob] in all the wrong places!</b>"), "You dig around in [affected_mob]'s chest and accidentally snip something important looking!")
			affected_mob.show_message(SPAN_ALERT("<b>You feel a [numb ? "numb" : "sharp"] stabbing pain in your chest!</b>"))
			affected_mob.TakeDamage("chest", numb ? 37.5 : 75, 0, 0, DAMAGE_CUT)
			return 0
		if (6 to 15)
			surgeon.visible_message(SPAN_ALERT("<b>[surgeon] clumsily cuts open [affected_mob]!</b>"), "You dig around in [affected_mob]'s chest and accidentally snip something not so important looking!")
			affected_mob.show_message(SPAN_ALERT("<b>You feel a [numb ? "mild " : " "]stabbing pain in your chest!</b>"))
			affected_mob.TakeDamage("chest", numb ? 20 : 40, 0, 0, DAMAGE_CUT)
			return 0
		if (16 to 60)
			var/around_msg = ""
			var/self_msg = ""
			var/success = 0
			if (prob(50))
				around_msg = SPAN_NOTICE("<b>[surgeon] cuts open [affected_mob] and removes some [name].</b>")
				self_msg = SPAN_NOTICE("You remove some [name] from [affected_mob]. You can still see some of it in there, though.")
			else
				around_msg = SPAN_NOTICE("<b>[surgeon] cuts open [affected_mob] and removes the remaining [name].</b>")
				self_msg = SPAN_NOTICE("You remove the remaining [name] from [affected_mob].")
				success = 1
			surgeon.visible_message(around_msg, self_msg)
			if (!numb)
				affected_mob.show_message(SPAN_ALERT("<b>You feel a mild stabbing pain in your chest!</b>"))
				affected_mob.TakeDamage("chest", 10, 0, 0, DAMAGE_STAB)
			return success
		if (61 to INFINITY)
			surgeon.visible_message(SPAN_NOTICE("<b>[surgeon] cuts open [affected_mob] and removes all traces of [name]</b>"), SPAN_NOTICE("You masterfully remove the [name] from [affected_mob]."))
			if (!numb)
				affected_mob.show_message(SPAN_ALERT("<b>You feel a mild stabbing pain in your chest!</b>"))
				affected_mob.TakeDamage("chest", 10, 0, 0, DAMAGE_STAB)
			return 1


/datum/ailment/parasite/spidereggs/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(2)
			if(probmult(3))
				affected_mob.reagents.add_reagent("histamine", 2)
		if(3)
			if(probmult(5))
				affected_mob.reagents.add_reagent("histamine", 3)
		if(4)
			if(probmult(12))
				affected_mob.reagents.add_reagent("histamine", 5)
		if(5)
			boutput(affected_mob, SPAN_ALERT("You feel like something is tearing its way out of your skin..."))
			affected_mob.reagents.add_reagent("histamine", 10 * mult)
			if(probmult(30))
				affected_mob.emote("scream")
				var/babyspiders = null
				babyspiders = rand(3,5)
				if(prob(1))
					babyspiders = rand(6,12)
				while(babyspiders-- > 0)
					new /mob/living/critter/spider/ice/baby(affected_mob.loc)
				affected_mob.visible_message(SPAN_ALERT("<b>[affected_mob] bursts open! Holy fuck!</b>"))
				logTheThing(LOG_COMBAT, affected_mob, "was gibbed by the disease [name] at [log_loc(affected_mob)].")
				affected_mob:gib()
				return
