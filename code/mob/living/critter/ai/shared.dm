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
	var/weight = 1 // for weighting the importance of the goal this sequence is in charge of
	var/max_dist = 5 // the maximum tile distance that we look for targets
	var/can_be_adjacent_to_target = 1 // do we need to be AT the target specifically, or is being in 1 tile of it fine?

/datum/aiTask/sequence/goalbased/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/move, list(holder)))
	// SECOND TASK IS SUBGOAL SPECIFIC

/datum/aiTask/sequence/goalbased/evaluate()
	return score_goal() * weight

/datum/aiTask/sequence/goalbased/proc/get_best_target(var/list/targets)
	. = null
	var/best_score = -1.#INF
	if(length(targets))
		for(var/atom/A in targets)
			var/score = src.score_target(A)
			if(score > best_score)
				best_score = score
				. = A
	holder.target = .

/datum/aiTask/sequence/goalbased/proc/get_targets()
	// obviously a specific goal will have specific requirements for targets
	return list()

/datum/aiTask/sequence/goalbased/proc/score_target(var/atom/target)
	if(target)
		return max_dist - distance(get_turf(holder.owner), get_turf(target))
	return 0

/datum/aiTask/sequence/goalbased/proc/precondition()
	// useful for goals that have a requirement, return 0 to instantly make this state score 0 and not be picked
	return 1

/datum/aiTask/sequence/goalbased/proc/score_goal()
	// do any specific stuff here, eg. if the goal requires some conditions and they don't exist, reduce the score here
	// by default, return the score of the best target
	return precondition() * score_target(get_best_target(get_targets()))

/datum/aiTask/sequence/goalbased/on_tick()
	..()
	if(!holder.target)
		holder.target = get_best_target(get_targets())
	if(subtask_index == 1) // MOVE TASK
		// make sure we both set our target and move to our target correctly
		var/datum/aiTask/succeedable/move/M = subtasks[subtask_index]
		if(M && !M.move_target)
			var/target_turf = get_turf(holder.target)
			if(can_be_adjacent_to_target)
				var/list/tempPath = cirrAstar(get_turf(holder.owner), target_turf, 1, null, /proc/heuristic, 40)
				if(tempPath.len > 0) // fix runtime Cannot read null.len
					M.move_target = tempPath[tempPath.len]
					if(M.move_target)
						return
			M.move_target = target_turf
	LAGCHECK(LAG_LOW)

/datum/aiTask/sequence/goalbased/on_reset()
	holder.target = null

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// WANDER TASK
// spend a few ticks wandering aimlessly
/datum/aiTask/timed/wander
	name = "wandering"
	minimum_task_ticks = 5
	maximum_task_ticks = 10

/datum/aiTask/timed/wander/evaluate()
	return 1 // it'd require every other task returning very small values for this to get selected

/datum/aiTask/timed/wander/on_tick()
	// thanks zewaka for reminding me the previous implementation of this is BYOND NATIVE
	// thanks byond forums for letting me know that the byond native implentation FUCKING SUCKS
	holder.owner.move_dir = pick(1,2,4,5,6,8,9,10)
	holder.owner.process_move()
	LAGCHECK(LAG_LOW)

/datum/aiTask/timed/wander/on_tick()
	. = ..()
	holder.stop_move()

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// TARGETED TASK
// a timed task that also relates to a target and the acquisition of said target
/datum/aiTask/timed/targeted
	name = "targeted"
	var/target_range = 8

/datum/aiTask/timed/targeted/proc/get_best_target(var/list/targets)
	. = null
	var/best_score = -1.#INF
	if(length(targets))
		for(var/atom/A in targets)
			var/score = src.score_target(A)
			if(score > best_score)
				best_score = score
				. = A
	holder.target = .

// vvv OVERRIDE THE PROCS BELOW AS REQUIRED vvv

/datum/aiTask/timed/targeted/proc/get_targets()
	return list()

/datum/aiTask/timed/targeted/proc/score_target(var/atom/target)
	if(target)
		return target_range - distance(get_turf(holder.owner), get_turf(target))
	return 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// MOVE TASK
// target: holder target assigned by a sequence task
/datum/aiTask/succeedable/move
	name = "moving"
	max_fails = 5
	var/list/found_path = null
	var/atom/move_target = null

// use the target from our holder
/datum/aiTask/succeedable/move/proc/get_path()
	if(!move_target)
		fails++
		return
	src.found_path = cirrAstar(get_turf(holder.owner), get_turf(move_target), 0, null, /proc/heuristic, 60)
	if(!src.found_path) // no path :C
		fails++

/datum/aiTask/succeedable/move/on_reset()
	src.found_path = null
	src.move_target = null

/datum/aiTask/succeedable/move/on_tick()
	walk(holder.owner, 0)
	if(src.found_path)
		if(src.found_path.len > 0)
			// follow the path
			src.found_path.Cut(1, 2)
			var/turf/next
			if(src.found_path.len >= 1)
				next = src.found_path[1]
			else
				next = move_target
			walk_to(holder.owner, next, 0, 4)
			if(get_dist(get_turf(holder.owner), next) <= 1)
				fails = 0
			else
				// we aren't where we ought to be
				fails++
				get_path()
	else
		// get a path
		get_path()

/datum/aiTask/succeedable/move/succeeded()
	if(move_target)
		return ((get_dist(get_turf(holder.owner), get_turf(move_target)) == 0) || (src.found_path && src.found_path.len <= 0))

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// WAIT TASK
// uh, yeah. spend a couple ticks waiting, whatever
// logic for going back to previous task is handled by holder
/datum/aiTask/timed/wait
	name = "waiting"
	minimum_task_ticks = 10
	maximum_task_ticks = 10

