/datum/aiHolder/cat
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/cat, list(src))

/datum/aiTask/prioritizer/critter/cat/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
