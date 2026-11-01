/datum/element/lifeprocess/critical/process(mob/living/target, mult, datum/gas_mixture/environment)
	if (isdead(target) || target.bioHolder?.HasEffect("revenant"))
		return

	// OXY damage counts 50%, BRUTE + BURN count 167%. Calculated before oxygen deprivation effects applied below.
	var/death_health = target.health + (target.get_oxygen_deprivation() * 0.5) - ((target.get_burn_damage() + target.get_brute_damage()) * 0.67)

	if (target.health < 0)
		target.changeStatus("critical_condition", 10 SECONDS)

		if (probmult(5))
			target.emote(pick("faint", "collapse", "cry", "moan", "gasp", "shudder", "shiver"))
		if (target.stuttering <= 5)
			target.stuttering += 5
		if (target.get_eye_blurry() <= 5)
			target.change_eye_blurry(5)
		if (probmult(7))
			target.change_misstep_chance(2)
		if (probmult(5))
			target.changeStatus("unconscious", 3 SECONDS)

		switch (target.health)
			if (-INFINITY to -100)
				target.take_oxygen_deprivation(1 * mult)

				if (probmult(target.health * -0.1) && !target.hasStatus("defibbed"))
					target.contract_disease(/datum/ailment/malady/flatline, null, null, TRUE)

				if (probmult(target.health * -0.2))
					target.contract_disease(/datum/ailment/malady/heartfailure, null, null, TRUE)

				// If they were alright before dropping below zero health, call lastgasp() before setting them unconscious.
				if (isalive(target) && target.mind)
					target.lastgasp()

				target.setStatusMin("unconscious", 1.5 SECONDS * mult)

			if (-99 to -80)
				target.take_oxygen_deprivation(1 * mult)

				if (probmult(4))
					boutput(target, SPAN_ALERT("<b>Your chest hurts...</b>"))
					target.changeStatus("unconscious", 2 SECONDS)
					target.contract_disease(/datum/ailment/malady/heartfailure, null, null, TRUE)

			if (-79 to -51)
				target.take_oxygen_deprivation(1 * mult)

				if (probmult(10))
					target.contract_disease(/datum/ailment/malady/shock, null, null, TRUE)

				if (probmult(target.health * -0.08))
					target.contract_disease(/datum/ailment/malady/heartfailure, null, null, TRUE)

				if (probmult(6))
					boutput(target, SPAN_ALERT("<b>You feel [pick("horrible pain", "awful", "like shit", "absolutely awful", "like death", "like you are dying", "nothing", "warm", "really sweaty", "tingly", "really, really bad", "horrible")]</b>!"))
					target.setStatusMin("knockdown", 3 SECONDS)

				if (probmult(3))
					target.changeStatus("unconscious", 2 SECONDS)

			if (-50 to 0)
				target.take_oxygen_deprivation(0.25 * mult)

				if (probmult(3))
					target.contract_disease(/datum/ailment/malady/shock, null, null, TRUE)

				if (probmult(5))
					boutput(target, SPAN_ALERT("<b>You feel [pick("terrible", "awful", "like shit", "sick", "numb", "cold", "really sweaty", "tingly", "horrible")]!</b>"))
					target.changeStatus("knockdown", 3 SECONDS)

		if (!ischangeling(target) || target.suiciding)
			if ((target.get_brain_damage() >= BRAIN_DAMAGE_DEATH) || (death_health <= -500))
				target.death()

			if (target.get_brain_damage() >= BRAIN_DAMAGE_LETHAL)
				boutput(target, SPAN_ALERT("Your head [pick("feels like shit", "hurts like fuck", "pounds horribly", "twinges with an awful pain")]."))
				target.losebreath += 10 * mult
				target.changeStatus("knockdown", 3 SECONDS * mult)

		if ((target.health <= -100) && probmult(src.get_deathchance(target)))
			target.death()

/// Returns the chance of the target dying, based on their current damages and reagents.
/datum/element/lifeprocess/critical/proc/get_deathchance(mob/living/target)
	// Brain damage counts 500% towards death chance.
	// OXY damage counts 50% towards death chance.
	. = ((target.get_brain_damage() * 5) - (target.health + (target.get_oxygen_deprivation() / 2))) * 0.01

	var/datum/reagents/reagents = target.reagents
	if (!reagents)
		return

	// The target has both synaptizine and atropine in their system.
	if (reagents.has_reagent("synaptizine") && reagents.has_reagent("atropine"))
		return . * 0.1

	// The target has cryoxadone in their system, is between 35K and 210K, and is not on fire.
	var/in_temp_range = (target.bodytemperature < target.base_body_temp - 100) && (target.bodytemperature > target.base_body_temp - 275)
	if (in_temp_range && reagents.has_reagent("cryoxadone") && !target.hasStatus("burning"))
		return . * 0.1
