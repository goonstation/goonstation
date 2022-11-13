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
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab, list(holder, src))

/datum/aiTask/prioritizer/sawfly/on_reset()
	..()
	walk(holder.owner, 0)

// Custom behaviour starts here
/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab
	name = "chasing"
	weight = 15
	max_dist = 6
	can_be_adjacent_to_target = TRUE
	var/found_path = null
	var/target_range = 1
	var/list/dummy_params = list("icon-x" = 16, "icon-y" = 16)

/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab/New(parentHolder, transTask)
	..(parentHolder, transTask)

/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab/evaluate()
	. = precondition() * weight * score_target(get_best_target(get_targets()))

/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab/on_tick()
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

		var/dist = GET_DIST(owncritter, holder.target)
		if(dist > target_range)
			if(!src.found_path)
				src.found_path = get_path_to(holder.owner, holder.target, 18, 0)
			if(src.found_path)
				walk_rand(src,4)
				holder.move_to_with_path(holder.target, src.found_path, 1)
				if(in_interact_range(owncritter, holder.target))
					owncritter.set_dir(get_dir(owncritter, holder.target)) //attack regardless
					owncritter.hand_attack(holder.target, dummy_params)
		else
			if(in_interact_range(owncritter, holder.target))
				owncritter.set_dir(get_dir(owncritter, holder.target))
				owncritter.hand_attack(holder.target, dummy_params)

	if(!holder.target)
		holder.target = get_best_target(get_targets())
	..()

/datum/aiTask/sequence/goalbased/sawfly_chase_n_stab/get_targets()
	. = list()
	var/targetcount = 0
	var/maxtargets = 8

	var/mob/living/critter/robotic/sawfly/owncritter = holder.owner
	for (var/mob/living/C in viewers(max_dist, owncritter))
		if (C.health < -50 || !isalive(C))
			continue
		if(istype(C, /mob/living/critter/robotic/sawfly))
			continue
		if (isintangible(C))
			continue
		if(C.mind?.special_role)
			if (issawflybuddy(C)) // frens :)
				if (!(C.weakref in owncritter.friends))
					boutput(C, "<span class='alert'> [owncritter]'s IFF system silently flags you as an ally! </span>")
					owncritter.friends += get_weakref(C)
				continue
		if(C.job in list( "Head of Security", "Security Officer", "Nanotrasen Security Consultant")) //hopefully this is cheaper than the OR chain I had before
			. = list(C) //go get em, tiger
			return
		if(GET_DIST(C, owncritter) <2) //go after those standing right next to you. <2 is slightly
			. = list(C)
			return
		. += C //you passed all the checks it, now you get added to the list for consideration

		targetcount++
		if(targetcount >= maxtargets) //prevents them from getting too hung up on finding folks
			break
