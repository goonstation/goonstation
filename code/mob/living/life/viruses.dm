
/datum/lifeprocess/viruses
	process(var/datum/gas_mixture/environment)
		if (length(owner.ailments))
			for (var/mob/living/carbon/M in oviewers(4, owner))
				if (prob(40))
					owner.viral_transmission(M,"Airborne",0)

			if (!isdead(owner))
				for (var/datum/ailment_data/am in owner.ailments)
					var/mult = src.get_multiplier()
					am.stage_act(mult)

		..()
