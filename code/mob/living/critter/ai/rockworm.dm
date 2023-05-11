/datum/aiHolder/rockworm
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/rockworm, list(src))

/datum/aiTask/prioritizer/critter/rockworm/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat/worm, list(holder, src))

/datum/aiTask/sequence/goalbased/critter/eat/worm

/datum/aiTask/sequence/goalbased/critter/eat/worm/New(parentHolder, transTask)
	..()
	src.subtasks -= /datum/aiTask/succeedable/critter/eat
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/eat/worm, list(src.holder)))

/datum/aiTask/succeedable/critter/eat/worm/on_tick()
	if(!has_started)
		var/mob/living/critter/rockworm/C = holder.owner
		var/obj/item/reagent_containers/food/snacks/T = holder.target
		if(C && T && BOUNDS_DIST(holder.owner, holder.target) == 0)
			holder.owner.set_dir(get_dir(holder.owner, holder.target))
			T.Eat(C, C, TRUE, TRUE)
			C.aftereat()
			has_started = TRUE
