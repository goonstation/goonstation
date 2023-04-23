/// Aggressive Wanderer
/datum/aiHolder/wanderer_aggressive
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/wanderer_aggressive, list(src))

/datum/aiTask/prioritizer/critter/wanderer_aggressive/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(src.holder, src))

/// Agressive Wanderer scavenger
/datum/aiHolder/wanderer_aggressive/scavenger
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/wanderer_aggressive/scavenger, list(src))

/datum/aiTask/prioritizer/critter/wanderer_aggressive/scavenger/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/scavenge, list(holder, src))

