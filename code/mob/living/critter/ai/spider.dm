// This file is full of spider brains. ew.

/datum/aiHolder/spider
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/spider, list(src))

/datum/aiTask/prioritizer/critter/spider/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/scavenge, list(holder, src))

