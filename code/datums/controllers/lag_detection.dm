var/global/datum/controller/lag_detection/lag_detection_process = new

/datum/controller/lag_detection
	var/tmp/highCpuCount = 0 // how many times in a row has the cpu been high
	var/tmp/automatic_profiling_on = FALSE
	var/tmp/manual_profiling_on = FALSE
	var/tmp/manual_profiling_disable_time = 0
	var/tmp/time_since_last = 0
	var/tmp/last_tick_time = null
	var/tmp/tick_count = 0

	var/tmp/cpu_start_profiling_immediately_threshold = CPU_START_PROFILING_IMMEDIATELY_THRESHOLD
	var/tmp/tick_time_profiling_threshold = TICK_TIME_PROFILING_THRESHOLD

	proc/setup()
		#ifdef PRE_PROFILING_ENABLED
		world.Profile(PROFILE_START | PROFILE_CLEAR, null, "json")
		#endif
		#if !defined(LIVE_SERVER)
		manual_profiling_on = TRUE
		#endif
		SPAWN(0)
			while(TRUE)
				sleep(0.001)
				process()

	proc/process()
		tick_count++
		var/current_time = TIME
		if(!isnull(last_tick_time))
			time_since_last = current_time - last_tick_time
		last_tick_time = current_time
		if(manual_profiling_on)
			if(manual_profiling_disable_time && (current_time > manual_profiling_disable_time))
				message_admins("Manual profiling disabled, profile will periodically reset!")
				manual_profiling_on = FALSE
			return
		automatic_profiling()
		#ifdef PRE_PROFILING_ENABLED
		if(!automatic_profiling_on && tick_count % 100 == 0)
			world.Profile(PROFILE_START | PROFILE_CLEAR, null, "json")
			last_tick_time = null
			time_since_last = 0
		#endif

	proc/automatic_profiling(force_stop=FALSE, force_start=FALSE)
		var/static/profilerLogID = 0
		if(automatic_profiling_on)
			if(world.cpu <= CPU_STOP_PROFILING_THRESHOLD)
				highCpuCount--
			else
				highCpuCount = CPU_STOP_PROFILING_COUNT
			if(highCpuCount <= 0 || force_stop)
				var/output = world.Profile(PROFILE_REFRESH | PROFILE_STOP, null, "json")
				var/fname = "data/logs/profiling/[global.roundLog_date]_automatic_[profilerLogID++].json"
				rustg_file_write(output, fname)
				message_admins("CPU back down to [world.cpu], turning off profiling, saved as [fname].")
				logTheThing(LOG_DEBUG, null, "Automatic profiling finished, CPU at [world.cpu], saved as [fname].")
				ircbot.export_async("admin_debug", list("msg"="Automatic profiling finished, CPU at [world.cpu], saved as [fname]."))
				highCpuCount = 0
				automatic_profiling_on = FALSE
				last_tick_time = null
				time_since_last = 0
		else if(ticker.round_elapsed_ticks > CPU_PROFILING_ROUNDSTART_GRACE_PERIOD) // give server some time to settle
			if(world.cpu >= CPU_START_PROFILING_THRESHOLD)
				highCpuCount++
			if(world.cpu >= cpu_start_profiling_immediately_threshold || time_since_last > tick_time_profiling_threshold)
				#ifdef PRE_PROFILING_ENABLED
				var/output = world.Profile(PROFILE_REFRESH, null, "json")
				var/fname = "data/logs/profiling/[global.roundLog_date]_automatic_[profilerLogID++]_spike.json"
				rustg_file_write(output, fname)
				#endif
				force_start = TRUE
			else
				highCpuCount = 0
			if(highCpuCount >= CPU_START_PROFILING_COUNT || force_start)
				var/prof_flags = PROFILE_START
				#ifndef PRE_PROFILING_ENABLED
				prof_flags |= PROFILE_CLEAR
				#endif
				world.Profile(prof_flags , null, "json")
				message_admins("CPU at [world.cpu], map CPU at [world.map_cpu], last tick time at [time_since_last], turning on profiling.")
				logTheThing(LOG_DEBUG, null, "Automatic profiling started, CPU at [world.cpu], map CPU at [world.map_cpu], last tick time at [time_since_last].")
				ircbot.export_async("admin_debug", list("msg"="Automatic profiling started, CPU at [world.cpu], map CPU at [world.map_cpu], last tick time at [time_since_last]."))
				highCpuCount = CPU_STOP_PROFILING_COUNT
				automatic_profiling_on = TRUE

	proc/delay_disable_manual_profiling(delay)
		message_admins("Manual profiling enabled for [delay/10/60] minutes!")
		manual_profiling_on = TRUE
		manual_profiling_disable_time = TIME + delay

