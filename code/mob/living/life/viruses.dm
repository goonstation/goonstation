
/datum/lifeprocess/viruses
	process(var/datum/gas_mixture/environment)
		//proc/handle_virus_updates()
		//might need human
		if (owner.ailments && owner.ailments.len)
			for (var/mob/living/carbon/M in oviewers(4, owner))
				if (prob(40))
					owner.viral_transmission(M,"Airborne",0)
				if (prob(20))
					owner.viral_transmission(M,"Sight", 0)

			if (!isdead(owner))
				for (var/datum/ailment_data/am in owner.ailments)
					am.stage_act()

		if (prob(40))
			for (var/obj/decal/cleanable/blood/B in view(2, owner))
				for (var/datum/ailment_data/disease/virus in B.diseases)
					if (virus.spread == "Airborne")
						owner.contract_disease(null,null,virus,0)
		..()
