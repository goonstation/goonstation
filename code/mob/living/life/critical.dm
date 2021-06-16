
/datum/lifeprocess/critical //for mobs that use crit (humans only right now)
	process(var/datum/gas_mixture/environment)
		var/mult = get_multiplier()
		//health_update_queue |= src //#843 uncomment this if things go funky maybe
		var/death_health = owner.health + (owner.get_oxygen_deprivation() * 0.5) - (owner.get_burn_damage() * 0.67) - (owner.get_brute_damage() * 0.67) //lower weight of oxy, increase weight of brute/burn here
		// I don't think the revenant needs any of this crap - Marq
		if (owner.bioHolder && owner.bioHolder.HasEffect("revenant") || isdead(owner)) //You also don't need to do a whole lot of this if the dude's dead.
			return ..()

		if (owner.health < 0 && !isdead(owner))
			if (prob(percentmult(5, mult)))
				owner.emote(pick("faint", "collapse", "cry","moan","gasp","shudder","shiver"))
			if (owner.stuttering <= 5)
				owner.stuttering+=5
			if (owner.get_eye_blurry() <= 5)
				owner.change_eye_blurry(5)
			if (prob(percentmult(7, mult)))
				owner.change_misstep_chance(2)
			if (prob(percentmult(5, mult)))
				owner.changeStatus("paralysis", 3 SECONDS)
			switch(owner.health)
				if (-INFINITY to -100)
					owner.take_oxygen_deprivation(1 * mult)
					if (prob(percentmult(owner.health * -0.1, mult)) && !owner.hasStatus("defibbed"))
						owner.contract_disease(/datum/ailment/malady/flatline,null,null,1)
						//boutput(world, "\b LOG: ADDED FLATLINE TO [src].")
					if (prob(percentmult(owner.health * -0.2, mult)))
						owner.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
						//boutput(world, "\b LOG: ADDED HEART FAILURE TO [src].")
					if (isalive(owner))
						if (owner?.mind)
							owner.lastgasp() // if they were ok before dropping below zero health, call lastgasp() before setting them unconscious
					owner.setStatus("paralysis", max(owner.getStatusDuration("paralysis"), 15 * mult))
				if (-99 to -80)
					owner.take_oxygen_deprivation(1 * mult)
					if (prob(percentmult(4, mult)))
						boutput(owner, "<span class='alert'><b>Your chest hurts...</b></span>")
						owner.changeStatus("paralysis", 2 SECONDS)
						owner.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
				if (-79 to -51)
					owner.take_oxygen_deprivation(1 * mult)
					if (prob(percentmult(10, mult))) // shock added back to crit because it wasn't working as a bloodloss-only thing
						owner.contract_disease(/datum/ailment/malady/shock,null,null,1)
						//boutput(world, "\b LOG: ADDED SHOCK TO [src].")
					if (prob(percentmult(owner.health * -0.08, mult)))
						owner.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
						//boutput(world, "\b LOG: ADDED HEART FAILURE TO [src].")
					if (prob(percentmult(6, mult)))
						boutput(owner, "<span class='alert'><b>You feel [pick("horrible pain", "awful", "like shit", "absolutely awful", "like death", "like you are dying", "nothing", "warm", "really sweaty", "tingly", "really, really bad", "horrible")]</b>!</span>")
						owner.setStatus("weakened", max(owner.getStatusDuration("weakened"), 30))
					if (prob(percentmult(3, mult)))
						owner.changeStatus("paralysis", 2 SECONDS)
				if (-50 to 0)
					owner.take_oxygen_deprivation(0.25 * mult)
					/*if (src.reagents)
						if (!src.reagents.has_reagent("inaprovaline") && prob(50))
							src.take_oxygen_deprivation(1)*/
					if (prob(percentmult(3, mult)))
						owner.contract_disease(/datum/ailment/malady/shock,null,null,1)
						//boutput(world, "\b LOG: ADDED SHOCK TO [src].")
					if (prob(percentmult(5, mult)))
						boutput(owner, "<span class='alert'><b>You feel [pick("terrible", "awful", "like shit", "sick", "numb", "cold", "really sweaty", "tingly", "horrible")]!</b></span>")
						owner.changeStatus("weakened", 3 SECONDS)

		var/is_chg = ischangeling(owner)
		//if (src.brain_op_stage == 4.0) // handled above in handle_organs() now
			//death()
		if (owner.get_brain_damage() >= 120 || death_health <= -500) //-200) a shitty test here // let's lower the weight of oxy
			if (!is_chg || owner.suiciding)
				owner.death()

		if (owner.get_brain_damage() >= 100) // braindeath
			if (!is_chg)
				boutput(owner, "<span class='alert'>Your head [pick("feels like shit","hurts like fuck","pounds horribly","twinges with an awful pain")].</span>")
				owner.losebreath += 10 * mult
				owner.changeStatus("weakened", 3 * mult SECONDS)
		if (owner.health <= -100)
			if (owner.reagents && owner.reagents.has_reagent("synaptizine") && owner.reagents.has_reagent("atropine"))
				var/deathchance = min(99, ((owner.get_brain_damage() * -5) + (owner.health + (owner.get_oxygen_deprivation() / 2))) * -0.001)
				if (prob(percentmult(deathchance, mult)))
					owner.death()
			else
				var/deathchance = min(99, ((owner.get_brain_damage() * -5) + (owner.health + (owner.get_oxygen_deprivation() / 2))) * -0.01)
				if (prob(percentmult(deathchance, mult)))
					owner.death()


		..()
