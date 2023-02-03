/datum/aiHolder/scorpion
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/scorpion, list(src))

/datum/aiTask/prioritizer/critter/scorpion/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
