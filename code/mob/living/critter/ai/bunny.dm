/datum/aiHolder/bunny
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/bunny, list(src))

/datum/aiTask/prioritizer/critter/bunny/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/flight_range, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/floor_only, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(holder, src))

