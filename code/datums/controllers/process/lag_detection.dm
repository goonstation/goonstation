
/datum/controller/process/lag_detection
	var/tmp/highCpuCount = 0 // how many times in a row has the cpu been high
	var/tmp/automatic_profiling_on = FALSE
	var/tmp/manual_profiling_on = FALSE
	var/tmp/time_since_last = 0
	var/tmp/last_tick_time = null

	setup()
		name = "Lag Detection"
		schedule_interval = 0 SECONDS
		#ifdef PRE_PROFILING_ENABLED
		world.Profile(PROFILE_START | PROFILE_CLEAR, null, "json")
		#endif

	doWork()
		var/current_time = TIME
		if(!isnull(last_tick_time))
			time_since_last = current_time - last_tick_time
		last_tick_time = current_time
		if(manual_profiling_on)
			return
		automatic_profiling()
		#ifdef PRE_PROFILING_ENABLED
		if(!automatic_profiling_on)
			world.Profile(PROFILE_START | PROFILE_CLEAR, null, "json")
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
				logTheThing("debug", null, null, "Automatic profiling finished, CPU at [world.cpu], saved as [fname].")
				ircbot.export("admin_debug", list("msg"="Automatic profiling finished, CPU at [world.cpu], saved as [fname]."))
				highCpuCount = 0
				automatic_profiling_on = FALSE
		else if(ticker.round_elapsed_ticks > CPU_PROFILING_ROUNDSTART_GRACE_PERIOD) // give server some time to settle
			if(world.cpu >= CPU_START_PROFILING_THRESHOLD)
				highCpuCount++
			if(world.cpu >= CPU_START_PROFILING_IMMEDIATELY_THRESHOLD || time_since_last > 2.5 SECONDS)
				#ifdef PRE_PROFILING_ENABLED
				var/output = world.Profile(PROFILE_REFRESH, null, "json")
				var/fname = "data/logs/profiling/[global.roundLog_date]_automatic_[profilerLogID++]_spike.json"
				rustg_file_write(output, fname)
				#endif
				force_start = TRUE
			else
				highCpuCount = 0
			if(highCpuCount >= CPU_START_PROFILING_COUNT || force_start)
				world.Profile(PROFILE_START | PROFILE_CLEAR, null, "json")
				message_admins("CPU at [world.cpu], map CPU at [world.map_cpu], last tick time at [time_since_last], turning on profiling.")
				logTheThing("debug", null, null, "Automatic profiling started, CPU at [world.cpu], map CPU at [world.map_cpu], last tick time at [time_since_last].")
				ircbot.export("admin_debug", list("msg"="Automatic profiling started, CPU at [world.cpu], map CPU at [world.map_cpu], last tick time at [time_since_last]."))
				highCpuCount = CPU_STOP_PROFILING_COUNT
				automatic_profiling_on = TRUE
