//For the sawfly critter itself, check mob/living/critter/sawfly.dm
//For misc things, check sawflymisc.dm in code/obj.sawflymisc

/datum/aiHolder/sawfly

	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/sawfly, list(src))

/datum/aiTask/prioritizer/critter/sawfly/New()
	..()
	// populate the list of tasks
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
