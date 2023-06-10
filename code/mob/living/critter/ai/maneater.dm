
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
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat, list(holder, src))

/datum/aiTask/prioritizer/critter/maneater/on_reset()
	..()
	holder.stop_move()

/datum/aiTask/sequence/goalbased/critter/manhunter_hunting
	name = "attacking"
	weight = 10 // this behaviour gets a high priority
	ai_turbo = TRUE
	max_dist = 7

/datum/aiTask/sequence/goalbased/critter/manhunter_hunting/get_targets()
	var/mob/living/critter/task_owner = holder.owner
	return task_owner.seek_target(src.max_dist)

/datum/aiTask/sequence/goalbased/critter/manhunter_hunting/precondition()
	var/mob/living/critter/task_owner = holder.owner
	return task_owner.can_critter_attack()

/datum/aiTask/sequence/goalbased/critter/manhunter_hunting/score_target(atom/target)
	. = 0
	if(target)
		if (istype(target, /mob))
			var/mob/evaluate_target = target
			var/weighting = 50
			if (ishuman(evaluate_target))
				weighting = 100 //We want to eat people that are alive
			if (isdead(evaluate_target))
				weighting = 25 //We still want to eat dead people, just less likely
			return weighting*(src.max_dist - GET_MANHATTAN_DIST(get_turf(src.holder.owner), get_turf(target)))/src.max_dist

/datum/aiTask/sequence/goalbased/critter/manhunter_hunting/New(parentHolder, transTask) //goalbased aitasks have an inherent movement component
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/attack, list(holder)))
