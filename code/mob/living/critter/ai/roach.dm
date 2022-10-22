/datum/aiHolder/roach
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/roach, list(src))

/datum/aiTask/prioritizer/critter/roach/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
