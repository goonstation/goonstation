/datum/aiHolder/flock/bit

/datum/aiHolder/flock/bit/New()
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/flock/bit, list(src))

///////////////////////////////////////////////////////////////////////////////////////////////////////////

// main default "what do we do next" task, run for one tick and then switches to a new task
/datum/aiTask/prioritizer/flock/bit
	name = "thinking"

/datum/aiTask/prioritizer/flock/bit/New()
	..()
	// populate the list of tasks
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/build, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
