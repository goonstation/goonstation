
/datum/aiHolder/maneater
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/maneater, list(src))


/datum/aiTask/prioritizer/critter/maneater
	name = "Maneater priorisation"

/datum/aiTask/prioritizer/critter/maneater/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/manhunter_hunting, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/scavenge/manhunter_scavenging, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(holder, src))

/datum/aiTask/prioritizer/critter/maneater/on_reset()
	..()
	holder.stop_move()

/datum/aiTask/sequence/goalbased/critter/scavenge/manhunter_scavenging
	//This is a in-combat scavenging (this is why we need ai_turbo) that should be able to over-prioritize the manhunter_hunting task if the distances plays well into it
	weight = 10
	ai_turbo = TRUE
	max_dist = 7


/datum/aiTask/sequence/goalbased/critter/manhunter_hunting
	name = "attacking"
	weight = 32 // this behaviour gets a high priority
	ai_turbo = TRUE
	max_dist = 7

/datum/aiTask/sequence/goalbased/critter/manhunter_hunting/get_targets()
	var/mob/living/critter/task_owner = holder.owner
	return task_owner.seek_target(src.max_dist)

/datum/aiTask/sequence/goalbased/critter/manhunter_hunting/precondition()
	var/mob/living/critter/task_owner = holder.owner
	return task_owner.can_critter_attack()

/datum/aiTask/sequence/goalbased/critter/manhunter_hunting/score_by_distance_only = FALSE
/datum/aiTask/sequence/goalbased/critter/manhunter_hunting/score_target(atom/target)
	. = 0
	if (istype(target, /mob))
		var/mob/evaluate_target = target
		var/weighting = 0.5
		if (ishuman(evaluate_target))
			weighting = 1.05 //We want to eat people that are alive
		return weighting*(src.max_dist - GET_MANHATTAN_DIST(get_turf(src.holder.owner), get_turf(target)))/src.max_dist

/datum/aiTask/sequence/goalbased/critter/manhunter_hunting/New(parentHolder, transTask) //goalbased aitasks have an inherent movement component
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/attack, list(holder)))
