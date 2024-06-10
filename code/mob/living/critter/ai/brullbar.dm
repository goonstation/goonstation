/datum/aiHolder/brullbar
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/brullbar, list(src))

/datum/aiTask/prioritizer/critter/brullbar/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/scavenge, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/critter/brullbar/invis, list(holder, src))

// brullbar invis task
/datum/aiTask/critter/brullbar/invis
	name = "go invisible"
	weight = 2

/datum/aiTask/critter/brullbar/invis/on_tick()
	var/mob/living/critter/brullbar/C = holder.owner
	if(length(C.seek_target()) || length(C.seek_scavenge_target()))
		C.ai.interrupt()
		return
	else
		C.go_invis()

