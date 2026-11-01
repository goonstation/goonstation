/datum/element/lifeprocess/honk_randomly/process(mob/living/target, datum/gas_mixture/environment)
	var/mult = src.get_multiplier(target)
	if (prob(5 + (5 * mult)))
		playsound(get_turf(target), "sound/musical_instruments/Bikehorn_[rand(1, 2)].ogg", 30, 1)


/datum/element/lifeprocess/cluwne_honk_randomly/process(mob/living/target, datum/gas_mixture/environment)
	var/mult = src.get_multiplier(target)
	if (prob(5 + (5 * mult)))
		playsound(get_turf(target), "sound/voice/cluwnelaugh[rand(1, 3)].ogg", 35, 1)
