/datum/aiHolder/mouse
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/mouse, list(src))

/datum/aiTask/prioritizer/critter/mouse/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(holder, src))

/datum/aiHolder/mouse/mad
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/mouse_mad, list(src))

/datum/aiTask/prioritizer/critter/mouse_mad/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))

/datum/aiHolder/mouse_remy
	New()
		..()
		default_task = get_instance(/datum/aiTask/timed/wander, list(src))
