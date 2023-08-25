//General idea: Sit next to the console, grab people who come close, walk to the pod, stuff them in, give them genes, spit them out.
//Todo, figure out why he stands around when you arent near.
/datum/aiHolder/critter/human/crazy_geneticist
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/human/crazy_geneticist, list(src))
		/*
		var/datum/aiTask/timed/targeted/human/genetics/G = get_instance(/datum/aiTask/timed/targeted/human/genetics, list(src))
		default_task = G
		G.transition_task = G
*/
/datum/aiTask/prioritizer/critter/human/crazy_geneticist/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/find_console, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/grab_patient, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wait_for_patient, list(holder, src))


/datum/aiTask/timed/wait_for_patient
	name = "waiting for patients"
	minimum_task_ticks = 5
	maximum_task_ticks = 10
	weight = 15

/datum/aiTask/timed/wait_for_patient/evaluate()
	var/mob/living/critter/C = holder.owner
	var/near_console = FALSE
	for (var/obj/fake_genetics_console/console in range(C, 1))
		near_console = TRUE
		break
	if (!near_console)
		return FALSE
	return TRUE

/datum/aiTask/timed/wait_for_patient/evaluate()
	var/mob/living/critter/C = holder.owner
	if(length(C.seek_target(3)))
		return 0
	return 100*weight  //Note goalbased evaluate returns a percentage which is multiplied by a weight. Only return a high priority if we're hiding, otherwise 0

/datum/aiTask/timed/wait_for_patient/on_tick()
	var/mob/living/critter/C = holder.owner
	holder.stop_move()
	if(length(C.seek_target(3))) //ambush max dist
		src.holder.owner.ai.interrupt()

/// If a target is in range and we're hiding, attack them until they're incapacitated
/datum/aiTask/sequence/goalbased/grab_patient
	name = "grab a patient"
	weight = 20
	max_dist = 3
	ai_turbo = TRUE

/datum/aiTask/sequence/goalbased/grab_patient/New(parentHolder, transTask)
	..()
	add_task(holder.get_instance(/datum/aiTask/succeedable/grab_patient, list(holder)))

/datum/aiTask/sequence/goalbased/grab_patient/evaluate()
	var/mob/living/critter/C = holder.owner
	var/near_console = FALSE
	for (var/obj/fake_genetics_console/console in range(C, 1))
		near_console = TRUE
		break
	if (!near_console || (GET_COOLDOWN(src.holder.owner, "try_grab")))
		return FALSE
	return TRUE

/datum/aiTask/sequence/goalbased/grab_patient/precondition()
	var/mob/living/critter/C = holder.owner
	return C.can_critter_attack()

/datum/aiTask/sequence/goalbased/grab_patient/get_targets()
	var/mob/living/critter/C = holder.owner
	var/target_list = list()
	for (var/mob/living/M in hearers(5, C))
		if (C.valid_target(M))
			if (M.bioHolder && M.bioHolder.effects && M.bioHolder.effects.len <= 6)
				target_list += M
			else
				C.say("You have enough genes pal.")
	return target_list

/datum/aiTask/succeedable/grab_patient
	name = "grab a patient subtask"
	max_dist = 5
	var/has_started = FALSE

/datum/aiTask/succeedable/grab_patient/failed()
	//failure condition is just that the target escaped
	if(holder.owner && holder.target)
		return (GET_DIST(holder.owner, holder.target) > max_dist)
	else
		return TRUE //we also fail if owner or target are somehow null

/datum/aiTask/succeedable/grab_patient/succeeded()
	//check for grab
	var/mob/living/critter/C = holder.owner
	var/obj/item/grab/G = C.equipped()
	if (istype(G) && G.state >= GRAB_AGGRESSIVE) //if it hasn't grabbed something, try to
		C.say(pick("Let's get you some genes.", "It'll be quick, come on.", "You need genes."))
		holder.priority_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/stuff_scanner, list(holder, holder.default_task))
		src.holder.owner.ai.interrupt()
		return TRUE
	return FALSE

/datum/aiTask/succeedable/grab_patient/on_tick()
	//keep moving towards the target and attempt to grab them
	//has_started marks that we've hit them once
	ON_COOLDOWN(src.holder.owner, "try_grab", 15 SECONDS)
	var/mob/living/critter/C = holder.owner
	var/mob/M = holder.target
	if(C && M && BOUNDS_DIST(C, M) == 0)
		C.set_dir(get_dir(C, M))
		if(C.can_critter_attack()) //if we can't attack, just do nothing until we can
			C.set_a_intent(INTENT_GRAB)
			var/list/params = list()
			params["left"] = TRUE
			params["ai"] = TRUE
			var/obj/item/grab/G = C.equipped()
			if (!istype(G)) //if it hasn't grabbed something, try to
				if(!isnull(G)) //if we somehow have something that isn't a grab in our hand
					C.drop_item()
				C.hand_attack(M, params)
			else
				if (G.affecting == null || G.assailant == null || G.disposed || isdead(G.affecting))
					C.drop_item()
				else
					if (G.state <= GRAB_PASSIVE)
						G.AttackSelf(C)
			src.has_started = TRUE
	else if(C && M)
		//we're not in punching range, let's fix that by moving back to the move subtask
		var/datum/aiTask/sequence/goalbased/grab_patient/parent_task = holder.current_task
		parent_task.current_subtask = parent_task.subtasks[1] //index 1 is always the move task in goalbased
		parent_task.subtask_index = 1
		parent_task.current_subtask.reset()

/datum/aiTask/succeedable/grab_patient/on_reset()
	src.has_started = FALSE
	var/mob/living/critter/C = holder.owner
	if(C)
		C.set_a_intent(INTENT_GRAB)

// Go fetch!
/datum/aiTask/sequence/goalbased/find_console
	name = "find our console"
	weight = 15
	max_dist = 10

/datum/aiTask/sequence/goalbased/find_console/New(parentHolder, transTask)
	..()
	var/mob/living/critter/C = holder.owner
	var/near_console = FALSE
	for (var/obj/fake_genetics_console/console in range(C, 1))
		near_console = TRUE
		break
	if (!near_console)
		add_task(holder.get_instance(/datum/aiTask/succeedable/find_console, list(holder)))

/datum/aiTask/sequence/goalbased/find_console/evaluate()
	var/mob/living/critter/C = holder.owner
	var/near_console = FALSE
	for (var/obj/fake_genetics_console/console in range(C, 1))
		near_console = TRUE
		break
	if (!near_console)
		return TRUE
	return FALSE

/datum/aiTask/sequence/goalbased/find_console/get_targets()
	for (var/obj/fake_genetics_console/console in range(holder.owner, src.max_dist))
		return list(console)
	return list()

//Fetch subtask, pick up the item
/datum/aiTask/succeedable/find_console
	name = "fetch subtask"
	var/is_complete = FALSE

/datum/aiTask/succeedable/find_console/failed()
	var/mob/living/critter/C = holder.owner
	var/obj/item/I = holder.target
	if(!C || !I || BOUNDS_DIST(I, C) > 0 || !istype(I.loc, /turf)) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/find_console/succeeded()
	return is_complete

/datum/aiTask/succeedable/find_console/on_tick()
	if(!is_complete)
		holder.stop_move()
		var/mob/living/critter/C = holder.owner
		var/obj/item/I = holder.target
		if(C && I && BOUNDS_DIST(C, I) == 0 && istype(I.loc, /turf))
			C.set_dir(get_dir(C, I))
			C.visible_message("<span class='notice'>[C] walks to their console and sits down.</span>")
			is_complete = TRUE

//We couldn't find our console. Walk around aimlessly until we find it
/datum/aiTask/succeedable/find_console/on_reset()
	is_complete = FALSE
	//holder.priority_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, holder.default_task))

// Go fetch!
/datum/aiTask/sequence/goalbased/stuff_scanner
	name = "find our console"
	max_dist = 10

/datum/aiTask/sequence/goalbased/stuff_scanner/New(parentHolder, transTask)
	..()
	add_task(holder.get_instance(/datum/aiTask/succeedable/stuff_scanner, list(holder)))

/datum/aiTask/sequence/goalbased/stuff_scanner/get_targets()
	for (var/obj/fake_gene_scanner/scanner in range(holder.owner, src.max_dist))
		return list(scanner)
	return list()

//Fetch subtask, pick up the item
/datum/aiTask/succeedable/stuff_scanner
	name = "fetch subtask"
	var/is_complete = FALSE

/datum/aiTask/succeedable/stuff_scanner/failed()
	var/mob/living/critter/C = holder.owner
	var/obj/fake_gene_scanner/I = holder.target
	if(!C || !I || BOUNDS_DIST(I, C) > 0 || !istype(I.loc, /turf)) //the tasks fails and is re-evaluated if the target is not in range
		return TRUE

/datum/aiTask/succeedable/stuff_scanner/succeeded()
	return is_complete

/datum/aiTask/succeedable/stuff_scanner/on_tick()
	if(!is_complete)
		holder.stop_move()
		var/mob/living/critter/C = holder.owner
		var/obj/fake_gene_scanner/I = holder.target
		if(C && I && BOUNDS_DIST(C, I) == 0 && istype(I.loc, /turf))
			C.set_dir(get_dir(C, I))
			C.visible_message("<span class='notice'>[C] walks up to [I].</span>")
			var/obj/item/grab/G = C.equipped()
			if (istype(G) && G.state >= GRAB_AGGRESSIVE) //if it hasn't grabbed something, try to
				if (G.affecting && ismob(G.affecting))
					var/mob/M = G.affecting
					M.set_loc(I)
					I.gene_randomly(G.affecting)
			is_complete = TRUE

//We couldn't find our console. Walk around aimlessly until we find it
/datum/aiTask/succeedable/stuff_scanner/on_reset()
	is_complete = FALSE
