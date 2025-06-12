/datum/lifeprocess/ranch/evolution
	process()
		var/mob/living/critter/small_animal/ranch_base/C = critter_owner
		if(istype(C))
			for(var/datum/ranch/evolution/E as anything in C.evolutions)
				if(!isnull(C.evolved) && (E == C.evolved))
					continue
				if(E.check_evolution_conditions(C))
					if(C.evolved)
						if(E.evolution_priority >= C.evolved.evolution_priority)
							E.evolve(C)
						else if (C.evolved == C.base_evolution)
							E.evolve(C)
					else
						E.evolve(C)

			if(!isnull(C.base_evolution) && (isnull(C.evolved) || !C.evolved.check_evolution_conditions(C)))
				C.base_evolution.evolve(C)

ABSTRACT_TYPE(/datum/ranch/evolution)
/datum/ranch/evolution
	/// given conflicting evolutions, which takes priority?
	var/evolution_priority = 0
	proc/check_evolution_conditions(var/mob/living/critter/small_animal/ranch_base/C)
		. = TRUE
		if(isdead(C))
			. = FALSE

	proc/evolve(var/mob/living/critter/small_animal/ranch_base/C)
		C.evolved = src
		return
