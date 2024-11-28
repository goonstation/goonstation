/datum/aiHolder/bat
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/bat, list(src))

/datum/aiTask/prioritizer/critter/bat/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/bat/drink_blood, list(holder, src))

// Bluh
/datum/aiTask/sequence/goalbased/critter/bat/drink_blood
	name = "drinking blood"
	weight = 10
	max_dist = 7
	ai_turbo = TRUE

/datum/aiTask/sequence/goalbased/critter/bat/drink_blood/New(parentHolder, transTask)
	..()
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/bat/drink_blood, list(holder)))

/datum/aiTask/sequence/goalbased/critter/bat/drink_blood/get_targets()
	var/mob/living/critter/small_animal/bat/the_bat = holder.owner
	return the_bat.seek_target()

// Drink blood subtask, go to target
/datum/aiTask/succeedable/critter/bat/drink_blood
	name = "drink subtask"
	var/is_complete = FALSE

/datum/aiTask/succeedable/critter/bat/drink_blood/failed()
	var/mob/living/critter/C = holder.owner

	// the tasks fails and is re-evaluated if the target is not in range
	if(!C || !holder.target || BOUNDS_DIST(holder.target, C) > 0 || !istype(holder.target.loc, /turf))
		return TRUE

/datum/aiTask/succeedable/critter/bat/drink_blood/succeeded()
	return is_complete

/datum/aiTask/succeedable/critter/bat/drink_blood/on_tick()
	if(!is_complete)
		var/mob/living/critter/C = holder.owner
		if(C && holder.target && BOUNDS_DIST(C, holder.target) == 0 && istype(holder.target.loc, /turf))
			var/datum/targetable/critter/drink_blood/B = C.abilityHolder.getAbility(/datum/targetable/critter/drink_blood)
			if (B && !B.disabled && B.cooldowncheck())
				B.handleCast(holder.target)
				is_complete = TRUE

/datum/aiTask/succeedable/critter/bat/drink_blood/on_reset()
	is_complete = FALSE

