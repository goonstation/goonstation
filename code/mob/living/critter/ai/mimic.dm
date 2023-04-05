/datum/aiHolder/mimic
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/mimic, list(src))

/datum/aiTask/prioritizer/critter/mimic/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/ambush, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wait_in_ambush, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/run_and_hide, list(holder, src))
	//wander and attack are only called if nothing else is possible
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))

/// Wait in ambush - while hidden, stay hidden until a potential target is nearby, then interupt AI so ambush or attack can trigger
/datum/aiTask/timed/wait_in_ambush
	name = "waiting in ambush"
	minimum_task_ticks = 5
	maximum_task_ticks = 10
	weight = 12 //Higher than attack - if we can wait in ambush instead of attacking, we should.

/datum/aiTask/timed/wait_in_ambush/evaluate()
	var/mob/living/critter/mimic/C = holder.owner
	if(length(C.seek_target(3)))
		return 0
	return 100*C.is_hiding*weight  //Note goalbased evaluate returns a percentage which is multiplied by a weight. Only return a high priority if we're hiding, otherwise 0

/datum/aiTask/timed/wait_in_ambush/on_tick()
	var/mob/living/critter/mimic/C = holder.owner
	holder.stop_move()
	if(length(C.seek_target(3))) //ambush max dist
		src.holder.owner.ai.interrupt()

/// If a target is in range and we're hiding, attack them until they're incapacitated
/datum/aiTask/sequence/goalbased/ambush
	name = "ambushing"
	weight = 13 //higher than waiting in ambush
	max_dist = 3
	ai_turbo = TRUE

/datum/aiTask/sequence/goalbased/ambush/New(parentHolder, transTask)
	..()
	add_task(holder.get_instance(/datum/aiTask/succeedable/ambush, list(holder)))

/datum/aiTask/sequence/goalbased/ambush/precondition()
	var/mob/living/critter/mimic/C = holder.owner
	return C.is_hiding && C.can_critter_attack()

/datum/aiTask/sequence/goalbased/ambush/get_targets()
	var/mob/living/critter/C = holder.owner
	return C.seek_target(src.max_dist)

/datum/aiTask/sequence/goalbased/ambush/on_tick()
	var/mob/living/critter/mimic/C = holder.owner
	if(C.is_hiding)
		C.stop_hiding()
	. = ..()

/datum/aiTask/succeedable/ambush
	name = "ambush subtask"
	max_dist = 5
	var/has_started = FALSE

/datum/aiTask/succeedable/ambush/failed()
	//failure condition is just that the target escaped
	if(holder.owner && holder.target)
		return (GET_DIST(holder.owner, holder.target) > max_dist)
	else
		return TRUE //we also fail if owner or target are somehow null

/datum/aiTask/succeedable/ambush/succeeded()
	if(is_incapacitated(holder.target)) //attack until target is incapacitated
		return TRUE
	return FALSE

/datum/aiTask/succeedable/ambush/on_tick()
	//keep moving towards the target and attacking them in range for as long as is necessary
	//has_started marks that we've hit them once
	var/mob/living/critter/C = holder.owner
	var/mob/M = holder.target
	if(C && M && BOUNDS_DIST(C, M) == 0)
		C.set_dir(get_dir(C, M))
		if(C.can_critter_attack()) //if we can't attack, just do nothing until we can
			C.critter_attack(holder.target)
			src.has_started = TRUE
	else if(C && M)
		//we're not in punching range, let's fix that by moving back to the move subtask
		var/datum/aiTask/sequence/goalbased/ambush/parent_task = holder.current_task
		parent_task.current_subtask = parent_task.subtasks[1] //index 1 is always the move task in goalbased
		parent_task.subtask_index = 1
		parent_task.current_subtask.reset()

/datum/aiTask/succeedable/ambush/on_reset()
	src.has_started = FALSE
	var/mob/living/critter/C = holder.owner
	if(C)
		C.set_a_intent(INTENT_HARM)	//we an angry critter


/// If a target can see us and we're not hiding, then lets run away and hide
/datum/aiTask/sequence/goalbased/run_and_hide
	name = "hiding"
	weight = 11 //lower than ambush & waiting in ambush, but higher than attack
	max_dist = 11
	var/min_dist = 7

/datum/aiTask/sequence/goalbased/run_and_hide/New(parentHolder, transTask)
	..()
	add_task(holder.get_instance(/datum/aiTask/succeedable/run_and_hide, list(holder)))

/datum/aiTask/sequence/goalbased/run_and_hide/precondition()
	var/mob/living/critter/mimic/C = holder.owner
	var/datum/targetable/critter/mimic/mimic_ability = C.abilityHolder.getAbility(/datum/targetable/critter/mimic)
	return !C.is_hiding && !mimic_ability.disabled && mimic_ability.cooldowncheck()

//list of items in a range min to max that are not visible to other mobs
/datum/aiTask/sequence/goalbased/run_and_hide/get_targets()
	. = list()
	for(var/turf/T in orange(holder.owner, max_dist))
		if(GET_DIST(holder.owner, T) < min_dist)
			continue
		for(var/mob/living/carbon/human/H in viewers(T, 3))
			if(!isdead(H))
				goto breakout //this is a little cursed. If there are humans that can see this turf, jump to the end of the outer loop
		for(var/obj/item/I in T) //otherwise add the items in this turf
			if(!I.anchored) //don't be wall closets or buttons
				. += I
		breakout:

/datum/aiTask/succeedable/run_and_hide
	name = "hiding subtask"
	max_dist = 7
	var/has_started = FALSE

/datum/aiTask/succeedable/run_and_hide/failed()
	var/mob/living/critter/C = holder.owner
	//we got where we're going and we're still visible
	return length(C.seek_target(src.max_dist))

/datum/aiTask/succeedable/run_and_hide/succeeded()
	var/mob/living/critter/mimic/C = holder.owner
	//we sucesssfully hid
	return C.is_hiding

/datum/aiTask/succeedable/run_and_hide/on_tick()
	//cast mimic ability on target item, then try and hide
	if(holder.target)
		var/datum/targetable/critter/mimic/mimic_ability = holder.owner.abilityHolder.getAbility(/datum/targetable/critter/mimic)
		mimic_ability.tryCast(holder.target)

/datum/aiTask/succeedable/run_and_hide/on_reset()
	src.has_started = FALSE
	var/mob/living/critter/C = holder.owner
	if(C)
		C.set_a_intent(INTENT_HELP)	//easier to run away if we can scoot past people
