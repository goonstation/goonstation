/datum/aiHolder/pig
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/pig, list(src))

/datum/aiTask/prioritizer/critter/pig/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/sitting, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(src.holder, src))

/datum/aiHolder/pig_flying
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/pig_flying, list(src))

/datum/aiTask/prioritizer/critter/pig_flying/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(src.holder, src))
