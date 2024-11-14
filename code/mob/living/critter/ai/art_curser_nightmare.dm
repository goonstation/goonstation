/datum/aiHolder/art_curser_nightmare
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/art_curser_nightmare, list(src))

/datum/aiTask/prioritizer/art_curser_nightmare/New()
	..()
	//transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/art_curser_nightmare_chase, list(src.holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack/art_curser_nightmare, list(src.holder, src))

/datum/aiTask/sequence/goalbased/critter/attack/art_curser_nightmare
	New()
		src.max_dist = max(world.maxx, world.maxy)
		..()

/datum/aiTask/timed/art_curser_nightmare_chase
	name = "chase"
	minimum_task_ticks = 5
	maximum_task_ticks = 10
	move_through_space = TRUE

	on_tick()
		var/mob/living/critter/art_curser_nightmare/C = src.holder.owner
		walk_towards(C, C.cursed_human, 0, 16)
		if (BOUNDS_DIST(C, C.cursed_human) == 0)
			src.holder.owner.ai.interrupt()
		..()

	evaluate()
		. = 1
