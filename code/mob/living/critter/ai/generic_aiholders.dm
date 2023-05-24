/* this file is for AI Holders which are used by multiple different critters to reduce code duplication
if there is otherwise unique behaviour which you add to another mob consider moving it to here */

/// Wanderer
/datum/aiHolder/wanderer
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/wanderer, list(src))

/datum/aiTask/prioritizer/critter/wanderer/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(src.holder, src))

/// Aggressive Wanderer
/datum/aiHolder/wanderer/aggressive
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/wanderer_aggressive, list(src))

/datum/aiTask/prioritizer/critter/wanderer_aggressive/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(src.holder, src))

/// Agressive Wanderer scavenger
/datum/aiHolder/wanderer/aggressive/scavenger
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/wanderer_aggressive/scavenger, list(src))

/datum/aiTask/prioritizer/critter/wanderer_aggressive/scavenger/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/scavenge, list(holder, src))

