/datum/aiHolder/art_curser_nightmare
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/art_curser_nightmare, list(src))

/datum/aiTask/prioritizer/art_curser_nightmare/New()
	..()
	//transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/art_curser_nightmare_chase, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack/art_curser_nightmare, list(src.holder, src))

/datum/aiTask/timed/art_curser_nightmare_chase
	name = "chase"
	minimum_task_ticks = 1
	maximum_task_ticks = 1
	move_through_space = TRUE
	score_by_distance_only = FALSE

	on_tick()
		var/mob/living/critter/art_curser_nightmare/C = src.holder.owner
		if (BOUNDS_DIST(C, C.cursed_human) == 0)
			src.holder.owner.ai.interrupt()
		else
			walk_towards(C, C.cursed_human, 0, 32)
		..()

	score_target()
		return 100

	evaluate()
		. = 1

/datum/aiTask/sequence/goalbased/critter/attack/art_curser_nightmare

	score_by_distance_only = FALSE
	New()
		src.max_dist = max(world.maxx, world.maxy)
		..()

	score_target()
		return 100
