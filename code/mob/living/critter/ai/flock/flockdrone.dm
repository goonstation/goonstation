/datum/aiHolder/flock/drone

/datum/aiHolder/flock/drone/New()
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/flock/drone, list(src))

/datum/aiHolder/flock/drone/was_harmed(obj/item/W, mob/M)
	. = ..()
	if (!istype(src.current_task, /datum/aiTask/timed/targeted/flockdrone_shoot))
		src.interrupt()

///////////////////////////////////////////////////////////////////////////////////////////////////////////

// main default "what do we do next" task, run for one tick and then switches to a new task
/datum/aiTask/prioritizer/flock/drone
	name = "thinking"

/datum/aiTask/prioritizer/flock/drone/New()
	..()
	// populate the list of tasks
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/replicate, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/nest, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/build/drone, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/repair, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/deposit, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/open_container, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/butcher, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/rummage, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/harvest, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/flockdrone_shoot, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/flockdrone_capture, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/deconstruct, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/flock/stare, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/flock, list(holder, src))

/datum/aiTask/prioritizer/flock/drone/on_reset()
	..()
	if(holder.owner)
		var/mob/living/critter/flock/drone/F = holder.owner
		F.set_a_intent(INTENT_GRAB)
		F.flock_name_tag?.set_info_tag(capitalize(src.name))

/datum/aiHolder/flock/drone/tutorial

/datum/aiHolder/flock/drone/tutorial/New()
	..()
	default_task = get_instance(/datum/aiTask/prioritizer/flock/drone/tutorial, list(src))

/datum/aiTask/prioritizer/flock/drone/tutorial
	New()
		..()
		transition_tasks = list(holder.get_instance(/datum/aiTask/timed/wait, list(holder, src)))
