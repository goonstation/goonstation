/datum/element/lifeprocess/ranch/chicken/produce_reagent
	target_type = /mob/living/critter/small_animal/ranch_base/chicken/glass

/datum/element/lifeprocess/ranch/chicken/produce_reagent/process(mob/living/critter/small_animal/ranch_base/chicken/glass/target, mult, datum/gas_mixture/environment)
	var/amount = 5 * mult
	var/datum/reagents/R = new(amount)
	R.add_reagent(target.my_reagent_id, amount)

	if (prob(50))
		R.reaction(target, INGEST)
	else
		R.reaction(target, TOUCH)

	R.trans_to(target, amount)
