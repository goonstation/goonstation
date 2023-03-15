/datum/aiHolder/bear
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/bear list(src))

/datum/aiTask/prioritizer/critter/bear/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
