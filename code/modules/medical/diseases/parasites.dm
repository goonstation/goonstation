/datum/ailment/parasite/spidereggs
	name = "Spider Eggs"
	max_stages = 5
	stage_prob = 8
	affected_species = list("Human", "Monkey")
//

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

/datum/ailment/parasite/cluwnespider
	name = "Spider Eggs"
	max_stages = 5
	stage_prob = 5
	affected_species = list("Human", "Monkey")
	temperature_cure = INFINITY

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

//IBM note: haha this is the dumbest thing I have ever coded
/datum/ailment/parasite/bee_larva
	name = "Unidentified Foreign Body"
	max_stages = 5
	stage_prob = 8
	affected_species = list("Human", "Monkey")
	temperature_cure = INFINITY
//

/datum/ailment/parasite/bee_larva/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if (2, 3)
			if(probmult(1))
				affected_mob.emote("sneeze")
			if(probmult(1))
				affected_mob.emote("cough")
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Your throat feels sore."))
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("Mucous runs down the back of your throat."))
		if(4)
			if(probmult(1))
				affected_mob.emote("sneeze")
			if(probmult(1))
				affected_mob.emote("cough")
			if(probmult(2))
				boutput(affected_mob, SPAN_ALERT("Your stomach hurts."))
				if(prob(20))
					affected_mob.take_toxin_damage(1)
		if(5)
			boutput(affected_mob, SPAN_ALERT("You feel something tearing its way out of your stomach..."))
			if (affected_mob.get_toxin_damage() < 30)
				affected_mob.take_toxin_damage(10 * mult)

			if(probmult(40))
				var/obj/critter/domestic_bee_larva/larva = new /obj/critter/domestic_bee_larva (get_turf(affected_mob))
				larva.name = "li'l [affected_mob:real_name]"
				if (affected_mob.bioHolder && affected_mob.bioHolder.mobAppearance)
					larva.color = "[affected_mob.bioHolder.mobAppearance.customizations["hair_bottom"].color]"
					if (!affected_mob.bioHolder.mobAppearance.customizations["hair_bottom"].color)
						larva.color = "#FFFFFF"

				larva.beeMom = affected_mob
				larva.beeMomCkey = affected_mob.ckey

				if (ishuman(affected_mob))
					var/mob/living/carbon/human/human = affected_mob
					if (human.head && !istype(human.head, /obj/item/clothing/head/void_crown))
						var/obj/item/clothing/head/cloned_hat = new human.head.type
						cloned_hat.set_loc(larva)
						larva.stored_hat = cloned_hat

					if (human.mind?.assigned_role == "Mime")
						larva.color = "#ebedeb"
						if (human.bioHolder.HasEffect(/datum/bioEffect/noir))
							larva.custom_bee_type = /obj/critter/domestic_bee/mimebee/noirbee
						else
							larva.custom_bee_type = /obj/critter/domestic_bee/mimebee
					else if (human.mind?.assigned_role == "Clown")
						larva.color = "#ff0033"
						larva.custom_bee_type = /obj/critter/domestic_bee/clownbee
					else if (iscluwne(human))
						larva.custom_bee_type = /obj/critter/domestic_bee/cluwnebee
						larva.color = "#35bf4f"

				playsound(affected_mob.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
				affected_mob.visible_message(SPAN_ALERT("<b>[affected_mob] horks up a bee larva!  Grody!</b>"), SPAN_ALERT("<b>You cough up...a bee larva. Uhhhhh</b>"))

				affected_mob.cure_disease(D)
