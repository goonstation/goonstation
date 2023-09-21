/// Base definition of a process controller
/datum/controller/process
	/*
	 * State vars
	 */

	// Main controller ref
	var/tmp/datum/controller/processScheduler/main

	/// TRUE if the process is not running or queued
	var/tmp/idle = TRUE

	/// TRUE if process is queued
	var/tmp/queued = FALSE

	/// TRUE if process is running
	var/tmp/running = FALSE

	/// TRUE if process is blocked up
	var/tmp/hung = FALSE

	/// TRUE if process was killed
	var/tmp/killed = FALSE

	/// Status text to be displayed
	var/tmp/status

	/// Previous status text
	var/tmp/previousStatus

	/// TRUE if process is disabled
	var/tmp/disabled = 0

	/*
	 * Process Vars
	 */

	/// Process name
	var/name

	/// This controls how often the process would run under ideal conditions.
	/// If the process scheduler sees that the process has finished, it will wait until
	/// this amount of time has elapsed from the start of the previous run to start the
	/// process running again.
	var/tmp/schedule_interval = PROCESS_DEFAULT_SCHEDULE_INTERVAL

	/**
	 * This is added to the [/datum/controller/process/var/schedule_interval] when checking it.
	 * By default, this adjusts the interval by either adding or subtracting anywhere in the jitter range.
	 * For example, a jitter of `2 SECONDS` for an interval of `10 SECONDS` would give times from `8 SECONDS` to `12 SECONDS`.
	 *
	 * For more complex behavior, override [/datum/controller/processScheduler/proc/setQueuedProcessState]. Necessary for runtime jitter range change.
	 */
	var/tmp/schedule_jitter = PROCESS_DEFAULT_SCHEDULE_JITTER

	/// This controls what percentage a single tick (0 to 100) the process should be allowed to run before sleeping.
	var/tmp/tick_allowance = PROCESS_DEFAULT_TICK_ALLOWANCE

	/// This is the time after which the server will begin to show "maybe hung" in the context window.
	var/tmp/hang_warning_time = PROCESS_DEFAULT_HANG_WARNING_TIME

	///  After this much time, the server will send an admin debug message saying the process may be hung.
	var/tmp/hang_alert_time = PROCESS_DEFAULT_HANG_ALERT_TIME

	/// After this much time, the server will automatically kill and restart the process.
	var/tmp/hang_restart_time = PROCESS_DEFAULT_HANG_RESTART_TIME

	/// How many times in the current run has the process deferred work till the next tick?
	var/tmp/cpu_defer_count = 0

	/*
	 * recordkeeping vars
	 */

	/// Records the time (1/10s timeofday) at which the process last finished sleeping
	var/tmp/last_slept = 0

	/// Records the time (1/10s timeofday) at which the process last began running
	var/tmp/run_start = 0

	/// Records the world.tick_usage (0 to 100) at which the process last began running
	/// drsingh - as of byond 514, world.map_cpu is also included in this via APPROX_TICK_USE
	var/tmp/tick_start = 0

	/// Records the total usage of the current run, each 100 = 1 byond tick
	var/tmp/current_usage = 0

	/// Records the total usage of the last run, each 100 = 1 byond tick
	var/tmp/last_usage = 0

	/// Records the total usage over the life of the process, each 100 = 1 byond tick
	var/tmp/total_usage = 0

	/// Records the number of times this process has been killed and restarted
	var/tmp/times_killed

	/// Tick count
	var/tmp/ticks = 0

	/// Settable last task this loop was working on
	var/tmp/last_task = ""

	/// Settable last object this loop was processing
	var/tmp/last_object

/datum/controller/process/New(datum/controller/processScheduler/scheduler)
	. = ..()
	main = scheduler
	previousStatus = "idle"
	idle()
	name = "process"
	schedule_interval = 50
	schedule_jitter = ((rand() * 2) - 1) * schedule_jitter // for first run
	last_slept = 0
	run_start = 0
	tick_start = 0
	current_usage = 0
	last_usage = 0
	total_usage = 0
	ticks = 0
	last_task = 0
	last_object = null

/datum/controller/process/proc/started()
	// Initialize last_slept so we can record timing information
	last_slept = TimeOfHour

	// Initialize run_start so we can detect hung processes.
	run_start = TimeOfHour

	// Initialize tick_start so we can know when to sleep
	tick_start = APPROX_TICK_USE

	// Initialize the cpu usage counter
	current_usage = 0

	// Initialize defer count
	cpu_defer_count = 0

	running()
	if (!main)
		world.log << "main is null somehow. src=\ref[src] ..."
	main.processStarted(src)

	onStart()

/datum/controller/process/proc/finished()
	ticks++
	current_usage += APPROX_TICK_USE - tick_start
	last_usage = current_usage
	current_usage = 0
	idle()
	main.processFinished(src)

	onFinish()

/datum/controller/process/proc/doWork()
	return

/datum/controller/process/proc/setup()
	return

/datum/controller/process/proc/process()
	started()
	doWork()
	finished()

/datum/controller/process/proc/running()
	idle = 0
	queued = 0
	running = 1
	hung = 0
	setStatus(PROCESS_STATUS_RUNNING)

/datum/controller/process/proc/idle()
	queued = 0
	running = 0
	idle = 1
	hung = 0
	setStatus(PROCESS_STATUS_IDLE)

/datum/controller/process/proc/queued()
	idle = 0
	running = 0
	queued = 1
	hung = 0
	setStatus(PROCESS_STATUS_QUEUED)

/datum/controller/process/proc/hung()
	hung = 1
	setStatus(PROCESS_STATUS_HUNG)

/datum/controller/process/proc/handleHung()
	var/datum/lastObj = last_object
	var/lastObjType = "null"
	if(istype(lastObj))
		lastObjType = lastObj.type

	// If world.timeofday has rolled over, then we need to adjust.
	if (TimeOfHour < run_start)
		run_start -= 36000
	var/msg = "[name] process hung at tick #[ticks]. Process was unresponsive for [(TimeOfHour - run_start) / 10] seconds and was restarted. Last task: [last_task]. Last Object Type: [lastObjType]. Last object: <a href='byond://?src=%client_ref%;Vars=\ref[lastObj]'>[lastObj]</a>"
	logTheThing(LOG_DEBUG, null, msg)
	logTheThing(LOG_DIARY, null, msg, "debug")
	message_admins(msg)

	main.restartProcess(src.name)

/datum/controller/process/proc/kill()
	if (!killed)
		var/msg = "[name] process was killed at tick #[ticks]."
		logTheThing(LOG_DEBUG, null, msg)
		logTheThing(LOG_DIARY, null, msg, "debug")
		//finished()

		// Allow inheritors to clean up if needed
		onKill()

		// This should del
		del(src)

/datum/controller/process/proc/scheck()
	. = 0
	if (killed)
		// The kill proc is the only place where killed is set.
		// The kill proc should have deleted this datum, and all sleeping procs that are
		// owned by it.
		CRASH("A killed process is still running somehow...")
	if (hung)
		// This will only really help if the doWork proc ends up in an infinite loop.
		handleHung()
		CRASH("Process [name] hung and was restarted.")

  // Allow the process to continue if it's already been waiting to run for a while.
	if (cpu_defer_count >= PROCESS_MAX_DEFER_COUNT)
		cpu_defer_count = 0
		return 0

	// Check the current server load and decide if the process should wait
	if (APPROX_TICK_USE > PROCESS_MAX_TICK_USAGE || ( (APPROX_TICK_USE - tick_start) > tick_allowance ))
		current_usage += APPROX_TICK_USE - tick_start
		sleep( world.tick_lag * main.running.len )
		cpu_defer_count++
		last_slept = TimeOfHour
		tick_start = APPROX_TICK_USE

		return 1

/datum/controller/process/proc/update()
	// Clear delta
	if(previousStatus != status)
		setStatus(status)

	var/elapsedTime = getElapsedTime()

	if (hung)
		handleHung()
		return
	else if (elapsedTime > hang_restart_time)
		hung()
	else if (elapsedTime > hang_alert_time)
		setStatus(PROCESS_STATUS_PROBABLY_HUNG)
	else if (elapsedTime > hang_warning_time)
		setStatus(PROCESS_STATUS_MAYBE_HUNG)

/datum/controller/process/proc/getElapsedTime()
	if (TimeOfHour < run_start)
		return TimeOfHour - (run_start - 36000)
	return TimeOfHour - run_start

/datum/controller/process/proc/getAverageUsage()
	return

/datum/controller/process/proc/tickDetail()
	return

/datum/controller/process/proc/getContext()
	return "<tr><td>[name]</td><td>[main.averageRunTime(src)]</td><td>[main.last_run_time[src]]</td><td>[main.highest_run_time[src]]</td><td>[ticks]</td></tr>\n"

/datum/controller/process/proc/getContextData()
	return list(
		"name" = name,
		"averageRunTime" = main.averageRunTime(src),
		"lastRunTime" = main.last_run_time[src],
		"highestRunTime" = main.highest_run_time[src],
		"ticks" = ticks,
		"schedule" = schedule_interval,
		"status" = getStatusText(),
		"disabled" = disabled
	)

/datum/controller/process/proc/getStatus()
	return status

/datum/controller/process/proc/getStatusText(s = 0)
	if(!s)
		s = status
	switch(s)
		if(PROCESS_STATUS_IDLE)
			return "idle"
		if(PROCESS_STATUS_QUEUED)
			return "queued"
		if(PROCESS_STATUS_RUNNING)
			return "running"
		if(PROCESS_STATUS_MAYBE_HUNG)
			return "maybe hung"
		if(PROCESS_STATUS_PROBABLY_HUNG)
			return "probably hung"
		if(PROCESS_STATUS_HUNG)
			return "HUNG"
		else
			return "UNKNOWN"

/datum/controller/process/proc/getPreviousStatus()
	return previousStatus

/datum/controller/process/proc/getPreviousStatusText()
	return getStatusText(previousStatus)

/datum/controller/process/proc/setStatus(newStatus)
	previousStatus = status
	status = newStatus

/datum/controller/process/proc/setLastTask(task, object)
	last_task = task
	last_object = object

/datum/controller/process/proc/_copyStateFrom(datum/controller/process/target)
	main = target.main
	name = target.name
	schedule_interval = target.schedule_interval
	last_slept = 0
	run_start = 0
	tick_start = 0
	last_usage = 0
	total_usage = 0
	times_killed = target.times_killed
	ticks = target.ticks
	last_task = target.last_task
	last_object = target.last_object
	copyStateFrom(target)

/datum/controller/process/proc/copyStateFrom(datum/controller/process/target)

/datum/controller/process/proc/onKill()

/datum/controller/process/proc/onStart()

/datum/controller/process/proc/onFinish()

/datum/controller/process/proc/disable()
	disabled = 1

/datum/controller/process/proc/enable()
	disabled = 0
