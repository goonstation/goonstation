/datum/aiHolder/mindmite
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/mindmite, list(src))

/datum/aiTask/prioritizer/mindmite/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/mindmite_chase, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack/mindmite, list(src.holder, src))

/datum/aiTask/timed/mindmite_chase
	name = "chase"
	minimum_task_ticks = 1
	maximum_task_ticks = 1
	move_through_space = TRUE
	score_by_distance_only = FALSE

	on_tick()
		var/mob/living/critter/mindmite/C = src.holder.owner
		if (BOUNDS_DIST(C, C.target_mob) == 0)
			src.holder.owner.ai.interrupt()
		else
			walk_towards(C, C.target_mob, 0, 32)
		..()

	score_target()
		return 100

	evaluate()
		. = 1

/datum/aiTask/sequence/goalbased/critter/attack/mindmite

	score_by_distance_only = FALSE
	New()
		src.max_dist = max(world.maxx, world.maxy)
		..()

	score_target()
		return 100
