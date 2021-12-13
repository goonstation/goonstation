/datum/aiHolder/flock/bit

INIT_TYPE(/datum/aiHolder/flock/bit)
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/flock/bit, list(src))

///////////////////////////////////////////////////////////////////////////////////////////////////////////

// main default "what do we do next" task, run for one tick and then switches to a new task
/datum/aiTask/prioritizer/flock/bit
	name = "thinking"

INIT_TYPE(/datum/aiTask/prioritizer/flock/bit)
	..()
	// populate the list of tasks
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/build, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
