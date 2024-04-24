/datum/aiHolder/securitron
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/securitron, list(src))

/datum/aiTask/prioritizer/critter/securitron/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack/securitron, list(holder, src))

/datum/aiTask/sequence/goalbased/critter/attack/securitron

/datum/aiTask/sequence/goalbased/critter/attack/securitron/on_reset()
	..()
	var/mob/living/critter/C = holder.owner
	if(C)
		C.set_a_intent(INTENT_DISARM)
