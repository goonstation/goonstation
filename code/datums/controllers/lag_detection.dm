var/global/datum/controller/lag_detection/lag_detection_process = new

/datum/controller/lag_detection
	var/tmp/highCpuCount = 0 // how many times in a row has the cpu been high
	var/tmp/automatic_profiling_count = 0 // how many times has the auto-profiler been triggered this round
	var/tmp/automatic_profiling_on = FALSE
	var/tmp/automatic_profiling_started = 0
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
				manual_profiling_disable_time = 0
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
				var/fname = "[global.roundLog_date]_automatic_[profilerLogID++].json"
				var/external_url = "https://logs.goonhub.com/[config.server_id]/logs/profiling/[fname]"
				var/fpath = "data/logs/profiling/[fname]"
				rustg_file_write(output, fpath)
				var/spike_time = (TIME - automatic_profiling_started) / (1 SECOND)
				message_admins("CPU back down to [world.cpu], turning off profiling, saved as <a href='[external_url]'>[external_url]</a>. Spike took [spike_time] seconds.")
				logTheThing(LOG_DEBUG, null, "Automatic profiling finished, CPU at [world.cpu], saved as [external_url]. Spike took [spike_time] seconds.")
				ircbot.export_async("admin_debug", list("msg"="Automatic profiling finished, CPU at [world.cpu], saved as [external_url]. Spike took [spike_time] seconds."))
				highCpuCount = 0
				automatic_profiling_on = FALSE
				last_tick_time = null
				time_since_last = 0
		else if(ticker.round_elapsed_ticks > CPU_PROFILING_ROUNDSTART_GRACE_PERIOD) // give server some time to settle
			if(world.cpu >= CPU_START_PROFILING_THRESHOLD)
				highCpuCount++
			if(world.cpu >= cpu_start_profiling_immediately_threshold || time_since_last > tick_time_profiling_threshold)
				#ifdef PRE_PROFILING_ENABLED
				var/output = src.start_auto_profile(PROFILE_REFRESH)
				var/fname = "data/logs/profiling/[global.roundLog_date]_automatic_[profilerLogID++]_spike.json"
				rustg_file_write(output, fname)
				#endif
				force_start = TRUE
			else
				highCpuCount = 0
			if (global.current_state >= GAME_STATE_FINISHED) //we don't reeaally care about the end of game lag spike, probably
				return
			if(highCpuCount >= CPU_START_PROFILING_COUNT || force_start)
				var/prof_flags = PROFILE_START
				#ifndef PRE_PROFILING_ENABLED
				prof_flags |= PROFILE_CLEAR
				#endif
				src.start_auto_profile(prof_flags)
				message_admins("CPU at [world.cpu], map CPU at [world.map_cpu], last tick time at [time_since_last], turning on profiling.")
				logTheThing(LOG_DEBUG, null, "Automatic profiling started, CPU at [world.cpu], map CPU at [world.map_cpu], last tick time at [time_since_last].")
				ircbot.export_async("admin_debug", list("msg"="Automatic profiling started, CPU at [world.cpu], map CPU at [world.map_cpu], last tick time at [time_since_last]."))
				highCpuCount = CPU_STOP_PROFILING_COUNT
				automatic_profiling_on = TRUE
				automatic_profiling_started = TIME

	proc/delay_disable_manual_profiling(delay)
		message_admins("Manual profiling enabled for [delay/10/60] minutes!")
		manual_profiling_on = TRUE
		manual_profiling_disable_time = TIME + delay

	proc/start_auto_profile(prof_flags)
		src.automatic_profiling_count++
		if (src.automatic_profiling_count > 3)
			global.flick_hack_enabled = TRUE
			ircbot.export_async("admin_debug", list("msg"="Autoprofiler triggered 4 times this round, enabling ACCURSED FLICK HACK."))
		return world.Profile(prof_flags, null, "json")

// ---- stupid flick hell zone ----
var/global/flick_hack_enabled = FALSE

//conditionally replace flick with an approximation carved out of animate calls, it's not good but it's better than crashing the server
//credit goes to Melbert and RufusZero for this abomination
#define FLICK(icon_state, thing)\
do {\
	if (global.flick_hack_enabled) {\
		var/___old_state = thing.icon_state;\
		animate(thing, icon_state = icon_state, easing = JUMP_EASING|EASE_IN, time = 0.5 SECONDS);\
		animate(icon_state = ___old_state, easing = JUMP_EASING|EASE_IN, time = 0.5 SECONDS);\
	} else {\
		FLICK(icon_state, thing);\
	};\
} while(FALSE)
