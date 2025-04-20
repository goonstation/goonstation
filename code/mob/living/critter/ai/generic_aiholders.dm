/* this file is for AI Holders which are used by multiple different critters to reduce code duplication
if there is otherwise unique behaviour which you add to another mob consider moving it to here */

/// Empty AIholder for when you only want to add things to the prioritizer (such as retaliation tasks)
/datum/aiHolder/empty
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/empty, list(src))

/datum/aiTask/prioritizer/critter/empty/New()
	..()

/// Wanderer
/datum/aiHolder/wanderer
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/wanderer, list(src))

/datum/aiTask/prioritizer/critter/wanderer/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(src.holder, src))

/// Floor-only Wanderer
/datum/aiHolder/wanderer/floor_only
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/wanderer/floor_only, list(src))

/datum/aiTask/prioritizer/critter/wanderer/floor_only/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/floor_only, list(src.holder, src))

/// Aggressive Wanderer
/datum/aiHolder/aggressive
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/aggressive, list(src))

/datum/aiTask/prioritizer/critter/aggressive/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(src.holder, src))

/// Agressive Wanderer scavenger
/datum/aiHolder/aggressive/scavenger
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/aggressive/scavenger, list(src))

/datum/aiTask/prioritizer/critter/aggressive/scavenger/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/scavenge, list(holder, src))

/// Aggressive wander with ranged attack
/datum/aiHolder/ranged
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/ranged, list(src))

/datum/aiTask/prioritizer/critter/ranged/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/range_attack, list(src.holder, src))
