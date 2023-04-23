/* this file is for AI Holders which are used by multiple different critters to reduce code duplication
if there is otherwise unique behaviour which you add to another mob consider moving it to here */

/// Wanderer
/datum/aiHolder/wanderer
	New()
		. = ..()
		var/datum/aiTask/timed/wander/W =  get_instance(/datum/aiTask/timed/wander, list(src))
		W.transition_task = W
		default_task = W

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

