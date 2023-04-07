/datum/aiHolder/skeleton

	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/skeleton, list(src))

/datum/aiTask/prioritizer/critter/skeleton/New()
	..()
	// populate the list of tasks
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
