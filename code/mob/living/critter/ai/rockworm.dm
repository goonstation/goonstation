/datum/aiHolder/rockworm
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/rockworm, list(src))

/datum/aiTask/prioritizer/critter/rockworm/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/eat/worm, list(holder, src))

/datum/aiTask/sequence/goalbased/critter/eat/worm

/datum/aiTask/sequence/goalbased/critter/eat/worm/precondition()
	var/mob/living/critter/rockworm/C = holder.owner
	return C.can_critter_eat() && C.seek_ore

/datum/aiTask/sequence/goalbased/critter/eat/worm/New(parentHolder, transTask)
	..()
	remove_task(holder.get_instance(/datum/aiTask/succeedable/critter/eat, list(src.holder)))
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/eat/worm, list(src.holder)))

/datum/aiTask/succeedable/critter/eat/worm/on_tick()
	if(!has_started)
		var/mob/living/critter/rockworm/C = holder.owner
		var/obj/item/I = holder.target
		if(C && I && BOUNDS_DIST(C, I) == 0)
			holder.owner.set_dir(get_dir(C, I))
			I.Eat(C, C)
			C.aftereat()
			has_started = TRUE
