var/list/ai_move_scheduled = list()

/datum/aiHolder
	var/mob/living/owner = null
	var/mob/living/carbon/human/ownhuman = null // for use when you would normally cast holder.owner as human for a proc.
	var/atom/target = null // the simplest blackboard ever
	var/datum/aiTask/current_task = null  // what the critter is currently doing
	var/datum/aiTask/default_task = null  // what behavior the critter will fall back on
	var/list/task_cache = list()
	var/move_target = null

	var/move_dist = 0
	var/move_reverse = 0
	var/move_side = 0 //merge with reverse later ok messy

	var/enabled = 1

	var/exclude_from_mobs_list = 0

	New(var/mob/M)
		..()
		owner = M
		if(istype(M, /mob/living/carbon/human))
			ownhuman = M
		if (exclude_from_mobs_list)
			mobs.Remove(M)
			M.mob_flags |= LIGHTWEIGHT_AI_MOB
		ai_mobs.Add(M)

	disposing()
		..()
		stop_move()
		if (owner)
			if (owner.mob_flags & LIGHTWEIGHT_AI_MOB)
				owner.mob_flags &= ~LIGHTWEIGHT_AI_MOB
				mobs.Add(owner)
			ai_mobs.Remove(owner)
			owner = null
			ownhuman = null

		target = null
		if(current_task)
			current_task.dispose()
		current_task = null
		if(default_task)
			default_task.dispose()
		default_task = null
		if(task_cache)
			for(var/key in task_cache)
				var/datum/aiTask/task = task_cache[key]
				task?.dispose()
			task_cache.len = 0
			task_cache = null
		..()

	proc/tick()
		if(!enabled)
			walk(owner, 0)
			return
		if (!current_task)
			current_task = default_task
		if (current_task)
			current_task.tick()

			var/datum/aiTask/T = current_task.next_task()
			if (T)
				current_task = T
				T.reset()

	proc/get_instance(taskType, list/nparams)
		if (taskType in task_cache)
			return task_cache[taskType]
		task_cache[taskType] = new taskType(arglist(nparams))
		return task_cache[taskType]

// bumping these up to parent because these are undoubtedly gonna be useful for more than just flockdrones - cirr
	proc/wait()
		// switch into the wait task NOW, and add our current task as the task to return to
		var/datum/aiTask/timed/wait/waitTask = src.get_instance(/datum/aiTask/timed/wait, list(src))
		waitTask.transition_task = current_task
		current_task = waitTask

	proc/interrupt()
		if(src.enabled)
			current_task = default_task

	proc/die()
		src.enabled = 0
		stop_move()
		current_task = null

	proc/move_to(var/A, var/dist = 1)
		if (!move_target)
			ai_move_scheduled += src
		move_target = A
		move_dist = dist
		move_reverse = 0
		move_side = 0

	proc/move_away(var/A, var/dist = 6)
		if (!move_target)
			ai_move_scheduled += src
		move_target = A
		move_dist = dist
		move_reverse = 1
		move_side = 0

	proc/move_circ(var/A, var/dist = 1)
		if (!move_target)
			ai_move_scheduled += src
		move_target = A
		move_dist = dist
		move_reverse = prob(50)?0:1
		move_side = 1

	proc/stop_move()
		move_target = null
		ai_move_scheduled -= src
		walk(src,0)

	proc/move_step()
		if (src.move_side)
			if (get_dist(src.owner,get_turf(src.move_target)) > src.move_dist)
				var/turn = src.move_reverse?90:-90
				src.owner.move_dir = turn( get_dir(src.owner,get_turf(src.move_target)),turn )
				src.owner.process_move()
		else if (src.move_reverse)
			if (get_dist(src.owner,get_turf(src.move_target)) < src.move_dist)
				var/turn = 180
				switch(rand(1,4)) //fudge walk away behavior
					if (1)
						turn -= 45
					if (2)
						turn += 45

				src.owner.move_dir = turn(get_dir(src.owner,get_turf(src.move_target)),turn)
				src.owner.process_move()
		else
			if (get_dist(src.owner,get_turf(src.move_target)) > src.move_dist)
				src.owner.move_dir = get_dir(src.owner,get_turf(src.move_target))
				src.owner.process_move()


	proc/was_harmed(obj/item/W, mob/M)
		.=0

/datum/aiTask
	var/name = "task"
	var/datum/aiHolder/holder = null

	New(parentHolder)
		..()
		holder = parentHolder

		reset()

	disposing()
		holder = null
		..()

	proc/on_tick()

	proc/next_task()
		return null

	proc/on_reset()

	proc/evaluate() // evaluate the current environment and assign priority to switching to this task
		return 0

	//     do not override procs below this line
	// --------------------------------------------
	// unless you are building a new direct subtype

	proc/tick()
		on_tick()

	proc/reset()
		on_reset()

// an AI task that evaluates all tasks within its list of transition tasks
// immediately transitions to task with highest evaluation score after first tick
/datum/aiTask/prioritizer
	var/list/transition_tasks = list()

	proc/add_transition(transTask)
		transition_tasks[transTask] = 0

	next_task()
		var/mp = -100
		var/mT = null
		for (var/T in transition_tasks)
			if (!mT || transition_tasks[T] > mp || (transition_tasks[T] == mp && prob(50)))
				mT = T
				mp = transition_tasks[mT]
		reset()
		return mT

	reset()
		..()
		for (var/T in transition_tasks)
			transition_tasks[T] = 0

	tick()
		..()
		for (var/datum/aiTask/T in transition_tasks)
			transition_tasks[T] = T.evaluate()

// an AI task that runs for the number of ticks given
// an optional frustration tick count is available for tasks that might fail prematurely
/datum/aiTask/timed
	var/minimum_task_ticks = 20
	var/maximum_task_ticks = 40
	var/elapsed_ticks = 0
	var/current_target_ticks = 20
	var/frustration = 0
	var/frustration_threshold = 10
	var/datum/aiTask/transition_task = null

	New(parentHolder, transTask)
		transition_task = transTask
		..()

	proc/frustration_check()
		return 0

	next_task()
		if (current_target_ticks <= elapsed_ticks || frustration >= frustration_threshold)
			return transition_task
		return null

	tick()
		..()
		if (frustration_check())
			frustration++
		else
			frustration = 0
			elapsed_ticks++

	reset()
		..()
		elapsed_ticks = 0
		current_target_ticks = rand(minimum_task_ticks, maximum_task_ticks)

// an AI task that invokes a /datum/action on initiation
// transitions to the transition task on completion or interruption (or failure) of action
/datum/aiTask/action
	var/datum/action/action_path = null
	var/datum/action/action_instance = null
	var/list/action_params = null
	var/datum/aiTask/transition_task = null

	New(parentHolder, transTask, action)
		transition_task = transTask
		action_path = action
		..()

	proc/set_action_params(list/aparams)
		action_params = aparams

	proc/collect_action_params()
		// advised to override this for subtypes
		// return a list of params, probably fished out by reference to holder.owner values, good luck with that
		return list()

	next_task()
		if (!action_instance || action_instance.state == ACTIONSTATE_DELETE)
			return transition_task
		return null

	tick()
		..()
		if(!action_instance)
			// create and start the action
			if(!action_params) // a list of length 0 is perfectly acceptable (no params), but a null list means this wasn't set up
				set_action_params(collect_action_params())
			action_instance = actions.start(new action_path(arglist(action_params)), holder.owner)

	reset()
		..()
		action_instance = null
		action_params = null // to avoid weird "sticky" bugs relating to statefulness, forcibly clear out the parameters each time

// an AI task that goes sequentially through its list of subtasks, WHICH MUST BE SUCCEEDABLE TASKS
// it will only give a next task
/datum/aiTask/sequence
	name = "sequence"

	var/list/subtasks = list()
	var/datum/aiTask/succeedable/current_subtask = null
	var/subtask_index = 1
	var/datum/aiTask/transition_task = null // the task to go to after our sequence either fails or ends
	var/terminated = 0

	New(parentHolder, transTask)
		transition_task = transTask
		..()

	proc/add_task(var/datum/aiTask/succeedable/T)
		if(T)
			subtasks += T // add to end of the sequence

	next_task()
		if(terminated)
			return transition_task
		else
			return null

	tick()
		..()
		if(!subtasks || subtasks.len < 1 || !current_subtask)
			terminated = 1 // we can't operate with no subtasks
			return

		current_subtask.tick()
		if(current_subtask.succeeded())
			// advance to the next step in the sequence
			subtask_index++
			if(subtask_index > subtasks.len)
				// sequence complete
				terminated = 1
				return
			else
				current_subtask = subtasks[subtask_index]
				current_subtask.reset()
				// ready to run this immediately next tick
				return
		else if(current_subtask.failed())
			// the sequence is ruined
			terminated = 1
			return

	reset()
		..()
		if(subtasks && subtasks.len >= 1)
			current_subtask = subtasks[1]
			current_subtask.reset()
		subtask_index = 1
		terminated = 0

// an AI task that runs forever until it either succeeds or fails
// exists pretty much solely for the sequence
// DO NOT USE THIS TASK OUTSIDE OF A SEQUENCE UNLESS YOU LIKE YOUR AI DOING THE SAME THING FOREVER
/datum/aiTask/succeedable
	var/fails = 0
	var/max_fails = 1 // if fails ticks up to this value, the task has failed

	// next task is not defined here, handled by sequence
	proc/failed()
		return fails >= max_fails

	proc/succeeded()
		return 1 // we have succeeded at doing literally nothing

	tick()
		..()

	reset()
		..()
		fails = 0


