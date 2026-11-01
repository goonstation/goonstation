/datum/element/lifeprocess/ranch/crowding/process(mob/living/critter/small_animal/ranch_base/target, mult, datum/gas_mixture/environment)
	if (!isalive(target))
		return

	var/num_neighbors = length(global.ranch_animal_hashmap.exact_supremum(get_turf(target), 5))
	if (num_neighbors <= target.crowded_minimum)
		return

	target.change_happiness((target.crowded_minimum - num_neighbors) * target.crowding_coefficient)
	if (prob(20))
		target.visible_message(SPAN_ALERT("[target] looks upset at their crowded conditions."))
