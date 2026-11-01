/datum/aiHolder/hungry_critter
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/hungry, list(src))

/datum/aiTask/prioritizer/critter/hungry/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/floor_only, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(holder, src))
