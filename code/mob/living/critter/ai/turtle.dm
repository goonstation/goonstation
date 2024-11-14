/datum/aiHolder/turtle
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/turtle, list(src))

/datum/aiTask/prioritizer/critter/turtle/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
