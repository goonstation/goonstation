//For the sawfly critter itself, check mob/living/critter/sawfly.dm
//For misc things, check sawflymisc.dm in code/obj.sawflymisc

/datum/aiHolder/sawfly

	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/sawfly, list(src))

/datum/aiTask/prioritizer/sawfly
	name = "base thinking (should never see this)"

/datum/aiTask/prioritizer/sawfly/New()
	..()
	// populate the list of tasks
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/targeted/sawfly_attack, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab, list(holder, src))

/datum/aiTask/prioritizer/sawfly/on_tick()
	if(isdead(holder.owner))
		holder.enabled = FALSE
		walk(holder.owner, 0)

/datum/aiTask/prioritizer/sawfly/on_reset()
	..()
	walk(holder.owner, 0)

// Custom behaviour starts here

// Attack code - looks for adjacent targets, tries to stab them
/datum/aiTask/timed/targeted/sawfly_attack
	var/found_path = null
	name = "attacking"
	minimum_task_ticks = 10
	maximum_task_ticks = 25
	var/weight = 10
	target_range = 1
	var/list/dummy_params = list("icon-x" = 16, "icon-y" = 16)

/datum/aiTask/timed/targeted/sawfly_attack/evaluate()
	return weight * score_target(get_best_target(get_targets()))

/datum/aiTask/timed/targeted/sawfly_attack/on_tick()
	var/mob/living/critter/robotic/sawfly/owncritter = holder.owner
	if(prob(5)) owncritter.communalbeep()
	holder.stop_move()
	if(!holder.target)
		holder.target = get_best_target(get_targets())
	if(holder.target)
		var/atom/T = holder.target
		// if target is dead
		// fetch a new one if we can
		if(isliving(T))
			var/mob/living/M = T
			if(M.health < -50)
				holder.target = get_best_target(get_targets())
			if(istype(T, /mob/living/critter/robotic/sawfly))
				holder.target = get_best_target(get_targets())
		if(!holder.target) //we lost target, re-evaluate tasks
			holder.interrupt()
			return

		var/dist = get_dist(owncritter, holder.target)
		if(dist > target_range)
			if(!src.found_path)
				src.found_path = get_path_to(holder.owner, holder.target, 18, 0)
			if(src.found_path)
				walk_rand(src,4)
				holder.move_to_with_path(holder.target, src.found_path, 1)
				owncritter.set_dir(get_dir(owncritter, holder.target)) //attack regardless
				owncritter.hand_attack(holder.target, dummy_params)
			frustration++ //if frustration gets too high, the task is ended and re-evaluated
		else
			owncritter.set_dir(get_dir(owncritter, holder.target))
			owncritter.hand_attack(holder.target, dummy_params)



/datum/aiTask/timed/targeted/sawfly_attack/get_targets()
	. = list()
	var/mob/living/critter/robotic/sawfly/owncritter = holder.owner

	for (var/mob/living/C in view(owncritter,target_range))
		if(C == owncritter) continue

		if(istype(C, /mob/living/critter/robotic/sawfly)) continue
		if (C.health < -50 || !isalive(C)) continue
		if (C.job == "Security Officer" || C.job == "Head of Security")
			. = list(C) //found a secoff, just return that
			return
		if (C in owncritter.friends) continue
		if (istraitor(C) || isnukeop(C) || isspythief(C)) // frens :)
			boutput(C, "<span class='alert'> The sawfly's IFF system silently flags you as an ally! </span>")
			owncritter.friends += C
			continue
		if(istype(C, /mob/living/silicon/ai)) continue // AI cores are tanky and distract nukie sawflies in med/robotics
		. += C //you passed all the checks it, now you get added to the list for consideration

//chase behaviour - pick someone, run up to them, and stab em
/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab
	name = "chasing"
	weight = 15
	max_dist = 12
	can_be_adjacent_to_target = TRUE
	var/found_path = null

/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/sawfly_stab, list(holder)))

/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab/evaluate()
	. = precondition() * weight * score_target(get_best_target(get_targets()))

/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab/on_tick()

	if(!holder.target)
		holder.target = get_best_target(get_targets())
	..()

/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab/get_targets()
	. = list()
	var/mob/living/critter/robotic/sawfly/owncritter = holder.owner
	for (var/mob/living/C in view(owncritter,max_dist))
		if(C == owncritter) continue
		if (C.health < -50 || !isalive(C)) continue
		if (C.job == "Security Officer" || C.job == "Head of Security")
			. = list(C) //found a secoff, just return that
			return
		if(istype(C, /mob/living/critter/robotic/sawfly)) continue
		if (C in owncritter.friends) continue
		if (istraitor(C) || isnukeop(C) || isspythief(C)) // frens :)
			boutput(C, "<span class='alert'> The [owncritter]'s IFF system silently flags you as an ally! </span>")
			owncritter.friends += C
			continue
		. += C //you passed all the checks it, now you get added to the list for consideration
	. = get_path_to(holder.owner, ., max_dist*2, 1) //calculate paths to the target, any unreachable targets will be discarded
	//if(prob(5))
	//	holder.owner.communalbeep()

/datum/aiTask/succeedable/sawfly_stab
	name = "stab subtask"
	var/found_path = null
	var/has_started = FALSE
	var/list/dummy_params = list("icon-x" = 16, "icon-y" = 16)

/datum/aiTask/succeedable/sawfly_stab/failed()
	var/mob/living/critter/robotic/sawfly/F = holder.owner
	if(!F)
		return TRUE
	if(!holder.target)
		return TRUE
	if(get_dist(F, holder.target) > 1) //moved away before we could finish
		return TRUE

/datum/aiTask/succeedable/sawfly_stab/succeeded()
	return has_started

/datum/aiTask/succeedable/sawfly_stab/on_tick()
	if(!has_started && !failed() && !succeeded())
		if(holder.target)
			var/mob/living/critter/robotic/sawfly/owncritter = holder.owner
			owncritter.set_dir(get_dir(owncritter, holder.target))
			owncritter.hand_attack(holder.target, dummy_params)
			has_started = TRUE
		else
			holder.interrupt() //somehow lost target, go do something else
			return

/datum/aiTask/succeedable/sawfly_stab/on_reset()
	has_started = FALSE
	src.found_path = null
	..()
