// in here I dump ai tasks that seem like they could be useful to other people
// but are far too specific to warrant going into ai.dm - cirr

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// GOALBASED PRIORITIZER TASK
// a child prioritizer geared to a very specific set of needs
// responsible for: selecting a target (and reporting back the evaluation score based on its value)
// and moving through the following two tasks:
// moving to a selected target, performing a /datum/action on the selected target
/datum/aiTask/sequence/goalbased/
	name = "goal parent"

/datum/aiTask/sequence/goalbased/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/move, list(holder)))
	// SECOND TASK IS SUBGOAL SPECIFIC

/datum/aiTask/sequence/goalbased/evaluate()
	. = 0
	if(src.precondition())
		return score_target(get_best_target(get_targets())) * weight

///Is the target VALID?
/datum/aiTask/sequence/goalbased/proc/valid_target(var/atom/target)
	return FALSE

/datum/aiTask/sequence/goalbased/proc/precondition()
	// useful for goals that have a requirement, return 0 to instantly make this state score 0 and not be picked
	. = TRUE

/datum/aiTask/sequence/goalbased/on_tick()
	..()
	if(!holder.target)
		holder.target = get_best_target(get_targets())
	if(istype(subtasks[subtask_index], /datum/aiTask/succeedable/move)) // MOVE TASK
		// make sure we both set our target and move to our target correctly
		var/datum/aiTask/succeedable/move/M = subtasks[subtask_index]
		if(M && !M.move_target)
			M.distance_from_target = src.distance_from_target
			M.move_target = holder.target

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// WANDER TASK
// spend a few ticks wandering aimlessly
/datum/aiTask/timed/wander
	name = "wandering"
	minimum_task_ticks = 5
	maximum_task_ticks = 10

/datum/aiTask/timed/wander/evaluate()
	. = 1 // it'd require every other task returning very small values for this to get selected

/datum/aiTask/timed/wander/on_tick()
	// thanks zewaka for reminding me the previous implementation of this is BYOND NATIVE
	// thanks byond forums for letting me know that the byond native implentation FUCKING SUCKS
	holder.owner.move_dir = pick(alldirs)
	holder.owner.process_move()
	holder?.stop_move() // Just in case they yeet themselves out of existance
	holder?.owner.move_dir = null // clear out direction so it doesn't get latched when client is attached

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// TARGETED TASK
// a timed task that also relates to a target and the acquisition of said target
/datum/aiTask/timed/targeted
	name = "targeted"
	var/target_range = 8

	score_target(atom/target)
		. = 0
		if(target)
			return 100*(target_range - GET_MANHATTAN_DIST(get_turf(holder.owner), get_turf(target)))/target_range //normalize distance weighting
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// MOVE TASK
// target: holder target assigned by a sequence task
/datum/aiTask/succeedable/move
	name = "moving"
	max_fails = 2
	var/max_path_dist = 50 //keeping this low by default, but you can override it - see /datum/aiTask/sequence/goalbased/rally for details
	var/list/found_path = null
	var/turf/move_target = null

// use the target from our holder
/datum/aiTask/succeedable/move/proc/get_path()
	if(QDELETED(src.move_target))
		fails++
		return
	if(length(holder.target_path) && GET_DIST(holder.target_path[length(holder.target_path)], move_target) <= distance_from_target)
		src.found_path = holder.target_path
	else
		src.found_path = get_path_to(holder.owner, move_target, src.max_path_dist, distance_from_target, null, !move_through_space)
		if(GET_DIST(get_turf(holder.target), move_target) <= distance_from_target)
			holder.target_path = src.found_path
	if(!src.found_path) // no path :C
		fails++

/datum/aiTask/succeedable/move/on_reset()
	src.found_path = null
	src.move_target = null


/datum/aiTask/succeedable/move/on_tick()
	if(!src.move_target)
		fails++
		return
	if(!length(src.found_path))
		get_path()
	if(length(src.found_path))
		holder.move_to_with_path(move_target, src.found_path, 0)

/datum/aiTask/succeedable/move/succeeded()
	if(move_target)
		. = (GET_DIST(holder.owner, src.move_target) <= distance_from_target)
		if(.)
			holder.stop_move()
		return

/datum/aiTask/succeedable/move/failed()
	if(!move_target || !src.found_path)
		fails++
	return fails >= max_fails

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// WAIT TASK
// uh, yeah. spend a couple ticks waiting, whatever
// logic for going back to previous task is handled by holder
/datum/aiTask/timed/wait
	name = "waiting"
	minimum_task_ticks = 10
	maximum_task_ticks = 10

/datum/aiTask/timed/hibernate
	name = "hibernate"
	minimum_task_ticks = 1
	maximum_task_ticks = 1
	var/min_time_between_hibernations = 20 SECONDS
	var/hibernation_priority = 100

	evaluate()
		. = ..()
		var/mob/living/critter/M = holder.owner
		if (!M)
			return -1
		var/area/A = get_area(M)
		if (A?.active)
			return -1
		if ((M.last_hibernation_wake_tick + min_time_between_hibernations) >= TIME)
			return -1
		return hibernation_priority

	on_tick()
		. = ..()
		var/mob/living/critter/M = holder.owner
		if (!M) return
		holder.disable()
		M.is_hibernating = TRUE
		M.registered_area = get_area(M)
		if(M.registered_area)
			M.registered_area.registered_mob_critters |= M

//AI: Follower
// You will have to code your own exit conditions and your own code for setting "following"
/datum/aiTask/timed/targeted/follower
	name = "follow"
	minimum_task_ticks = 10000
	maximum_task_ticks = 10000
	target_range = 10
	frustration_threshold = 3
	var/last_seek = null
	var/following = null

/datum/aiTask/timed/targeted/follower/proc/precondition()
	. = 0
	if(following)
		if(IN_RANGE(holder.owner, following, target_range))
			. = 1

/datum/aiTask/timed/targeted/follower/frustration_check()
	.= 0
	if (!IN_RANGE(holder.owner, holder.target, target_range))
		return 1

	if (ismob(holder.target))
		var/mob/M = holder.target
		. = !(holder.target && !isdead(M))
	else
		. = !(holder.target)

/datum/aiTask/timed/targeted/follower/score_target(atom/target)
	. = ..()

/datum/aiTask/timed/targeted/follower/evaluate()
	..()
	. = precondition() * 4 //FOLLOW_PRIORITY = 4

/datum/aiTask/timed/targeted/follower/on_tick()
	var/mob/living/critter/owncritter = holder.owner
	if (HAS_ATOM_PROPERTY(owncritter, PROP_MOB_CANTMOVE))
		return

	if(length(holder.owner.grabbed_by) > 1)
		holder.owner.resist()

	if(!holder.target)
		if (world.time > last_seek + 4 SECONDS)
			last_seek = world.time
			var/list/possible = get_targets()
			if (possible.len)
				holder.target = pick(possible)
	if(holder.target && holder.target.z == owncritter.z)
		var/mob/living/M = holder.target
		if(!isalive(M))
			holder.target = null
			holder.target = get_best_target(get_targets())
			if(!holder.target)
				return ..() // try again next tick
			else
				M = holder.target

		var/dist = get_dist(owncritter, M)
		if (dist > 1)
			holder.move_to(M,1)
	..()

/datum/aiTask/timed/targeted/follower/get_targets()
	. = list()
	. += following

/datum/aiTask/timed/targeted/follower/on_reset()
	..()
	holder.target = null
	holder.stop_move()
