/// Aggressive Wanderer
/datum/aiHolder/ranged
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/ranged, list(src))

/datum/aiTask/prioritizer/critter/ranged/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/range_attack, list(src.holder, src))
