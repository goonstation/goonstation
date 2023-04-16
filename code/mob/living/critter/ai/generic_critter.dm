// This is the mob-ai version of the /obj/critter default AI
// If you're transitioning an /obj/critter to /mob/living/critter, you probably want this file to start unless you're doing super weird stuff

/* To implement your mobAI, you want to copy the following code and replace critter_name with your critter's name, then subclass
	/datum/aiTask/prioritizer/critter and add the appropriate transition tasks - see ./spider.dm for an example

/datum/aiHolder/critter_name
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/critter_name, list(src))

*/

/datum/aiTask/prioritizer/critter
	name = "base critter thinking (should never see this)"


/// When you subclass this for your critter, add tasks to transition_tasks here to have them be considered each tick
/datum/aiTask/prioritizer/critter/New()
	..()
	//EXAMPLE OF TASK ADDING - DON'T REMOVE
	//transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	//transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/critter/attack, list(holder, src))

/datum/aiTask/prioritizer/critter/on_reset()
	..()
	//holder.stop_move()

// TASK DEFINITIONS GO BELOW
// This is where the actual behaviour is defined.
//--------------------------------------------------------------------------------------------------------------------------------------------------//


///This is standard wander behaviour with frequent checks for nearby enemies, which will interrupt the wandering.
/datum/aiTask/timed/wander/critter/aggressive
	name = "aggressive wander"

/datum/aiTask/timed/wander/critter/aggressive/on_tick()
	var/mob/living/critter/C = holder.owner
	if(istype(holder.owner) && length(C.seek_target()))
		src.holder.owner.ai.interrupt()
	else
		..()


//--------------------------------------------------------------------------------------------------------------------------------------------------//

/// This one makes the critter move towards a target returned from holder.owner.seek_target()
/datum/aiTask/sequence/goalbased/critter/attack
	name = "attacking"
	weight = 10 // attack behaviour gets a high priority
	ai_turbo = TRUE //attack behaviour gets a speed boost for robustness
	max_dist = 7

/datum/aiTask/sequence/goalbased/critter/attack/New(parentHolder, transTask) //goalbased aitasks have an inherent movement component
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/attack, list(holder)))

/datum/aiTask/sequence/goalbased/critter/attack/precondition()
	var/mob/living/critter/C = holder.owner
	return C.can_critter_attack()

/datum/aiTask/sequence/goalbased/critter/attack/on_reset()
	..()
	var/mob/living/critter/C = holder.owner
	if(C)
		C.set_a_intent(INTENT_HARM)

/datum/aiTask/sequence/goalbased/critter/attack/get_targets()
	var/mob/living/critter/C = holder.owner
	return C.seek_target(src.max_dist)

/////////////// The aiTask/succeedable handles the behaviour to do when we're in range of the target

/datum/aiTask/succeedable/critter/attack
	name = "attack subtask"
	var/has_started = FALSE

/datum/aiTask/succeedable/critter/attack/failed()
	var/mob/living/critter/C = holder.owner
	var/mob/T = holder.target
	if(!has_started && !C.can_critter_attack()) //if we haven't started and can't attack, task fail.
		return TRUE
	if(!C || !T || BOUNDS_DIST(T, C) > 0) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/critter/attack/succeeded()
	var/mob/living/critter/C = holder.owner
	return has_started && C.can_critter_attack() //if we've started an attack, and can attack again, then hooray, we have completed this task

/datum/aiTask/succeedable/critter/attack/on_tick()
	if(!has_started)
		var/mob/living/critter/C = holder.owner
		var/mob/T = holder.target
		if(C && T && BOUNDS_DIST(holder.owner, holder.target) == 0)
			holder.owner.set_dir(get_dir(holder.owner, holder.target))
			C.critter_attack(holder.target)
			has_started = TRUE

/datum/aiTask/succeedable/critter/attack/on_reset()
	has_started = FALSE


//--------------------------------------------------------------------------------------------------------------------------------------------------//


/// This one makes the critter move towards a corpse returned from holder.owner.seek_scavenge_target()
/datum/aiTask/sequence/goalbased/critter/scavenge
	name = "scavenging"
	weight = 3
	max_dist = 7

/datum/aiTask/sequence/goalbased/critter/scavenge/New(parentHolder, transTask) //goalbased aitasks have an inherent movement component
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/scavenge, list(holder)))

/datum/aiTask/sequence/goalbased/critter/scavenge/precondition()
	var/mob/living/critter/C = holder.owner
	return C.can_critter_scavenge()

/datum/aiTask/sequence/goalbased/critter/scavenge/get_targets()
	var/mob/living/critter/C = holder.owner
	return C.seek_scavenge_target(src.max_dist)

////////

/datum/aiTask/succeedable/critter/scavenge
	name = "scavenge subtask"
	var/has_started = FALSE

/datum/aiTask/succeedable/critter/scavenge/failed()
	var/mob/living/critter/C = holder.owner
	var/mob/T = holder.target
	if(!has_started && !C.can_critter_attack()) //if we haven't started and can't scavenge, task fail.
		return TRUE
	if(!C || !T || BOUNDS_DIST(T, C) > 0) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/critter/scavenge/succeeded()
	var/mob/living/critter/C = holder.owner
	return has_started && C.can_critter_scavenge() //if we've started, and can scavenge again, then hooray, we have completed this task

/datum/aiTask/succeedable/critter/scavenge/on_tick()
	if(!has_started)
		var/mob/living/critter/C = holder.owner
		var/mob/T = holder.target
		if(C && T && BOUNDS_DIST(holder.owner, holder.target) == 0)
			holder.owner.set_dir(get_dir(holder.owner, holder.target))
			C.critter_scavenge(holder.target)
			has_started = TRUE

/datum/aiTask/succeedable/critter/scavenge/on_reset()
	has_started = FALSE


//--------------------------------------------------------------------------------------------------------------------------------------------------//


/// This one makes the critter move towards a food item returned from holder.owner.seek_food_target()
/datum/aiTask/sequence/goalbased/critter/eat
	name = "eating"
	weight = 3
	max_dist = 7

/datum/aiTask/sequence/goalbased/critter/eat/New(parentHolder, transTask) //goalbased aitasks have an inherent movement component
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/eat, list(holder)))

/datum/aiTask/sequence/goalbased/critter/eat/precondition()
	var/mob/living/critter/C = holder.owner
	return C.can_critter_eat()

/datum/aiTask/sequence/goalbased/critter/eat/get_targets()
	var/mob/living/critter/C = holder.owner
	return C.seek_food_target(src.max_dist)

////////

/datum/aiTask/succeedable/critter/eat
	name = "eat subtask"
	var/has_started = FALSE

/datum/aiTask/succeedable/critter/eat/failed()
	var/mob/living/critter/C = holder.owner
	var/obj/item/reagent_containers/food/snacks/T = holder.target
	if(!has_started && !C.can_critter_eat()) //if we haven't started and can't eat, task fail.
		return TRUE
	if(!C || !T || BOUNDS_DIST(T, C) > 0) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/critter/eat/succeeded()
	var/mob/living/critter/C = holder.owner
	return has_started && C.can_critter_eat() //if we've started, and can eat again, then hooray, we have completed this task

/datum/aiTask/succeedable/critter/eat/on_tick()
	if(!has_started)
		var/mob/living/critter/C = holder.owner
		var/obj/item/reagent_containers/food/snacks/T = holder.target
		if(C && T && BOUNDS_DIST(holder.owner, holder.target) == 0)
			holder.owner.set_dir(get_dir(holder.owner, holder.target))
			T.Eat(C, C, TRUE)
			has_started = TRUE

/datum/aiTask/succeedable/critter/eat/on_reset()
	has_started = FALSE


/// This one makes the mob move towards a target mob and attack it. Repeats until the target is dead, gone, too far, or we are incapacitated. Called upon being attacked if the ai is set to retaliate
/datum/aiTask/sequence/goalbased/retaliate
	name = "retaliating"
	weight = -100
	max_dist = 7
	ai_turbo = TRUE
	var/mob/targetted_mob = null
	var/start_time = 0


/datum/aiTask/sequence/goalbased/retaliate/New(parentHolder, transTask)
	..()
	add_task(holder.get_instance(/datum/aiTask/succeedable/retaliate, list(holder)))

/datum/aiTask/sequence/goalbased/retaliate/get_targets()
	return list(src.targetted_mob)

////////

/datum/aiTask/succeedable/retaliate
	name = "retaliate subtask"
	max_dist = 7
	var/has_started = FALSE
	var/persistence = 0


/datum/aiTask/succeedable/retaliate/failed()
	//failure condition is just that the target escaped
	if(holder.owner && holder.target)
		return (GET_DIST(holder.owner, holder.target) > max_dist)
	else
		return TRUE //we also fail if C or T are somehow null


/datum/aiTask/succeedable/retaliate/succeeded()
	var/mob/T = holder.target
	//for persistence special values
	if(src.persistence == RETALIATE_ONCE && src.has_started) //we're on "attack-once" mode, and we've done that. Good job!
		return TRUE
	if(src.persistence == RETALIATE_UNTIL_INCAP && is_incapacitated(T)) //attack until downed, and the target is incapacitated
		return TRUE
	if(src.persistence == RETALIATE_UNTIL_DEAD && isdead(T)) //attack until dead, and the target is dead
		return TRUE
	var/datum/aiTask/sequence/goalbased/retaliate/parent_task = holder.current_task
	if(src.persistence > 0 && ((TIME - parent_task.start_time) > src.persistence)) //otherwise, has the time run out?
		return TRUE
	return FALSE


/datum/aiTask/succeedable/retaliate/on_tick()
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
		var/datum/aiTask/sequence/goalbased/retaliate/parent_task = holder.current_task
		parent_task.current_subtask = parent_task.subtasks[1] //index 1 is always the move task in goalbased
		parent_task.subtask_index = 1
		parent_task.current_subtask.reset()

/datum/aiTask/succeedable/retaliate/on_reset()
	src.has_started = FALSE
	var/mob/living/critter/C = holder.owner
	if(C)
		C.set_a_intent(INTENT_HARM)	//we an angry critter
		src.persistence = C.ai_retaliate_persistence

// Don't worry about this, we need to enable unsimulated turf pathing for the critter gauntlet
/datum/aiTask/sequence/goalbased/critter
	move_through_space = TRUE


