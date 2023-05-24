/datum/aiHolder/penguin
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/penguin, list(src))

/datum/aiTask/prioritizer/critter/penguin/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
