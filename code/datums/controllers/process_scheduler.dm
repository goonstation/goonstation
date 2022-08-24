// Singleton instance of game_controller_new, setup in world.New()
var/global/datum/controller/processScheduler/processScheduler

/datum/controller/processScheduler
	// Processes known by the scheduler
	var/tmp/list/datum/controller/process/processes = new

	// Processes that are currently running
	var/tmp/list/datum/controller/process/running = new

	// Processes that are idle
	var/tmp/list/datum/controller/process/idle = new

	// Processes that are queued to run
	var/tmp/list/datum/controller/process/queued = new

	// Process name -> process object map
	var/tmp/list/datum/controller/process/nameToProcessMap = new

	// Process last start times
	var/tmp/list/datum/controller/process/last_start = new

	// Process last run durations
	var/tmp/list/datum/controller/process/last_run_time = new

	// Per process list of the last 20 durations
	var/tmp/list/datum/controller/process/last_twenty_run_times = new

	// Process highest run time
	var/tmp/list/datum/controller/process/highest_run_time = new

	// Sleep epsilon deciseconds, internally for byond this means to sleep until next tick
	var/tmp/scheduler_sleep_interval = 0.001

	// When starting more than one queued process, how many ticks apart will they be started
	var/tmp/process_run_interval = 2

	// Controls whether the scheduler is running or not
	var/tmp/isRunning = 0

	// Setup for these processes will be deferred until all the other processes are set up.
	var/tmp/list/deferredSetupList = new
	var/tmp/list/alreadyCreatedPathsList = new
	var/tmp/list/alreadyCreatedList = new

	var/tmp/currentTick = 0

	var/tmp/currentTickStart = 0

	var/tmp/cpuAverage = 0


/datum/controller/processScheduler/New()
	..()
	scheduler_sleep_interval = world.tick_lag

/**
 * deferSetupFor
 * @param path processPath
 * If a process needs to be initialized after everything else, add it to
 * the deferred setup list. On goonstation, only the ticker needs to have
 * this treatment.
 */
/datum/controller/processScheduler/proc/deferSetupFor(var/processPath)
	deferredSetupList |= processPath

/datum/controller/processScheduler/proc/addNowSkipSetup(var/processPath)
	src.alreadyCreatedPathsList += processPath
	var/newProcess = new processPath(src)
	src.alreadyCreatedList += newProcess
	return newProcess

/datum/controller/processScheduler/proc/setup()
	// There can be only one
	if(processScheduler && (processScheduler != src))
		del(src)
		return 0

	var/process
	// Add all the processes we can find, except for the ticker
	for (process in childrentypesof(/datum/controller/process))
		if (!(process in deferredSetupList) && !(process in alreadyCreatedPathsList))
			addProcess(new process(src))

	for (process in deferredSetupList)
		addProcess(new process(src))

	for (process in alreadyCreatedList)
		// already created and set up so just add it.
		addProcess(process, TRUE)

	global.lag_detection_process.setup()

/datum/controller/processScheduler/proc/start()
	isRunning = 1
	SPAWN(0)
		process()

/datum/controller/processScheduler/proc/process()
	while(isRunning)
		checkRunningProcesses()
		queueProcesses()
		runQueuedProcesses()

		sleep(scheduler_sleep_interval)

/datum/controller/processScheduler/proc/stop()
	isRunning = 0

/datum/controller/processScheduler/proc/checkRunningProcesses()
	for(var/datum/controller/process/p in running)
		p.update()

		if (isnull(p)) // Process was killed
			continue

		var/status = p.getStatus()
		var/previousStatus = p.getPreviousStatus()

		// Check status changes
		if(status != previousStatus)
			//Status changed.
			switch(status)
				if(PROCESS_STATUS_PROBABLY_HUNG)
					message_admins("Process '[p.name]' may be hung.")
				if(PROCESS_STATUS_HUNG)
					message_admins("Process '[p.name]' is hung and will be restarted.")

/datum/controller/processScheduler/proc/queueProcesses()
	for (var/datum/controller/process/p as anything in processes)
		// Don't double-queue, don't queue running processes
		if (p.disabled || p.running || p.queued || !p.idle)
			continue

		// If world.timeofday has rolled over, then we need to adjust.
		if (TimeOfHour < last_start[p])
			last_start[p] -= 36000

		// If the process should be running by now, go ahead and queue it
		if (TimeOfHour > last_start[p] + p.schedule_interval + p.schedule_jitter)
			setQueuedProcessState(p)

/datum/controller/processScheduler/proc/runQueuedProcesses()
	if (length(queued))
		var/delay = 0
		for (var/datum/controller/process/p as anything in queued)
			runProcess(p, delay)
			delay += process_run_interval * world.tick_lag
		queued.len = 0

/datum/controller/processScheduler/proc/addProcess(var/datum/controller/process/process, var/skipSetup = 0)
	// zamu here, sorry for making this dumb thing
	if (game_start_countdown)
		var/procname = copytext("[process.type]", findlasttext("[process.type]", "/", -1) + 1)
		game_start_countdown.update_status("Starting [procname]")

	processes.Add(process)
	process.idle()
	idle.Add(process)

	// init recordkeeping vars
	last_start.Add(process)
	last_start[process] = 0
	last_run_time.Add(process)
	last_run_time[process] = 0
	last_twenty_run_times.Add(process)
	last_twenty_run_times[process] = list()
	highest_run_time.Add(process)
	highest_run_time[process] = 0

	// init starts and stops record starts
	recordStart(process, 0)
	recordEnd(process, 0)

	// Set up process
	if (!skipSetup)
		process.setup()

	// Save process in the name -> process map
	nameToProcessMap[process.name] = process

/datum/controller/processScheduler/proc/replaceProcess(var/datum/controller/process/oldProcess, var/datum/controller/process/newProcess)
	processes.Remove(oldProcess)
	processes.Add(newProcess)

	newProcess.idle()
	idle.Remove(oldProcess)
	running.Remove(oldProcess)
	queued.Remove(oldProcess)
	idle.Add(newProcess)

	last_start.Remove(oldProcess)
	last_start.Add(newProcess)
	last_start[newProcess] = 0

	last_run_time.Add(newProcess)
	last_run_time[newProcess] = last_run_time[oldProcess]
	last_run_time.Remove(oldProcess)

	last_twenty_run_times.Add(newProcess)
	last_twenty_run_times[newProcess] = last_twenty_run_times[oldProcess]
	last_twenty_run_times.Remove(oldProcess)

	highest_run_time.Add(newProcess)
	highest_run_time[newProcess] = highest_run_time[oldProcess]
	highest_run_time.Remove(oldProcess)

	recordStart(newProcess, 0)
	recordEnd(newProcess, 0)

	nameToProcessMap[newProcess.name] = newProcess

/datum/controller/processScheduler/proc/runProcess(var/datum/controller/process/process, var/delay)
	SPAWN(delay)
		process.process()

/datum/controller/processScheduler/proc/processStarted(var/datum/controller/process/process)
	setRunningProcessState(process)
	recordStart(process)

/datum/controller/processScheduler/proc/processFinished(var/datum/controller/process/process)
	setIdleProcessState(process)
	recordEnd(process)

/datum/controller/processScheduler/proc/setIdleProcessState(var/datum/controller/process/process)
	running -= process
	queued -= process
	idle |= process

/datum/controller/processScheduler/proc/setQueuedProcessState(var/datum/controller/process/process)
	// Do jitter adjustments since we just queued (± in the !initial! jitter range)
	process.schedule_jitter = ((rand() * 2) - 1) * initial(process.schedule_jitter)

	running -= process
	idle -= process
	queued |= process

	// The other state transitions are handled internally by the process.
	process.queued()

/datum/controller/processScheduler/proc/setRunningProcessState(var/datum/controller/process/process)
	queued -= process
	idle -= process
	running |= process

/datum/controller/processScheduler/proc/recordStart(var/datum/controller/process/process, var/time = null)
	if (isnull(time))
		time = TimeOfHour

	last_start[process] = time

/datum/controller/processScheduler/proc/recordEnd(var/datum/controller/process/process, var/time = null)
	if (isnull(time))
		time = TimeOfHour

	// If world.timeofday has rolled over, then we need to adjust.
	if (time < last_start[process])
		last_start[process] -= 36000

	var/lastRunTime = time - last_start[process]

	if(lastRunTime < 0)
		lastRunTime = 0

	recordRunTime(process, lastRunTime)

/**
 * recordRunTime
 * Records a run time for a process
 */
/datum/controller/processScheduler/proc/recordRunTime(var/datum/controller/process/process, time)
	last_run_time[process] = time
	if(time > highest_run_time[process])
		highest_run_time[process] = time

	var/list/lastTwenty = last_twenty_run_times[process]
	if (lastTwenty.len == 20)
		lastTwenty.Cut(1, 2)
	lastTwenty.len++
	lastTwenty[lastTwenty.len] = time

/**
 * averageRunTime
 * returns the average run time (over the last 20) of the process
 */
/datum/controller/processScheduler/proc/averageRunTime(var/datum/controller/process/process)
	var/lastTwenty = last_twenty_run_times[process]

	var/t = 0
	var/c = 0
	for(var/time in lastTwenty)
		t += time
		c++

	if(c > 0)
		return t / c
	return c

/datum/controller/processScheduler/proc/getStatusData()
	var/list/data = new

	for (var/datum/controller/process/p in processes)
		data.len++
		data[data.len] = p.getContextData()

	return data

/datum/controller/processScheduler/proc/getProcessCount()
	return length(processes)

/datum/controller/processScheduler/proc/hasProcess(var/processName as text)
	if (nameToProcessMap[processName])
		return 1

/datum/controller/processScheduler/proc/getProcess(var/processName as text)
	RETURN_TYPE(/datum/controller/process)
	. = nameToProcessMap[processName]

/datum/controller/processScheduler/proc/killProcess(var/processName as text)
	restartProcess(processName)

/datum/controller/processScheduler/proc/restartProcess(var/processName as text)
	if (hasProcess(processName))
		var/datum/controller/process/oldInstance = nameToProcessMap[processName]
		var/datum/controller/process/newInstance = new oldInstance.type(src)
		newInstance._copyStateFrom(oldInstance)
		replaceProcess(oldInstance, newInstance)
		oldInstance.kill()

/datum/controller/processScheduler/proc/enableProcess(var/processName as text)
	if (hasProcess(processName))
		var/datum/controller/process/process = nameToProcessMap[processName]
		process.enable()

/datum/controller/processScheduler/proc/disableProcess(var/processName as text)
	if (hasProcess(processName))
		var/datum/controller/process/process = nameToProcessMap[processName]
		process.disable()

/datum/controller/processScheduler/proc/editProcess(var/processName as text)
	if (hasProcess(processName))
		var/datum/controller/process/process = nameToProcessMap[processName]
		usr.client.debug_variables(process)
