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
