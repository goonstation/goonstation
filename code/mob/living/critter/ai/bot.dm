/datum/aiHolder/securitron
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/securitron, list(src))

/datum/aiTask/prioritizer/critter/securitron/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
