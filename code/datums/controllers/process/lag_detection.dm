
/datum/controller/process/lag_detection
	var/tmp/highCpuCount = 0 // how many times in a row has the cpu been high
	var/tmp/automatic_profiling_on = FALSE
	var/tmp/manual_profiling_on = FALSE

	setup()
		name = "Lag Detection"
		schedule_interval = 0.1 SECONDS
		#ifdef PRE_PROFILING_ENABLED
		world.Profile(PROFILE_START | PROFILE_CLEAR, null, "json")
		#endif

	doWork()
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
				ircbot.export("admin", list("msg"="Automatic profiling finished, CPU at [world.cpu], saved as [fname]."))
				highCpuCount = 0
				automatic_profiling_on = FALSE
		else if(ticker.round_elapsed_ticks > CPU_PROFILING_ROUNDSTART_GRACE_PERIOD) // give server some time to settle
			if(world.cpu >= CPU_START_PROFILING_THRESHOLD)
				highCpuCount++
				if(world.cpu >= CPU_START_PROFILING_IMMEDIATELY_THRESHOLD)
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
				message_admins("CPU at [world.cpu], turning on profiling.")
				logTheThing("debug", null, null, "Automatic profiling started, CPU at [world.cpu].")
				ircbot.export("admin", list("msg"="Automatic profiling started, CPU at [world.cpu]."))
				highCpuCount = CPU_STOP_PROFILING_COUNT
				automatic_profiling_on = TRUE
