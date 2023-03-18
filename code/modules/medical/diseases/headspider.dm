/datum/ailment/parasite/headspider
	name = "Unidentified Foreign Body"
	max_stages = 4 // takes too goddamn long
	affected_species = list("Human", "Monkey")
	cure = "Surgery"
	stage_prob = 13
//

/datum/ailment/parasite/headspider/surgery(var/mob/living/surgeon, var/mob/living/affected_mob, var/datum/ailment_data/D)
	if (D.disposed)
		return 0
	var/outcome = rand(90)
	if (surgeon.traitHolder.hasTrait("training_medical"))
		outcome += 10
	var/numb = affected_mob.reagents.has_reagent("morphine") || affected_mob.sleeping
	switch (outcome)
		if (0 to 5)
			// im doctor
			surgeon.visible_message("<span class='alert'><b>[surgeon] cuts open [affected_mob] in all the wrong places!</b></span>", "You dig around in [affected_mob]'s chest and accidentally snip something important looking!")
			affected_mob.show_message("<span class='alert'><b>You feel a [numb ? "numb" : "sharp"] stabbing pain in your chest!</b></span>")
			affected_mob.TakeDamage("chest", numb ? 37.5 : 75, 0, DAMAGE_CUT)
			return 0
		if (6 to 15)
			surgeon.visible_message("<span class='alert'><b>[surgeon] clumsily cuts open [affected_mob]!</b></span>", "You dig around in [affected_mob]'s chest and accidentally snip something not so important looking!")
			affected_mob.show_message("<span class='alert'><b>You feel a [numb ? "mild " : " "]stabbing pain in your chest!</b></span>")
			affected_mob.TakeDamage("chest", numb ? 20 : 40, 0, 0, DAMAGE_CUT)
			return 0
		if (16 to 60)
			var/around_msg = ""
			var/self_msg = ""
			var/success = 0
			if (prob(50))
				around_msg = "<span class='notice'><b>[surgeon] cuts open [affected_mob] and removes a part of the headspider.</b></span>"
				self_msg = "<span class='notice'>You remove some bits of the headspider from [affected_mob], but it quickly regrows them.</span>"
			else
				around_msg = "<span class='notice'><b>[surgeon] cuts open [affected_mob] and removes the entire headspider.</b></span>"
				self_msg = "<span class='notice'>You remove the remaining headspider from [affected_mob].</span>"
				success = 1
				move_spider_out(surgeon, affected_mob)
			surgeon.visible_message(around_msg, self_msg)
			if (!numb)
				affected_mob.show_message("<span class='alert'><b>You feel a mild stabbing pain in your chest!</b></span>")
				affected_mob.TakeDamage("chest", 10, 0, 0, DAMAGE_STAB)
			return success
		if (61 to INFINITY)
			surgeon.visible_message("<span class='notice'><b>[surgeon] cuts open [affected_mob] and removes all traces of the headspider.</b></span>", "<span class='notice'>You masterfully remove the headspider from [affected_mob].</span>")
			if (!numb)
				affected_mob.show_message("<span class='alert'><b>You feel a mild stabbing pain in your chest!</b></span>")
				affected_mob.TakeDamage("chest", 10, 0, 0, DAMAGE_STAB)
			move_spider_out(surgeon, affected_mob)
			return 1

/datum/ailment/parasite/headspider/proc/move_spider_out(var/mob/living/surgeon, var/mob/living/M)
	for (var/mob/living/critter/changeling/headspider/HS in M.contents)
		HS.changeStatus("stunned", 5 SECONDS)
		HS.health = 0
		HS.death()
		HS.set_loc(M.loc)

	JOB_XP(surgeon, "Medical Doctor", 15)


/datum/ailment/parasite/headspider/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/parasite/D, mult)
	if (..())
		return

	if (!ismind(D.source?.mind))
		affected_mob.ailments -= D
		qdel(D)
		return

	switch(D.stage)
		if(2)
			if(probmult(15))
				if(affected_mob.canmove && isturf(affected_mob.loc))
					step(affected_mob, pick(cardinal))
			if(probmult(3))
				affected_mob.emote("twitch")
			if(probmult(3))
				affected_mob.emote("twitch_v")
			if(probmult(2))
				boutput(affected_mob, "<span class='alert'>You feel strange.</span>")
				affected_mob.change_misstep_chance(5)
		if(3)
			if(probmult(50))
				if(affected_mob.canmove && isturf(affected_mob.loc))
					step(affected_mob, pick(cardinal))
			if(probmult(5))
				affected_mob.emote("twitch")
			if(probmult(5))
				affected_mob.emote("twitch_v")
			if(probmult(5))
				boutput(affected_mob, "<span class='alert'>You feel very strange.</span>")
				affected_mob.change_misstep_chance(10)
			if(probmult(2))
				boutput(affected_mob, "<span class='alert'>Your stomach hurts.</span>")
				affected_mob.emote("groan")
		if(4)
			boutput(affected_mob, "<span class='alert'>You feel something pushing at your spine...</span>")
			if(probmult(40))
				if(!D.source.changeling)
					//if the headspider doesn't have a changeling, we create one
					D.source.mind.add_antagonist(ROLE_CHANGELING, TRUE, FALSE, FALSE, TRUE, ANTAGONIST_SOURCE_SUMMONED, FALSE, FALSE, FALSE)
					var/datum/antagonist/changeling/antag_datum = D.source.mind.get_antagonist(ROLE_CHANGELING)
					D.source.changeling = antag_datum.ability_holder
					logTheThing(LOG_COMBAT, D.source.mind, "became a changeling by infecting [affected_mob] as [D.source].")
				// Absorb their DNA. Copies identities and DNA points automatically if victim was another changeling. This also inserts them into the hivemind.
				D.source.changeling.addDna(affected_mob, TRUE)
				// Remove changeling AH (if any) and copy our own.
				if (ischangeling(affected_mob))
					D.source.show_text("[affected_mob] was a changeling! We have incorporated their entire genetic structure.", "blue")
					affected_mob.remove_ability_holder(/datum/abilityHolder/changeling)

				affected_mob.add_existing_ability_holder(D.source.changeling)
				D.source.changeling.reassign_hivemind_target_mob()

				// Transfer player control.
				D.source.changeling = null //so the spider doesn't have a ref to our holder as well
				D.source.mind.transfer_to(affected_mob)
				affected_mob.change_misstep_chance(-INFINITY)
				affected_mob.show_text("<h3>We have assumed control of the new host.</h3>", "blue")
				logTheThing(LOG_COMBAT, affected_mob, "'s headspider successfully assumes control of new host at [log_loc(affected_mob)].")

				D.stealth_asymptomatic = TRUE //Retain the disease but don't actually do anything with it
				//kill the headspider, so if something causes it to drop it doesn't look alive with no mind
				if(!QDELETED(D.source))
					D.source.death(FALSE)
				SPAWN(2 MINUTES) //Disease stays for two minutes after a complete infection, then it removes itself.
					affected_mob.cure_disease_by_path(/datum/ailment/parasite/headspider)

/datum/ailment/parasite/headspider/on_remove(mob/living/affected_mob, datum/ailment_data/parasite/D)
	if(!QDELETED(D?.source))
		if(isalive(D.source))
			D.source.death(FALSE)
		//the headspider gets fully absorbed
		D.source?.set_loc(null)
		qdel(D.source)
		D.source = null
	. = ..()
