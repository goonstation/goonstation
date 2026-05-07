/datum/aiHolder/gorilla
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/gorilla, list(src))

/datum/aiTask/prioritizer/critter/gorilla/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/floor_only, list(holder, src))


/datum/aiHolder/gorilla/aggressive
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/gorilla/aggressive, list(src))

/datum/aiTask/prioritizer/critter/gorilla/aggressive/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive/melee, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/critter/gorilla/smash, list(src.holder, src))

/datum/aiTask/critter/gorilla/smash
	name = "smash shit"
	weight = 2

/datum/aiTask/critter/gorilla/smash/on_tick()
	var/mob/living/critter/gorilla/C = holder.owner
	if(length(C.seek_target()))
		C.ai.interrupt()
		return
	else
		C.gorilla_smash()
