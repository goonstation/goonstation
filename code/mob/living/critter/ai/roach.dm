/datum/aiHolder/roach
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/roach, list(src))

/datum/aiTask/prioritizer/critter/roach/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/floor_only, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(holder, src))
