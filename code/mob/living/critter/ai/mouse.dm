/datum/aiHolder/mouse
	default_task = /datum/aiTask/prioritizer/critter/mouse

/datum/aiTask/prioritizer/critter/mouse/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/floor_only, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(holder, src))

/datum/aiHolder/mouse/mad
	default_task = /datum/aiTask/prioritizer/critter/mouse_mad

/datum/aiTask/prioritizer/critter/mouse_mad/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive/melee, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))

/datum/aiHolder/mouse_remy
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/remy, list(src))

/datum/aiTask/prioritizer/critter/remy/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/floor_only/less, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/go_home, list(holder, src))
