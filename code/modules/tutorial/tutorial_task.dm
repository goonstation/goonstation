/**
 * This is the datum for an individual 'task' in a stage. Think of something small like "collect fire extinguisher".
 *
 *
 */
/datum/tutorial/task
	/// Name of the task (mostly for debugging)
	var/name = "COLLECT THE RINGS"
	/// TODO: How often we check is_finished: (0=never, 1=every tick, 2=every other tick,...)
	var/check_frequency = 0
	/// Our parent [datum/tutorial/stage]
	var/datum/tutorial/stage/stage = null
	/// Current status of the task ([TASK_NOTSTARTED] [TASK_INPROGRESS], [TASK_FINISHED])
	var/status = TASK_NOTSTARTED

	New(datum/tutorial/stage/stage)
		. = ..()
		stage = stage

	/// Starts the task, triggered by our [stage]
	proc/start()
		status = TASK_INPROGRESS
		started()

	/// Stub. Override to do stuff when the task is started
	proc/started()
		return

	/// Finishes the task immediately - preferable if we can directly proc off an action.
	/// Call parent last when overriding.
	proc/finish()
		status = TASK_FINISHED
		stage.finish_or_advance()

	/// Stub. Check if the conditions for finishing the task have been achieved.
	/// Polled every [check_frequency].
	/// Return TRUE if conditions are met and we are to advance.
	proc/is_finished()
		return FALSE


	/// Called when we're being deleted, e.g. the client moved past this task
	disposing()
		. = ..()
		stage = null
