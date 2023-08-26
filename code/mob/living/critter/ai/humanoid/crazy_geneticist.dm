//General idea: Sit next to the console, grab people who come close, walk to the pod, stuff them in, give them genes, spit them out.
/datum/aiHolder/critter/human/crazy_geneticist
	New()
		..()
		default_task = get_instance(/datum/aiTask/prioritizer/critter/human/crazy_geneticist, list(src))

/datum/aiTask/prioritizer/critter/human/crazy_geneticist/New()
	..()
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/find_console, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/grab_patient, list(holder, src))
	transition_tasks += holder.get_instance(/datum/aiTask/timed/wait_for_patient, list(holder, src))

/datum/aiTask/timed/wait_for_patient
	name = "waiting for patients"
	minimum_task_ticks = 5
	maximum_task_ticks = 10
	weight = 14

/datum/aiTask/timed/wait_for_patient/evaluate()
	var/mob/living/critter/C = holder.owner
	var/near_console = FALSE
	for (var/obj/fake_genetics_console/console in range(C, 1))
		near_console = TRUE
		break
	if (!near_console)
		return FALSE
	if(length(C.seek_target(3)))
		return FALSE
	return TRUE

/datum/aiTask/timed/wait_for_patient/on_tick()
	var/mob/living/critter/C = holder.owner
	holder.stop_move()
	if(length(C.seek_target(3)))
		src.holder.owner.ai.interrupt()

/// Agressively grab anyone who comes close, then begin moving to the pod
/datum/aiTask/sequence/goalbased/grab_patient
	name = "grab a patient"
	weight = 16
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
	if (near_console && !ON_COOLDOWN(C, "try_grab", 15 SECONDS))
		return TRUE
	return FALSE

/datum/aiTask/sequence/goalbased/grab_patient/precondition()
	var/mob/living/critter/C = holder.owner
	return C.can_critter_attack()

/datum/aiTask/sequence/goalbased/grab_patient/get_targets()
	var/mob/living/critter/C = holder.owner
	var/target_list = list()
	for (var/mob/living/M in hearers(5, C))
		if (C.valid_target(M))
			if (M.bioHolder && M.bioHolder.effects && M.bioHolder.effects.len <= 5)
				target_list += M
	return target_list

/datum/aiTask/succeedable/grab_patient
	name = "grab a patient subtask"
	max_dist = 5
	var/has_started = FALSE

/datum/aiTask/succeedable/grab_patient/failed()
	if(holder.owner && holder.target)
		return (GET_DIST(holder.owner, holder.target) > max_dist)
	else
		return TRUE

/datum/aiTask/succeedable/grab_patient/succeeded()
	//Do we have a grab?
	var/mob/living/critter/C = holder.owner
	var/obj/item/grab/G = C.equipped()
	if (istype(G) && G.state >= GRAB_AGGRESSIVE) //We are holding someone, add a stuff_scanner task and immediatly cancel AI to do it.
		C.say(pick("Let's get you some genes.", "It'll be quick, come on.", "You need genes.", "Gene time!"))
		holder.priority_tasks += holder.get_instance(/datum/aiTask/sequence/goalbased/stuff_scanner, list(holder, holder.default_task))
		src.holder.owner.ai.interrupt()
		return TRUE
	return FALSE

/datum/aiTask/succeedable/grab_patient/on_tick()
	var/mob/living/critter/C = holder.owner
	var/mob/M = holder.target
	if(C && M && BOUNDS_DIST(C, M) == 0)
		C.set_dir(get_dir(C, M))
		if(C.can_critter_attack())
			C.set_a_intent(INTENT_GRAB)
			var/list/params = list()
			params["left"] = TRUE
			params["ai"] = TRUE
			var/obj/item/grab/G = C.equipped()
			if (!istype(G))
				if(!isnull(G))
					C.drop_item()
				C.hand_attack(M, params)
				attack_particle(C, M)
			else
				if (G.affecting == null || G.assailant == null || G.disposed || isdead(G.affecting))
					C.drop_item()
				else
					if (G.state <= GRAB_PASSIVE)
						G.AttackSelf(C)
			src.has_started = TRUE
	else if(C && M)
		var/datum/aiTask/sequence/goalbased/grab_patient/parent_task = holder.current_task
		parent_task.current_subtask = parent_task.subtasks[1]
		parent_task.subtask_index = 1
		parent_task.current_subtask.reset()

/datum/aiTask/succeedable/grab_patient/on_reset()
	src.has_started = FALSE
	var/mob/living/critter/C = holder.owner
	if(C)
		C.set_a_intent(INTENT_GRAB)

// If we have nothing to do and we aren't at a console, find one.
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
	for_by_tcl(console, /obj/fake_genetics_console)
		if (IN_RANGE(console, holder.owner, max_dist))
			return list(console)
	//If we couldn't find our console, walk around a bit. Maybe it's around here somewhere
	holder.priority_tasks += holder.get_instance(/datum/aiTask/timed/wander, list(holder, holder.default_task))
	return list()

/datum/aiTask/succeedable/find_console
	name = "fetch subtask"
	var/is_complete = FALSE

/datum/aiTask/succeedable/find_console/failed()
	var/mob/living/critter/C = holder.owner
	var/obj/item/I = holder.target
	if(!C || !I || BOUNDS_DIST(I, C) > 0 || !istype(I.loc, /turf))
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
			C.visible_message("<span class='notice'>[C] walks to their console and begins typing away.</span>")
			is_complete = TRUE

/datum/aiTask/succeedable/find_console/on_reset()
	is_complete = FALSE

/datum/aiTask/sequence/goalbased/stuff_scanner
	name = "find a gene scanner"
	max_dist = 10

/datum/aiTask/sequence/goalbased/stuff_scanner/New(parentHolder, transTask)
	..()
	add_task(holder.get_instance(/datum/aiTask/succeedable/stuff_scanner, list(holder)))

/datum/aiTask/sequence/goalbased/stuff_scanner/get_targets()
	for_by_tcl(scanner, /obj/fake_gene_scanner)
		if (IN_RANGE(scanner, holder.owner, max_dist))
			return list(scanner)
	return list()

/datum/aiTask/succeedable/stuff_scanner
	name = "find a gene scanner subtask"
	var/is_complete = FALSE

/datum/aiTask/succeedable/stuff_scanner/failed()
	var/mob/living/critter/C = holder.owner
	if (holder.target == list() || holder.target == null)
		C.drop_item()
		C.say("Where the hell is my scanner?")
		return TRUE
	var/obj/fake_gene_scanner/I = holder.target
	if(!C || !I || BOUNDS_DIST(I, C) > 0 || !istype(I.loc, /turf))
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
			if (istype(G) && G.state >= GRAB_AGGRESSIVE && G.affecting && ismob(G.affecting))
				var/mob/M = G.affecting
				C.visible_message("<span class='alert'>[C] expertly shoves [M] inside [I] and locks it down. [I] whirs to life and begins operating automatically.</span>")
				I.lock_and_gene(M)
			is_complete = TRUE

/datum/aiTask/succeedable/stuff_scanner/on_reset()
	is_complete = FALSE
