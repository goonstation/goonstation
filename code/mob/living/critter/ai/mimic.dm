/datum/aiHolder/mimic
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/mimic, list(src))

/datum/aiTask/prioritizer/critter/mimic/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander/critter/aggressive, list(holder, src))

//TODO
// We basically wanna replicate Prey mimics here. So mimics that are disguised should wander when not visible, and hide
// when people are nearby. If discovered, they should become aggressive until the target is incapacitated, then run and
// re-disguise as something else.
// Pouncing, biting. Maybe venom if you're feeling mean.

/// If a target is in range and we're hiding, attack them until they're incapacitated
/datum/aiTask/sequence/goalbased/ambush
	name = "ambushing"
	weight = 10
	max_dist = 3
	ai_turbo = TRUE

/datum/aiTask/sequence/goalbased/ambush/New(parentHolder, transTask)
	..()
	add_task(holder.get_instance(/datum/aiTask/succeedable/ambush, list(holder)))

/datum/aiTask/sequence/goalbased/critter/ambush/precondition()
	var/mob/living/critter/mimic/C = holder.owner
	return C.can_critter_attack() && C.is_hiding

/datum/aiTask/sequence/goalbased/ambush/get_targets()
	var/mob/living/critter/C = holder.owner
	return C.seek_target(src.max_dist)

/datum/aiTask/succeedable/ambush
	name = "ambush subtask"
	max_dist = 7
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
	var/mob/T = holder.target
	if(C && T && BOUNDS_DIST(C, T) == 0)
		C.set_dir(get_dir(C, T))
		if(C.can_critter_attack()) //if we can't attack, just do nothing until we can
			C.critter_attack(holder.target)
			src.has_started = TRUE
	else if(C && T)
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
	weight = 9
	max_dist = 7

/datum/aiTask/sequence/goalbased/run_and_hide/New(parentHolder, transTask)
	..()
	add_task(holder.get_instance(/datum/aiTask/succeedable/run_and_hide, list(holder)))

/datum/aiTask/sequence/goalbased/critter/run_and_hide/precondition()
	var/mob/living/critter/mimic/C = holder.owner
	return !C.is_hiding && length(C.seek_target(src.max_dist))

/datum/aiTask/sequence/goalbased/run_and_hide/get_targets()
	var/mob/living/critter/C = holder.owner
	return list of items that aren't visible to other mobs? fuck that'll be expensive

/datum/aiTask/succeedable/run_and_hide
	name = "hiding subtask"
	max_dist = 7
	var/has_started = FALSE

/datum/aiTask/succeedable/run_and_hide/failed()
	//we got where we're going and we're still visible
	return length(C.seek_target(src.max_dist))

/datum/aiTask/succeedable/run_and_hide/succeeded()
	//we sucesssfully hid
	return C.is_hiding

/datum/aiTask/succeedable/run_and_hide/on_tick()
	//cast mimic ability on target item, then try and hide

/datum/aiTask/succeedable/run_and_hide/on_reset()
	src.has_started = FALSE
	var/mob/living/critter/C = holder.owner
	if(C)
		C.set_a_intent(INTENT_HELP)	//easier to run away if we can scoot past people
