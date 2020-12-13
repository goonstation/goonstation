/datum/aiHolder/flock/drone

/datum/aiHolder/flock/drone/New()
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/flock/drone, list(src))

///////////////////////////////////////////////////////////////////////////////////////////////////////////

// main default "what do we do next" task, run for one tick and then switches to a new task
/datum/aiTask/prioritizer/flock/drone
	name = "thinking"

/datum/aiTask/prioritizer/flock/drone/New()
	..()
	// populate the list of tasks
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/replicate, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/build, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/repair, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/deposit, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/open_container, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/butcher, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/rummage, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/harvest, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/flockdrone_shoot, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/flockdrone_capture, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))

/datum/aiTask/prioritizer/flock/drone/on_reset()
	..()
	if(holder.owner)
		holder.owner.a_intent = INTENT_GRAB
